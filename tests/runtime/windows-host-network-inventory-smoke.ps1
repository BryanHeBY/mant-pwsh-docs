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
    finally { $process.Dispose() }
}

if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'This smoke test requires Windows.'
}

$systemDirectory = [Environment]::GetFolderPath('System')
$commands = [ordered]@{
    'hostname.exe' = 1
    'getmac.exe' = 0
    'driverquery.exe' = 0
    'arp.exe' = 1
    'route.exe' = 1
}

foreach ($pair in $commands.GetEnumerator()) {
    $path = Join-Path $systemDirectory $pair.Key
    $item = Get-Item -LiteralPath $path -ErrorAction SilentlyContinue
    Add-Check -Name ('identity:' + $pair.Key) `
        -Passed ($null -ne $item -and $item.Name -ieq $pair.Key -and
            $item.DirectoryName -ieq $systemDirectory -and
            -not [string]::IsNullOrWhiteSpace($item.VersionInfo.FileVersion)) `
        -Actual $(if ($item) {
            '{0}; version-resource-present={1}' -f $item.FullName,
                (-not [string]::IsNullOrWhiteSpace($item.VersionInfo.FileVersion))
        } else { $null }) `
        -Expected "exact System32 $($pair.Key) with a nonempty file-version resource"

    if ($null -ne $item) {
        $help = Invoke-BoundedNativeCapture $item.FullName '/?'
        Add-Check -Name ('help:' + $pair.Key) `
            -Passed ($help.exitCode -eq $pair.Value -and
                ($help.stdoutLines + $help.stderrLines) -gt 0) `
            -Actual ('exit={0}; stdout-lines={1}; stderr-lines={2}' -f
                $help.exitCode, $help.stdoutLines, $help.stderrLines) `
            -Expected "exit=$($pair.Value) and nonempty localized help"
    }
}

$hostname = Invoke-BoundedNativeCapture `
    (Join-Path $systemDirectory 'hostname.exe') ''
Add-Check 'query:hostname-short-local-name' `
    ($hostname.exitCode -eq 0 -and $hostname.stdoutLines -eq 1) `
    "exit=$($hostname.exitCode); lines=$($hostname.stdoutLines); value-emitted=false" `
    'exit=0 and exactly one captured local short-name line'

$getmac = Invoke-BoundedNativeCapture `
    (Join-Path $systemDirectory 'getmac.exe') '/fo csv /nh'
Add-Check 'query:getmac-local-csv' `
    ($getmac.exitCode -eq 0 -and $getmac.stdoutLines -gt 0) `
    "exit=$($getmac.exitCode); rows=$($getmac.stdoutLines); payload-emitted=false" `
    'exit=0 and at least one captured local adapter row'

$driverQuery = Invoke-BoundedNativeCapture `
    (Join-Path $systemDirectory 'driverquery.exe') '/fo csv /nh' 30000
Add-Check 'query:driverquery-local-csv' `
    ($driverQuery.exitCode -eq 0 -and $driverQuery.stdoutLines -gt 0) `
    "exit=$($driverQuery.exitCode); rows=$($driverQuery.stdoutLines); payload-emitted=false" `
    'exit=0 and at least one captured local driver row'

$arp = Invoke-BoundedNativeCapture (Join-Path $systemDirectory 'arp.exe') '-a'
Add-Check 'query:arp-local-cache' `
    ($arp.exitCode -eq 0 -and $arp.stdoutLines -gt 0) `
    "exit=$($arp.exitCode); lines=$($arp.stdoutLines); payload-emitted=false" `
    'exit=0 and nonempty captured local ARP cache presentation'

$route = Invoke-BoundedNativeCapture `
    (Join-Path $systemDirectory 'route.exe') 'print'
Add-Check 'query:route-local-table' `
    ($route.exitCode -eq 0 -and
        ($route.stdoutLines + $route.stderrLines) -gt 0) `
    "exit=$($route.exitCode); stdout-lines=$($route.stdoutLines); stderr-lines=$($route.stderrLines); payload-emitted=false" `
    'exit=0 and nonempty captured local route-table presentation'

$failed = @($checks | Where-Object { -not $_.passed })
[pscustomobject]@{
    schema = 'mant-pwsh-docs.windows-host-network-inventory-smoke/v1'
    runtime = [pscustomobject]@{
        version = $PSVersionTable.PSVersion.ToString()
        edition = $PSVersionTable.PSEdition
        osVersion = [Environment]::OSVersion.VersionString
    }
    safety = [pscustomobject]@{
        scope = 'exact System32 help and local read-only host/network inventory only'
        remoteHosts = 0
        credentials = 0
        externalNetworkTargets = 0
        mutations = 0
        emittedHostNames = 0
        emittedMacAddresses = 0
        emittedDriverRows = 0
        emittedArpEntries = 0
        emittedRouteEntries = 0
    }
    summary = [pscustomobject]@{
        total = $checks.Count
        passed = $checks.Count - $failed.Count
        failed = $failed.Count
    }
    checks = $checks
} | ConvertTo-Json -Depth 6

if ($failed.Count -ne 0) { exit 1 }
