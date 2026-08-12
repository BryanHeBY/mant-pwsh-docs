<!-- mant:tldr:start -->
# netcfg.exe

> Inventory Windows network components and bindings before any install, uninstall, or all-adapter cleanup.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/netcfg.

- Resolve the exact native executable and show installed syntax:

`Get-Command netcfg.exe -All -ErrorAction SilentlyContinue | Select-Object Source,@{Name='FileVersionFixed';Expression={$_.FileVersionInfo.FileVersionRaw.ToString()}},@{Name='FileVersionString';Expression={$_.FileVersionInfo.FileVersion}}; netcfg.exe -?`

- List installed network components without changing them:

`netcfg.exe -s n`

- Query whether one exact component ID is installed:

`netcfg.exe -q "{{MS_Server}}"; $LASTEXITCODE`

- Export a binding map to a new protected working directory and inspect the artifact:

`Push-Location -LiteralPath "{{C:\Diagnostics\NetCfg}}"; try { if (Test-Path -LiteralPath '.\NetworkBindingMap.txt') { throw 'Refusing to overwrite NetworkBindingMap.txt' }; netcfg.exe /m; $code = $LASTEXITCODE; Get-Item -LiteralPath '.\NetworkBindingMap.txt' | Select-Object FullName,Length,LastWriteTime; $code } finally { Pop-Location }`
<!-- mant:tldr:end -->

# netcfg.exe

## Overview

`netcfg.exe` manages Windows network components and bindings. Query/list/map
forms can inventory state; `/i`, `/u`, `/winpe`, `/d`, and `/x` install,
uninstall, provision, or broadly clean network devices. `/d` and `/x` require
a reboot and can disrupt every adapter, including the management path.

## Command families

<!-- mant:entries role=command case=insensitive -->
- `netcfg.exe`: Inspect or change Windows network components and bindings.

Query and mutation modes share the same executable; `/d` and `/x` are broad,
connectivity-breaking cleanup operations.

<!-- mant:entries role=option case=insensitive -->
- `-s`, `/s`: List installed components of a selected class/type.
- `-q`, `/q`: Query whether one component ID is installed.
- `-b`, `/b`: Display the binding path containing one component.
- `-m`, `/m`: Write a network binding map in the current directory.
- `-v`, `/v`: Enable verbose information, including with binding-map output.

Component installation and removal require exact published IDs.

<!-- mant:entries role=option case=insensitive -->
- `-l`, `/l`: Select the INF used for component installation.
- `-c`, `/c`: Select the component class.
- `-i`, `/i`: Install one exact component ID from the selected INF.
- `-u`, `/u`: Uninstall one exact component ID.

Provisioning and broad cleanup are separate high-impact modes.

<!-- mant:entries role=option case=insensitive -->
- `-winpe`, `/winpe`: Install the predefined WinPE networking component set.

Full device cleanup is broader than WinPE provisioning.

<!-- mant:entries role=option case=insensitive -->
- `-d`, `/d`: Clean all network devices and require a restart.
- `-x`, `/x`: Clean network devices, skipping those without a physical object.
- `-?`, `/?`: Display installed syntax. Current help prints hyphen spellings,
  while both punctuation forms are accepted on the recorded build.

Use the separate `netcfg.exe -?` form to display installed syntax.

| Family | Forms and boundary |
| --- | --- |
| Read-only inventory | `-s`/`/s`, `-q`/`/q`, and `-b`/`/b` list, test, or display one reviewed component/binding scope. |
| Binding-map artifact | `-m`/`/m` writes `NetworkBindingMap.txt` in the current directory; `-v`/`/v` adds detail. |
| Component install/remove | `-l -c -i` or the slash equivalents install from an optional INF; `-u`/`/u` removes one exact component. |
| WinPE provisioning | `-winpe`/`/winpe` installs the predefined TCP/IP, NetBIOS, and Microsoft Client set. |
| Broad cleanup | `-d`/`/d` and `-x`/`/x` clean network devices and require a restart; the latter skips devices without physical object names. |

## Common mistakes

### Recommending `/d` as a generic network reset

It is not equivalent to flushing DNS or renewing DHCP. It cleans all network
devices, can remove virtual/VPN/filter bindings, requires reboot, and may sever
remote management. Diagnose name, route, address, firewall, proxy, Winsock,
adapter and component layers before choosing the narrow supported repair.

### Using a display name where a component ID is required

Bind `/q`, `/i`, or `/u` to the published/install-time component ID and record
class (`p`, `s`, or `c` where applicable), INF/provider/version and current
binding paths. A friendly adapter or product name is not interchangeable.

### Trusting an INF because installation returned zero

Verify publisher/signature/catalog, architecture, OS compatibility and package
source before installation. Re-query the exact ID and inspect bindings, device
state, events, connectivity and reboot requirements afterward.

### Running cleanup remotely without an out-of-band recovery path

Assume the management NIC, virtual switch, VPN, cluster/storage network and
security filters can be affected. Require console/OOB access, configuration
backup, maintenance window and tested restore/re-enrollment procedures.

### Forgetting that `/m` writes into the current directory

Use a dedicated protected directory, ensure the fixed filename does not exist,
and retain a hash/timestamp. A binding map exposes product and network-stack
details and should not be posted publicly without review.

## PowerShell boundaries

Call `netcfg.exe` explicitly and capture `$LASTEXITCODE` before other commands.
PowerShell's current directory determines `/m` output location. Do not assemble
component IDs or INF paths from untrusted discovery text, and do not mistake
`/q` (query) for PowerShell quiet behavior.

## Version and platform differences

Windows-only. Component IDs, installed filters/protocols, WinPE context and
cleanup behavior vary by build, hardware, hypervisor, VPN/security product and
OEM image. Validate on an equivalent disposable host before mutation.

## Runtime evidence

On Windows NT `10.0.26200.0`, both PowerShell collectors resolved signed
`C:\Windows\System32\netcfg.exe`, fixed file version `10.0.26100.8737` and
collector-selected file-version string `10.0.26100.8875
(WinBuild.160101.0800)`. File identity does not prove a component or binding
operation. Behavior verification remains `/s`, exact `/q`, and one new
protected `/m` artifact only; no INF/component, WinPE, all-device cleanup,
reboot, binding, adapter, or management-path mutation is required merely for
evidence.

## Related documents
- [netsh.exe](netsh.exe.md)
- [ipconfig.exe](ipconfig.exe.md)
- [pnputil.exe](pnputil.exe.md)
- [getmac.exe](getmac.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[netcfg reference](https://learn.microsoft.com/windows-server/administration/windows-commands/netcfg).
The high demand for overly broad “full reset” recipes was cross-checked against
a [Server Fault network-adapter reset discussion](https://serverfault.com/questions/770396/how-to-fully-reset-network-adapter).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Server Fault contributions are licensed under CC BY-SA 4.0.
