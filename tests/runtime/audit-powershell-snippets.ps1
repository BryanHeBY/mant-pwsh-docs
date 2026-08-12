[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('pwsh51', 'pwsh7')]
    [string] $Source
)

$ErrorActionPreference = 'Stop'

$expectedEdition = if ($Source -eq 'pwsh51') { 'Desktop' } else { 'Core' }
if ($PSVersionTable.PSEdition -ne $expectedEdition) {
    throw "Run the $Source snippet audit with the $expectedEdition edition."
}

$documentsRoot = Join-Path $PSScriptRoot "..\..\docs\en-US\$Source"
$documentsRoot = [IO.Path]::GetFullPath($documentsRoot)
$failures = New-Object System.Collections.Generic.List[object]
$snippetCount = 0

foreach ($file in Get-ChildItem -LiteralPath $documentsRoot -Filter '*.md' |
    Sort-Object Name) {
    $heading = ''
    $fenceHeading = ''
    $fenceLanguage = ''
    $contentStartLine = 0
    $inFence = $false
    $buffer = New-Object System.Collections.Generic.List[string]
    $lines = Get-Content -LiteralPath $file.FullName -Encoding UTF8

    for ($index = 0; $index -lt $lines.Count; $index++) {
        $line = $lines[$index]

        if (-not $inFence -and $line -match '^#{1,6}\s+(.+)$') {
            $heading = $Matches[1]
            continue
        }

        if (-not $inFence -and $line -match '^```([^\s`]*)\s*$') {
            $inFence = $true
            $fenceLanguage = $Matches[1]
            $fenceHeading = $heading
            $contentStartLine = $index + 2
            $buffer.Clear()
            continue
        }

        if ($inFence -and $line -match '^```\s*$') {
            if ($fenceLanguage -eq 'powershell' -and
                $fenceHeading -notin @('Synopsis', 'Syntax')) {
                $snippetCount++
                $tokens = $null
                $parseErrors = $null
                $snippet = $buffer -join [Environment]::NewLine
                $null = [Management.Automation.Language.Parser]::ParseInput(
                    $snippet,
                    [ref] $tokens,
                    [ref] $parseErrors
                )
                foreach ($parseError in $parseErrors) {
                    $failures.Add([pscustomobject]@{
                        document = $file.Name
                        section = $fenceHeading
                        line = $contentStartLine +
                            $parseError.Extent.StartLineNumber - 1
                        errorId = $parseError.ErrorId
                        message = $parseError.Message
                    })
                }
            }

            $inFence = $false
            $fenceLanguage = ''
            $fenceHeading = ''
            $buffer.Clear()
            continue
        }

        if ($inFence) {
            $buffer.Add($line)
        }
    }
}

$result = [pscustomobject]@{
    schema = 'mant-pwsh-docs.snippet-audit/v1'
    source = $Source
    runtime = $PSVersionTable.PSVersion.ToString()
    documents = @(Get-ChildItem -LiteralPath $documentsRoot -Filter '*.md').Count
    snippets = $snippetCount
    failures = $failures.Count
    details = @($failures | ForEach-Object { $_ })
}

$result | ConvertTo-Json -Depth 5
if ($failures.Count -ne 0) {
    exit 1
}
