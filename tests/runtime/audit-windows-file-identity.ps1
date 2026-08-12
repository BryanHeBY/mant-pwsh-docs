[CmdletBinding()]
param(
    [switch] $IncludeHash,
    [switch] $FailOnIdentityError
)

$ErrorActionPreference = 'Stop'

if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'This audit requires Windows.'
}

$repositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$catalogPath = Join-Path $repositoryRoot 'upstream\windows-tools.json'
$catalog = Get-Content -LiteralPath $catalogPath -Raw -Encoding UTF8 |
    ConvertFrom-Json
$rows = [Collections.Generic.List[object]]::new()
$commandFamilyMappings = @{
    'extract.md' = @('extract.exe', 'extrac32.exe')
}
$candidateDocumentNames = @(
    $catalog.documents.PSObject.Properties |
        Where-Object {
            $_.Value.kind -ne 'command-resolution-guide' -and
            ($_.Name -match '^.+\.(?:exe|com|cmd|msc|cpl|vbs)\.md$' -or
                $commandFamilyMappings.ContainsKey($_.Name))
        } |
        ForEach-Object Name |
        Sort-Object -Unique
)
$appExecutionAliasRoot = [IO.Path]::GetFullPath(
    (Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps')
).TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar

function Get-FixedVersion {
    param(
        [Parameter(Mandatory)] [Diagnostics.FileVersionInfo] $VersionInfo,
        [Parameter(Mandatory)] [ValidateSet('File', 'Product')] [string] $Kind
    )

    $major = $VersionInfo.("${Kind}MajorPart")
    $minor = $VersionInfo.("${Kind}MinorPart")
    $build = $VersionInfo.("${Kind}BuildPart")
    $private = $VersionInfo.("${Kind}PrivatePart")
    return ([Version]::new($major, $minor, $build, $private)).ToString()
}

function Test-FixedVersionPresent {
    param(
        [Parameter(Mandatory)] [Diagnostics.FileVersionInfo] $VersionInfo,
        [Parameter(Mandatory)] [ValidateSet('File', 'Product')] [string] $Kind
    )

    return [bool](
        $VersionInfo.("${Kind}MajorPart") -or
        $VersionInfo.("${Kind}MinorPart") -or
        $VersionInfo.("${Kind}BuildPart") -or
        $VersionInfo.("${Kind}PrivatePart")
    )
}

foreach ($property in $catalog.documents.PSObject.Properties) {
    if ($property.Value.kind -eq 'command-resolution-guide') {
        continue
    }

    $commandNames = if (
        $property.Name -match '^(?<command>.+\.(?:exe|com|cmd|msc|cpl|vbs))\.md$'
    ) {
        @($Matches.command)
    } elseif ($commandFamilyMappings.ContainsKey($property.Name)) {
        @($commandFamilyMappings[$property.Name])
    } else {
        @()
    }
    if ($commandNames.Count -eq 0) {
        continue
    }

    foreach ($commandName in $commandNames) {
        $matches = @(Get-Command $commandName -All -ErrorAction SilentlyContinue)
        if ($matches.Count -eq 0) {
            $rows.Add([pscustomobject]@{
                document = $property.Name
                kind = $property.Value.kind
                command = $commandName
                present = $false
                commandType = $null
                path = $null
                appExecutionAlias = $false
                length = $null
                fileVersionFixed = $null
                fileVersionString = $null
                productVersionFixed = $null
                productVersionString = $null
                versionStringsDifferFromFixed = $null
                signatureStatus = $null
                signerSubject = $null
                sha256 = $null
                identityErrors = @()
            })
            continue
        }

        foreach ($match in $matches) {
        $path = $match.Source
        $item = if ($path -and (Test-Path -LiteralPath $path -PathType Leaf)) {
            Get-Item -LiteralPath $path
        } else {
            $null
        }
        $isAppExecutionAlias = [bool](
            $item -and
            $item.FullName.StartsWith(
                $appExecutionAliasRoot,
                [StringComparison]::OrdinalIgnoreCase
            ) -and
            ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)
        )
        $versionInfo = if ($item -and -not $isAppExecutionAlias) {
            $item.VersionInfo
        } else { $null }
        $fileFixed = if ($versionInfo -and
            (Test-FixedVersionPresent -VersionInfo $versionInfo -Kind File)) {
            Get-FixedVersion -VersionInfo $versionInfo -Kind File
        } else { $null }
        $productFixed = if ($versionInfo -and
            (Test-FixedVersionPresent -VersionInfo $versionInfo -Kind Product)) {
            Get-FixedVersion -VersionInfo $versionInfo -Kind Product
        } else { $null }
        $identityErrors = [Collections.Generic.List[string]]::new()
        $signature = if ($item -and -not $isAppExecutionAlias) {
            try {
                Get-AuthenticodeSignature -LiteralPath $item.FullName
            } catch {
                $identityErrors.Add('signature: ' + $_.Exception.Message)
                $null
            }
        } else { $null }
        $hash = if ($IncludeHash -and $item -and -not $isAppExecutionAlias) {
            try {
                (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash
            } catch {
                $identityErrors.Add('sha256: ' + $_.Exception.Message)
                $null
            }
        } else { $null }

            $rows.Add([pscustomobject]@{
            document = $property.Name
            kind = $property.Value.kind
            command = $commandName
            present = $true
            commandType = $match.CommandType.ToString()
            path = if ($item) { $item.FullName } else { $path }
            appExecutionAlias = $isAppExecutionAlias
            length = if ($item) { $item.Length } else { $null }
            fileVersionFixed = $fileFixed
            fileVersionString = if ($versionInfo) { $versionInfo.FileVersion } else { $null }
            productVersionFixed = $productFixed
            productVersionString = if ($versionInfo) { $versionInfo.ProductVersion } else { $null }
            versionStringsDifferFromFixed = if ($versionInfo -and $fileFixed) {
                $versionInfo.FileVersion -notmatch [regex]::Escape($fileFixed) -or
                $versionInfo.ProductVersion -notmatch [regex]::Escape($productFixed)
            } else { $null }
            signatureStatus = if ($signature) { $signature.Status.ToString() } else { $null }
            signerSubject = if ($signature -and $signature.SignerCertificate) {
                $signature.SignerCertificate.Subject
            } else { $null }
            sha256 = $hash
            identityErrors = @($identityErrors)
            })
        }
    }
}

$identityDocumentNames = @($rows.document | Sort-Object -Unique)
$missingCandidateDocuments = @(
    $candidateDocumentNames | Where-Object {
        $_ -notin $identityDocumentNames
    }
)
$unexpectedIdentityDocuments = @(
    $identityDocumentNames | Where-Object {
        $_ -notin $candidateDocumentNames
    }
)
$present = @($rows | Where-Object { $_.present })
$absent = @($rows | Where-Object { -not $_.present })
$versionDifferences = @(
    $present | Where-Object { $_.versionStringsDifferFromFixed -eq $true }
)
$signatureReview = @(
    $present | Where-Object {
        $_.signatureStatus -and $_.signatureStatus -notin 'Valid', 'NotSigned'
    }
)
$identityErrorRows = @($present | Where-Object { $_.identityErrors.Count -gt 0 })
$appExecutionAliases = @($present | Where-Object { $_.appExecutionAlias })
$guiRows = @(
    $rows | Where-Object {
        $_.kind -in 'windows-gui-entrypoint', 'windows-gui-cli'
    }
)
$guiPresent = @($guiRows | Where-Object { $_.present })
$guiAbsent = @($guiRows | Where-Object { -not $_.present })
$guiIdentityErrors = @(
    $guiPresent | Where-Object { $_.identityErrors.Count -gt 0 }
)

[pscustomobject]@{
    schema = 'mant-pwsh-docs.windows-file-identity-audit/v1'
    runtime = $PSVersionTable.PSVersion.ToString()
    edition = $PSVersionTable.PSEdition
    clr = if ($PSVersionTable.PSObject.Properties['CLRVersion']) {
        $PSVersionTable.CLRVersion.ToString()
    } else {
        [Environment]::Version.ToString()
    }
    platform = [Environment]::OSVersion.VersionString
    catalog = 'upstream/windows-tools.json'
    includeHash = [bool]$IncludeHash
    failOnIdentityError = [bool]$FailOnIdentityError
    safety = [pscustomobject]@{
        invokedDiscoveredCommands = 0
        openedWindows = 0
        remoteEndpoints = 0
        stateChanges = 0
        hashesRequested = [bool]$IncludeHash
    }
    rows = $rows.Count
    candidateDocuments = $candidateDocumentNames.Count
    identityDocuments = $identityDocumentNames.Count
    missingCandidateDocuments = $missingCandidateDocuments
    unexpectedIdentityDocuments = $unexpectedIdentityDocuments
    present = $present.Count
    absent = $absent.Count
    appExecutionAliases = $appExecutionAliases.Count
    versionStringDifferences = $versionDifferences.Count
    signatureReview = $signatureReview.Count
    identityErrors = $identityErrorRows.Count
    guiEntrypointDocuments = $guiRows.Count
    guiPresent = $guiPresent.Count
    guiAbsent = $guiAbsent.Count
    guiIdentityErrors = $guiIdentityErrors.Count
    guiAbsentDocuments = @($guiAbsent.document | Sort-Object -Unique)
    absentDocuments = @($absent.document | Sort-Object -Unique)
    versionDifferenceRows = $versionDifferences
    signatureReviewRows = $signatureReview
    identityErrorRows = $identityErrorRows
    appExecutionAliasRows = $appExecutionAliases
    identities = $rows
} | ConvertTo-Json -Depth 8

if ($FailOnIdentityError -and (
    $identityErrorRows.Count -gt 0 -or
    $missingCandidateDocuments.Count -gt 0 -or
    $unexpectedIdentityDocuments.Count -gt 0
)) {
    exit 1
}
