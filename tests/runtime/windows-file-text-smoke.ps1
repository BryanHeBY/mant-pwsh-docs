[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$checks = New-Object System.Collections.Generic.List[object]
$testRoot = Join-Path ([IO.Path]::GetTempPath()) (
    'mant-file-text-' + [guid]::NewGuid().ToString('N')
)

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

function Write-AsciiFile {
    param(
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [string[]] $Lines
    )
    [IO.File]::WriteAllLines($Path, $Lines, [Text.Encoding]::ASCII)
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

$resolvedTemp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
$resolvedRoot = [IO.Path]::GetFullPath($testRoot)
if (-not $resolvedRoot.StartsWith($resolvedTemp + '\',
    [StringComparison]::OrdinalIgnoreCase) -or
    [IO.Path]::GetFileName($resolvedRoot) -notlike 'mant-file-text-*') {
    throw "Unsafe test root: $resolvedRoot"
}

$systemDirectory = [Environment]::GetFolderPath('System')
$paths = @{
    attrib = Join-Path $systemDirectory 'attrib.exe'
    find = Join-Path $systemDirectory 'find.exe'
    findstr = Join-Path $systemDirectory 'findstr.exe'
    sort = Join-Path $systemDirectory 'sort.exe'
    fc = Join-Path $systemDirectory 'fc.exe'
    tree = Join-Path $systemDirectory 'tree.com'
    xcopy = Join-Path $systemDirectory 'xcopy.exe'
    cmd = Join-Path $systemDirectory 'cmd.exe'
}

try {
    $null = New-Item -ItemType Directory -Path $resolvedRoot
    $nested = Join-Path $resolvedRoot 'nested'
    $empty = Join-Path $resolvedRoot 'empty'
    $null = New-Item -ItemType Directory -Path $nested
    $null = New-Item -ItemType Directory -Path $empty

    $textPath = Join-Path $resolvedRoot 'sample.txt'
    Write-AsciiFile $textPath @('charlie', 'Needle Phrase', 'alpha', 'bravo')
    $nestedPath = Join-Path $nested 'child.txt'
    Write-AsciiFile $nestedPath @('nested marker')

    $binaryA = Join-Path $resolvedRoot 'a.bin'
    $binarySame = Join-Path $resolvedRoot 'same.bin'
    $binaryDifferent = Join-Path $resolvedRoot 'different.bin'
    [IO.File]::WriteAllBytes($binaryA, [byte[]](0, 1, 2, 3, 254, 255))
    [IO.File]::WriteAllBytes($binarySame, [byte[]](0, 1, 2, 3, 254, 255))
    [IO.File]::WriteAllBytes($binaryDifferent, [byte[]](0, 1, 2, 4, 254, 255))

    $attrib = Invoke-BoundedNativeCapture $paths.attrib ('"{0}"' -f $textPath)
    Add-Check 'attrib:exact-file-query-only' `
        ($attrib.exitCode -eq 0 -and $attrib.stdout -match 'sample\.txt') `
        "exit=$($attrib.exitCode); stdout-lines=$($attrib.stdoutLines); attribute-text-emitted=false" `
        'status 0 and one exact-file attribute result without a modifier'

    $findMatch = Invoke-BoundedNativeCapture $paths.find `
        ('/i /n "needle phrase" "{0}"' -f $textPath)
    Add-Check 'find:literal-case-insensitive-match' `
        ($findMatch.exitCode -eq 0 -and $findMatch.stdout -match 'Needle Phrase') `
        "exit=$($findMatch.exitCode); lines=$($findMatch.stdoutLines)" `
        'status 0 and fixed literal match'
    $findMiss = Invoke-BoundedNativeCapture $paths.find `
        ('/i "absent marker" "{0}"' -f $textPath)
    Add-Check 'find:no-match-is-status-one' `
        ($findMiss.exitCode -eq 1) $findMiss.exitCode 1

    $findstrMatch = Invoke-BoundedNativeCapture $paths.findstr `
        ('/i /n /l /c:"needle phrase" "{0}"' -f $textPath)
    Add-Check 'findstr:explicit-literal-phrase' `
        ($findstrMatch.exitCode -eq 0 -and
            $findstrMatch.stdout -match 'Needle Phrase') `
        "exit=$($findstrMatch.exitCode); lines=$($findstrMatch.stdoutLines)" `
        'status 0 and fixed literal phrase match'
    $findstrMiss = Invoke-BoundedNativeCapture $paths.findstr `
        ('/i /l /c:"absent marker" "{0}"' -f $textPath)
    Add-Check 'findstr:no-match-is-status-one' `
        ($findstrMiss.exitCode -eq 1) $findstrMiss.exitCode 1

    $sort = Invoke-BoundedNativeCapture $paths.sort ('"{0}"' -f $textPath)
    $sorted = @($sort.stdout -split '\r?\n' | Where-Object { $_ })
    Add-Check 'sort:fixed-ascii-lines' `
        ($sort.exitCode -eq 0 -and $sorted.Count -eq 4 -and
            $sorted[0] -eq 'alpha' -and $sorted[3] -eq 'Needle Phrase') `
        "exit=$($sort.exitCode); lines=$($sorted.Count); payload-emitted=false" `
        'status 0 and four locale-sorted fixed ASCII lines'

    $typeScript = Join-Path $resolvedRoot 'type.cmd'
    Write-AsciiFile $typeScript @('@echo off', ('type "{0}"' -f $textPath))
    $type = Invoke-BoundedNativeCapture $paths.cmd ('/d /c "{0}"' -f $typeScript)
    Add-Check 'type:fixed-ascii-text' `
        ($type.exitCode -eq 0 -and $type.stdout -match 'Needle Phrase' -and
            $type.stdoutLines -eq 4) `
        "exit=$($type.exitCode); lines=$($type.stdoutLines); payload-emitted=false" `
        'status 0 and four fixed text lines through Cmd builtin'

    $fcSame = Invoke-BoundedNativeCapture $paths.fc `
        ('/b "{0}" "{1}"' -f $binaryA, $binarySame)
    Add-Check 'fc:binary-identical-is-status-zero' `
        ($fcSame.exitCode -eq 0) $fcSame.exitCode 0
    $fcDifferent = Invoke-BoundedNativeCapture $paths.fc `
        ('/b "{0}" "{1}"' -f $binaryA, $binaryDifferent)
    Add-Check 'fc:binary-different-is-status-one' `
        ($fcDifferent.exitCode -eq 1 -and
            ($fcDifferent.stdoutLines + $fcDifferent.stderrLines) -gt 0) `
        "exit=$($fcDifferent.exitCode); stdout-lines=$($fcDifferent.stdoutLines); stderr-lines=$($fcDifferent.stderrLines)" `
        'status 1 and a nonempty difference report'

    $treeDirectories = Invoke-BoundedNativeCapture $paths.tree `
        ('"{0}" /a' -f $resolvedRoot)
    $treeFiles = Invoke-BoundedNativeCapture $paths.tree `
        ('"{0}" /a /f' -f $resolvedRoot)
    Add-Check 'tree:file-inclusion-is-explicit' `
        ($treeDirectories.exitCode -eq 0 -and $treeFiles.exitCode -eq 0 -and
            $treeDirectories.stdout -notmatch 'child\.txt' -and
            $treeFiles.stdout -match 'child\.txt') `
        "directories-exit=$($treeDirectories.exitCode); files-exit=$($treeFiles.exitCode); payload-emitted=false" `
        'child filename absent without /f and present with /f'

    $destination = Join-Path $resolvedRoot 'preview destination'
    $xcopy = Invoke-BoundedNativeCapture $paths.xcopy `
        ('"{0}\*" "{1}" /s /e /h /i /l' -f $nested, $destination)
    Add-Check 'xcopy:list-only-does-not-create-destination' `
        ($xcopy.exitCode -eq 0 -and $xcopy.stdoutLines -gt 0 -and
            -not (Test-Path -LiteralPath $destination)) `
        "exit=$($xcopy.exitCode); lines=$($xcopy.stdoutLines); destination-exists=$(Test-Path -LiteralPath $destination); payload-emitted=false" `
        'status 0, nonempty preview, and absent destination after /l'

    $failed = @($checks | Where-Object { -not $_.passed })
    [pscustomobject]@{
        schema = 'mant-pwsh-docs.windows-file-text-smoke/v1'
        runtime = [pscustomobject]@{
            version = $PSVersionTable.PSVersion.ToString()
            edition = $PSVersionTable.PSEdition
            osVersion = [Environment]::OSVersion.VersionString
        }
        safety = [pscustomobject]@{
            temporaryRoot = $resolvedRoot
            fixedAsciiOnly = $true
            fixedBinaryBytes = 18
            userData = $false
            network = $false
            registry = $false
            attributeMutations = 0
            copyMutations = 0
            emittedFixturePayloads = 0
        }
        summary = [pscustomobject]@{
            total = $checks.Count
            passed = $checks.Count - $failed.Count
            failed = $failed.Count
        }
        checks = $checks
    } | ConvertTo-Json -Depth 6

    if ($failed.Count -ne 0) { exit 1 }
}
finally {
    if (Test-Path -LiteralPath $resolvedRoot) {
        $finalRoot = [IO.Path]::GetFullPath($resolvedRoot)
        if (-not $finalRoot.StartsWith($resolvedTemp + '\',
            [StringComparison]::OrdinalIgnoreCase) -or
            [IO.Path]::GetFileName($finalRoot) -notlike 'mant-file-text-*') {
            throw "Refusing unsafe cleanup: $finalRoot"
        }
        Remove-Item -LiteralPath $finalRoot -Recurse -Force
    }
}
