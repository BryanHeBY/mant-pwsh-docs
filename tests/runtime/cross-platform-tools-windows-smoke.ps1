[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$checks = New-Object System.Collections.Generic.List[object]

function Add-Check {
    param(
        [Parameter(Mandatory = $true)] [string] $Name,
        [Parameter(Mandatory = $true)] [ValidateSet('passed', 'failed', 'skipped')]
        [string] $Status,
        [AllowNull()] [object] $Actual,
        [AllowNull()] [object] $Expected
    )

    $checks.Add([pscustomobject]@{
        name = $Name
        status = $Status
        actual = $Actual
        expected = $Expected
    })
}

function Invoke-BoundedNativeCapture {
    param(
        [Parameter(Mandatory = $true)] [string] $FilePath,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Arguments,
        [hashtable] $Environment = @{},
        [int] $TimeoutMilliseconds = 15000
    )

    $startInfo = New-Object Diagnostics.ProcessStartInfo
    $startInfo.FileName = $FilePath
    $startInfo.Arguments = $Arguments
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.StandardOutputEncoding = [Text.Encoding]::UTF8
    $startInfo.StandardErrorEncoding = [Text.Encoding]::UTF8
    foreach ($name in $Environment.Keys) {
        $startInfo.EnvironmentVariables[$name] = [string] $Environment[$name]
    }

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

function Select-ExactApplication {
    param(
        [Parameter(Mandatory = $true)] [string] $Name,
        [AllowNull()] [string] $PreferredPath
    )

    $applications = @(Get-Command $Name -All -CommandType Application `
        -ErrorAction SilentlyContinue)
    $selected = if (-not [string]::IsNullOrWhiteSpace($PreferredPath)) {
        $applications | Where-Object { $_.Source -ieq $PreferredPath } |
            Select-Object -First 1
    }
    else { $null }
    if ($null -eq $selected) {
        $selected = $applications | Select-Object -First 1
    }
    [pscustomobject]@{
        candidates = $applications
        selected = $selected
    }
}

if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'This smoke test records the Windows boundary of cross-platform tools.'
}

$systemDirectory = [Environment]::GetFolderPath('System')
$windowsDirectory = [Environment]::GetFolderPath('Windows')
$programFiles = [Environment]::GetFolderPath('ProgramFiles')

$bareCurl = Get-Command curl -ErrorAction SilentlyContinue
$expectedCurlType = if ($PSVersionTable.PSEdition -eq 'Desktop') {
    'Alias'
} else { 'Application' }
Add-Check -Name 'resolution:bare-curl-edition-boundary' `
    -Status $(if ($bareCurl -and
        $bareCurl.CommandType.ToString() -eq $expectedCurlType) {
        'passed'
    } else { 'failed' }) `
    -Actual $(if ($bareCurl) {
        '{0}; name={1}' -f $bareCurl.CommandType, $bareCurl.Name
    } else { 'absent' }) `
    -Expected "$expectedCurlType under $($PSVersionTable.PSEdition)"

$gitPreferred = Join-Path $programFiles 'Git\cmd\git.exe'
$git = Select-ExactApplication -Name 'git.exe' -PreferredPath $gitPreferred
Add-Check -Name 'identity:git-application' `
    -Status $(if ($git.selected) { 'passed' } else { 'failed' }) `
    -Actual "candidates=$(@($git.candidates).Count); selected=$($git.selected.Source)" `
    -Expected 'at least one exact git.exe Application candidate'
if ($git.selected) {
    $gitVersion = Invoke-BoundedNativeCapture $git.selected.Source '--version'
    Add-Check -Name 'probe:git-version' `
        -Status $(if ($gitVersion.exitCode -eq 0 -and
            $gitVersion.stdout -match '(?im)^git version\s+') {
            'passed'
        } else { 'failed' }) `
        -Actual "exit=$($gitVersion.exitCode); stdout-lines=$($gitVersion.stdoutLines); stderr-lines=$($gitVersion.stderrLines)" `
        -Expected 'status 0 and a git version line'
    $gitHelp = Invoke-BoundedNativeCapture $git.selected.Source '-h'
    Add-Check -Name 'probe:git-top-level-help' `
        -Status $(if ($gitHelp.exitCode -eq 0 -and
            $gitHelp.stdout -match '(?im)^usage:\s+git\s') {
            'passed'
        } else { 'failed' }) `
        -Actual "exit=$($gitHelp.exitCode); stdout-lines=$($gitHelp.stdoutLines); stderr-lines=$($gitHelp.stderrLines)" `
        -Expected 'status 0 and top-level usage without repository context'
}
else {
    Add-Check 'probe:git-version' 'skipped' 'git.exe absent' 'run only when installed'
    Add-Check 'probe:git-top-level-help' 'skipped' 'git.exe absent' 'run only when installed'
}

$sshPreferred = Join-Path $systemDirectory 'OpenSSH\ssh.exe'
$ssh = Select-ExactApplication -Name 'ssh.exe' -PreferredPath $sshPreferred
Add-Check -Name 'identity:ssh-application' `
    -Status $(if ($ssh.selected) { 'passed' } else { 'failed' }) `
    -Actual "candidates=$(@($ssh.candidates).Count); selected=$($ssh.selected.Source)" `
    -Expected 'at least one exact ssh.exe Application candidate'
if ($ssh.selected) {
    $sshVersion = Invoke-BoundedNativeCapture $ssh.selected.Source '-V'
    Add-Check -Name 'probe:ssh-version-stderr' `
        -Status $(if ($sshVersion.exitCode -eq 0 -and
            $sshVersion.stderr -match 'OpenSSH') { 'passed' } else { 'failed' }) `
        -Actual "exit=$($sshVersion.exitCode); stdout-lines=$($sshVersion.stdoutLines); stderr-lines=$($sshVersion.stderrLines)" `
        -Expected 'status 0 and OpenSSH version text on stderr'
    $sshQuestion = Invoke-BoundedNativeCapture $ssh.selected.Source '-?'
    Add-Check -Name 'probe:ssh-question-is-not-generic-help' `
        -Status $(if ($sshQuestion.exitCode -ne 0 -and
            $sshQuestion.stderrLines -gt 0) { 'passed' } else { 'failed' }) `
        -Actual "exit=$($sshQuestion.exitCode); stdout-lines=$($sshQuestion.stdoutLines); stderr-lines=$($sshQuestion.stderrLines)" `
        -Expected 'nonzero unknown-option/usage diagnostic, not a help-success contract'
}
else {
    Add-Check 'probe:ssh-version-stderr' 'skipped' 'ssh.exe absent' 'run only when installed'
    Add-Check 'probe:ssh-question-is-not-generic-help' 'skipped' 'ssh.exe absent' 'run only when installed'
}

$curlPreferred = Join-Path $systemDirectory 'curl.exe'
$curl = Select-ExactApplication -Name 'curl.exe' -PreferredPath $curlPreferred
Add-Check -Name 'identity:curl-application' `
    -Status $(if ($curl.selected) { 'passed' } else { 'failed' }) `
    -Actual "candidates=$(@($curl.candidates).Count); selected=$($curl.selected.Source)" `
    -Expected 'at least one exact curl.exe Application candidate'
if ($curl.selected) {
    $curlVersion = Invoke-BoundedNativeCapture $curl.selected.Source '--version'
    Add-Check -Name 'probe:curl-version' `
        -Status $(if ($curlVersion.exitCode -eq 0 -and
            $curlVersion.stdout -match '(?im)^curl\s') { 'passed' } else { 'failed' }) `
        -Actual "exit=$($curlVersion.exitCode); stdout-lines=$($curlVersion.stdoutLines); stderr-lines=$($curlVersion.stderrLines)" `
        -Expected 'status 0 and curl version text without a URL'
    $curlHelp = Invoke-BoundedNativeCapture $curl.selected.Source '--help all'
    Add-Check -Name 'probe:curl-all-help' `
        -Status $(if ($curlHelp.exitCode -eq 0 -and
            $curlHelp.stdoutLines -gt 20) { 'passed' } else { 'failed' }) `
        -Actual "exit=$($curlHelp.exitCode); stdout-lines=$($curlHelp.stdoutLines); stderr-lines=$($curlHelp.stderrLines)" `
        -Expected 'status 0 and nonempty all-help without a URL'
}
else {
    Add-Check 'probe:curl-version' 'skipped' 'curl.exe absent' 'run only when installed'
    Add-Check 'probe:curl-all-help' 'skipped' 'curl.exe absent' 'run only when installed'
}

$tarPreferred = Join-Path $systemDirectory 'tar.exe'
$tar = Select-ExactApplication -Name 'tar.exe' -PreferredPath $tarPreferred
Add-Check -Name 'identity:tar-application' `
    -Status $(if ($tar.selected) { 'passed' } else { 'failed' }) `
    -Actual "candidates=$(@($tar.candidates).Count); selected=$($tar.selected.Source)" `
    -Expected 'at least one exact tar.exe Application candidate'
if ($tar.selected) {
    $tarVersion = Invoke-BoundedNativeCapture $tar.selected.Source '--version'
    Add-Check -Name 'probe:tar-implementation-version' `
        -Status $(if ($tarVersion.exitCode -eq 0 -and
            ($tarVersion.stdout + $tarVersion.stderr) -match '(?i)(tar|libarchive)') {
            'passed'
        } else { 'failed' }) `
        -Actual "exit=$($tarVersion.exitCode); stdout-lines=$($tarVersion.stdoutLines); stderr-lines=$($tarVersion.stderrLines)" `
        -Expected 'status 0 and implementation/version identity'
    $tarHelp = Invoke-BoundedNativeCapture $tar.selected.Source '--help'
    Add-Check -Name 'probe:tar-implementation-help' `
        -Status $(if ($tarHelp.exitCode -eq 0 -and
            ($tarHelp.stdoutLines + $tarHelp.stderrLines) -gt 5) {
            'passed'
        } else { 'failed' }) `
        -Actual "exit=$($tarHelp.exitCode); stdout-lines=$($tarHelp.stdoutLines); stderr-lines=$($tarHelp.stderrLines)" `
        -Expected 'status 0 and implementation-specific help without an archive operand'
}
else {
    Add-Check 'probe:tar-implementation-version' 'skipped' 'tar.exe absent' 'run only when installed'
    Add-Check 'probe:tar-implementation-help' 'skipped' 'tar.exe absent' 'run only when installed'
}

$dotnetPreferred = Join-Path $programFiles 'dotnet\dotnet.exe'
$dotnet = Select-ExactApplication -Name 'dotnet.exe' -PreferredPath $dotnetPreferred
Add-Check -Name 'availability:dotnet-application' -Status 'passed' `
    -Actual $(if ($dotnet.selected) {
        "available; candidates=$(@($dotnet.candidates).Count); selected=$($dotnet.selected.Source)"
    } else { 'unavailable' }) `
    -Expected 'availability is explicitly classified without direct fallback invocation'

$dotnetRoot = $null
if ($dotnet.selected) {
    $dotnetRoot = Join-Path ([IO.Path]::GetTempPath()) (
        'mant-dotnet-cli-' + [guid]::NewGuid().ToString('N')
    )
    $resolvedTemp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
    $resolvedDotnetRoot = [IO.Path]::GetFullPath($dotnetRoot)
    if (-not $resolvedDotnetRoot.StartsWith($resolvedTemp + '\',
        [StringComparison]::OrdinalIgnoreCase) -or
        [IO.Path]::GetFileName($resolvedDotnetRoot) -notlike 'mant-dotnet-cli-*') {
        throw "Unsafe dotnet CLI home: $resolvedDotnetRoot"
    }
    $null = New-Item -ItemType Directory -Path $resolvedDotnetRoot
    try {
        $dotnetEnvironment = @{
            DOTNET_CLI_HOME = $resolvedDotnetRoot
            DOTNET_CLI_TELEMETRY_OPTOUT = '1'
            DOTNET_SKIP_FIRST_TIME_EXPERIENCE = '1'
            DOTNET_NOLOGO = '1'
        }
        $dotnetVersion = Invoke-BoundedNativeCapture $dotnet.selected.Source `
            '--version' $dotnetEnvironment 30000
        Add-Check -Name 'probe:dotnet-selected-sdk-version' `
            -Status $(if ($dotnetVersion.exitCode -eq 0 -and
                $dotnetVersion.stdout -match '(?m)^\d+\.\d+') {
                'passed'
            } else { 'failed' }) `
            -Actual "exit=$($dotnetVersion.exitCode); stdout-lines=$($dotnetVersion.stdoutLines); stderr-lines=$($dotnetVersion.stderrLines)" `
            -Expected 'status 0 and one selected SDK version in an isolated CLI home'
    }
    finally {
        if (Test-Path -LiteralPath $resolvedDotnetRoot) {
            Remove-Item -LiteralPath $resolvedDotnetRoot -Recurse -Force
        }
    }
}
else {
    Add-Check 'probe:dotnet-selected-sdk-version' 'skipped' `
        'dotnet.exe unavailable on this host' `
        'run only on a compatible installed SDK host'
}

$failed = @($checks | Where-Object status -eq 'failed')
$skipped = @($checks | Where-Object status -eq 'skipped')
[pscustomobject]@{
    schema = 'mant-pwsh-docs.cross-platform-tools-windows-smoke/v1'
    runtime = [pscustomobject]@{
        version = $PSVersionTable.PSVersion.ToString()
        edition = $PSVersionTable.PSEdition
        osVersion = [Environment]::OSVersion.VersionString
    }
    safety = [pscustomobject]@{
        repositoryOperations = 0
        remoteDestinations = 0
        urls = 0
        archives = 0
        projects = 0
        persistentEnvironmentChanges = 0
        dotnetCliHomeRemoved = $null -eq $dotnetRoot -or
            -not (Test-Path -LiteralPath $dotnetRoot)
    }
    summary = [pscustomobject]@{
        total = $checks.Count
        passed = @($checks | Where-Object status -eq 'passed').Count
        skipped = $skipped.Count
        failed = $failed.Count
    }
    checks = $checks
} | ConvertTo-Json -Depth 7

if ($failed.Count -ne 0) {
    exit 1
}
