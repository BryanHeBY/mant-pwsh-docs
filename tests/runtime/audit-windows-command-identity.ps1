[CmdletBinding()]
param()

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
        $stem = [IO.Path]::GetFileNameWithoutExtension($commandName)
        $exact = @(Get-Command $commandName -All -ErrorAction SilentlyContinue)
        $alternate = @()
        if ($exact.Count -eq 0) {
            $alternate = @(
                Get-Command $stem -All -ErrorAction SilentlyContinue |
                    Where-Object Name -INotLike $commandName |
                    ForEach-Object {
                        [pscustomobject]@{
                            commandType = $_.CommandType.ToString()
                            name = $_.Name
                            source = $_.Source
                        }
                    }
            )
        }

        $rows.Add([pscustomobject]@{
            document = $property.Name
            kind = $property.Value.kind
            command = $commandName
            exactPresent = $exact.Count -gt 0
            exactMatches = @(
                $exact | ForEach-Object {
                    [pscustomobject]@{
                        commandType = $_.CommandType.ToString()
                        name = $_.Name
                        source = $_.Source
                    }
                }
            )
            alternateMatches = $alternate
        })
    }
}

$present = @($rows | Where-Object exactPresent)
$absent = @($rows | Where-Object { -not $_.exactPresent })
$missingWithAlternate = @(
    $absent | Where-Object { $_.alternateMatches.Count -gt 0 }
)

[pscustomobject]@{
    runtime = $PSVersionTable.PSVersion.ToString()
    platform = [Environment]::OSVersion.VersionString
    catalog = 'upstream/windows-tools.json'
    entrypointDocumentKeys = @($rows.document | Sort-Object -Unique).Count
    entrypointDocuments = $rows.Count
    exactPresent = $present.Count
    exactAbsent = $absent.Count
    missingWithAlternate = $missingWithAlternate.Count
    alternateReviewQueue = $missingWithAlternate
    absentDocuments = @($absent.document | Sort-Object)
} | ConvertTo-Json -Depth 8
