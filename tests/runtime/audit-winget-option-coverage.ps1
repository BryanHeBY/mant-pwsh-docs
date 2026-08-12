[CmdletBinding()]
param(
    [string] $MantPath,
    [string] $WingetPath,
    [string[]] $Command = @(
        'search',
        'show',
        'install',
        'upgrade',
        'uninstall',
        'list'
    ),
    [switch] $FailOnDifference
)

$ErrorActionPreference = 'Stop'

if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'This audit requires Windows.'
}

if (-not $MantPath) {
    $mantCommand = Get-Command mant -CommandType Application -ErrorAction Stop |
        Select-Object -First 1
    $MantPath = $mantCommand.Source
}

if (-not $WingetPath) {
    $wingetCommand = Get-Command winget.exe -CommandType Application -ErrorAction Stop |
        Select-Object -First 1
    $WingetPath = $wingetCommand.Source
}

$repositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent

function Add-OutlineName {
    param(
        [Parameter(Mandatory)] [object[]] $Node,
        [Parameter(Mandatory)] [string] $Role,
        [Parameter(Mandatory)] [AllowEmptyCollection()]
        [Collections.Generic.HashSet[string]] $Destination,
        [string] $Prefix
    )

    foreach ($item in $Node) {
        if ($item.role -eq $Role) {
            foreach ($name in @($item.names)) {
                if (-not $Prefix -or $name.StartsWith($Prefix)) {
                [void] $Destination.Add($name.ToLowerInvariant())
                }
            }
        }

        if ($item.children) {
            Add-OutlineName -Node @($item.children) -Role $Role `
                -Destination $Destination -Prefix $Prefix
        }
    }
}

$versionOutput = @(& $WingetPath --version 2>&1)
$versionExitCode = $LASTEXITCODE
if ($versionExitCode -ne 0) {
    throw "winget --version failed with exit code $versionExitCode"
}

$rootHelpOutput = @(& $WingetPath --help 2>&1)
$rootHelpExitCode = $LASTEXITCODE
if ($rootHelpExitCode -ne 0) {
    throw "winget --help failed with exit code $rootHelpExitCode"
}

$runtimeRootOptions = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::OrdinalIgnoreCase
)
$runtimeCommands = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::OrdinalIgnoreCase
)
foreach ($line in $rootHelpOutput) {
    foreach ($match in [regex]::Matches([string] $line, '--[a-z0-9][a-z0-9-]*')) {
        [void] $runtimeRootOptions.Add($match.Value.ToLowerInvariant())
    }
    if ([string] $line -match '^\s{2}(?<command>[a-z][a-z0-9-]*)\s{2,}\S') {
        [void] $runtimeCommands.Add($Matches.command.ToLowerInvariant())
    }
}

$rootDocumentPath = Join-Path $repositoryRoot `
    'docs\en-US\windows-tools\winget.exe.md'
$rootOutlineText = @(
    & $MantPath $rootDocumentPath --outline=entries --format json --compact 2>&1
) -join [Environment]::NewLine
if ($LASTEXITCODE -ne 0) {
    throw "ManT outline failed for $rootDocumentPath`n$rootOutlineText"
}
$rootOutline = $rootOutlineText | ConvertFrom-Json
$documentedRootOptions = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::OrdinalIgnoreCase
)
$documentedCommands = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::OrdinalIgnoreCase
)
$globalOptionNode = @($rootOutline.nodes | Where-Object id -eq 'global-options')
$mcpOptionNode = @($rootOutline.nodes | Where-Object id -eq 'mcp-command-options')
Add-OutlineName -Node $globalOptionNode -Role option `
    -Destination $documentedRootOptions -Prefix '--'
Add-OutlineName -Node @($rootOutline.nodes) -Role command `
    -Destination $documentedCommands

$rootResult = [pscustomobject]@{
    helpExitCode = $rootHelpExitCode
    runtimeOptionCount = $runtimeRootOptions.Count
    documentedOptionCount = $documentedRootOptions.Count
    runtimeOnlyOptions = @($runtimeRootOptions | Where-Object {
        -not $documentedRootOptions.Contains($_)
    } | Sort-Object)
    documentOnlyOptions = @($documentedRootOptions | Where-Object {
        -not $runtimeRootOptions.Contains($_)
    } | Sort-Object)
    runtimeCommandCount = $runtimeCommands.Count
    documentedCommandCount = $documentedCommands.Count
    runtimeOnlyCommands = @($runtimeCommands | Where-Object {
        -not $documentedCommands.Contains($_)
    } | Sort-Object)
    documentOnlyCommands = @($documentedCommands | Where-Object {
        -not $runtimeCommands.Contains($_)
    } | Sort-Object)
}

$mcpHelpOutput = @(& $WingetPath mcp --help 2>&1)
$mcpHelpExitCode = $LASTEXITCODE
if ($mcpHelpExitCode -ne 0) {
    throw "winget mcp --help failed with exit code $mcpHelpExitCode"
}
$runtimeMcpSpecificOptions = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::OrdinalIgnoreCase
)
foreach ($line in $mcpHelpOutput) {
    foreach ($match in [regex]::Matches([string] $line, '--[a-z0-9][a-z0-9-]*')) {
        if (-not $runtimeRootOptions.Contains($match.Value)) {
            [void] $runtimeMcpSpecificOptions.Add($match.Value.ToLowerInvariant())
        }
    }
}
$documentedMcpSpecificOptions = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::OrdinalIgnoreCase
)
Add-OutlineName -Node $mcpOptionNode -Role option `
    -Destination $documentedMcpSpecificOptions -Prefix '--'
$mcpResult = [pscustomobject]@{
    helpExitCode = $mcpHelpExitCode
    runtimeSpecificOptionCount = $runtimeMcpSpecificOptions.Count
    documentedSpecificOptionCount = $documentedMcpSpecificOptions.Count
    runtimeOnlyOptions = @($runtimeMcpSpecificOptions | Where-Object {
        -not $documentedMcpSpecificOptions.Contains($_)
    } | Sort-Object)
    documentOnlyOptions = @($documentedMcpSpecificOptions | Where-Object {
        -not $runtimeMcpSpecificOptions.Contains($_)
    } | Sort-Object)
}

$results = foreach ($subcommand in $Command) {
    if ($subcommand -notmatch '^[a-z][a-z0-9-]*$') {
        throw "Unsafe WinGet subcommand token: $subcommand"
    }

    $documentPath = Join-Path $repositoryRoot (
        'docs\en-US\windows-tools\winget-{0}.md' -f $subcommand
    )
    if (-not (Test-Path -LiteralPath $documentPath -PathType Leaf)) {
        throw "Missing document: $documentPath"
    }

    $helpOutput = @(& $WingetPath $subcommand --help 2>&1)
    $helpExitCode = $LASTEXITCODE
    if ($helpExitCode -ne 0) {
        throw "winget $subcommand --help failed with exit code $helpExitCode"
    }

    $runtimeOptions = [Collections.Generic.HashSet[string]]::new(
        [StringComparer]::OrdinalIgnoreCase
    )
    foreach ($line in $helpOutput) {
        if ([string] $line -notmatch '^\s+-') {
            continue
        }

        foreach ($match in [regex]::Matches([string] $line, '--[a-z0-9][a-z0-9-]*')) {
            [void] $runtimeOptions.Add($match.Value.ToLowerInvariant())
        }
    }

    $outlineText = @(
        & $MantPath $documentPath --outline=entries --format json --compact 2>&1
    ) -join [Environment]::NewLine
    $outlineExitCode = $LASTEXITCODE
    if ($outlineExitCode -ne 0) {
        throw "ManT outline failed for $documentPath with exit code $outlineExitCode`n$outlineText"
    }

    $outline = $outlineText | ConvertFrom-Json
    $documentedOptions = [Collections.Generic.HashSet[string]]::new(
        [StringComparer]::OrdinalIgnoreCase
    )
    Add-OutlineName -Node @($outline.nodes) -Role option `
        -Destination $documentedOptions -Prefix '--'

    $runtimeOnly = @($runtimeOptions | Where-Object {
        -not $documentedOptions.Contains($_)
    } | Sort-Object)
    $documentOnly = @($documentedOptions | Where-Object {
        -not $runtimeOptions.Contains($_)
    } | Sort-Object)

    [pscustomobject]@{
        command = $subcommand
        helpExitCode = $helpExitCode
        runtimeOptionCount = $runtimeOptions.Count
        documentedOptionCount = $documentedOptions.Count
        runtimeOnly = $runtimeOnly
        documentOnly = $documentOnly
    }
}

$rootDifferenceCount = @($rootResult.runtimeOnlyOptions).Count +
    @($rootResult.documentOnlyOptions).Count +
    @($rootResult.runtimeOnlyCommands).Count +
    @($rootResult.documentOnlyCommands).Count
$mcpDifferenceCount = @($mcpResult.runtimeOnlyOptions).Count +
    @($mcpResult.documentOnlyOptions).Count
$subcommandDifferenceCount = @($results | ForEach-Object {
    @($_.runtimeOnly).Count + @($_.documentOnly).Count
} | Measure-Object -Sum).Sum

$report = [pscustomobject]@{
    schema = 'mant.runtime.winget-option-coverage/v2'
    collectedAt = [DateTimeOffset]::Now.ToString('o')
    collector = $PSVersionTable.PSVersion.ToString()
    wingetPath = $WingetPath
    wingetVersion = ($versionOutput -join [Environment]::NewLine).Trim()
    mantPath = $MantPath
    root = $rootResult
    mcp = $mcpResult
    commands = @($results)
    differenceCount = $rootDifferenceCount + $mcpDifferenceCount +
        $subcommandDifferenceCount
}

$report | ConvertTo-Json -Depth 8

if ($FailOnDifference -and $report.differenceCount -ne 0) {
    exit 1
}
