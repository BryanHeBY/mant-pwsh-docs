[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$checks = [Collections.Generic.List[object]]::new()

function Add-Check {
    param(
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [bool] $Passed,
        [AllowNull()] [object] $Actual,
        [AllowNull()] [object] $Expected
    )

    $checks.Add([pscustomobject]@{
        name = $Name
        passed = $Passed
        actual = $Actual
        expected = $Expected
    })
}

if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'This smoke test requires Windows.'
}

$repositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$windowsDocs = Join-Path $repositoryRoot 'docs\en-US\windows-tools'

foreach ($document in 'format.com.md', 'format.exe.md', 'winrm.cmd.md', 'winrm.exe.md',
    'convert.exe.md', 'extract.md') {
    $path = Join-Path $windowsDocs $document
    Add-Check ('document:' + $document) (Test-Path -LiteralPath $path -PathType Leaf) `
        $path 'existing file'
}

$formatCom = Get-Command format.com -CommandType Application -ErrorAction SilentlyContinue
$formatExe = Get-Command format.exe -CommandType Application -ErrorAction SilentlyContinue
$bareFormat = @(Get-Command format -All -ErrorAction SilentlyContinue)
Add-Check 'format.com-present' (
    $null -ne $formatCom -and $formatCom.Name -ieq 'format.com'
) $(if ($formatCom) { $formatCom.Source } else { $null }) 'Windows format.com application'
Add-Check 'format.exe-not-built-in' ($null -eq $formatExe) `
    $(if ($formatExe) { $formatExe.Source } else { $null }) $null
Add-Check 'bare-format-includes-format.com' (
    @($bareFormat | Where-Object Name -IEQ 'format.com').Count -ge 1
) @($bareFormat | ForEach-Object { $_.CommandType.ToString() + ':' + $_.Source }) `
    'at least one format.com application'

$formatHelp = @(& $formatCom.Source /? 2>&1)
$formatHelpExit = $LASTEXITCODE
Add-Check 'format.com-help-only' (
    $formatHelpExit -eq 0 -and $formatHelp.Count -gt 0
) "exit=$formatHelpExit; lines=$($formatHelp.Count)" 'exit=0 and nonempty help'

$systemConvertPath = Join-Path ([Environment]::GetFolderPath('System')) 'convert.exe'
$convertCommands = @(Get-Command convert.exe -All -ErrorAction SilentlyContinue)
$systemConvert = $convertCommands |
    Where-Object { $_.CommandType -eq 'Application' -and $_.Source -ieq $systemConvertPath } |
    Select-Object -First 1
Add-Check 'convert.exe-system32-present' ($null -ne $systemConvert) `
    $(if ($systemConvert) { $systemConvert.Source } else { $null }) $systemConvertPath

$convertIdentity = if (Test-Path -LiteralPath $systemConvertPath -PathType Leaf) {
    (Get-Item -LiteralPath $systemConvertPath).VersionInfo
} else {
    $null
}
Add-Check 'convert.exe-file-system-utility' (
    $null -ne $convertIdentity -and
    $convertIdentity.OriginalFilename -ieq 'CONVERT.EXE' -and
    $convertIdentity.FileDescription -eq 'File System Conversion Utility'
) $(if ($convertIdentity) {
        $convertIdentity.OriginalFilename + '; ' + $convertIdentity.FileDescription
    } else { $null }) 'CONVERT.EXE; File System Conversion Utility'

$convertHelp = if ($systemConvert) { @(& $systemConvert.Source /? 2>&1) } else { @() }
$convertHelpExit = if ($systemConvert) { $LASTEXITCODE } else { $null }
Add-Check 'convert.exe-help-only' (
    $convertHelpExit -eq 0 -and $convertHelp.Count -gt 0
) "exit=$convertHelpExit; lines=$($convertHelp.Count)" `
    'exit=0 and nonempty help without a volume operand'

$systemExtrac32Path = Join-Path ([Environment]::GetFolderPath('System')) 'extrac32.exe'
$systemExtrac32 = Get-Command extrac32.exe -All -ErrorAction SilentlyContinue |
    Where-Object {
        $_.CommandType -eq 'Application' -and $_.Source -ieq $systemExtrac32Path
    } |
    Select-Object -First 1
$extractExe = Get-Command extract.exe -CommandType Application -ErrorAction SilentlyContinue
Add-Check 'extrac32.exe-system32-present' ($null -ne $systemExtrac32) `
    $(if ($systemExtrac32) { $systemExtrac32.Source } else { $null }) $systemExtrac32Path
Add-Check 'extract.exe-not-built-in' ($null -eq $extractExe) `
    $(if ($extractExe) { $extractExe.Source } else { $null }) $null

$extrac32Signature = if (Test-Path -LiteralPath $systemExtrac32Path -PathType Leaf) {
    Get-AuthenticodeSignature -LiteralPath $systemExtrac32Path
} else {
    $null
}
Add-Check 'extrac32.exe-signature-valid' (
    $null -ne $extrac32Signature -and $extrac32Signature.Status -eq 'Valid'
) $(if ($extrac32Signature) { $extrac32Signature.Status.ToString() } else { $null }) `
    'Valid'

$extrac32HelpCommand = '"' + $systemExtrac32Path + '" /? | more'
$extrac32Help = if ($systemExtrac32) {
    @(& "$env:SystemRoot\System32\cmd.exe" /d /c $extrac32HelpCommand 2>&1)
} else {
    @()
}
$extrac32HelpExit = if ($systemExtrac32) { $LASTEXITCODE } else { $null }
$extrac32HelpLines = @(
    $extrac32Help |
        ForEach-Object { $_.ToString() } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
)
Add-Check 'extrac32.exe-help-only' (
    $extrac32HelpExit -eq 0 -and $extrac32HelpLines.Count -gt 0
) ([pscustomobject]@{
    exitCode = $extrac32HelpExit
    nonemptyLines = $extrac32HelpLines.Count
    payloadRetained = $false
}) 'exit=0 and nonempty help through more; payload not retained'

$winrmCmd = Get-Command winrm.cmd -CommandType Application -ErrorAction SilentlyContinue
$winrmVbs = Get-Command winrm.vbs -All -ErrorAction SilentlyContinue |
    Select-Object -First 1
$winrmExe = Get-Command winrm.exe -CommandType Application -ErrorAction SilentlyContinue
Add-Check 'winrm.cmd-present' (
    $null -ne $winrmCmd -and $winrmCmd.Name -ieq 'winrm.cmd'
) $(if ($winrmCmd) { $winrmCmd.Source } else { $null }) 'Windows winrm.cmd application'
Add-Check 'winrm.vbs-present' ($null -ne $winrmVbs) `
    $(if ($winrmVbs) { $winrmVbs.Source } else { $null }) 'Windows winrm.vbs script'
Add-Check 'winrm.exe-not-built-in' ($null -eq $winrmExe) `
    $(if ($winrmExe) { $winrmExe.Source } else { $null }) $null

$wrapper = if ($winrmCmd) {
    (Get-Content -LiteralPath $winrmCmd.Source -Raw -Encoding Ascii).Trim()
} else {
    $null
}
Add-Check 'winrm.cmd-wrapper' (
    $wrapper -match '^@cscript\s+//nologo\s+"%~dpn0\.vbs"\s+%\*$'
) $wrapper '@cscript //nologo "%~dpn0.vbs" %*'

$originalOutputEncoding = [Console]::OutputEncoding
try {
    $oemCodePage = (Get-Culture).TextInfo.OEMCodePage
    [Console]::OutputEncoding = [Text.Encoding]::GetEncoding($oemCodePage)
    $winrmHelp = @(& $winrmCmd.Source help 2>&1)
    $winrmHelpExit = $LASTEXITCODE
} finally {
    [Console]::OutputEncoding = $originalOutputEncoding
}
Add-Check 'winrm.cmd-local-help-only' (
    $winrmHelpExit -eq 0 -and $winrmHelp.Count -gt 0
) "exit=$winrmHelpExit; lines=$($winrmHelp.Count); OEM=$oemCodePage" `
    'exit=0 and nonempty help decoded with the console OEM code page'

$failed = @($checks | Where-Object { -not $_.passed })
[pscustomobject]@{
    runtime = $PSVersionTable.PSVersion.ToString()
    platform = [Environment]::OSVersion.VersionString
    passed = $checks.Count - $failed.Count
    failed = $failed.Count
    checks = $checks
} | ConvertTo-Json -Depth 6

if ($failed.Count -gt 0) {
    exit 1
}
