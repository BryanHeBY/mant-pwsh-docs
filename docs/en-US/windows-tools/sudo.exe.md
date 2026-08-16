<!-- mant:tldr:start -->
# sudo.exe

> Run one command elevated through Windows UAC on supported Windows 11 builds.
> More information: https://learn.microsoft.com/windows/advanced-settings/sudo/.

- Display the current Sudo for Windows mode:

`sudo.exe config`

- Display run-command help even when Sudo is disabled:

`sudo.exe /?`

- Elevate one native command in a new window:

`sudo.exe --new-window {{command.exe}} {{arguments}}`

- Elevate a PowerShell command explicitly:

`sudo.exe --inline pwsh.exe -NoProfile -Command {{command}}`
<!-- mant:tldr:end -->

# sudo.exe

## Overview

Sudo for Windows launches a command as the administrator who approves a User
Account Control prompt. It does not switch to an arbitrary named account and
is not a port of Unix `sudo`; Unix sudoers files, environment rules, and command
syntax do not apply.

## Syntax

```text
sudo.exe [run] [options] COMMAND [arguments...]
sudo.exe config [--enable [MODE]]
```

`run` is optional. `config` reports the current mode; changing it requires an
already elevated process and can be restricted by policy.

## Commands and modes

<!-- mant:entries role=command case=insensitive -->
- `run`: Run the following command elevated; this is the default operation.
- `config`: Show current configuration or set it with `--enable`.
- `forceNewWindow`: Allow only a new elevated console window, the most isolated mode.
- `disableInput`: Run inline but prevent the elevated target from reading terminal input.
- `normal`: Run inline with input enabled; this is also called Inline mode and has the largest input-injection exposure.
- `disable`: Disable Sudo for Windows.
- `enable`, `default`: Compatibility values that the current CLI implementation maps to `normal` (Inline); they do not select the safer Settings-app default described by Microsoft.

## Options

<!-- mant:entries role=option case=sensitive -->
- `-E`, `--preserve-env`: Copy current environment variables into the elevated process; review values for secrets and unsafe search paths.
- `-N`, `--new-window`: Override this invocation to Force New Window mode when system policy permits it.
- `--disable-input`: Override this invocation to inline execution without target input when policy permits it.
- `--inline`: Override this invocation to Inline mode when policy permits it.
- `-D DIRECTORY`, `--chdir DIRECTORY`: Set the target working directory explicitly.
- `--enable MODE`: Set configuration to `disable`, `enable`, `forceNewWindow`, `disableInput`, `normal`, or `default` from an elevated process.
- `-h`, `--help`: Display standard help when Sudo is enabled; when disabled, the top-level help is replaced by the disabled-state message.
- `/?`: Display run-command help before the enabled-state check; this spelling is not a general subcommand help flag, so `sudo.exe config --help` is rejected.
- `-V`, `--version`: Display the Sudo for Windows version.

The three per-run mode switches are mutually exclusive. A requested mode that
is more permissive than the configured or policy maximum fails.

## PowerShell usage

Sudo launches executables; it cannot directly resolve a PowerShell cmdlet or
function inside the current session. Start a clean shell explicitly:

```powershell
sudo.exe --new-window pwsh.exe -NoLogo -NoProfile -Command `
    'Get-Service -Name wuauserv | Select-Object Name, Status'
if ($LASTEXITCODE -ne 0) { throw "sudo failed: $LASTEXITCODE" }
```

Nested command text crosses two parsers. Prefer an executable with discrete
arguments or a reviewed script file over constructing `-Command` from
untrusted input. In New Window mode, the default working directory can be
`C:\Windows\System32`; use `--chdir` and absolute paths when location matters.

Sudo waits for a console target and returns its exit result, but it can return
immediately after starting a graphical application. Do not use the launcher
status as proof that a GUI task finished.

## Security modes

Force New Window isolates the elevated console input surface but changes window
and working-directory behavior. Disable Input keeps output inline while the
target cannot read input. Inline is convenient but Microsoft warns that an
unelevated process attached to the same console can inject input into the
elevated process. Choose the least permissive mode compatible with the command.

Microsoft's user documentation describes Force New Window as the default and
recommended configuration. The open-source CLI currently maps the legacy
`config --enable enable` and `config --enable default` values to `normal`, which
is Inline mode. Use the explicit `forceNewWindow`, `disableInput`, or `normal`
value in administrative configuration instead of relying on the word
`default`.

`--preserve-env` can carry attacker-controlled executable search paths,
configuration variables, and secrets across the elevation boundary. Prefer an
explicit clean environment and absolute executable paths.

## Headless automation

No Sudo for Windows mode provides unattended elevation. Every elevated Sudo
invocation still goes through UAC verification: `forceNewWindow` opens a new
window, `disableInput` only closes the elevated target's console input, and
`normal` keeps the elevated target attached to the current console. None of
these settings suppresses the UAC prompt.

For a fixed unattended administrative operation, provision a narrowly scoped
Scheduled Task or Windows service once from an approved administrator session.
For delegated PowerShell administration, prefer a constrained Just Enough
Administration (JEA) endpoint with explicit role capabilities and auditing.
Do not expose an arbitrary command line, PowerShell expression, user-writable
script, working directory, configuration file, or executable path through a
privileged task, service, or endpoint.

Changing UAC policy to approve elevation without prompting is system-wide, not
a Sudo mode, and removes the interactive safeguard from other applications as
well. An automation runner's own sandbox and approval policy is also separate
from Windows UAC and is not bypassed by enabling Sudo.

## Common mistakes

### Using a cmdlet as the target

`sudo.exe Get-Process` searches for an executable named `Get-Process`. Invoke
`pwsh.exe -NoProfile -Command ...` or use an exact native executable.

### Expecting Unix sudo behavior

Windows Sudo uses UAC and the approving administrator. It has no Unix-style
`-u`, sudoers policy, cached terminal credential, or shell built-in behavior.

### Using Inline mode around untrusted processes

Do not paste or run elevated interactive commands while untrusted code shares
the console. Prefer New Window or Disable Input and keep the target noninteractive.

### Treating Disable Input as unattended elevation

`disableInput` prevents the elevated target from reading the current console;
it does not acknowledge UAC. Use a pre-provisioned, least-privilege automation
boundary when no person will be present to approve elevation.

## Version and availability

Inbox Sudo for Windows is available on Windows 11 version 24H2 and later and
must be enabled in Developer settings or by supported configuration. Edition,
organizational policy, user administrator membership, and current mode can
prevent use. Inspect `sudo.exe config` and `sudo.exe --version` on the target.

## Runtime evidence

On a supported Windows 11 host with Sudo for Windows 1.0.1 installed but
disabled, `sudo.exe --version` returned `1.0.1`. `sudo.exe config` reported the
disabled state and returned `-2147024891` (`E_ACCESSDENIED`). Top-level
`--help` returned only the disabled-state message with status 0, while `/?` and
`run /?` each returned 26 run-help lines with status 0; `config --help` rejected
the argument with status 2. Source review confirmed that the disabled state
overrides top-level help and that the special `/?` path prints run help before
the enabled-state check. No UAC prompt, configuration change, environment
preservation, or elevated target process ran.

## Related documents

- [runas.exe](runas.exe.md)
- [schtasks.exe](schtasks.exe.md)
- PowerShell `Start-Process`
- [Windows Terminal](wt.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[Sudo for Windows documentation](https://learn.microsoft.com/windows/advanced-settings/sudo/)
and the [open-source implementation](https://github.com/microsoft/sudo).
Exact revisions and paths are recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under CC BY 4.0 and the implementation is
licensed under MIT. This adaptation is licensed under CC BY 4.0.
