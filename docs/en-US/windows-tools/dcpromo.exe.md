<!-- mant:tldr:start -->
# dcpromo.exe

> Treat Dcpromo as legacy compatibility syntax: inventory the AD DS role,
> modern deployment cmdlets, DC topology, and health before any promotion or
> demotion workflow.
> More information: https://learn.microsoft.com/windows-server/identity/ad-ds/deploy/troubleshooting-domain-controller-deployment.

- Check whether the legacy executable exists and display operation-specific help only:

`$cmd = Get-Command dcpromo.exe -ErrorAction Stop; & $cmd.Source '/?:Promotion'`

- Discover the supported ADDSDeployment installation and removal cmdlets on this Server build:

`Get-Command -Module ADDSDeployment -Name 'Install-ADDS*','Uninstall-ADDS*','Test-ADDS*' | Sort-Object Name | Select-Object Name, Version, Source`

- Inventory existing domain controllers and their roles/sites without changing them:

`Get-ADDomainController -Filter * -Server "{{example.com}}" | Select-Object HostName, Site, IsGlobalCatalog, IsReadOnly, OperationMasterRoles`

- Run focused health inventory against one intended replication partner:

`dcdiag.exe /s:"{{dc01.example.com}}" /test:Connectivity /v; repadmin.exe /showrepl "{{dc01.example.com}}" /all /verbose`

<!-- mant:tldr:end -->

# dcpromo.exe

## Overview

`dcpromo.exe` is the historical command for AD DS promotion, demotion, RODC
account attachment, install-from-media, and binary removal. Microsoft deprecated
unattended Dcpromo beginning with Windows Server 2012 in favor of Server Manager
and the ADDSDeployment PowerShell module, which add prerequisite checks and
typed parameters. The current command reference remains useful for legacy
systems and answer-file forensics; it is not a recommendation for new automation.

Promotion/demotion changes forest/domain topology, DNS, SYSVOL, replication,
machine identity, services, credentials, FSMO/GC placement, and reboot state.
Use a target-version, role-specific Microsoft deployment procedure.

## Legacy modes and parameters

<!-- mant:entries role=command case=insensitive -->
- `dcpromo.exe`: Run a legacy AD DS promotion, demotion, staged RODC, IFM, or
  binary-removal workflow on Windows versions that support it.

The historical property surface is extensive and topology-dependent. Prefer
the matching `Test-ADDS*`, `Install-ADDS*`, or `Uninstall-ADDS*` cmdlet today.

<!-- mant:entries role=option case=insensitive -->
- `/answer`: Read legacy promotion/demotion properties from an answer file.
- `/unattend`: Run the selected legacy operation without the wizard.
- `/adv`: Enable advanced install-from-media promotion options.
- `/createdcaccount`: Precreate the AD account used by a staged RODC deployment.
- `/useexistingaccount`: Attach to a precreated RODC account where supported.
- `/uninstallbinaries`: Remove AD DS role binaries after a valid lifecycle decision.
- `/forceremoval`: Force demotion when ordinary communication fails, leaving
  cleanup and credential consequences for a separate recovery procedure.
- `/forceremovalconfirm`: Confirm forced-removal behavior in supported legacy syntax.
- `/replicationSourceDC`: Select an explicit source DC for promotion.
- `/replicationSourcePath`: Select reviewed install-from-media content.
- `/safemodeadminpassword`: Supply the DSRM password; never place it in CLI history.
- `/administratorpassword`: Supply a post-demotion local password; avoid CLI exposure.
- `/rebootonsuccess`: Control restart after a successful legacy operation.
- `/rebootoncompletion`: Control restart after the selected legacy operation completes.
- `/?`: Display top-level or operation-specific installed legacy help.

## Operation map

- `/answer` and `/unattend` consume an answer file; command-line property forms
  can expose credentials and are difficult to review safely.
- `/adv` selects install from media (IFM); media age, source DC, naming contexts,
  integrity, custody, and remaining network replication all matter.
- `/CreateDCAccount` and `/UseExistingAccount:Attach` participate in staged RODC
  deployment with delegated roles and exact precreated identity.
- promotion parameters can create a forest/domain/DC, install DNS/GC, select
  sites/paths/replication source, set functional levels, and reboot.
- demotion parameters can transfer/retain roles, remove DNS/delegation, force
  removal, set the local Administrator password, and delete application data.
- `/UninstallBinaries` removes AD DS binaries; it is not equivalent to a healthy
  demotion and must not orphan directory metadata.

## Common mistakes

### Copying plaintext passwords from official or community examples

Historical examples place DSRM, domain, or local Administrator passwords in the
command or answer file. Never do this. Use `SecureString`/credential parameters
through the supported deployment module, approved secret handling, protected
transcripts/logs, and immediate incident handling if a secret enters history or
source control.

### Treating promotion as “install one role”

Verify forest/domain design, DNS namespace/delegation, sites/subnets, time,
functional levels, schema preparation, FSMO/GC/RODC placement, replication
partners, SYSVOL technology, database/log/SYSVOL volumes, backup, and recovery.
Role-binary presence does not prove the server is safe to promote.

### Skipping prerequisite checks

The ADDSDeployment module performs prerequisite validation that legacy
unattended Dcpromo does not provide equivalently. Do not use `-SkipPreChecks`,
force flags, or Dcpromo merely to bypass a blocking result. Preserve full error
and deployment logs, correct the cause, and rerun the supported test cmdlet.

### Forcing demotion to solve a connectivity problem

Forced removal can leave metadata, DNS records, SYSVOL/DFSR membership, FSMO
roles, trusts, certificates, clients, and application dependencies behind.
Establish whether the DC is permanently unrecoverable, transfer/seize roles as
appropriate, preserve system-state evidence, and follow metadata-cleanup and
credential-reset procedures after authorization.

### Reusing stale IFM or an existing RODC account

Bind media/account to the intended forest, domain, DC name, source, date,
backup generation, site, delegated operator, and current replication state.
Validate integrity and confidentiality; IFM does not eliminate required online
replication or make stale directory data authoritative.

### Interpreting process exit without reboot and postchecks

Some successful deployment codes require reboot or report noncritical warnings.
After restart, verify directory service, DNS registration, SYSVOL/NETLOGON,
replication for every naming context, GC/RODC/FSMO expectations, event logs,
time, backup, and client location/authentication. Do not declare success from a
single exit code.

## PowerShell boundaries

For supported Server releases, use the explicit `Test-ADDS*`, `Install-ADDS*`,
or `Uninstall-ADDSDomainController` command selected for the topology. Inspect
`Get-Help -Full` for that installed module and keep `-WhatIf` separate from
actual prerequisite tests. Never construct a legacy Dcpromo command through
string concatenation or log secret-bearing arguments.

## Version and platform differences

Dcpromo is Windows Server legacy tooling. GUI, unattended behavior, role-binary
installation, available parameters, functional-level values, and inclusion vary
by Server release. Current Learn applicability banners do not erase Microsoft's
deprecation/migration guidance. Use ADDSDeployment for supported modern
automation and preserve Dcpromo only where the exact legacy platform requires it.

## Runtime evidence

On Windows NT `10.0.26200.0`, the catalog identity audit found no
`dcpromo.exe` Application candidate under either PowerShell collector. No
feature, role, or compatibility component was installed merely to change
that result, and no same-named PATH substitute was used. This is target-host
command-resolution evidence, not proof that the tool is unsupported on every
applicable Windows environment.

Behavior verification remains legacy help, modern module/cmdlet
discovery, existing-DC inventory and exact-partner health queries only; no
promotion, demotion, forced removal, role binary, RODC, IFM, answer-file,
credential or reboot operation is permitted merely for evidence.

## Related documents
- [adprep.exe](adprep.exe.md)
- [dcdiag.exe](dcdiag.exe.md)
- [repadmin.exe](repadmin.exe.md)
- [nltest.exe](nltest.exe.md)
- [netdom.exe](netdom.exe.md)

## Sources and license

This original guide was adapted from Microsoft's current
[Dcpromo command reference](https://learn.microsoft.com/windows-server/administration/windows-commands/dcpromo),
the migration guidance in
[new-forest deployment documentation](https://learn.microsoft.com/windows-server/identity/ad-ds/deploy/install-a-new-windows-server-2012-active-directory-forest--level-200-),
current
[domain-controller deployment troubleshooting](https://learn.microsoft.com/windows-server/identity/ad-ds/deploy/troubleshooting-domain-controller-deployment),
and the
[Install-ADDSForest reference](https://learn.microsoft.com/powershell/module/addsdeployment/install-addsforest?view=windowsserver2025-ps).
Prerequisite/replication failures were cross-checked against a practitioner
[promotion failure report](https://serverfault.com/questions/758812/), used as a
demand signal rather than a cleanup recipe. Microsoft documentation and the
target module's help govern behavior. Exact sources and licenses are recorded in
`upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Server Fault contributions are licensed under CC BY-SA 4.0.
