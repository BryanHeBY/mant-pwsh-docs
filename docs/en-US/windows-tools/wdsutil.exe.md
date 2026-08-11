<!-- mant:tldr:start -->
# wdsutil.exe

> Inventory an exact Windows Deployment Services server before changing devices, drivers, images, PXE policy, transports, namespaces, or multicast sessions.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/wdsutil.

- Resolve the administrative tool and WDS role state without installing or starting anything:

`Get-Command wdsutil.exe -All -ErrorAction SilentlyContinue | Select-Object Source,@{Name='FileVersion';Expression={$_.FileVersionInfo.FileVersion}}; Get-WindowsFeature -Name WDS* -ErrorAction SilentlyContinue`

- Display installed command help:

`wdsutil.exe /?`

- Inventory configuration on one exact server (never omit `/Server` in remote automation):

`wdsutil.exe /Get-Server /Server:"{{wds01.example.com}}" /Show:Config`

- Inventory image groups, boot/install images, filenames, architectures, metadata, and enabled state:

`wdsutil.exe /Verbose /Get-Server /Server:"{{wds01.example.com}}" /Show:Images /Detailed`
<!-- mant:tldr:end -->

# wdsutil.exe

## Overview

`wdsutil.exe` manages Windows Deployment Services (WDS). Its families cover
server initialization/configuration, AD-prestaged devices, images and groups,
driver packages/groups/filters, pending clients, multicast transmissions,
namespaces and Transport Server lifecycle. Most non-`Get` verbs change a live
deployment control plane and can affect many machines on their next PXE boot.

## Command families and global parameters

<!-- mant:entries role=command case=insensitive -->
- `wdsutil.exe`: Inspect or administer Windows Deployment Services and Transport Server.

WDSUtil expresses its operations as slash options. The global `/Verbose` and
`/Progress` options must immediately follow the executable.

<!-- mant:entries role=option case=insensitive -->
- `/get-server`: Display one WDS server's configuration, images, or combined state.
- `/get-device`: Display one prestaged device selected by stable identity.
- `/get-alldevices`: Enumerate prestaged devices in the selected scope.
- `/get-image`: Display one boot/install/capture/discover image.
- `/get-allimages`: Enumerate images on one WDS server.
- `/get-imagefile`: Inspect metadata and indexes in one image file.
- `/get-imagegroup`: Display one image group's configuration and membership.
- `/get-driverpackage`: Display one driver package by stable ID/name context.
- `/get-alldriverpackages`: Enumerate driver packages on the server.
- `/get-drivergroup`: Display one driver group and its filters/membership.
- `/get-alldrivergroups`: Enumerate driver groups.
- `/get-multicasttransmission`: Display one multicast transmission and clients.
- `/get-allmulticasttransmissions`: Enumerate multicast transmissions.
- `/get-namespace`: Display one Transport Server namespace.
- `/get-allnamespaces`: Enumerate Transport Server namespaces.
- `/get-transportserver`: Display Transport Server configuration.
- `/set-device`: Change a prestaged device's identity or deployment assignments.
- `/set-drivergroup`: Change one driver group's metadata/state.
- `/set-drivergroupfilter`: Change one driver-group applicability filter.
- `/set-driverpackage`: Change one driver package's metadata/state.
- `/set-image`: Change one exact image's metadata, state, filter, or unattend mapping.
- `/set-imagegroup`: Change one image group's metadata or access state.
- `/set-server`: Change broad WDS server/PXE/deployment defaults.
- `/set-transportserver`: Change Transport Server network/multicast settings.
- `/set-multicasttransmission`: Change one transmission's scheduling/client policy.
- `/start-namespace`: Start one exact Transport Server namespace.
- `/start-server`: Start all Windows Deployment Services on the selected server.
- `/start-transportserver`: Start the Transport Server service/surface.
- `/stop-server`: Stop all WDS services and active deployment availability.
- `/stop-transportserver`: Stop Transport Server and affect active namespaces/sessions.
- `/server`: Select the exact WDS server; omission normally means local computer.
- `/show`: Select `Config`, `Images`, or `All` for supported query families.
- `/detailed`: Request extended query output.
- `/verbose`: Enable global verbose output and place it immediately after WDSUtil.
- `/progress`: Enable global progress output and place it immediately after WDSUtil.
- `/skipverify`: Skip supported integrity verification and increase deployment risk.
- `/?`: Display installed top-level or family help.

## Query before change

Use the matching `Get-*` family and bind the exact server/object identity before
any mutation:

- `Get-Server /Show:Config|Images|All [/Detailed]` for PXE/DHCP, response,
  image, unattend, multicast and transport context.
- `Get-Device` or `Get-AllDevices` for AD computer name, UUID/MAC, referral,
  boot program/image, OU, join and unattended-file assignments.
- `Get-Image`, `Get-AllImages`, `Get-ImageFile`, and `Get-ImageGroup` for image
  type, architecture, group, display name, filename, ACL/filter and metadata.
- `Get-DriverPackage*` and `Get-*DriverGroup*` for package identity, contained
  files, filters, applicability, enabled state and group membership.
- `Get-MulticastTransmission`, `Get-AllMulticastTransmissions`, `Get-Namespace`,
  `Get-AllNamespaces`, and `Get-TransportServer` for clients, scheduling,
  endpoints, address/port ranges, throttling and current lifecycle state.

Preserve the full command, server FQDN, collection time and native status.
Broad enumeration can disclose deployment topology, client identifiers,
drivers, image names and unattended configuration paths.

## Set families

### Set-Device

Changes a prestaged AD computer's UUID/MAC association and deployment choices,
including referral server, boot program/image, unattended file, join behavior,
OU and delegated join identity. Re-read the exact computer by both stable
hardware identifier and AD object before and after. A wrong association can
deploy or domain-join the wrong physical machine.

### Set-DriverGroup, Set-DriverGroupFilter, and Set-DriverPackage

These change group name/state/applicability, filter policy/values, and package
metadata/state. Inventory package ID, provider, class, version, architecture,
catalog signature, files, hardware IDs, all group memberships and filter order.
Driver selection is the combined result of every applicable filter and ranking,
not proof that the intended package will win on a client.

### Set-Image and Set-ImageGroup

Bind image type, architecture, group, display name and filename before changing
name, description, enabled state, access/user filter or unattended association.
Names alone are not unique. Hash and service a source copy, validate WIM indexes,
signatures, boot chain, drivers and answer files, then use staged client rings.

### Set-Server

This broad family changes DHCP authorization/rogue detection, answered-client
policy, PXE prompts/programs, architecture discovery, pending-device approval,
client naming/OU/domain join, response delay, logging, TFTP/network profiles,
unattended files, image precedence and other global defaults. Change one
reviewed setting at a time and export before/after configuration.

### Set-TransportServer

Changes IPv4/IPv6 multicast address allocation, port ranges, network profiles,
slow-client policy, thresholds and stream counts. Validate uniqueness, routing,
IGMP/network support, firewall policy, bandwidth and concurrent deployment load;
some documented options are release-specific legacy behavior.

### Set-MulticastTransmission

Changes one transmission's scheduling/AutoCast behavior and client thresholds.
Bind server, transmission/namespace, image and current clients. A policy change
can delay, disconnect, repartition or unexpectedly begin serving many clients.

## Start and stop families

- `Start-Namespace` activates one exact namespace after its content, schedule,
  client set and network path are revalidated.
- `Start-Server` starts all WDS services and can expose PXE, deployment,
  multicast, namespace and transport surfaces.
- `Start-TransportServer` starts the Transport Server role/surface.
- `Stop-Server` stops all WDS services; treat it as a deployment-wide outage.
- `Stop-TransportServer` affects transport namespaces/sessions and clients.

Do not use start/stop as feature detection or a generic repair. Capture active
deployments and clients, notify owners, drain/cancel by an approved procedure,
define recovery and verify actual service/session state afterward.

## Common mistakes

### Omitting `/Server` and changing the local machine

Many WDSUtil commands default to the local server. Always pass the exact FQDN
in automation, confirm role/cluster/management identity, and echo it in change
evidence before executing a non-query verb.

### Trusting the broad Learn applicability banner

Client Windows may carry administration components, but WDS server operations
require the applicable server role and rights. Some per-option notes still
refer only to Windows Server 2008/2008 R2. Installed help and the target build's
supported workflow outrank a generic page header.

### Using installation-media `boot.wim` for current WDS-only deployment

Microsoft blocks WDS-only Windows 11 and Windows Server 2025 deployment through
installation-media `boot.wim`; Server 2022 use is deprecated. Custom PXE boot
images remain a distinct scenario. Do not “fix” the expected media-driver or
deprecation error with random drivers or older unsupported image combinations.

### Re-enabling insecure hands-free deployment after April 2026

An answer file can include credentials and was exposed over unauthenticated RPC.
After the April 14, 2026 security update, native hands-free WDS deployment is
securely disabled by default and unsupported. Do not set the documented insecure
override merely to restore an old workflow; migrate and review the WDS diagnostic
events and all secrets previously placed in `RemoteInstall`.

### Treating `/SkipVerify`, a signature, or import success as image trust

Do not skip integrity verification. A validly signed driver/image can still be
wrong, vulnerable or incompatible. Verify hashes, provenance, servicing level,
architecture, WIM index, Secure Boot/revocation state, malware scan, storage
space and a complete disposable PXE boot/deployment before promotion.

### Identifying a device by a copied MAC address alone

MACs can be duplicated, changed, virtualized or confused with a UUID's firmware
byte order. Correlate firmware UUID, all NIC MACs, asset/serial, AD object,
pending request and physical owner before prestaging, approving or retargeting.

### Assuming a `Set-*` success changed an in-progress client

Clients may already hold boot files, cached policy or a multicast session.
Re-query the object and server, inspect WDS events/current clients, and test a
new approved boot. Never restart all WDS services just to force propagation.

### Putting `/Verbose` or `/Progress` in the wrong position

Microsoft requires global options directly after `wdsutil`. Preserve parser
order, quote values containing spaces, and use installed help for the exact
subcommand instead of normalizing WDS syntax like PowerShell parameters.

## PowerShell boundaries

Call `wdsutil.exe` explicitly and capture `$LASTEXITCODE` immediately. Output
is localized human text, not a stable object model; prefer the WDS PowerShell
module for typed automation where it exposes the required operation, while
still preserving exact identities and before/after evidence. Never construct
image, device, server, SDDL, path or answer-file arguments from untrusted text.

## Version and platform differences

Windows-only and role/tool dependent. WDS PXE with custom images, native WDS
operating-system deployment, Transport Server and Configuration Manager use of
WDS are different support boundaries. Recheck Microsoft's current support and
security guidance for every target/server/image combination.

## Related documents

- [dism.exe](dism.exe.md)
- [pnputil.exe](pnputil.exe.md)
- [pnpunattend.exe](pnpunattend.exe.md)
- [netcfg.exe](netcfg.exe.md)

## Sources and license

This original family guide was adapted from Microsoft's official
[WDSUtil command index](https://learn.microsoft.com/windows-server/administration/windows-commands/wdsutil),
the linked `Get`, `Set`, `Start`, and `Stop` subcommand references,
[current WDS boot.wim support matrix](https://learn.microsoft.com/windows/deployment/wds-boot-support),
and [CVE-2026-0386 hands-free deployment hardening guidance](https://support.microsoft.com/servicing/os/windows/2025/12/windows-deployment-services-wds-hands-free-deployment-hardening-guidance-related-to-cve-2026-0386).
Early operational demand around the Windows 11 boundary was cross-checked
against a [Microsoft Q&A deployment report](https://learn.microsoft.com/questions/536587/windows-11-deployment-via-wds).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft Learn command documentation and this adaptation are licensed
under CC BY 4.0. Microsoft Support and Q&A content are governed by Microsoft
Web Terms.
