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

if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'This smoke test requires Windows.'
}

$initialSecurityModule = @(Get-Module Microsoft.PowerShell.Security)
$initialProviders = @(Get-PSProvider)
$coreProviderNames = @(
    'Alias', 'Environment', 'FileSystem', 'Function', 'Registry', 'Variable'
)
$missingCoreProviders = @(
    $coreProviderNames | Where-Object {
        $_ -notin @($initialProviders.Name)
    }
)
Add-Check -Name 'providers:initial-core-set' `
    -Passed ($missingCoreProviders.Count -eq 0) `
    -Actual "providers=$($initialProviders.Count); missing=$($missingCoreProviders -join ',')" `
    -Expected 'Alias, Environment, FileSystem, Function, Registry, and Variable present'
Add-Check -Name 'provider:certificate-not-yet-loaded' `
    -Passed ($initialSecurityModule.Count -eq 0 -and
        @($initialProviders | Where-Object Name -eq 'Certificate').Count -eq 0) `
    -Actual "security-module=$($initialSecurityModule.Count); certificate-provider=$(@($initialProviders | Where-Object Name -eq 'Certificate').Count)" `
    -Expected 'fresh -NoProfile session has not yet loaded Microsoft.PowerShell.Security'

$drives = @(Get-PSDrive)
$providersAfterDriveDiscovery = @(Get-PSProvider)
$certificateDrives = @($drives | Where-Object Name -eq 'Cert')
$certificateProviders = @(
    $providersAfterDriveDiscovery | Where-Object Name -eq 'Certificate'
)
$securityModuleAfterDriveDiscovery = @(Get-Module Microsoft.PowerShell.Security)
Add-Check -Name 'provider:certificate-autoload-via-drive-discovery' `
    -Passed ($certificateDrives.Count -eq 1 -and
        $certificateProviders.Count -eq 1 -and
        $securityModuleAfterDriveDiscovery.Count -eq 1) `
    -Actual "cert-drives=$($certificateDrives.Count); certificate-providers=$($certificateProviders.Count); security-modules=$($securityModuleAfterDriveDiscovery.Count)" `
    -Expected 'Get-PSDrive exposes Cert and loads one Certificate provider/module'

$itemCases = @(
    [pscustomobject]@{
        label = 'filesystem'
        path = $env:SystemRoot
        type = 'System.IO.DirectoryInfo'
        provider = 'FileSystem'
    }
    [pscustomobject]@{
        label = 'alias'
        path = 'Alias:gci'
        type = 'System.Management.Automation.AliasInfo'
        provider = 'Alias'
    }
    [pscustomobject]@{
        label = 'environment'
        path = 'Env:ComSpec'
        type = 'System.Collections.DictionaryEntry'
        provider = 'Environment'
    }
    [pscustomobject]@{
        label = 'function'
        path = 'Function:prompt'
        type = 'System.Management.Automation.FunctionInfo'
        provider = 'Function'
    }
    [pscustomobject]@{
        label = 'variable'
        path = 'Variable:PSVersionTable'
        type = 'System.Management.Automation.PSVariable'
        provider = 'Variable'
    }
    [pscustomobject]@{
        label = 'registry'
        path = 'HKLM:\SOFTWARE'
        type = 'Microsoft.Win32.RegistryKey'
        provider = 'Registry'
    }
    [pscustomobject]@{
        label = 'certificate'
        path = 'Cert:\CurrentUser'
        type = 'Microsoft.PowerShell.Commands.X509StoreLocation'
        provider = 'Certificate'
    }
)

foreach ($case in $itemCases) {
    $item = Get-Item -LiteralPath $case.path -ErrorAction SilentlyContinue
    $actualType = if ($null -ne $item) { $item.GetType().FullName } else { $null }
    $actualProvider = if ($null -ne $item) { $item.PSProvider.Name } else { $null }
    Add-Check -Name ('item-type:' + $case.label) `
        -Passed ($null -ne $item -and $actualType -eq $case.type -and
            $actualProvider -eq $case.provider) `
        -Actual "present=$($null -ne $item); type=$actualType; provider=$actualProvider; value-emitted=false" `
        -Expected "type=$($case.type); provider=$($case.provider)"
}

$filesystemParameters = @(
    (Get-Command Get-ChildItem -ArgumentList $env:SystemRoot).Parameters.Keys
)
$registryParameters = @(
    (Get-Command Get-ChildItem -ArgumentList 'HKLM:\').Parameters.Keys
)
$certificateParameters = @(
    (Get-Command Get-ChildItem -ArgumentList 'Cert:\').Parameters.Keys
)
$filesystemDynamic = @('Attributes', 'Directory', 'File', 'Hidden', 'ReadOnly', 'System')
Add-Check -Name 'dynamic-parameters:filesystem' `
    -Passed (@($filesystemDynamic | Where-Object {
        $_ -notin $filesystemParameters
    }).Count -eq 0) `
    -Actual "present=$(@($filesystemDynamic | Where-Object { $_ -in $filesystemParameters }).Count); names-emitted=false" `
    -Expected 'all six selected FileSystem-only parameters present'
Add-Check -Name 'dynamic-parameters:registry-excludes-filesystem-set' `
    -Passed (@($filesystemDynamic | Where-Object {
        $_ -in $registryParameters
    }).Count -eq 0) `
    -Actual "filesystem-parameter-overlap=$(@($filesystemDynamic | Where-Object { $_ -in $registryParameters }).Count)" `
    -Expected 0
Add-Check -Name 'dynamic-parameters:certificate-code-signing' `
    -Passed ($certificateParameters -contains 'CodeSigningCert') `
    -Actual "CodeSigningCert=$($certificateParameters -contains 'CodeSigningCert')" `
    -Expected $true

$providerHelp = Get-Help Get-ChildItem -Path 'Cert:\' -ErrorAction SilentlyContinue
Add-Check -Name 'help:get-childitem-certificate-path' `
    -Passed ($null -ne $providerHelp -and
        $providerHelp.Name -eq 'Get-ChildItem' -and
        -not [string]::IsNullOrWhiteSpace([string]$providerHelp.Synopsis)) `
    -Actual $(if ($null -ne $providerHelp) {
        "name=$($providerHelp.Name); synopsis-present=$(-not [string]::IsNullOrWhiteSpace([string]$providerHelp.Synopsis))"
    } else { 'help-result=null' }) `
    -Expected 'Get-ChildItem help with a nonempty provider-customized synopsis'

$failed = @($checks | Where-Object { -not $_.passed })
[pscustomobject]@{
    schema = 'mant-pwsh-docs.powershell-provider-readonly-smoke/v1'
    runtime = [pscustomobject]@{
        version = $PSVersionTable.PSVersion.ToString()
        edition = $PSVersionTable.PSEdition
        osVersion = [Environment]::OSVersion.VersionString
    }
    safety = [pscustomobject]@{
        noProfile = $true
        writes = 0
        providerMutations = 0
        network = 0
        emittedEnvironmentValues = 0
        emittedRegistryData = 0
        emittedCertificates = 0
        emittedUserPaths = 0
    }
    summary = [pscustomobject]@{
        total = $checks.Count
        passed = $checks.Count - $failed.Count
        failed = $failed.Count
    }
    checks = $checks
} | ConvertTo-Json -Depth 6

if ($failed.Count -ne 0) { exit 1 }
