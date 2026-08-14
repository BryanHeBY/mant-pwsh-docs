<!-- mant:tldr:start -->
# wsb.exe

> Create and control Windows Sandbox sessions on Windows 11 24H2 and later.
> More information: https://learn.microsoft.com/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-cli.

- Start a default sandbox and return machine-readable output:

`wsb.exe start --raw`

- List the current user's sandbox sessions:

`wsb.exe list --raw`

- Inspect whether the Windows Sandbox optional feature is enabled:

`Get-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM`

- Stop one exact sandbox after preserving required artifacts:

`wsb.exe stop --id {{sandbox-id}}`
<!-- mant:tldr:end -->

# wsb.exe

## Overview

Starting with Windows 11 version 24H2, the Windows Sandbox CLI (`wsb.exe`)
creates, lists, connects to, executes inside, shares folders with, and stops
sandbox sessions. It returns a sandbox ID used by later commands. The CLI is
distinct from launching a `.wsb` configuration file through its shell
association.

Sandbox uses hypervisor isolation, but host integrations are security
boundaries: networking and clipboard redirection are enabled by default, vGPU
is normally enabled on non-Arm64, and a writable shared folder persists sandbox
changes onto the host.

## Install and verify the optional feature

Do not infer installation from the Windows edition or the presence of Hyper-V.
Windows Sandbox uses the exact optional-feature identity
`Containers-DisposableClientVM`. Inspect it before looking for the application
or CLI:

```powershell
$featureName = 'Containers-DisposableClientVM'
$feature = Get-WindowsOptionalFeature -Online -FeatureName $featureName
$feature | Select-Object FeatureName, State
```

Enable the feature only from an approved elevated PowerShell session. Preserve
an existing pending-restart condition instead of stacking an unexplained
servicing change, and use `-NoRestart` so the caller controls when open work is
closed:

```powershell
$featureName = 'Containers-DisposableClientVM'
$result = Enable-WindowsOptionalFeature `
    -Online `
    -FeatureName $featureName `
    -All `
    -NoRestart `
    -ErrorAction Stop

$result | Select-Object FeatureName, State, RestartNeeded
```

`-Online` changes the running Windows installation, `-All` enables required
parent features, and `-NoRestart` suppresses an automatic restart without
removing the restart requirement. Save work and restart deliberately when the
result or servicing state requires it. After restart, verify feature state and
discover each application entry point independently:

```powershell
$feature = Get-WindowsOptionalFeature `
    -Online `
    -FeatureName Containers-DisposableClientVM

if ($feature.State -ne 'Enabled') {
    throw "Windows Sandbox feature state is $($feature.State)."
}

Get-Command WindowsSandbox.exe, wsb.exe -ErrorAction SilentlyContinue
Get-AppxPackage -Name WindowsSandbox |
    Select-Object Name, Version, Status
```

On Windows 11 24H2 and later, the newer Store-serviced Sandbox application
supplies the modern `wsb.exe` CLI. Feature enablement and CLI availability are
therefore separate observations: an enabled feature with no `wsb.exe` can
require the application update rather than another feature-enable operation.
Use the equivalent elevated DISM workflow in [dism.exe](dism.exe.md) when a
native servicing command is required.

## Syntax

```text
wsb.exe <start|list|exec|stop|share|connect|ip> [options]
```

## Commands

<!-- mant:entries role=command case=insensitive -->
- `start`: Create and launch a sandbox, returning its unique sandbox ID.
- `list`: List the current user's sandbox sessions, IDs, running/stopped state, and uptime.
- `exec`: Execute one command in a sandbox as `System` or the active logged-on sandbox user.
- `stop`: Terminate one sandbox, close its desktop, release resources, and discard non-shared state.
- `share`: Map one host directory into a running sandbox, read-only unless write access is explicitly allowed.
- `connect`: Open an interactive Remote Desktop window to one sandbox.
- `ip`: Display one sandbox's IP address.

## Common and start options

<!-- mant:entries role=option case=sensitive -->
- `--raw`: Format command output as JSON for machine processing.
- `-?`, `-h`, `--help`: Display command or subcommand help.
- `--id ID`: Select or assign the sandbox ID where the subcommand supports it.
- `--config CONFIG`: For `start`, pass the complete `<Configuration>...</Configuration>` XML as one argument.

`start` also accepts the short spelling `-c`. The same spelling means
`--command` under `exec`, so ManT registers the unambiguous long names and keeps
the contextual short spelling in searchable prose.

Prefer `--raw` for automation and capture the exact returned ID rather than
scraping the display table:

```powershell
$started = wsb.exe start --raw
if ($LASTEXITCODE -ne 0) { throw "Sandbox start failed: $LASTEXITCODE" }
$session = $started | ConvertFrom-Json
$session
```

Validate the actual JSON field names emitted by the target build before using
them in scripts; do not assume the ID is a bare stdout string when `--raw` is
selected.

## Exec options and behavior

<!-- mant:entries role=option case=sensitive -->
- `--command COMMAND`: Execute the supplied command line inside the selected sandbox; its `exec`-context short spelling is `-c`.
- `-r CONTEXT`, `--run-as CONTEXT`: Run as `ExistingLogin` or `System`; this option is required by the documented `exec` interface.
- `-d DIRECTORY`, `--working-directory DIRECTORY`: Set the working directory inside the sandbox.

`exec` currently has no process I/O transport: it returns an exit code but not
the command's stdout/stderr. `ExistingLogin` requires an active sandbox user
session, normally established with `connect`; otherwise it fails. `System`
runs with high privilege inside the sandbox and should not be used as default.

For results, write to a sandbox file and deliberately copy/export only the
reviewed artifact. Do not make a writable host share the automatic output path
for untrusted code.

## Share options and host boundary

<!-- mant:entries role=option case=sensitive -->
- `-f DIRECTORY`, `--host-path DIRECTORY`: Select an existing host directory to expose.
- `-s DIRECTORY`, `--sandbox-path DIRECTORY`: Select or create its path inside the sandbox.
- `-w`, `--allow-write`: Allow the sandbox to modify the mapped host directory; omit for read-only sharing.

Use a dedicated staging directory containing only copied inputs, default to
read-only, and never share a source checkout, profile, credential store,
Downloads folder, SSH directory, package cache, or broad drive root. Treat
files returned from a sandbox as untrusted even when the session ran cleanly.

## Connect, IP, and stop

`connect --id ID` opens GUI/RDP state and can block or outlive a PowerShell
launcher. `ip --id ID` exposes an ephemeral address, not a durable session
identity. `stop --id ID` destroys non-shared state; export required evidence
first and verify that the exact ID belongs to the intended current-user session.

## `.wsb` configuration elements

A `.wsb` file is XML rooted at `<Configuration>`. It can be launched through
its file association, or its complete XML can be passed to `wsb start --config`.
Prefer a version-controlled local file for complex configuration rather than
embedding multiline XML in a command line.

### vGPU

`<vGPU>Enable|Disable|Default</vGPU>` controls GPU sharing. Disable it to reduce
attack surface when accelerated rendering is unnecessary.

### Networking

`<Networking>Enable|Disable|Default</Networking>` controls the virtual network.
Default enables networking through the Hyper-V switch and can expose an
untrusted application to the host's internal network.

### MappedFolders

Each `<MappedFolder>` contains existing absolute `<HostFolder>`, optional
absolute `<SandboxFolder>`, and `<ReadOnly>true|false</ReadOnly>`. Environment
variables in paths are supported starting with Windows 11 23H2. Default write
access is false only when `ReadOnly` is explicitly true; set it explicitly.

### LogonCommand

`<LogonCommand><Command>...</Command></LogonCommand>` runs once after sandbox
logon as the sandbox container administrator. Put complex steps in a reviewed
script delivered through a read-only mapped folder.

### AudioInput and VideoInput

`AudioInput` and `VideoInput` accept `Enable`, `Disable`, or `Default`. Audio
input defaults enabled; video input defaults disabled. Disable both for
untrusted workloads that do not require host sensors.

### ProtectedClient

`ProtectedClient` accepts `Enable`, `Disable`, or `Default`. Enable adds an
AppContainer-isolated RDP client boundary but can restrict clipboard/file
transfer. Current default is disabled.

### PrinterRedirection and ClipboardRedirection

Both accept `Enable`, `Disable`, or `Default`. Printer redirection defaults
disabled; clipboard redirection defaults enabled and can transfer text/files
in both directions. Disable clipboard for untrusted content.

### MemoryInMB

`<MemoryInMB>NUMBER</MemoryInMB>` requests memory in MB. A value too small to
boot is raised to the current minimum, documented as 2048 MB.

## Safer untrusted-file profile

Use no network, no clipboard/devices, no writable share, and one read-only
staging folder. Review the exact host path before launch:

```xml
<Configuration>
  <Networking>Disable</Networking>
  <vGPU>Disable</vGPU>
  <AudioInput>Disable</AudioInput>
  <VideoInput>Disable</VideoInput>
  <PrinterRedirection>Disable</PrinterRedirection>
  <ClipboardRedirection>Disable</ClipboardRedirection>
  <ProtectedClient>Enable</ProtectedClient>
  <MappedFolders>
    <MappedFolder>
      <HostFolder>C:\SandboxInput</HostFolder>
      <SandboxFolder>C:\Input</SandboxFolder>
      <ReadOnly>true</ReadOnly>
    </MappedFolder>
  </MappedFolders>
</Configuration>
```

Isolation reduces risk but is not a guarantee against vulnerabilities. Keep
Windows patched, avoid host secrets, and use a stronger disposable VM or
detonation service when threat/risk requires it.

## PowerShell considerations

Use `--raw` and `ConvertFrom-Json` only after checking `$LASTEXITCODE`. Paths,
XML, and nested command lines must each be passed as one native argument. Avoid
constructing `--command` or `--config` from untrusted text. GUI connect/file-
association launch lifetime is not represented by ordinary pipeline completion.

## Common mistakes

### Assuming default Sandbox has no network or host data channel

Networking and clipboard are enabled by default. Disable them explicitly and
map only a read-only staging folder.

### Using `--allow-write` for convenient output

Untrusted code can modify, encrypt, replace, or plant executable host files.
Export a narrow reviewed artifact through a controlled process instead.

### Expecting output from `wsb exec`

The current interface returns process status but has no stdout/stderr transport.
Design an explicit artifact/result channel and authenticate what crosses it.

### Stopping the wrong ephemeral session

List current-user sessions, match the exact ID returned by `start`, and retain
it as immutable workflow state; never select by table order or IP address.

### Treating feature state and CLI availability as the same check

The Windows optional feature, GUI application, Store-serviced application
version, and `wsb.exe` command can have different states. Query the exact
feature, application package, and command separately before diagnosing or
repeating an installation.

## Version and availability

Windows Sandbox is an optional feature supported on Windows Pro, Enterprise,
Pro Education/SE, and Education, not Home, with virtualization prerequisites.
The `wsb` CLI requires Windows 11 24H2 or later; `.wsb` files are supported from
Windows 10 build 18342. Windows Sandbox currently supports only one running
instance, and available elements/behavior can evolve by build and policy.

## Verification boundary

The current Microsoft CLI commands/options, lack of exec I/O, supported
editions, defaults, and `.wsb` elements were reviewed. No optional feature,
sandbox, hypervisor, RDP window, command, network, clipboard, device, mapping,
artifact, XML configuration, IP, or stop/discard action ran.

## Related documents

- [optionalfeatures.exe](optionalfeatures.exe.md)
- [dism.exe](dism.exe.md)
- [mstsc.exe](mstsc.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[Windows Sandbox CLI](https://learn.microsoft.com/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-cli),
[installation guidance](https://learn.microsoft.com/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-install),
[version and servicing guidance](https://learn.microsoft.com/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-versions),
[configuration-file reference](https://learn.microsoft.com/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-configure-using-wsb-file),
[overview](https://learn.microsoft.com/windows/security/application-security/application-isolation/windows-sandbox/),
and the DISM module references for
[`Get-WindowsOptionalFeature`](https://learn.microsoft.com/powershell/module/dism/get-windowsoptionalfeature?view=windowsserver2025-ps)
and
[`Enable-WindowsOptionalFeature`](https://learn.microsoft.com/powershell/module/dism/enable-windowsoptionalfeature?view=windowsserver2025-ps).
Exact page revisions are recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
