<!-- mant:tldr:start -->
# adprep.exe

> Verify the exact Windows Server installation-media binary, FSMO owner, and
> current schema state before any forest, domain, GPO, or RODC preparation;
> every preparation mode changes Active Directory.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/adprep.

- Inspect the exact Adprep binary from the target Windows Server installation media:

`Get-Item -LiteralPath "{{D:\support\adprep\adprep.exe}}" | Select-Object FullName, Length, @{Name='ProductVersion';Expression={$_.VersionInfo.ProductVersion}}`

- Verify Microsoft's signature on that exact binary before running even its help:

`Get-AuthenticodeSignature -LiteralPath "{{D:\support\adprep\adprep.exe}}" | Select-Object Status, StatusMessage, SignerCertificate`

- Identify the Schema Master and Infrastructure Master for one exact domain:

`netdom.exe query /domain:"{{example.com}}" FSMO`

- Read the schema object version from one exact DC without changing it:

`$root = Get-ADRootDSE -Server "{{dc01.example.com}}"; Get-ADObject -Server "{{dc01.example.com}}" -Identity $root.SchemaNamingContext -Properties objectVersion | Select-Object DistinguishedName, objectVersion`

<!-- mant:tldr:end -->

# adprep.exe

## Overview

`adprep.exe` extends the Active Directory schema and changes directory
permissions to prepare an existing forest/domain for a newer Windows Server
domain controller or an RODC. Use the binary included with the exact target
Windows Server installation media, from an elevated shell. Do not substitute a
copy from an arbitrary DC, download, PATH entry, or older media.

There is no read-only Adprep preparation mode. The TLDR therefore establishes
binary provenance, FSMO placement, and schema state rather than running a
change. The DC deployment workflow can run required preparation automatically;
manual Adprep should be an explicit design decision, not a ritual prerequisite.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `adprep.exe`: Prepare an existing AD forest/domain with the schema and
  permissions required by the exact Windows Server installation media.

Every operational mode changes Active Directory. `/wssg` only expands result
codes, and `/silent` only suppresses output.

<!-- mant:entries role=option case=insensitive -->
- `/forestprep`: Extend the schema and forest-wide configuration on the Schema Master.
- `/domainprep`: Prepare the current domain on its Infrastructure Master.
- `/gpprep`: With `/domainprep`, update permissions needed for RSoP planning.
- `/rodcprep`: Prepare application-directory-partition permissions for RODCs.
- `/wssg`: Return expanded status codes intended for scripted setup integration.
- `/silent`: Suppress output and require `/wssg`; it does not suppress changes.
- `/?`: Display syntax from the exact installation-media binary.

## Operation map

- `/forestprep` updates the schema and forest; run it once on the Schema Master
  with Enterprise Admins, Schema Admins, and the forest-root Domain Admins.
- `/domainprep` updates one domain after forest preparation has replicated; run
  it on that domain's Infrastructure Master with Domain Admin rights.
- `/domainprep /gpprep` also updates permissions needed for RSoP planning and
  can create substantial AD/SYSVOL GPO replication traffic.
- `/rodcprep` updates application-partition permissions across the forest and
  contacts each domain's Infrastructure Master.
- `/wssg` returns expanded exit codes. `/silent` suppresses output and is valid
  only with `/wssg`; neither makes the change safer.

## Common mistakes

### Running a binary that does not match the target Server release

The newer DC's installation media is the source of the required schema update.
Record media release/build, file version, signature, hash, architecture, source
path, and target DC release. Do not infer correctness from the filename alone.

### Running on the wrong FSMO owner

`/forestprep` requires the reachable Schema Master; domain preparation requires
the domain's Infrastructure Master. Resolve FSMO holders, DNS, time, RPC/LDAP,
site/link state, and replication health immediately before the approved window.
Do not seize or move a role merely to make Adprep start without a separate FSMO
recovery decision.

### Treating “already done” as generic success

Expanded exit codes distinguish conflicts, FSMO, connection, permission,
schema, busy, and already-prepared states. Preserve `$LASTEXITCODE`, console
output, and `%SystemRoot%\debug\adprep\<timestamp>` logs. Verify the expected
object versions and update containers on multiple DCs after replication; do not
collapse every nonzero code to “failed” or every message to “complete.”

### Starting domain preparation before forest convergence

Microsoft requires forest preparation to finish and replicate before domain
preparation. Confirm every relevant naming context, partner, last-success time,
and schema version on all required sites. A successful command on the Schema
Master is not evidence that remote DCs have converged.

### Underestimating `/gpprep` and `/rodcprep` scope

GPO ACL changes can produce AD and SYSVOL traffic; RODC preparation remotely
contacts Infrastructure Masters and changes application-partition permissions.
Inventory domains, partitions, offline DCs, constrained links, backups, change
owners, and monitoring before choosing either operation.

### Retrying blindly after a partial failure

Adprep is designed to tolerate some reruns, but a retry does not fix DNS,
replication, schema conflicts, missing privileges, or unavailable FSMO roles.
Preserve logs and directory state, identify the exact completed update, correct
the cause, and follow the target-version Microsoft deployment procedure.

## PowerShell boundaries

Invoke the exact media path with `&`, not bare `adprep`. Capture all streams and
`$LASTEXITCODE` without putting credentials in the command. Output/log text is
not a stable object contract. Prefer AD cmdlets for typed pre/post inventory,
but do not mistake inventory cmdlets for proof that every DC has converged.

## Version and platform differences

Adprep is Windows Server media tooling. Architecture, schema version, update
steps, privileges, automated deployment behavior, logs, and exit codes vary by
source/target Server release and forest state. Use current target-version
deployment guidance and the binary's local help; never project an older upgrade
procedure onto a newer forest.

## Related documents

- [dcpromo.exe](dcpromo.exe.md)
- [repadmin.exe](repadmin.exe.md)
- [dcdiag.exe](dcdiag.exe.md)
- [netdom.exe](netdom.exe.md)
- [gpfixup.exe](gpfixup.exe.md)

## Sources and license

This original guide was adapted from Microsoft's current
[Adprep reference](https://learn.microsoft.com/windows-server/administration/windows-commands/adprep)
and
[domain-controller deployment troubleshooting](https://learn.microsoft.com/windows-server/identity/ad-ds/deploy/troubleshooting-domain-controller-deployment).
FSMO, privilege, and log failures were cross-checked against a practitioner
[Adprep failure report](https://serverfault.com/questions/1090562/). Microsoft
documentation and the exact installation-media help govern behavior. Exact
sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Server Fault contributions are licensed under CC BY-SA 4.0.
