[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$checks = [Collections.Generic.List[object]]::new()
$testRoot = Join-Path ([IO.Path]::GetTempPath()) (
    'mant-cmd-builtins-' + [guid]::NewGuid().ToString('N')
)

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

function Write-AsciiFile {
    param(
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [AllowEmptyString()] [string[]] $Lines
    )

    [IO.File]::WriteAllLines($Path, $Lines, [Text.Encoding]::ASCII)
}

function Invoke-CmdFile {
    param([Parameter(Mandatory)] [string] $Path)

    $output = @(& "$env:SystemRoot\System32\cmd.exe" /d /c $Path 2>&1)
    [pscustomobject]@{
        output = @($output | ForEach-Object ToString)
        exitCode = $LASTEXITCODE
    }
}

try {
    $null = New-Item -ItemType Directory -Path $testRoot

    $expansionScript = Join-Path $testRoot 'expansion.cmd'
    Write-AsciiFile -Path $expansionScript -Lines @(
        '@echo off',
        'set "MANT_COUNT=before"',
        '(set "MANT_COUNT=after" & echo percent=[%MANT_COUNT%])',
        'setlocal EnableDelayedExpansion',
        'set "MANT_COUNT=before"',
        '(set "MANT_COUNT=after" & echo delayed=[!MANT_COUNT!])',
        'endlocal'
    )
    $expansion = Invoke-CmdFile $expansionScript
    Add-Check 'parenthesized-percent-expansion-is-parse-time' `
        ($expansion.output -contains 'percent=[before]') $expansion.output 'percent=[before]'
    Add-Check 'delayed-expansion-is-execution-time' `
        ($expansion.output -contains 'delayed=[after]') $expansion.output 'delayed=[after]'

    $callScript = Join-Path $testRoot 'call.cmd'
    Write-AsciiFile -Path $callScript -Lines @(
        '@echo off',
        'set "MANT_VALUE=second-pass"',
        'call echo call=[%%MANT_VALUE%%]'
    )
    $call = Invoke-CmdFile $callScript
    Add-Check 'call-performs-second-expansion' `
        ($call.exitCode -eq 0 -and $call.output -contains 'call=[second-pass]') `
        ([pscustomobject]@{ output = $call.output; exitCode = $call.exitCode }) `
        'call=[second-pass], exit 0'

    $errorLevelScript = Join-Path $testRoot 'errorlevel.cmd'
    Write-AsciiFile -Path $errorLevelScript -Lines @(
        '@echo off',
        'cmd.exe /d /c exit 7',
        'if errorlevel 8 (echo ge8=[true]) else (echo ge8=[false])',
        'if errorlevel 7 (echo ge7=[true]) else (echo ge7=[false])',
        'exit /b 7'
    )
    $errorLevel = Invoke-CmdFile $errorLevelScript
    Add-Check 'if-errorlevel-is-greater-than-or-equal-threshold' `
        ($errorLevel.output -contains 'ge8=[false]' -and
            $errorLevel.output -contains 'ge7=[true]') `
        $errorLevel.output 'ge8=[false], ge7=[true]'
    Add-Check 'exit-b-becomes-child-process-exit-code' `
        ($errorLevel.exitCode -eq 7) $errorLevel.exitCode 7

    $localScript = Join-Path $testRoot 'local.cmd'
    Write-AsciiFile -Path $localScript -Lines @(
        '@echo off',
        'set "MANT_RESULT=outside"',
        'setlocal',
        'set "MANT_RESULT=inside"',
        'endlocal & set "MANT_RESULT=%MANT_RESULT%"',
        'echo transfer=[%MANT_RESULT%]'
    )
    $local = Invoke-CmdFile $localScript
    Add-Check 'endlocal-same-line-value-transfer' `
        ($local.exitCode -eq 0 -and $local.output -contains 'transfer=[inside]') `
        ([pscustomobject]@{ output = $local.output; exitCode = $local.exitCode }) `
        'transfer=[inside], exit 0'

    $lineFile = Join-Path $testRoot 'lines.txt'
    Write-AsciiFile -Path $lineFile -Lines @('alpha beta', '', 'gamma delta')
    $forScript = Join-Path $testRoot 'for.cmd'
    Write-AsciiFile -Path $forScript -Lines @(
        '@echo off',
        ('for /f "usebackq delims=" %%L in ("' + $lineFile + '") do echo line=[%%L]')
    )
    $forResult = Invoke-CmdFile $forScript
    Add-Check 'for-f-delims-preserves-nonblank-whole-lines' `
        ($forResult.output.Count -eq 2 -and
            $forResult.output[0] -eq 'line=[alpha beta]' -and
            $forResult.output[1] -eq 'line=[gamma delta]') `
        $forResult.output 'two whole nonblank lines; blank line omitted'

    $stackTarget = Join-Path $testRoot 'stack target'
    $null = New-Item -ItemType Directory -Path $stackTarget
    $stackScript = Join-Path $testRoot 'stack.cmd'
    Write-AsciiFile -Path $stackScript -Lines @(
        '@echo off',
        'set "MANT_ORIGINAL=%CD%"',
        ('pushd "' + $stackTarget + '"'),
        'echo pushed=[%CD%]',
        'popd',
        'echo restored=[%CD%]',
        'if /i "%CD%"=="%MANT_ORIGINAL%" (exit /b 0) else (exit /b 1)'
    )
    $stack = Invoke-CmdFile $stackScript
    Add-Check 'pushd-popd-restores-same-child-location' `
        ($stack.exitCode -eq 0 -and $stack.output.Count -eq 2) `
        ([pscustomobject]@{ output = $stack.output; exitCode = $stack.exitCode }) `
        'two locations and exit 0'

    $partA = Join-Path $testRoot 'part a.bin'
    $partB = Join-Path $testRoot 'part b.bin'
    $combined = Join-Path $testRoot 'combined.bin'
    [IO.File]::WriteAllBytes($partA, [byte[]](0, 1, 2, 3))
    [IO.File]::WriteAllBytes($partB, [byte[]](254, 255))
    $copyScript = Join-Path $testRoot 'copy.cmd'
    Write-AsciiFile -Path $copyScript -Lines @(
        '@echo off',
        ('copy /b /y "' + $partA + '"+"' + $partB + '" "' + $combined + '" >nul')
    )
    $copy = Invoke-CmdFile $copyScript
    $combinedBytes = if (Test-Path -LiteralPath $combined) {
        [IO.File]::ReadAllBytes($combined)
    } else { [byte[]]@() }
    Add-Check 'copy-b-concatenates-exact-bytes' `
        ($copy.exitCode -eq 0 -and
            [Convert]::ToBase64String($combinedBytes) -eq 'AAECA/7/') `
        ([pscustomobject]@{
            exitCode = $copy.exitCode
            base64 = [Convert]::ToBase64String($combinedBytes)
        }) `
        'AAECA/7/, exit 0'

    $fileRoot = Join-Path $testRoot 'file operations'
    $fileScript = Join-Path $testRoot 'files.cmd'
    Write-AsciiFile -Path $fileScript -Lines @(
        '@echo off',
        ('md "' + (Join-Path $fileRoot 'one\two') + '"'),
        ('echo payload>"' + (Join-Path $fileRoot 'one\two\before.txt') + '"'),
        ('ren "' + (Join-Path $fileRoot 'one\two\before.txt') + '" "after.txt"')
    )
    $files = Invoke-CmdFile $fileScript
    $renamed = Join-Path $fileRoot 'one\two\after.txt'
    Add-Check 'md-creates-intermediate-directories-with-extensions' `
        (Test-Path -LiteralPath (Join-Path $fileRoot 'one\two') -PathType Container) `
        (Test-Path -LiteralPath (Join-Path $fileRoot 'one\two')) $true
    Add-Check 'ren-new-name-is-in-place' `
        ($files.exitCode -eq 0 -and
            (Test-Path -LiteralPath $renamed -PathType Leaf)) `
        ([pscustomobject]@{ exitCode = $files.exitCode; path = $renamed }) `
        'renamed file in original directory, exit 0'

    $junctionTarget = Join-Path $testRoot 'junction target'
    $junctionPath = Join-Path $testRoot 'junction link'
    $null = New-Item -ItemType Directory -Path $junctionTarget
    $junctionScript = Join-Path $testRoot 'junction.cmd'
    Write-AsciiFile -Path $junctionScript -Lines @(
        '@echo off',
        ('mklink /j "' + $junctionPath + '" "' + $junctionTarget + '" >nul')
    )
    $junction = Invoke-CmdFile $junctionScript
    $junctionItem = Get-Item -LiteralPath $junctionPath -Force -ErrorAction SilentlyContinue
    Add-Check 'mklink-first-path-is-new-junction' `
        ($junction.exitCode -eq 0 -and $junctionItem -and
            ($junctionItem.Attributes -band [IO.FileAttributes]::ReparsePoint)) `
        ([pscustomobject]@{
            exitCode = $junction.exitCode
            path = if ($junctionItem) { $junctionItem.FullName } else { $null }
            attributes = if ($junctionItem) { $junctionItem.Attributes.ToString() } else { $null }
        }) `
        'first path exists as reparse point, exit 0'

    $queryScript = Join-Path $testRoot 'queries.cmd'
    Write-AsciiFile -Path $queryScript -Lines @(
        '@echo off',
        'date /t',
        'time /t',
        'ver',
        'verify',
        'echo'
    )
    $queries = Invoke-CmdFile $queryScript
    $queryLines = @($queries.output | Where-Object { $_.Trim() })
    Add-Check 'date-time-ver-verify-echo-query-only' `
        ($queries.exitCode -eq 0 -and $queryLines.Count -eq 5) `
        ([pscustomobject]@{
            exitCode = $queries.exitCode
            rawLineCount = $queries.output.Count
            nonemptyLineCount = $queryLines.Count
            version = if ($queryLines.Count -gt 2) { $queryLines[2] } else { $null }
            verify = if ($queryLines.Count -gt 3) { $queryLines[3] } else { $null }
            echo = if ($queryLines.Count -gt 4) { $queryLines[4] } else { $null }
        }) `
        'five nonempty localized query lines and exit 0'

    $help = @(& "$env:SystemRoot\System32\cmd.exe" /d /c help 2>&1)
    $helpExitCode = $LASTEXITCODE
    Add-Check 'help-list-has-nonzero-discovery-status' `
        ($helpExitCode -eq 1 -and
            @($help | Where-Object { $_.ToString().Trim() }).Count -gt 50) `
        ([pscustomobject]@{
            exitCode = $helpExitCode
            nonemptyLines = @($help | Where-Object { $_.ToString().Trim() }).Count
        }) `
        'more than 50 help lines and Cmd discovery status 1'

    foreach ($builtinName in @('BREAK', 'CLS', 'PAUSE', 'PROMPT', 'START')) {
        $builtinHelp = @(
            & "$env:SystemRoot\System32\cmd.exe" /d /c help $builtinName 2>&1
        )
        $builtinHelpExitCode = $LASTEXITCODE
        $builtinHelpLines = @(
            $builtinHelp |
                ForEach-Object { $_.ToString() } |
                Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        )
        Add-Check ("help-only-{0}" -f $builtinName.ToLowerInvariant()) `
            ($builtinHelpExitCode -eq 1 -and $builtinHelpLines.Count -gt 0) `
            ([pscustomobject]@{
                exitCode = $builtinHelpExitCode
                nonemptyLines = $builtinHelpLines.Count
                payloadRetained = $false
            }) `
            'nonempty static help, Cmd discovery status 1, payload not retained'
    }

    $flowScript = Join-Path $testRoot 'flow.cmd'
    Write-AsciiFile -Path $flowScript -Lines @(
        '@echo off',
        'call :sub A B C D',
        'set "MANT_RETURN=%ERRORLEVEL%"',
        'echo return=[%MANT_RETURN%]',
        'exit /b %MANT_RETURN%',
        ':sub',
        'echo original=[%1,%2,%3,%4;%*]',
        'shift /2',
        'echo shifted=[%1,%2,%3,%4;%*]',
        'rem This safe comment emits nothing.',
        'echo after-rem=[visible]',
        'cmd.exe /d /c exit 7',
        'goto :EOF'
    )
    $flow = Invoke-CmdFile $flowScript
    Add-Check 'shift-n-keeps-earlier-slots-and-original-star' `
        ($flow.output -contains 'original=[A,B,C,D;A B C D]' -and
            $flow.output -contains 'shifted=[A,C,D,;A B C D]') `
        $flow.output 'slot 1 retained; later slots shifted; original %* retained'
    Add-Check 'rem-plain-comment-emits-nothing-and-next-line-runs' `
        ($flow.output -contains 'after-rem=[visible]' -and
            -not ($flow.output -match 'safe comment')) `
        $flow.output 'only after-rem marker visible'
    Add-Check 'goto-eof-returns-with-current-errorlevel' `
        ($flow.exitCode -eq 7 -and $flow.output -contains 'return=[7]') `
        ([pscustomobject]@{ output = $flow.output; exitCode = $flow.exitCode }) `
        'return=[7], child exit 7'

    $failed = @($checks | Where-Object { -not $_.passed })
    [pscustomobject]@{
        schema = 'mant-pwsh-docs.cmd-builtins-smoke/v1'
        runtime = [pscustomobject]@{
            powershellVersion = $PSVersionTable.PSVersion.ToString()
            powershellEdition = $PSVersionTable.PSEdition
            cmdPath = "$env:SystemRoot\System32\cmd.exe"
            cmdFixedVersion = (
                Get-Item -LiteralPath "$env:SystemRoot\System32\cmd.exe"
            ).VersionInfo.FileVersionRaw.ToString()
            osVersion = [Environment]::OSVersion.VersionString
        }
        safety = [pscustomobject]@{
            temporaryRoot = $testRoot
            network = $false
            registry = $false
            persistentEnvironment = $false
            userData = $false
            interactiveBuiltinActions = $false
            staticHelpBuiltins = @('BREAK', 'CLS', 'PAUSE', 'PROMPT', 'START')
        }
        summary = [pscustomobject]@{
            total = $checks.Count
            passed = $checks.Count - $failed.Count
            failed = $failed.Count
        }
        checks = $checks
    } | ConvertTo-Json -Depth 7

    if ($failed.Count -ne 0) {
        exit 1
    }
}
finally {
    if (Test-Path -LiteralPath $testRoot) {
        $resolvedTestRoot = [IO.Path]::GetFullPath($testRoot)
        $resolvedTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
        $isExpectedTempPath = $resolvedTestRoot.StartsWith(
            $resolvedTempRoot,
            [StringComparison]::OrdinalIgnoreCase
        ) -and ([IO.Path]::GetFileName($resolvedTestRoot)).StartsWith(
            'mant-cmd-builtins-',
            [StringComparison]::Ordinal
        )

        if (-not $isExpectedTempPath) {
            throw "Refusing to remove unexpected runtime-test path: $resolvedTestRoot"
        }

        Remove-Item -LiteralPath $resolvedTestRoot -Recurse -Force
    }
}
