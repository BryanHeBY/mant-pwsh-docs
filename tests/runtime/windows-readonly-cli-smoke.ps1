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
        if (-not $process.Start()) {
            throw "Failed to start $FilePath"
        }
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
            stdout = $stdout
            stderr = $stderr
            stdoutLines = @($stdout -split '\r?\n' | Where-Object {
                -not [string]::IsNullOrWhiteSpace($_)
            }).Count
            stderrLines = @($stderr -split '\r?\n' | Where-Object {
                -not [string]::IsNullOrWhiteSpace($_)
            }).Count
        }
    }
    finally {
        $process.Dispose()
    }
}

if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'This smoke test requires Windows.'
}

$systemDirectory = [Environment]::GetFolderPath('System')
$commands = [ordered]@{
    'tasklist.exe' = 0
    'whoami.exe' = 0
    'systeminfo.exe' = 0
    'ipconfig.exe' = 1
    'netstat.exe' = 1
    'ping.exe' = 0
    'tracert.exe' = 1
    'where.exe' = 0
}

foreach ($pair in $commands.GetEnumerator()) {
    $path = Join-Path $systemDirectory $pair.Key
    $item = Get-Item -LiteralPath $path -ErrorAction SilentlyContinue
    Add-Check -Name ('identity:' + $pair.Key) `
        -Passed (
            $null -ne $item -and
            $item.Name -ieq $pair.Key -and
            $item.DirectoryName -ieq $systemDirectory -and
            -not [string]::IsNullOrWhiteSpace($item.VersionInfo.FileVersion)
        ) `
        -Actual $(if ($item) {
            '{0}; version={1}; resource-original={2}' -f (
                $item.FullName,
                $item.VersionInfo.FileVersion,
                $item.VersionInfo.OriginalFilename
            )
        } else { $null }) `
        -Expected "exact System32 $($pair.Key) with a nonempty file-version resource"

    if ($null -ne $item) {
        $help = Invoke-BoundedNativeCapture -FilePath $item.FullName -Arguments '/?'
        Add-Check -Name ('help:' + $pair.Key) `
            -Passed (
                $help.exitCode -eq $pair.Value -and
                ($help.stdoutLines + $help.stderrLines) -gt 0
            ) `
            -Actual ('exit={0}; stdout-lines={1}; stderr-lines={2}' -f (
                $help.exitCode, $help.stdoutLines, $help.stderrLines
            )) `
            -Expected "exit=$($pair.Value) and nonempty localized help"
    }
}

$tasklist = Invoke-BoundedNativeCapture `
    -FilePath (Join-Path $systemDirectory 'tasklist.exe') `
    -Arguments '/fo csv /nh'
Add-Check -Name 'query:tasklist-local-csv' `
    -Passed ($tasklist.exitCode -eq 0 -and $tasklist.stdoutLines -gt 0) `
    -Actual "exit=$($tasklist.exitCode); rows=$($tasklist.stdoutLines)" `
    -Expected 'exit=0 and at least one fully captured local process row'

$whoami = Invoke-BoundedNativeCapture `
    -FilePath (Join-Path $systemDirectory 'whoami.exe') `
    -Arguments '/user /fo csv /nh'
Add-Check -Name 'query:whoami-current-token-sid' `
    -Passed ($whoami.exitCode -eq 0 -and $whoami.stdout -match 'S-1-[0-9-]+') `
    -Actual "exit=$($whoami.exitCode); sid-present=$($whoami.stdout -match 'S-1-[0-9-]+')" `
    -Expected 'exit=0 and one current-token SID without emitting identity text'

$systemInfo = Invoke-BoundedNativeCapture `
    -FilePath (Join-Path $systemDirectory 'systeminfo.exe') `
    -Arguments '/fo csv /nh' -TimeoutMilliseconds 30000
Add-Check -Name 'query:systeminfo-local-csv' `
    -Passed ($systemInfo.exitCode -eq 0 -and $systemInfo.stdoutLines -gt 0) `
    -Actual "exit=$($systemInfo.exitCode); rows=$($systemInfo.stdoutLines)" `
    -Expected 'exit=0 and nonempty fully captured local snapshot'

$ipconfig = Invoke-BoundedNativeCapture `
    -FilePath (Join-Path $systemDirectory 'ipconfig.exe') -Arguments ''
Add-Check -Name 'query:ipconfig-local-summary' `
    -Passed ($ipconfig.exitCode -eq 0 -and $ipconfig.stdoutLines -gt 0) `
    -Actual "exit=$($ipconfig.exitCode); lines=$($ipconfig.stdoutLines)" `
    -Expected 'exit=0 and nonempty local adapter summary without mutation'

$netstat = Invoke-BoundedNativeCapture `
    -FilePath (Join-Path $systemDirectory 'netstat.exe') `
    -Arguments '-ano -p tcp'
Add-Check -Name 'query:netstat-local-tcp-snapshot' `
    -Passed ($netstat.exitCode -eq 0 -and $netstat.stdoutLines -gt 0) `
    -Actual "exit=$($netstat.exitCode); lines=$($netstat.stdoutLines)" `
    -Expected 'exit=0 and nonempty local numeric TCP/PID snapshot'

$ping = Invoke-BoundedNativeCapture `
    -FilePath (Join-Path $systemDirectory 'ping.exe') `
    -Arguments '/n 1 /w 100 127.0.0.1'
Add-Check -Name 'probe:ping-loopback-bounded' `
    -Passed ($ping.exitCode -eq 0 -and $ping.stdout -match '127\.0\.0\.1') `
    -Actual "exit=$($ping.exitCode); loopback-present=$($ping.stdout -match '127\.0\.0\.1')" `
    -Expected 'exit=0 and loopback address present after one bounded request'

$tracert = Invoke-BoundedNativeCapture `
    -FilePath (Join-Path $systemDirectory 'tracert.exe') `
    -Arguments '/d /h 1 /w 100 127.0.0.1'
Add-Check -Name 'probe:tracert-loopback-one-hop' `
    -Passed ($tracert.exitCode -eq 0 -and $tracert.stdout -match '127\.0\.0\.1') `
    -Actual "exit=$($tracert.exitCode); loopback-present=$($tracert.stdout -match '127\.0\.0\.1')" `
    -Expected 'exit=0 and loopback address present within one hop'

$wherePath = Join-Path $systemDirectory 'where.exe'
$where = Invoke-BoundedNativeCapture -FilePath $wherePath -Arguments 'where.exe'
$whereLines = @($where.stdout -split '\r?\n' | Where-Object {
    -not [string]::IsNullOrWhiteSpace($_)
})
Add-Check -Name 'query:where-exact-system32-candidate' `
    -Passed (
        $where.exitCode -eq 0 -and
        @($whereLines | Where-Object { $_.Trim() -ieq $wherePath }).Count -eq 1
    ) `
    -Actual "exit=$($where.exitCode); candidates=$($whereLines.Count); exact-system32=$(@($whereLines | Where-Object { $_.Trim() -ieq $wherePath }).Count)" `
    -Expected 'exit=0 and exactly one matching System32 where.exe candidate'

$failed = @($checks | Where-Object { -not $_.passed })
[pscustomobject]@{
    schema = 'mant-pwsh-docs.windows-readonly-cli-smoke/v1'
    runtime = [pscustomobject]@{
        version = $PSVersionTable.PSVersion.ToString()
        edition = $PSVersionTable.PSEdition
        osVersion = [Environment]::OSVersion.VersionString
    }
    safety = [pscustomobject]@{
        scope = 'fixed System32 help, local read-only snapshots, current token, PATH lookup, and IPv4 loopback only'
        externalNetworkTargets = 0
        remoteHosts = 0
        mutations = 0
        emittedCapturedPayloads = 0
    }
    summary = [pscustomobject]@{
        total = $checks.Count
        passed = $checks.Count - $failed.Count
        failed = $failed.Count
    }
    checks = $checks
} | ConvertTo-Json -Depth 6

if ($failed.Count -ne 0) {
    exit 1
}
