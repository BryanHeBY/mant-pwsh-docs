[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$checks = New-Object System.Collections.Generic.List[object]

function Add-Check {
    param(
        [Parameter(Mandatory = $true)] [string] $Name,
        [Parameter(Mandatory = $true)] [bool] $Passed,
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

function Invoke-BoundedNativeCapture {
    param(
        [Parameter(Mandatory = $true)] [string] $FilePath,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Arguments,
        [int] $TimeoutMilliseconds = 15000
    )

    $encoding = [Text.Encoding]::GetEncoding((Get-Culture).TextInfo.OEMCodePage)
    $startInfo = New-Object Diagnostics.ProcessStartInfo
    $startInfo.FileName = $FilePath
    $startInfo.Arguments = $Arguments
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.StandardOutputEncoding = $encoding
    $startInfo.StandardErrorEncoding = $encoding
    $process = New-Object Diagnostics.Process
    $process.StartInfo = $startInfo
    try {
        if (-not $process.Start()) { throw "Failed to start $FilePath" }
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit($TimeoutMilliseconds)) {
            try { $process.Kill() } catch { }
            throw "Timed out after $TimeoutMilliseconds ms: $FilePath $Arguments"
        }
        $stdout = $stdoutTask.GetAwaiter().GetResult()
        $stderr = $stderrTask.GetAwaiter().GetResult()
        [pscustomobject]@{
            exitCode = $process.ExitCode
            stdoutLines = @($stdout -split '\r?\n' | Where-Object {
                -not [string]::IsNullOrWhiteSpace($_)
            }).Count
            stderrLines = @($stderr -split '\r?\n' | Where-Object {
                -not [string]::IsNullOrWhiteSpace($_)
            }).Count
        }
    } finally {
        $process.Dispose()
    }
}

if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'This smoke test requires Windows.'
}

$systemDirectory = [Environment]::GetFolderPath('System')
$commands = @(
    [pscustomobject]@{ name = 'winrs.exe'; arguments = '/?'; exitCode = 0 }
    [pscustomobject]@{ name = 'rpcping.exe'; arguments = '/?'; exitCode = 0 }
    [pscustomobject]@{ name = 'sc.exe'; arguments = '/?'; exitCode = 1639 }
    [pscustomobject]@{ name = 'schtasks.exe'; arguments = '/?'; exitCode = 0 }
    [pscustomobject]@{ name = 'w32tm.exe'; arguments = '/?'; exitCode = 0 }
    [pscustomobject]@{ name = 'wecutil.exe'; arguments = '/?'; exitCode = 0 }
    [pscustomobject]@{ name = 'wevtutil.exe'; arguments = '/?'; exitCode = 0 }
    [pscustomobject]@{ name = 'netsh.exe'; arguments = 'help'; exitCode = 0 }
)

foreach ($command in $commands) {
    $path = Join-Path $systemDirectory $command.name
    $item = Get-Item -LiteralPath $path -ErrorAction SilentlyContinue
    Add-Check -Name ('identity:' + $command.name) `
        -Passed ($null -ne $item -and $item.Name -ieq $command.name -and
            $item.DirectoryName -ieq $systemDirectory -and
            -not [string]::IsNullOrWhiteSpace($item.VersionInfo.FileVersion)) `
        -Actual $(if ($item) {
            '{0}; version-resource-present={1}' -f $item.FullName,
                (-not [string]::IsNullOrWhiteSpace($item.VersionInfo.FileVersion))
        } else { $null }) `
        -Expected "exact System32 $($command.name) with a nonempty file-version resource"

    if ($null -ne $item) {
        $help = Invoke-BoundedNativeCapture -FilePath $item.FullName `
            -Arguments $command.arguments
        Add-Check -Name ('help:' + $command.name) `
            -Passed ($help.exitCode -eq $command.exitCode -and
                ($help.stdoutLines + $help.stderrLines) -gt 0) `
            -Actual ('exit={0}; stdout-lines={1}; stderr-lines={2}' -f
                $help.exitCode, $help.stdoutLines, $help.stderrLines) `
            -Expected "exit=$($command.exitCode) and nonempty local help"
    }
}

$winrmPath = Join-Path $systemDirectory 'winrm.cmd'
$winrmItem = Get-Item -LiteralPath $winrmPath -ErrorAction SilentlyContinue
$winrmWrapper = if ($winrmItem) {
    (Get-Content -LiteralPath $winrmItem.FullName -Raw -Encoding Ascii).Trim()
} else { $null }
Add-Check -Name 'identity:winrm.cmd-wrapper' `
    -Passed ($null -ne $winrmItem -and
        $winrmItem.DirectoryName -ieq $systemDirectory -and
        $winrmWrapper -match '^@cscript\s+//nologo\s+"%~dpn0\.vbs"\s+%\*$') `
    -Actual $(if ($winrmItem) {
        "$($winrmItem.FullName); bytes=$($winrmItem.Length); wrapper-matched=$($winrmWrapper -match '^@cscript\s+//nologo\s+"%~dpn0\.vbs"\s+%\*$')"
    } else { $null }) `
    -Expected 'exact System32 winrm.cmd wrapper for adjacent winrm.vbs'

if ($null -ne $winrmItem) {
    $winrmHelp = Invoke-BoundedNativeCapture -FilePath $winrmItem.FullName `
        -Arguments 'help'
    Add-Check -Name 'help:winrm.cmd' `
        -Passed ($winrmHelp.exitCode -eq 0 -and
            ($winrmHelp.stdoutLines + $winrmHelp.stderrLines) -gt 0) `
        -Actual ('exit={0}; stdout-lines={1}; stderr-lines={2}' -f
            $winrmHelp.exitCode, $winrmHelp.stdoutLines, $winrmHelp.stderrLines) `
        -Expected 'exit=0 and nonempty local help'
}

$winrmExe = @(Get-Command winrm.exe -CommandType Application `
    -ErrorAction SilentlyContinue)
Add-Check -Name 'resolution:winrm.exe-absent' `
    -Passed ($winrmExe.Count -eq 0) `
    -Actual $winrmExe.Count `
    -Expected 0

$failed = @($checks | Where-Object { -not $_.passed })
[pscustomobject]@{
    schema = 'mant-pwsh-docs.windows-remote-management-help-smoke/v1'
    runtime = [pscustomobject]@{
        version = $PSVersionTable.PSVersion.ToString()
        edition = $PSVersionTable.PSEdition
        osVersion = [Environment]::OSVersion.VersionString
    }
    safety = [pscustomobject]@{
        scope = 'exact local entry-point identity and top-level help only'
        remoteHosts = 0
        credentials = 0
        serviceQueries = 0
        taskQueries = 0
        eventQueries = 0
        networkConfigurationQueries = 0
        mutations = 0
        emittedHelpPayloads = 0
    }
    summary = [pscustomobject]@{
        total = $checks.Count
        passed = $checks.Count - $failed.Count
        failed = $failed.Count
    }
    checks = $checks
} | ConvertTo-Json -Depth 6

if ($failed.Count -ne 0) { exit 1 }
