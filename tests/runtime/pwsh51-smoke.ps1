[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$checks = New-Object System.Collections.Generic.List[object]
$testRoot = Join-Path ([IO.Path]::GetTempPath()) (
    'mant-pwsh51-runtime-' + [guid]::NewGuid().ToString('N')
)

function Add-Check {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Name,

        [Parameter(Mandatory = $true)]
        [bool] $Passed,

        [AllowNull()]
        [object] $Actual,

        [AllowNull()]
        [object] $Expected
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

    Add-Check -Name 'edition' `
        -Passed ($PSVersionTable.PSEdition -eq 'Desktop') `
        -Actual $PSVersionTable.PSEdition -Expected 'Desktop'
    Add-Check -Name 'version' `
        -Passed ($PSVersionTable.PSVersion.Major -eq 5 -and $PSVersionTable.PSVersion.Minor -eq 1) `
        -Actual $PSVersionTable.PSVersion.ToString() -Expected '5.1.x'
    $newItemParameters = (Get-Command New-Item -CommandType Cmdlet).Parameters
    Add-Check -Name 'new-item-path-not-literalpath' `
        -Passed (
            $newItemParameters.ContainsKey('Path') -and
            -not $newItemParameters.ContainsKey('LiteralPath')
        ) `
        -Actual ($newItemParameters.Keys -join ',') `
        -Expected 'Path present; LiteralPath absent'
    $hasPlatformAndOs = $PSVersionTable.ContainsKey('Platform') -or
        $PSVersionTable.ContainsKey('OS')
    Add-Check -Name 'version-table-no-platform-or-os' `
        -Passed (-not $hasPlatformAndOs) `
        -Actual ($PSVersionTable.Keys -join ',') `
        -Expected 'neither Platform nor OS key in Windows PowerShell 5.1'

    $runtimeVariablesPresent = @(
        'ExecutionContext', 'NestedPromptLevel', 'PSCulture', 'PSEdition',
        'PSHOME', 'PSUICulture', 'ShellId', 'StackTrace'
    ) | ForEach-Object {
        $null -ne (Get-Variable -Name $_ -ErrorAction SilentlyContinue)
    }
    $consoleFileVariable = Get-Variable ConsoleFileName `
        -ErrorAction SilentlyContinue
    $debugContextVariable = Get-Variable PSDebugContext `
        -ErrorAction SilentlyContinue
    Add-Check -Name 'automatic-runtime-and-context-variables' `
        -Passed (
            -not ($runtimeVariablesPresent -contains $false) -and
            $PSEdition -eq 'Desktop' -and
            $null -ne $consoleFileVariable -and
            $consoleFileVariable.Value -is [string] -and
            $consoleFileVariable.Value.Length -eq 0 -and
            $null -eq $debugContextVariable
        ) `
        -Actual ('edition={0}; console-file-present={1}; console-file-length={2}; debug-present={3}' -f (
            $PSEdition,
            ($null -ne $consoleFileVariable),
            $(if ($null -ne $consoleFileVariable) {
                $consoleFileVariable.Value.Length
            } else { $null }),
            ($null -ne $debugContextVariable)
        )) `
        -Expected 'Desktop; empty ConsoleFileName variable present; PSDebugContext absent'

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
    Add-Check -Name 'automatic-language-context-variables' `
        -Passed (
            $matchBeforeFailure -eq '123' -and
            $matchAfterFailure -eq '123' -and
            $foreachType -like '*Enumerator*' -and
            $switchType -like '*Enumerator*'
        ) `
        -Actual ('matches={0}/{1}; foreach={2}; switch={3}' -f (
            $matchBeforeFailure, $matchAfterFailure, $foreachType, $switchType
        )) `
        -Expected 'failed match retains 123; foreach and switch expose enumerators'

    $expectedAliases = [ordered]@{
        irm = 'Invoke-RestMethod'
        iwr = 'Invoke-WebRequest'
        iex = 'Invoke-Expression'
        ii = 'Invoke-Item'
        start = 'Start-Process'
        curl = 'Invoke-WebRequest'
        sc = 'Set-Content'
    }

    foreach ($pair in $expectedAliases.GetEnumerator()) {
        $alias = Get-Alias -Name $pair.Key -ErrorAction SilentlyContinue
        Add-Check -Name ('alias:' + $pair.Key) `
            -Passed ($null -ne $alias -and $alias.Definition -eq $pair.Value) `
            -Actual $(if ($alias) { $alias.Definition } else { $null }) `
            -Expected $pair.Value
    }

    $iexVariableName = 'MantIexProbe_' + [guid]::NewGuid().ToString('N')
    try {
        $iexCommands = @(
            "Set-Variable -Name '$iexVariableName' -Value 1 -Scope Script",
            "Set-Variable -Name '$iexVariableName' -Value 2 -Scope Script"
        )
        $iexCommands | Invoke-Expression
        $iexValue = Get-Variable -Name $iexVariableName -ValueOnly
        Add-Check -Name 'invoke-expression-pipeline-item-scope' `
            -Passed ($iexValue -eq 2) -Actual $iexValue `
            -Expected 'each fixed string evaluated in current script scope; final value 2'
    }
    finally {
        Remove-Variable -Name $iexVariableName -Scope Script `
            -ErrorAction SilentlyContinue
    }

    $irx = Get-Command irx -All -ErrorAction SilentlyContinue
    Add-Check -Name 'command:irx-absent' -Passed ($null -eq $irx) `
        -Actual @($irx).Count -Expected 0

    $coreCommands = @(
        'ForEach-Object',
        'Get-ChildItem',
        'Get-Command',
        'Get-Help',
        'Get-Member',
        'Import-Module',
        'Invoke-Expression',
        'Invoke-Item',
        'Invoke-RestMethod',
        'Invoke-WebRequest',
        'Select-Object',
        'Sort-Object',
        'Start-Process',
        'Where-Object'
    )
    foreach ($name in $coreCommands) {
        $command = Get-Command $name -ErrorAction SilentlyContinue
        Add-Check -Name ('command:' + $name) -Passed ($null -ne $command) `
            -Actual $(if ($command) { $command.CommandType.ToString() } else { $null }) `
            -Expected 'available'
    }

    function Get-MantCommandCollision { 'function' }
    Set-Alias -Name Get-MantCommandCollision -Value Get-Date
    $collisionCommands = @(Get-Command Get-MantCommandCollision -All)
    $collisionTypes = @($collisionCommands | ForEach-Object {
        $_.CommandType.ToString()
    })
    $collisionSyntax = Get-Command Get-MantCommandCollision -Syntax | Out-String
    Add-Check -Name 'get-command-precedence-all-and-syntax' `
        -Passed (
            (Get-Command Get-MantCommandCollision).CommandType -eq 'Alias' -and
            ($collisionTypes -join ',') -eq 'Alias,Function' -and
            -not [string]::IsNullOrWhiteSpace($collisionSyntax)
        ) `
        -Actual ('default={0}; all={1}; syntax={2}' -f (
            (Get-Command Get-MantCommandCollision).CommandType,
            ($collisionTypes -join ','),
            (-not [string]::IsNullOrWhiteSpace($collisionSyntax))
        )) `
        -Expected 'default=Alias; all=Alias,Function; syntax=True'

    $parameterHelp = Get-Help Get-Command -Parameter Name
    function Get-MantNoCommentHelp { param([string] $Value) $Value }
    $fallbackHelp = Get-Help Get-MantNoCommentHelp
    Add-Check -Name 'get-help-parameter-and-syntax-fallback' `
        -Passed (
            $parameterHelp.Name -eq 'Name' -and
            -not [string]::IsNullOrWhiteSpace(($parameterHelp | Out-String)) -and
            $fallbackHelp.Name -eq 'Get-MantNoCommentHelp' -and
            -not [string]::IsNullOrWhiteSpace(($fallbackHelp.Syntax | Out-String))
        ) `
        -Actual ('parameter={0}; fallback={1}; syntax={2}' -f (
            $parameterHelp.Name,
            $fallbackHelp.Name,
            (-not [string]::IsNullOrWhiteSpace(($fallbackHelp.Syntax | Out-String)))
        )) `
        -Expected 'parameter=Name; fallback=Get-MantNoCommentHelp; syntax=True'

    $expectedProfileProperties = @(
        'AllUsersAllHosts', 'AllUsersCurrentHost',
        'CurrentUserAllHosts', 'CurrentUserCurrentHost'
    )
    $actualProfileProperties = @($PROFILE.PSObject.Properties |
        Where-Object { $_.Name -in $expectedProfileProperties } |
        ForEach-Object Name |
        Sort-Object)
    Add-Check -Name 'profile-object-shape' `
        -Passed (
            $PROFILE -is [string] -and
            ($actualProfileProperties -join ',') -eq (
                ($expectedProfileProperties | Sort-Object) -join ','
            ) -and
            $PROFILE -eq $PROFILE.CurrentUserCurrentHost
        ) `
        -Actual ('type={0}; properties={1}; default-current={2}' -f (
            $PROFILE.GetType().FullName,
            ($actualProfileProperties -join ','),
            ($PROFILE -eq $PROFILE.CurrentUserCurrentHost)
        )) `
        -Expected 'String with four profile path properties; default is CurrentUserCurrentHost'

    $startProcessParameters = (Get-Command Start-Process).Parameters
    Add-Check -Name 'start-process-no-whatif' `
        -Passed (-not $startProcessParameters.ContainsKey('WhatIf')) `
        -Actual ($startProcessParameters.ContainsKey('WhatIf')) -Expected $false

    $processStartInfoProperties = @(
        [Diagnostics.ProcessStartInfo].GetProperties().Name
    )
    Add-Check -Name 'process-start-info-uses-arguments-string' `
        -Passed (
            $processStartInfoProperties -contains 'Arguments' -and
            $processStartInfoProperties -notcontains 'ArgumentList'
        ) `
        -Actual ('Arguments={0}; ArgumentList={1}' -f (
            ($processStartInfoProperties -contains 'Arguments'),
            ($processStartInfoProperties -contains 'ArgumentList')
        )) `
        -Expected 'Arguments=True; ArgumentList=False'

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
        'curl.md' = 'Invoke-WebRequest'
        'start.md' = 'Start-Process'
    }
    $documentsRoot = Join-Path $PSScriptRoot '..\..\docs\en-US\pwsh51'
    $missingOptions = New-Object System.Collections.Generic.List[string]
    $declaredOptionCount = 0
    foreach ($pair in $commandDocuments.GetEnumerator()) {
        $documentPath = Join-Path $documentsRoot $pair.Key
        $declaredOptions = New-Object System.Collections.Generic.List[string]
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
                    $declaredOptions.Add($match.Groups[1].Value)
                }
            }
            if ($inOptionEntries -and $line.Length -eq 0) {
                $inOptionEntries = $false
                $inOptionBullet = $false
            }
        }

        $command = Get-Command $pair.Value -ErrorAction Stop
        $knownOptions = New-Object 'System.Collections.Generic.HashSet[string]' (
            [StringComparer]::OrdinalIgnoreCase
        )
        foreach ($parameter in $command.Parameters.Values) {
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
    Add-Check -Name 'documented-option-metadata' `
        -Passed ($missingOptions.Count -eq 0) `
        -Actual $(if ($missingOptions.Count -eq 0) {
            "$declaredOptionCount declarations across $($commandDocuments.Count) documents"
        } else {
            $missingOptions -join ', '
        }) `
        -Expected 'every declared option exists in Windows PowerShell 5.1 command metadata'

    $pipelineObject = Get-ChildItem -LiteralPath $env:SystemRoot | Select-Object -First 1
    Add-Check -Name 'pipeline-object-type' `
        -Passed ($pipelineObject -is [IO.FileSystemInfo]) `
        -Actual $pipelineObject.GetType().FullName -Expected 'System.IO.FileSystemInfo subtype'

    $forEachWhatIfError = try {
        1 | ForEach-Object -WhatIf { 'not run' }
        'no error'
    } catch {
        $_.FullyQualifiedErrorId
    }
    Add-Check -Name 'foreach-object-scriptblock-whatif-rejected' `
        -Passed ($forEachWhatIfError -like 'NoShouldProcessForScriptBlockSet,*') `
        -Actual $forEachWhatIfError -Expected 'NoShouldProcessForScriptBlockSet'

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
    Add-Check -Name 'where-object-inputobject-versus-pipeline' `
        -Passed (
            $directWhereCalls -eq 1 -and $pipelineWhereCalls -eq 3 -and
            ($whereMatches.Name -join ',') -eq 'one,three'
        ) `
        -Actual ('direct={0}; pipeline={1}; matches={2}' -f (
            $directWhereCalls, $pipelineWhereCalls,
            ($whereMatches.Name -join ',')
        )) -Expected 'direct=1; pipeline=3; matches=one,three'

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
    Add-Check -Name 'foreach-object-streaming-phases-and-inputobject' `
        -Passed (
            $directForEachCalls -eq 1 -and $pipelineForEachCalls -eq 3 -and
            ($forEachPhases -join ',') -eq 'begin,item=1,item=2,item=3,end'
        ) `
        -Actual ('direct={0}; pipeline={1}; output={2}' -f (
            $directForEachCalls, $pipelineForEachCalls,
            ($forEachPhases -join ',')
        )) -Expected 'direct=1; pipeline=3; output=begin,item=1,item=2,item=3,end'

    $memberObject = [pscustomobject]@{ Name = 'Ada'; Count = 2 }
    $rawMemberNames = @(
        $memberObject | Get-Member -MemberType NoteProperty |
            Select-Object -ExpandProperty Name
    )
    $formattedMemberNames = @(
        $memberObject | Format-Table | Get-Member -MemberType Property |
            Select-Object -ExpandProperty Name
    )
    Add-Check -Name 'get-member-before-formatting' `
        -Passed (
            $rawMemberNames -contains 'Name' -and
            $rawMemberNames -contains 'Count' -and
            $formattedMemberNames -notcontains 'Name'
        ) `
        -Actual ('raw={0}; formatted={1}' -f (
            ($rawMemberNames -join ','), ($formattedMemberNames -join ',')
        )) -Expected 'raw includes Name/Count; formatted stream does not expose Name'

    $sortParameters = (Get-Command Sort-Object).Parameters
    $sortedIds = @(
        [pscustomobject]@{ Id = 'a'; Key = 2 }
        [pscustomobject]@{ Id = 'b'; Key = 1 }
        [pscustomobject]@{ Id = 'c'; Key = 1 }
    ) | Sort-Object Key, @{ Expression = { $_.Id }; Descending = $true } |
        Select-Object -ExpandProperty Id
    Add-Check -Name 'sort-object-51-parameters-and-calculated-key' `
        -Passed (
            -not $sortParameters.ContainsKey('Stable') -and
            -not $sortParameters.ContainsKey('Top') -and
            -not $sortParameters.ContainsKey('Bottom') -and
            ($sortedIds -join ',') -eq 'c,b,a'
        ) `
        -Actual ('stable={0}; top={1}; bottom={2}; order={3}' -f (
            $sortParameters.ContainsKey('Stable'),
            $sortParameters.ContainsKey('Top'),
            $sortParameters.ContainsKey('Bottom'),
            ($sortedIds -join ',')
        )) -Expected 'Stable/Top/Bottom absent; order=c,b,a'

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
        $list = New-Object Collections.ArrayList
        $list.Add(5)
        'done'
    })
    Add-Check -Name 'function-pipeline-blocks-and-implicit-output' `
        -Passed (
            $functionFlow.Count -eq 4 -and
            $functionFlow[0] -eq 'begin' -and
            $functionFlow[1].Value -eq 1 -and
            $functionFlow[2].Value -eq 2 -and
            $functionFlow[3] -eq 'end' -and
            ($implicitFunctionOutput -join ',') -eq '0,done'
        ) `
        -Actual ('flow={0}; implicit={1}' -f (
            (($functionFlow | ForEach-Object {
                if ($_ -is [string]) { $_ } else { 'value=' + $_.Value }
            }) -join ','), ($implicitFunctionOutput -join ',')
        )) -Expected 'flow=begin,value=1,value=2,end; implicit=0,done'

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
        Add-Check -Name 'import-module-no-clobber-prefix-and-passthru' `
            -Passed (
                $noClobberValue -eq 'existing' -and
                $prefixedValue -eq 'module' -and
                $modulePrefixed.Name -eq 'MantDocFixture' -and
                $prefixedSource -eq 'MantDocFixture'
            ) `
            -Actual ('noClobber={0}; prefixed={1}; module={2}; source={3}' -f (
                $noClobberValue, $prefixedValue,
                $modulePrefixed.Name, $prefixedSource
            )) -Expected 'existing command retained; prefixed module command imported'
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

    $legacyUnique = @('a', 'A', 'a' | Select-Object -Unique)
    Add-Check -Name 'select-object-unique-case-sensitive' `
        -Passed (($legacyUnique -join ',') -ceq 'a,A') `
        -Actual ($legacyUnique -join ',') -Expected 'a,A'
    $legacySkipLast = @(1, 2, 3 | Select-Object -SkipLast 1)
    Add-Check -Name 'select-object-skip-last' `
        -Passed (($legacySkipLast -join ',') -eq '1,2') `
        -Actual ($legacySkipLast -join ',') -Expected '1,2'
    $firstLastSkip = @(1..20 | Select-Object -First 3 -Last 3 -Skip 4)
    $skipLastConflict = try {
        $null = 1..20 | Select-Object -First 3 -Last 3 -SkipLast 4
        'no error'
    } catch {
        $_.FullyQualifiedErrorId
    }
    Add-Check -Name 'select-object-first-last-skip-parameter-sets' `
        -Passed (
            ($firstLastSkip -join ',') -eq '5,6,7,18,19,20' -and
            $skipLastConflict -like 'AmbiguousParameterSet,*'
        ) `
        -Actual ('selection={0}; conflict={1}' -f (
            $firstLastSkip -join ','
        ), $skipLastConflict) `
        -Expected 'selection=5,6,7,18,19,20; conflict=AmbiguousParameterSet'
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
    Add-Check -Name 'export-csv-no-clobber' `
        -Passed ($csvClobberError -ne 'no error' -and $csvValue -eq 'first') `
        -Actual ('error={0}; value={1}' -f $csvClobberError, $csvValue) `
        -Expected 'second export fails; first content remains'
    $followSymlinkParameter = (Get-Command Get-ChildItem).Parameters['FollowSymlink']
    Add-Check -Name 'get-childitem-follow-symlink-serviced-build' `
        -Passed ($null -ne $followSymlinkParameter) `
        -Actual $(if ($followSymlinkParameter) { 'present' } else { 'absent' }) `
        -Expected 'present on the recorded Windows build'

    $selectedVersion = powershell.exe -Version 5.1 -NoLogo -NoProfile `
        -Command '$PSVersionTable.PSVersion.ToString()'
    Add-Check -Name 'launcher-version-selector' `
        -Passed ($selectedVersion -eq $PSVersionTable.PSVersion.ToString()) `
        -Actual $selectedVersion -Expected $PSVersionTable.PSVersion.ToString()

    $redirectedPath = Join-Path $testRoot 'redirected.txt'
    'abc' > $redirectedPath
    $redirectedBytes = [IO.File]::ReadAllBytes($redirectedPath)
    $redirectedBom = ($redirectedBytes[0..1] | ForEach-Object { $_.ToString('X2') }) -join ' '
    Add-Check -Name 'redirection-default-encoding' `
        -Passed ($redirectedBom -eq 'FF FE') -Actual $redirectedBom -Expected 'FF FE (UTF-16LE BOM)'

    $utf8Path = Join-Path $testRoot 'utf8.txt'
    'abc' | Set-Content -LiteralPath $utf8Path -Encoding UTF8
    $utf8Bytes = [IO.File]::ReadAllBytes($utf8Path)
    $utf8Bom = ($utf8Bytes[0..2] | ForEach-Object { $_.ToString('X2') }) -join ' '
    Add-Check -Name 'set-content-utf8-encoding' `
        -Passed ($utf8Bom -eq 'EF BB BF') -Actual $utf8Bom -Expected 'EF BB BF (UTF-8 BOM)'

    $utf8NoBomPath = Join-Path $testRoot 'utf8-no-bom.txt'
    $utf8NoBomText = 'ASCII' + [char]0x2014 + 'Unicode'
    [IO.File]::WriteAllBytes(
        $utf8NoBomPath,
        [Text.Encoding]::UTF8.GetBytes($utf8NoBomText)
    )
    $legacyDefaultRead = Get-Content -LiteralPath $utf8NoBomPath -Raw
    $explicitUtf8Read = Get-Content -LiteralPath $utf8NoBomPath -Raw -Encoding UTF8
    Add-Check -Name 'utf8-no-bom-read-boundary' `
        -Passed (
            $legacyDefaultRead -ne $utf8NoBomText -and
            $explicitUtf8Read -eq $utf8NoBomText
        ) `
        -Actual ('default={0}; explicit={1}' -f $legacyDefaultRead, $explicitUtf8Read) `
        -Expected 'default uses active ANSI code page; -Encoding UTF8 preserves text'

    $webSourcePath = Join-Path $testRoot 'web-source.json'
    $iwrOutPath = Join-Path $testRoot 'iwr-output.json'
    $irmOutPath = Join-Path $testRoot 'irm-output.json'
    [IO.File]::WriteAllText(
        $webSourcePath,
        '{"ok":true}',
        (New-Object Text.UTF8Encoding($false))
    )
    $webSourceUri = [Uri]$webSourcePath
    $iwrPassThru = @(
        Invoke-WebRequest -UseBasicParsing -Uri $webSourceUri `
            -OutFile $iwrOutPath -PassThru
    )
    $irmPassThru = @(
        Invoke-RestMethod -UseBasicParsing -Uri $webSourceUri `
            -OutFile $irmOutPath -PassThru
    )
    $iwrOutLength = (Get-Item -LiteralPath $iwrOutPath).Length
    $irmOutLength = (Get-Item -LiteralPath $irmOutPath).Length
    Add-Check -Name 'iwr-passthru-serviced-build' `
        -Passed ($iwrPassThru.Count -eq 1 -and $iwrOutLength -gt 0) `
        -Actual "pipeline=$($iwrPassThru.Count); bytes=$iwrOutLength" `
        -Expected 'one pipeline result and a nonempty file for the file URI probe'
    Add-Check -Name 'irm-passthru-empty-file-defect' `
        -Passed ($irmPassThru.Count -eq 1 -and $irmOutLength -eq 0) `
        -Actual "pipeline=$($irmPassThru.Count); bytes=$irmOutLength" `
        -Expected 'one pipeline result and an empty file on the recorded 5.1 build'

    $indexedParts = @('alpha', 'beta')
    $embeddedIndex = "value=$indexedParts[1]"
    $subexpressionIndex = "value=$($indexedParts[1])"
    Add-Check -Name 'embedded-index-needs-subexpression' `
        -Passed (
            $embeddedIndex -eq 'value=alpha beta[1]' -and
            $subexpressionIndex -eq 'value=beta'
        ) `
        -Actual "plain=$embeddedIndex; subexpression=$subexpressionIndex" `
        -Expected 'plain=value=alpha beta[1]; subexpression=value=beta'

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
    Add-Check -Name 'language-statement-pipeline-boundary' `
        -Passed (
            $statementErrors.ErrorId -contains 'EmptyPipeElement' -and
            $statementCount -eq 3
        ) `
        -Actual (($statementErrors.ErrorId -join ',') +
            "; valid-count=$statementCount") `
        -Expected 'EmptyPipeElement; valid-count=3'

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
    Add-Check -Name 'where-object-token-boundary' `
        -Passed (
            $mergedTokenMatches.Count -eq 0 -and
            $explicitPredicateMatches.Count -eq 1 -and
            $explicitPredicateMatches[0].document -eq 'alpha'
        ) `
        -Actual ('merged={0}; explicit={1}; selected={2}' -f (
            $mergedTokenMatches.Count,
            $explicitPredicateMatches.Count,
            ($explicitPredicateMatches.document -join ',')
        )) `
        -Expected 'merged=0; explicit=1; selected=alpha'

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
    Add-Check -Name 'optional-null-array-count-boundary' `
        -Passed (
            $wrappedNullCount -eq 1 -and $directNullCount -eq 0 -and
            $safeDiagnosticsCount -eq 0
        ) `
        -Actual ('wrapped={0}; direct={1}; safe={2}' -f (
            $wrappedNullCount, $directNullCount, $safeDiagnosticsCount
        )) -Expected 'wrapped=1; direct=0; safe=0'

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
    Add-Check -Name 'interpolation-invariant-culture' `
        -Passed ($interpolatedNumber -eq '1.2') -Actual $interpolatedNumber -Expected '1.2'
    Add-Check -Name 'explicit-tostring-current-culture' `
        -Passed ($toStringNumber -eq '1,2') -Actual $toStringNumber -Expected '1,2 for de-DE'

    Write-Error 'direct status probe' -ErrorAction SilentlyContinue
    $directStatus = $?
    $(Write-Error 'subexpression status probe' -ErrorAction SilentlyContinue)
    $subexpressionStatus = $?
    (Write-Error 'parentheses status probe' -ErrorAction SilentlyContinue)
    $parenthesesStatus = $?
    @(Write-Error 'array-expression status probe' -ErrorAction SilentlyContinue)
    $arrayExpressionStatus = $?
    $legacyStatusResult = [ordered]@{
        direct = $directStatus
        subexpression = $subexpressionStatus
        parentheses = $parenthesesStatus
        arrayExpression = $arrayExpressionStatus
    }
    Add-Check -Name 'legacy-question-mark-expression-reset' `
        -Passed (
            -not $directStatus -and
            $subexpressionStatus -and
            $parenthesesStatus -and
            $arrayExpressionStatus
        ) `
        -Actual ($legacyStatusResult | ConvertTo-Json -Compress) `
        -Expected 'direct false; all three wrappers true in Windows PowerShell 5.1'

    cmd.exe /d /c exit 7
    $nativeExitCode = $LASTEXITCODE
    Add-Check -Name 'native-exit-code' -Passed ($nativeExitCode -eq 7) `
        -Actual $nativeExitCode -Expected 7

    $nativeStderrCaught = $false
    $nativeStderrErrorId = $null
    $nativeStderrItems = @()
    try {
        $nativeStderrItems = @(
            cmd.exe /d /c 'echo native-stderr 1>&2 & exit /b 7' 2>&1
        )
    } catch {
        $nativeStderrCaught = $true
        $nativeStderrErrorId = $_.FullyQualifiedErrorId
    }
    $oldErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $compatibleStderrItems = @(
            cmd.exe /d /c 'echo native-stderr 1>&2 & exit /b 7' 2>&1
        )
        $compatibleStderrExitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldErrorActionPreference
    }
    Add-Check -Name 'merged-native-stderr-error-action' `
        -Passed (
            $nativeStderrCaught -and
            $nativeStderrErrorId -eq 'NativeCommandError' -and
            $nativeStderrItems.Count -eq 0 -and
            $compatibleStderrExitCode -eq 7 -and
            $compatibleStderrItems.Count -eq 1 -and
            $compatibleStderrItems[0] -is [Management.Automation.ErrorRecord]
        ) `
        -Actual ('caught={0}; id={1}; stopped-items={2}; compatible-exit={3}; compatible-items={4}' -f (
            $nativeStderrCaught,
            $nativeStderrErrorId,
            $nativeStderrItems.Count,
            $compatibleStderrExitCode,
            $compatibleStderrItems.Count
        )) `
        -Expected 'caught=True; id=NativeCommandError; stopped-items=0; compatible-exit=7; compatible-items=1'

    $childSource = '$value = 1; $value'
    $childOutput = powershell.exe -NoProfile -Command $childSource
    Add-Check -Name 'literal-child-command-source' -Passed ($childOutput -eq 1) `
        -Actual $childOutput -Expected 1

    $failed = @($checks | Where-Object { -not $_.passed })
    [pscustomobject]@{
        schema = 'mant-pwsh-docs.runtime-smoke/v1'
        runtime = [pscustomobject]@{
            version = $PSVersionTable.PSVersion.ToString()
            edition = $PSVersionTable.PSEdition
            executable = (Get-Process -Id $PID).Path
            osVersion = [Environment]::OSVersion.VersionString
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
            'mant-pwsh51-runtime-',
            [StringComparison]::Ordinal
        )

        if (-not $isExpectedTempPath) {
            throw "Refusing to remove unexpected runtime-test path: $resolvedTestRoot"
        }

        Remove-Item -LiteralPath $resolvedTestRoot -Recurse -Force
    }
}
