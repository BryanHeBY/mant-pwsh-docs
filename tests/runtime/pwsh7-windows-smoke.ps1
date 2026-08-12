[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$checks = [Collections.Generic.List[object]]::new()
$testRoot = Join-Path ([IO.Path]::GetTempPath()) (
    'mant-pwsh7-runtime-' + [guid]::NewGuid().ToString('N')
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

try {
    $null = New-Item -ItemType Directory -Path $testRoot

    Add-Check edition ($PSVersionTable.PSEdition -eq 'Core') `
        $PSVersionTable.PSEdition 'Core'
    Add-Check version (
        $PSVersionTable.PSVersion.Major -eq 7 -and
        $PSVersionTable.PSVersion.Minor -eq 6
    ) $PSVersionTable.PSVersion.ToString() '7.6.x'
    $newItemParameters = (Get-Command New-Item -CommandType Cmdlet).Parameters
    Add-Check 'new-item-path-not-literalpath' (
        $newItemParameters.ContainsKey('Path') -and
        -not $newItemParameters.ContainsKey('LiteralPath')
    ) ($newItemParameters.Keys -join ',') 'Path present; LiteralPath absent'
    Add-Check platform ($PSVersionTable.Platform -eq 'Win32NT') `
        $PSVersionTable.Platform 'Win32NT'
    $hasPlatformAndOs = $PSVersionTable.ContainsKey('Platform') -and
        $PSVersionTable.ContainsKey('OS')
    Add-Check 'version-table-platform-and-os' $hasPlatformAndOs `
        ($PSVersionTable.Keys -join ',') 'both Platform and OS keys'

    $runtimeVariablesPresent = @(
        'EnabledExperimentalFeatures', 'ExecutionContext', 'IsCoreCLR',
        'IsLinux', 'IsMacOS', 'IsWindows', 'NestedPromptLevel', 'PSCulture',
        'PSEdition', 'PSHOME', 'PSUICulture', 'ShellId', 'StackTrace'
    ) | ForEach-Object {
        $null -ne (Get-Variable -Name $_ -ErrorAction SilentlyContinue)
    }
    Add-Check 'automatic-runtime-and-platform-variables' (
        -not ($runtimeVariablesPresent -contains $false) -and
        $IsCoreCLR -and $IsWindows -and -not $IsLinux -and -not $IsMacOS -and
        $PSEdition -eq 'Core'
    ) ('edition={0}; core={1}; win={2}; linux={3}; mac={4}' -f (
        $PSEdition, $IsCoreCLR, $IsWindows, $IsLinux, $IsMacOS
    )) 'all runtime variables present; Core on Windows only'

    $ordinaryContextVariables = @('ConsoleFileName', 'PSDebugContext') |
        ForEach-Object {
            Get-Variable -Name $_ -ErrorAction SilentlyContinue
        }
    Add-Check 'automatic-context-variables-ordinary-session' (
        @($ordinaryContextVariables).Count -eq 0
    ) (@($ordinaryContextVariables | ForEach-Object Name) -join ',') `
        'ConsoleFileName and PSDebugContext absent outside their legacy/debug contexts'

    $null = 'abc123' -match '(\d+)'
    $matchBeforeFailure = $Matches[1]
    $null = 'abc' -match '(\d+)'
    $matchAfterFailure = $Matches[1]
    $foreachType = $null
    foreach ($number in 1) {
        $foreachType = $foreach.GetType().FullName
    }
    $switchType = $null
    switch (1) {
        1 { $switchType = $switch.GetType().FullName }
    }
    Add-Check 'automatic-language-context-variables' (
        $matchBeforeFailure -eq '123' -and $matchAfterFailure -eq '123' -and
        $foreachType -like '*Enumerator*' -and $switchType -like '*Enumerator*'
    ) ('matches={0}/{1}; foreach={2}; switch={3}' -f (
        $matchBeforeFailure, $matchAfterFailure, $foreachType, $switchType
    )) 'failed match retains 123; foreach and switch expose enumerators'

    $launcherPath = (Get-Process -Id $PID).Path
    $commandWithArgsOutput = & $launcherPath -NoLogo -NoProfile `
        -CommandWithArgs '$args | ConvertTo-Json -Compress' alpha 'two words'
    Add-Check 'launcher-command-with-args' (
        $commandWithArgsOutput -eq '["alpha","two words"]'
    ) $commandWithArgsOutput '["alpha","two words"]'

    $expectedAliases = [ordered]@{
        irm = 'Invoke-RestMethod'
        iwr = 'Invoke-WebRequest'
        iex = 'Invoke-Expression'
        ii = 'Invoke-Item'
        start = 'Start-Process'
    }
    foreach ($pair in $expectedAliases.GetEnumerator()) {
        $alias = Get-Alias -Name $pair.Key -ErrorAction SilentlyContinue
        Add-Check ('alias:' + $pair.Key) (
            $null -ne $alias -and $alias.Definition -eq $pair.Value
        ) $(if ($alias) { $alias.Definition } else { $null }) $pair.Value
    }

    $iexVariableName = 'MantIexProbe_' + [guid]::NewGuid().ToString('N')
    try {
        $iexCommands = @(
            "Set-Variable -Name '$iexVariableName' -Value 1 -Scope Script",
            "Set-Variable -Name '$iexVariableName' -Value 2 -Scope Script"
        )
        $iexCommands | Invoke-Expression
        $iexValue = Get-Variable -Name $iexVariableName -ValueOnly
        Add-Check 'invoke-expression-pipeline-item-scope' ($iexValue -eq 2) `
            $iexValue 'each fixed string evaluated in current script scope; final value 2'
    }
    finally {
        Remove-Variable -Name $iexVariableName -Scope Script `
            -ErrorAction SilentlyContinue
    }

    $irx = Get-Command irx -All -ErrorAction SilentlyContinue
    Add-Check 'command:irx-absent' ($null -eq $irx) @($irx).Count 0

    foreach ($nativeName in 'curl','sc') {
        $command = Get-Command $nativeName -All -ErrorAction SilentlyContinue |
            Select-Object -First 1
        $expectedName = $nativeName + '.exe'
        $actual = if ($command) {
            $command.CommandType.ToString() + ':' + $command.Name
        } else {
            $null
        }
        Add-Check ('command:' + $nativeName + '-native') (
            $null -ne $command -and
            $command.CommandType -eq 'Application' -and
            $command.Name -eq $expectedName
        ) $actual ('Application:' + $expectedName)
    }

    $coreCommands = @(
        'ForEach-Object', 'Get-ChildItem', 'Get-Command', 'Get-Help',
        'Get-Member', 'Import-Module', 'Invoke-Expression', 'Invoke-Item',
        'Invoke-RestMethod', 'Invoke-WebRequest', 'Select-Object',
        'Sort-Object', 'Start-Process', 'Where-Object'
    )
    foreach ($name in $coreCommands) {
        $command = Get-Command $name -ErrorAction SilentlyContinue
        Add-Check ('command:' + $name) ($null -ne $command) `
            $(if ($command) { $command.CommandType.ToString() } else { $null }) `
            'available'
    }

    function Get-MantCommandCollision { 'function' }
    Set-Alias -Name Get-MantCommandCollision -Value Get-Date
    $collisionCommands = @(Get-Command Get-MantCommandCollision -All)
    $collisionTypes = @($collisionCommands | ForEach-Object {
        $_.CommandType.ToString()
    })
    $collisionSyntax = Get-Command Get-MantCommandCollision -Syntax | Out-String
    Add-Check 'get-command-precedence-all-and-syntax' (
        (Get-Command Get-MantCommandCollision).CommandType -eq 'Alias' -and
        ($collisionTypes -join ',') -eq 'Alias,Function' -and
        -not [string]::IsNullOrWhiteSpace($collisionSyntax)
    ) ('default={0}; all={1}; syntax={2}' -f (
        (Get-Command Get-MantCommandCollision).CommandType,
        ($collisionTypes -join ','),
        (-not [string]::IsNullOrWhiteSpace($collisionSyntax))
    )) 'default=Alias; all=Alias,Function; syntax=True'

    $parameterHelp = Get-Help Get-Command -Parameter Name
    function Get-MantNoCommentHelp { param([string] $Value) $Value }
    $fallbackHelp = Get-Help Get-MantNoCommentHelp
    Add-Check 'get-help-parameter-and-syntax-fallback' (
        $parameterHelp.Name -eq 'Name' -and
        -not [string]::IsNullOrWhiteSpace(($parameterHelp | Out-String)) -and
        $fallbackHelp.Name -eq 'Get-MantNoCommentHelp' -and
        -not [string]::IsNullOrWhiteSpace(($fallbackHelp.Syntax | Out-String))
    ) ('parameter={0}; fallback={1}; syntax={2}' -f (
        $parameterHelp.Name,
        $fallbackHelp.Name,
        (-not [string]::IsNullOrWhiteSpace(($fallbackHelp.Syntax | Out-String)))
    )) 'parameter=Name; fallback=Get-MantNoCommentHelp; syntax=True'

    $expectedProfileProperties = @(
        'AllUsersAllHosts', 'AllUsersCurrentHost',
        'CurrentUserAllHosts', 'CurrentUserCurrentHost'
    )
    $actualProfileProperties = @($PROFILE.PSObject.Properties |
        Where-Object Name -in $expectedProfileProperties |
        ForEach-Object Name |
        Sort-Object)
    Add-Check 'profile-object-shape' (
        $PROFILE -is [string] -and
        ($actualProfileProperties -join ',') -eq (
            ($expectedProfileProperties | Sort-Object) -join ','
        ) -and
        $PROFILE -eq $PROFILE.CurrentUserCurrentHost
    ) ('type={0}; properties={1}; default-current={2}' -f (
        $PROFILE.GetType().FullName,
        ($actualProfileProperties -join ','),
        ($PROFILE -eq $PROFILE.CurrentUserCurrentHost)
    )) 'String with four profile path properties; default is CurrentUserCurrentHost'

    $startProcessParameters = (Get-Command Start-Process).Parameters
    $hasStartProcessPreview =
        $startProcessParameters.ContainsKey('WhatIf') -and
        $startProcessParameters.ContainsKey('Confirm')
    Add-Check 'start-process-preview-parameters' $hasStartProcessPreview `
        ($startProcessParameters.Keys -join ',') 'WhatIf and Confirm parameters'

    $processStartInfoProperties = @(
        [Diagnostics.ProcessStartInfo].GetProperties().Name
    )
    Add-Check 'process-start-info-has-structured-argument-list' (
        $processStartInfoProperties -contains 'Arguments' -and
        $processStartInfoProperties -contains 'ArgumentList'
    ) ('Arguments={0}; ArgumentList={1}' -f (
        ($processStartInfoProperties -contains 'Arguments'),
        ($processStartInfoProperties -contains 'ArgumentList')
    )) 'Arguments=True; ArgumentList=True'

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
    $documentsRoot = Join-Path $PSScriptRoot '..\..\docs\en-US\pwsh7'
    $missingOptions = [Collections.Generic.List[string]]::new()
    $declaredOptionCount = 0
    foreach ($pair in $commandDocuments.GetEnumerator()) {
        $declaredOptions = [Collections.Generic.List[string]]::new()
        $inOptionEntries = $false
        $inOptionBullet = $false
        $documentPath = Join-Path $documentsRoot $pair.Key
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
                    $declaredOptions.Add($match.Groups[1].Value)
                }
            }
            if ($inOptionEntries -and $line.Length -eq 0) {
                $inOptionEntries = $false
                $inOptionBullet = $false
            }
        }

        $knownOptions = [Collections.Generic.HashSet[string]]::new(
            [StringComparer]::OrdinalIgnoreCase
        )
        foreach ($parameter in (Get-Command $pair.Value).Parameters.Values) {
            $null = $knownOptions.Add('-' + $parameter.Name)
            foreach ($alias in $parameter.Aliases) {
                $null = $knownOptions.Add('-' + $alias)
            }
        }
        foreach ($option in $declaredOptions) {
            $declaredOptionCount++
            if (-not $knownOptions.Contains($option)) {
                $missingOptions.Add($pair.Key + ':' + $option)
            }
        }
    }
    $optionActual = if ($missingOptions.Count -eq 0) {
        "$declaredOptionCount declarations across $($commandDocuments.Count) documents"
    } else {
        $missingOptions -join ', '
    }
    Add-Check 'documented-option-metadata' ($missingOptions.Count -eq 0) `
        $optionActual 'every declared option exists in PowerShell 7.6 metadata'

    $pipelineObject = Get-ChildItem -LiteralPath $env:SystemRoot |
        Select-Object -First 1
    Add-Check 'pipeline-object-type' ($pipelineObject -is [IO.FileSystemInfo]) `
        $pipelineObject.GetType().FullName 'System.IO.FileSystemInfo subtype'

    $forEachWhatIfError = try {
        1 | ForEach-Object -WhatIf { 'not run' }
        'no error'
    } catch {
        $_.FullyQualifiedErrorId
    }
    Add-Check 'foreach-object-scriptblock-whatif-rejected' (
        $forEachWhatIfError -like 'NoShouldProcessForScriptBlockSet,*'
    ) $forEachWhatIfError 'NoShouldProcessForScriptBlockSet'

    $whereItems = @(
        [pscustomobject]@{ Name = 'one'; Enabled = $true }
        [pscustomobject]@{ Name = 'two'; Enabled = $false }
        [pscustomobject]@{ Name = 'three'; Enabled = $true }
    )
    $directWhereCalls = 0
    $null = Where-Object -InputObject $whereItems -FilterScript {
        $directWhereCalls++
        $true
    }
    $pipelineWhereCalls = 0
    $whereMatches = @($whereItems | Where-Object {
        $pipelineWhereCalls++
        $_.Enabled
    })
    Add-Check 'where-object-inputobject-versus-pipeline' (
        $directWhereCalls -eq 1 -and $pipelineWhereCalls -eq 3 -and
        ($whereMatches.Name -join ',') -eq 'one,three'
    ) ('direct={0}; pipeline={1}; matches={2}' -f (
        $directWhereCalls, $pipelineWhereCalls,
        ($whereMatches.Name -join ',')
    )) 'direct=1; pipeline=3; matches=one,three'

    $directForEachCalls = 0
    $null = ForEach-Object -InputObject @(1, 2, 3) -Process {
        $directForEachCalls++
    }
    $pipelineForEachCalls = 0
    $forEachPhases = @(1, 2, 3 | ForEach-Object -Begin {
        'begin'
    } -Process {
        $pipelineForEachCalls++
        "item=$_"
    } -End {
        'end'
    })
    Add-Check 'foreach-object-streaming-phases-and-inputobject' (
        $directForEachCalls -eq 1 -and $pipelineForEachCalls -eq 3 -and
        ($forEachPhases -join ',') -eq 'begin,item=1,item=2,item=3,end'
    ) ('direct={0}; pipeline={1}; output={2}' -f (
        $directForEachCalls, $pipelineForEachCalls,
        ($forEachPhases -join ',')
    )) 'direct=1; pipeline=3; output=begin,item=1,item=2,item=3,end'

    $parallelCallerValue = 'caller-only'
    $parallelResults = @(1, 2, 3 | ForEach-Object -Parallel {
        [pscustomobject]@{
            Input = $_
            CallerValueVisible = $null -ne (
                Get-Variable parallelCallerValue -ErrorAction SilentlyContinue
            )
        }
    } -ThrottleLimit 2)
    Add-Check 'foreach-object-parallel-input-and-caller-scope' (
        (($parallelResults.Input | Sort-Object) -join ',') -eq '1,2,3' -and
        -not ($parallelResults.CallerValueVisible -contains $true)
    ) ('inputs={0}; caller-visible={1}' -f (
        (($parallelResults.Input | Sort-Object) -join ','),
        ($parallelResults.CallerValueVisible -join ',')
    )) 'all inputs returned; ordinary caller variable absent in parallel runspaces'

    $memberObject = [pscustomobject]@{ Name = 'Ada'; Count = 2 }
    $rawMemberNames = @(
        $memberObject | Get-Member -MemberType NoteProperty |
            Select-Object -ExpandProperty Name
    )
    $formattedMemberNames = @(
        $memberObject | Format-Table | Get-Member -MemberType Property |
            Select-Object -ExpandProperty Name
    )
    Add-Check 'get-member-before-formatting' (
        $rawMemberNames -contains 'Name' -and
        $rawMemberNames -contains 'Count' -and
        $formattedMemberNames -notcontains 'Name'
    ) ('raw={0}; formatted={1}' -f (
        ($rawMemberNames -join ','), ($formattedMemberNames -join ',')
    )) 'raw includes Name/Count; formatted stream does not expose Name'

    $sortParameters = (Get-Command Sort-Object).Parameters
    $stableIds = @(
        [pscustomobject]@{ Id = 'b'; Key = 1 }
        [pscustomobject]@{ Id = 'a'; Key = 1 }
        [pscustomobject]@{ Id = 'c'; Key = 1 }
    ) | Sort-Object Key -Stable | Select-Object -ExpandProperty Id
    Add-Check 'sort-object-7-stable-top-bottom-parameters' (
        $sortParameters.ContainsKey('Stable') -and
        $sortParameters.ContainsKey('Top') -and
        $sortParameters.ContainsKey('Bottom') -and
        ($stableIds -join ',') -eq 'b,a,c'
    ) ('stable={0}; top={1}; bottom={2}; order={3}' -f (
        $sortParameters.ContainsKey('Stable'),
        $sortParameters.ContainsKey('Top'),
        $sortParameters.ContainsKey('Bottom'),
        ($stableIds -join ',')
    )) 'Stable/Top/Bottom present; stable order=b,a,c'

    $functionFlow = @(& {
        function Invoke-MantDocFunction {
            [CmdletBinding()]
            param([Parameter(ValueFromPipeline)] [int] $Value)
            begin { 'begin' }
            process { [pscustomobject]@{ Value = $Value } }
            end { 'end' }
        }
        1, 2 | Invoke-MantDocFunction
    })
    $implicitFunctionOutput = @(& {
        $list = [Collections.ArrayList]::new()
        $list.Add(5)
        'done'
    })
    Add-Check 'function-pipeline-blocks-and-implicit-output' (
        $functionFlow.Count -eq 4 -and
        $functionFlow[0] -eq 'begin' -and
        $functionFlow[1].Value -eq 1 -and
        $functionFlow[2].Value -eq 2 -and
        $functionFlow[3] -eq 'end' -and
        ($implicitFunctionOutput -join ',') -eq '0,done'
    ) ('flow={0}; implicit={1}' -f (
        (($functionFlow | ForEach-Object {
            if ($_ -is [string]) { $_ } else { 'value=' + $_.Value }
        }) -join ','), ($implicitFunctionOutput -join ',')
    )) 'flow=begin,value=1,value=2,end; implicit=0,done'

    $modulePath = Join-Path $testRoot 'MantDocFixture.psm1'
    @'
function Get-MantDocFixture { 'module' }
Export-ModuleMember -Function Get-MantDocFixture
'@ | Set-Content -LiteralPath $modulePath -Encoding Ascii
    function Get-MantDocFixture { 'existing' }
    $moduleNoClobber = $null
    $modulePrefixed = $null
    try {
        $moduleNoClobber = Import-Module -Name $modulePath -NoClobber `
            -PassThru -Force -WarningAction SilentlyContinue
        $noClobberValue = Get-MantDocFixture
        Remove-Module -ModuleInfo $moduleNoClobber -Force
        $moduleNoClobber = $null
        Remove-Item Function:\Get-MantDocFixture -Force

        $modulePrefixed = Import-Module -Name $modulePath -Prefix Probe `
            -PassThru -Force
        $prefixedValue = Get-ProbeMantDocFixture
        $prefixedSource = (Get-Command Get-ProbeMantDocFixture).Source
        Add-Check 'import-module-no-clobber-prefix-and-passthru' (
            $noClobberValue -eq 'existing' -and
            $prefixedValue -eq 'module' -and
            $modulePrefixed.Name -eq 'MantDocFixture' -and
            $prefixedSource -eq 'MantDocFixture'
        ) ('noClobber={0}; prefixed={1}; module={2}; source={3}' -f (
            $noClobberValue, $prefixedValue,
            $modulePrefixed.Name, $prefixedSource
        )) 'existing command retained; prefixed module command imported'
    }
    finally {
        if ($moduleNoClobber) {
            Remove-Module -ModuleInfo $moduleNoClobber -Force -ErrorAction SilentlyContinue
        }
        if ($modulePrefixed) {
            Remove-Module -ModuleInfo $modulePrefixed -Force -ErrorAction SilentlyContinue
        }
        Remove-Item Function:\Get-MantDocFixture -Force -ErrorAction SilentlyContinue
        Remove-Item Function:\Get-ProbeMantDocFixture -Force -ErrorAction SilentlyContinue
    }

    $uniqueDefault = @('a', 'A', 'a' | Select-Object -Unique)
    $uniqueInsensitive = @(
        'a', 'A', 'a' | Select-Object -Unique -CaseInsensitive
    )
    Add-Check 'select-object-unique-case-policy' (
        ($uniqueDefault -join ',') -ceq 'a,A' -and
        ($uniqueInsensitive -join ',') -ceq 'a'
    ) ('default={0}; insensitive={1}' -f (
        $uniqueDefault -join ','
    ), ($uniqueInsensitive -join ',')) 'default=a,A; insensitive=a'

    $firstLastSkip = @(1..20 | Select-Object -First 3 -Last 3 -Skip 4)
    $skipLastConflict = try {
        $null = 1..20 | Select-Object -First 3 -Last 3 -SkipLast 4
        'no error'
    } catch {
        $_.FullyQualifiedErrorId
    }
    Add-Check 'select-object-first-last-skip-parameter-sets' (
        ($firstLastSkip -join ',') -eq '5,6,7,18,19,20' -and
        $skipLastConflict -like 'AmbiguousParameterSet,*'
    ) ('selection={0}; conflict={1}' -f (
        $firstLastSkip -join ','
    ), $skipLastConflict) 'selection=5,6,7,18,19,20; conflict=AmbiguousParameterSet'

    $csvPath = Join-Path $testRoot 'no-clobber.csv'
    [pscustomobject]@{ Value = 'first' } |
        Export-Csv -LiteralPath $csvPath -NoTypeInformation -NoClobber
    $csvClobberError = try {
        [pscustomobject]@{ Value = 'second' } |
            Export-Csv -LiteralPath $csvPath -NoTypeInformation -NoClobber `
                -ErrorAction Stop
        'no error'
    } catch {
        $_.FullyQualifiedErrorId
    }
    $csvValue = (Import-Csv -LiteralPath $csvPath).Value
    Add-Check 'export-csv-no-clobber' (
        $csvClobberError -ne 'no error' -and $csvValue -eq 'first'
    ) ('error={0}; value={1}' -f $csvClobberError, $csvValue) `
        'second export fails; first content remains'

    $utf8Path = Join-Path $testRoot 'utf8.txt'
    'abc' | Set-Content -LiteralPath $utf8Path -Encoding utf8
    $utf8Bytes = [IO.File]::ReadAllBytes($utf8Path)
    $utf8Prefix = ($utf8Bytes[0..2] | ForEach-Object { $_.ToString('X2') }) -join ' '
    Add-Check 'set-content-utf8-no-bom' ($utf8Prefix -eq '61 62 63') `
        $utf8Prefix '61 62 63 (no BOM)'

    $redirectedPath = Join-Path $testRoot 'redirected.txt'
    'abc' > $redirectedPath
    $redirectedBytes = [IO.File]::ReadAllBytes($redirectedPath)
    $redirectedPrefix = (
        $redirectedBytes[0..2] | ForEach-Object { $_.ToString('X2') }
    ) -join ' '
    Add-Check 'redirection-text-utf8-no-bom' ($redirectedPrefix -eq '61 62 63') `
        $redirectedPrefix '61 62 63 (no BOM)'

    $utf8NoBomPath = Join-Path $testRoot 'utf8-no-bom.txt'
    $utf8NoBomText = 'ASCII' + [char]0x2014 + 'Unicode'
    [IO.File]::WriteAllBytes(
        $utf8NoBomPath,
        [Text.Encoding]::UTF8.GetBytes($utf8NoBomText)
    )
    $defaultUtf8Read = Get-Content -LiteralPath $utf8NoBomPath -Raw
    Add-Check 'utf8-no-bom-default-read' ($defaultUtf8Read -eq $utf8NoBomText) `
        $defaultUtf8Read $utf8NoBomText

    $indexedParts = @('alpha', 'beta')
    $embeddedIndex = "value=$indexedParts[1]"
    $subexpressionIndex = "value=$($indexedParts[1])"
    Add-Check 'embedded-index-needs-subexpression' (
        $embeddedIndex -eq 'value=alpha beta[1]' -and
        $subexpressionIndex -eq 'value=beta'
    ) "plain=$embeddedIndex; subexpression=$subexpressionIndex" `
        'plain=value=alpha beta[1]; subexpression=value=beta'

    $statementSource = 'foreach ($item in 1..3) { $item } | Measure-Object'
    $statementTokens = $null
    $statementErrors = $null
    $null = [Management.Automation.Language.Parser]::ParseInput(
        $statementSource,
        [ref] $statementTokens,
        [ref] $statementErrors
    )
    $statementItems = foreach ($item in 1..3) { $item }
    $statementCount = ($statementItems | Measure-Object).Count
    $statementBoundaryPassed =
        $statementErrors.ErrorId -contains 'EmptyPipeElement' -and
        $statementCount -eq 3
    Add-Check 'language-statement-pipeline-boundary' `
        $statementBoundaryPassed `
        (($statementErrors.ErrorId -join ',') +
            "; valid-count=$statementCount") `
        'EmptyPipeElement; valid-count=3'

    $filterName = 'alpha'
    $filterRows = @(
        [pscustomobject]@{ document = 'alpha' }
        [pscustomobject]@{ document = 'beta' }
    )
    $mergedTokenMatches = @(
        $filterRows | Where-Object document-eq$filterName
    )
    $explicitPredicateMatches = @(
        $filterRows | Where-Object { $_.document -eq $filterName }
    )
    Add-Check 'where-object-token-boundary' (
        $mergedTokenMatches.Count -eq 0 -and
        $explicitPredicateMatches.Count -eq 1 -and
        $explicitPredicateMatches[0].document -eq 'alpha'
    ) ('merged={0}; explicit={1}; selected={2}' -f (
        $mergedTokenMatches.Count,
        $explicitPredicateMatches.Count,
        ($explicitPredicateMatches.document -join ',')
    )) 'merged=0; explicit=1; selected=alpha'

    $optionalPayload = [pscustomobject]@{ selections = @('ok') }
    $optionalDiagnostics = $optionalPayload.diagnostics
    $wrappedNullCount = @($optionalDiagnostics).Count
    $directNullCount = $optionalDiagnostics.Count
    $diagnosticsProperty = $optionalPayload.PSObject.Properties['diagnostics']
    $safeDiagnosticsCount = if (
        $null -eq $diagnosticsProperty -or
        $null -eq $diagnosticsProperty.Value
    ) {
        0
    } else {
        @($diagnosticsProperty.Value).Count
    }
    Add-Check 'optional-null-array-count-boundary' (
        $wrappedNullCount -eq 1 -and $directNullCount -eq 0 -and
        $safeDiagnosticsCount -eq 0
    ) ('wrapped={0}; direct={1}; safe={2}' -f (
        $wrappedNullCount, $directNullCount, $safeDiagnosticsCount
    )) 'wrapped=1; direct=0; safe=0'

    $binaryInputPath = Join-Path $testRoot 'binary-input.bin'
    $binaryOutputPath = Join-Path $testRoot 'binary-output.bin'
    $binaryProbe = [byte[]](0, 10, 13, 127, 128, 255)
    [IO.File]::WriteAllBytes($binaryInputPath, $binaryProbe)
    cmd.exe /d /c type $binaryInputPath > $binaryOutputPath
    $binaryOutput = [IO.File]::ReadAllBytes($binaryOutputPath)
    Add-Check 'native-stdout-byte-preservation' (
        [Linq.Enumerable]::SequenceEqual($binaryProbe, $binaryOutput)
    ) (($binaryOutput | ForEach-Object { $_.ToString('X2') }) -join ' ') `
        (($binaryProbe | ForEach-Object { $_.ToString('X2') }) -join ' ')

    $originalCulture = [Threading.Thread]::CurrentThread.CurrentCulture
    $originalUICulture = [Threading.Thread]::CurrentThread.CurrentUICulture
    try {
        $testCulture = [Globalization.CultureInfo]::GetCultureInfo('de-DE')
        [Threading.Thread]::CurrentThread.CurrentCulture = $testCulture
        [Threading.Thread]::CurrentThread.CurrentUICulture = $testCulture
        $number = 1.2
        $interpolatedNumber = "$number"
        $toStringNumber = $number.ToString()
    }
    finally {
        [Threading.Thread]::CurrentThread.CurrentCulture = $originalCulture
        [Threading.Thread]::CurrentThread.CurrentUICulture = $originalUICulture
    }
    Add-Check 'interpolation-invariant-culture' ($interpolatedNumber -eq '1.2') `
        $interpolatedNumber '1.2'
    Add-Check 'explicit-tostring-current-culture' ($toStringNumber -eq '1,2') `
        $toStringNumber '1,2 for de-DE'

    Write-Error 'direct status probe' -ErrorAction SilentlyContinue
    $directStatus = $?
    $(Write-Error 'subexpression status probe' -ErrorAction SilentlyContinue)
    $subexpressionStatus = $?
    (Write-Error 'parentheses status probe' -ErrorAction SilentlyContinue)
    $parenthesesStatus = $?
    @(Write-Error 'array-expression status probe' -ErrorAction SilentlyContinue)
    $arrayExpressionStatus = $?
    $statusResult = [ordered]@{
        direct = $directStatus
        subexpression = $subexpressionStatus
        parentheses = $parenthesesStatus
        arrayExpression = $arrayExpressionStatus
    }
    Add-Check 'question-mark-expression-status' (
        -not $directStatus -and -not $subexpressionStatus -and
        -not $parenthesesStatus -and -not $arrayExpressionStatus
    ) ($statusResult | ConvertTo-Json -Compress) `
        'direct and all three wrappers false in PowerShell 7'

    cmd.exe /d /c exit 7
    $nativeExitCode = $LASTEXITCODE
    Add-Check 'native-exit-code' ($nativeExitCode -eq 7) $nativeExitCode 7

    $nativeStderrCaught = $false
    $nativeStderrErrorId = $null
    $nativeStderrExitCode = $null
    $nativeStderrItems = @()
    try {
        $nativeStderrItems = @(
            cmd.exe /d /c 'echo native-stderr 1>&2 & exit /b 7' 2>&1
        )
        $nativeStderrExitCode = $LASTEXITCODE
    } catch {
        $nativeStderrCaught = $true
        $nativeStderrErrorId = $_.FullyQualifiedErrorId
        $nativeStderrExitCode = $LASTEXITCODE
    }
    $nativeStderrType = if ($nativeStderrItems.Count -eq 1) {
        $nativeStderrItems[0].GetType().FullName
    } else {
        $null
    }
    Add-Check 'merged-native-stderr-error-action' (
        -not $nativeStderrCaught -and
        -not $PSNativeCommandUseErrorActionPreference -and
        $nativeStderrExitCode -eq 7 -and
        $nativeStderrItems.Count -eq 1 -and
        $nativeStderrType -eq 'System.Management.Automation.ErrorRecord'
    ) ('caught={0}; preference={1}; exit={2}; items={3}; type={4}' -f (
        $nativeStderrCaught,
        $PSNativeCommandUseErrorActionPreference,
        $nativeStderrExitCode,
        $nativeStderrItems.Count,
        $nativeStderrType
    )) 'caught=False; preference=False; exit=7; items=1; type=System.Management.Automation.ErrorRecord'

    $childSource = '$value = 1; $value'
    $childOutput = & (Join-Path $PSHOME 'pwsh.exe') -NoProfile -Command $childSource
    Add-Check 'literal-child-command-source' ($childOutput -eq 1) $childOutput 1
    Add-Check 'native-argument-passing-mode' (
        $PSNativeCommandArgumentPassing.ToString() -eq 'Windows'
    ) $PSNativeCommandArgumentPassing.ToString() 'Windows'

    $failed = @($checks | Where-Object { -not $_.passed })
    [pscustomobject]@{
        schema = 'mant-pwsh-docs.runtime-smoke/v1'
        runtime = [pscustomobject]@{
            version = $PSVersionTable.PSVersion.ToString()
            edition = $PSVersionTable.PSEdition
            platform = $PSVersionTable.Platform
            executable = $launcherPath
            osVersion = $PSVersionTable.OS
            is64BitOperatingSystem = [Environment]::Is64BitOperatingSystem
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
}
finally {
    if (Test-Path -LiteralPath $testRoot) {
        $resolvedTestRoot = [IO.Path]::GetFullPath($testRoot)
        $resolvedTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
        $isExpectedTempPath = $resolvedTestRoot.StartsWith(
            $resolvedTempRoot,
            [StringComparison]::OrdinalIgnoreCase
        ) -and ([IO.Path]::GetFileName($resolvedTestRoot)).StartsWith(
            'mant-pwsh7-runtime-',
            [StringComparison]::Ordinal
        )
        if (-not $isExpectedTempPath) {
            throw "Refusing to remove unexpected runtime-test path: $resolvedTestRoot"
        }
        Remove-Item -LiteralPath $resolvedTestRoot -Recurse -Force
    }
}
