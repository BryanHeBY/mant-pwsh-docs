[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('pwsh7', 'pwsh51')]
    [string] $Source
)

$ErrorActionPreference = 'Stop'

$expectedRuntime = if ($Source -eq 'pwsh7') {
    [pscustomobject]@{ Edition = 'Core'; Major = 7; Minor = 6 }
} else {
    [pscustomobject]@{ Edition = 'Desktop'; Major = 5; Minor = 1 }
}

if (
    $PSVersionTable.PSEdition -ne $expectedRuntime.Edition -or
    $PSVersionTable.PSVersion.Major -ne $expectedRuntime.Major -or
    $PSVersionTable.PSVersion.Minor -ne $expectedRuntime.Minor
) {
    throw (
        'Run the {0} coverage audit with PowerShell {1}.{2} {3}; current runtime is {4} {5}.' -f
        $Source,
        $expectedRuntime.Major,
        $expectedRuntime.Minor,
        $expectedRuntime.Edition,
        $PSVersionTable.PSVersion,
        $PSVersionTable.PSEdition
    )
}

$commandDocuments = [ordered]@{
    'ForEach-Object.md' = 'ForEach-Object'
    'Get-ChildItem.md' = 'Get-ChildItem'
    'Get-Command.md' = 'Get-Command'
    'Get-Help.md' = 'Get-Help'
    'Get-Member.md' = 'Get-Member'
    'Import-Module.md' = 'Import-Module'
    'Invoke-Item.md' = 'Invoke-Item'
    'Select-Object.md' = 'Select-Object'
    'Sort-Object.md' = 'Sort-Object'
    'Start-Process.md' = 'Start-Process'
    'Where-Object.md' = 'Where-Object'
    'iex.md' = 'Invoke-Expression'
    'ii.md' = 'Invoke-Item'
    'irm.md' = 'Invoke-RestMethod'
    'iwr.md' = 'Invoke-WebRequest'
    'start.md' = 'Start-Process'
}
# curl.md is intentionally a command-resolution guide that points to iwr.md
# for cmdlet behavior; it has no semantic option declaration to compare.

$commonParameterNames = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::OrdinalIgnoreCase
)
foreach ($name in @(
    'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction',
    'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable',
    'OutBuffer', 'PipelineVariable', 'ProgressAction', 'UseTransaction'
)) {
    $null = $commonParameterNames.Add($name)
}

$documentsRoot = Join-Path $PSScriptRoot ('..\..\docs\en-US\' + $Source)
$reports = [Collections.Generic.List[object]]::new()
$missingTotal = 0

foreach ($pair in $commandDocuments.GetEnumerator()) {
    $documentPath = Join-Path $documentsRoot $pair.Key
    $documented = [Collections.Generic.HashSet[string]]::new(
        [StringComparer]::OrdinalIgnoreCase
    )
    $inOptionEntries = $false
    $inOptionBullet = $false
    foreach ($line in Get-Content -LiteralPath $documentPath -Encoding UTF8) {
        if ($line -match '<!-- mant:entries role=option') {
            $inOptionEntries = $true
            $inOptionBullet = $false
            continue
        }
        if ($inOptionEntries -and $line -match '^- ') {
            $inOptionBullet = $true
        } elseif ($inOptionEntries -and $line -notmatch '^  \S') {
            $inOptionBullet = $false
        }
        if ($inOptionEntries -and $inOptionBullet) {
            foreach ($match in [regex]::Matches(
                $line,
                '`(-{1,2}[A-Za-z][A-Za-z0-9-]*)'
            )) {
                $null = $documented.Add($match.Groups[1].Value.TrimStart('-'))
            }
        }
        if ($inOptionEntries -and $line.Length -eq 0) {
            $inOptionEntries = $false
            $inOptionBullet = $false
        }
    }

    $command = Get-Command $pair.Value -ErrorAction Stop
    $canonicalParameters = @(
        $command.Parameters.Values |
            Where-Object { -not $commonParameterNames.Contains($_.Name) } |
            ForEach-Object Name |
            Sort-Object -Unique
    )
    $missing = @(
        $canonicalParameters |
            Where-Object { -not $documented.Contains($_) }
    )
    $missingTotal += $missing.Count
    $reports.Add([pscustomobject]@{
        document = $pair.Key
        command = $pair.Value
        runtimeParameterCount = $canonicalParameters.Count
        documentedCanonicalCount = @(
            $canonicalParameters | Where-Object { $documented.Contains($_) }
        ).Count
        missing = $missing
    })
}

[pscustomobject]@{
    schema = 'mant-pwsh-docs.command-option-coverage/v1'
    source = $Source
    runtime = [pscustomobject]@{
        version = $PSVersionTable.PSVersion.ToString()
        edition = $PSVersionTable.PSEdition
        platform = $PSVersionTable.Platform
    }
    summary = [pscustomobject]@{
        documents = $reports.Count
        missingCanonicalParameters = $missingTotal
    }
    documents = $reports
} | ConvertTo-Json -Depth 6
