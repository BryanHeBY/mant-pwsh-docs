<!-- mant:tldr:start -->
# powershell_ise.exe

> Open the Windows-only graphical host for Windows PowerShell 5.1; it does not host PowerShell 7.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/powershell_ise.

- Confirm the resolved executable and Windows PowerShell version before opening the GUI:

`Get-Command powershell_ise.exe -ErrorAction Stop; powershell.exe -NoProfile -Command '$PSVersionTable | Format-List'`

- Inspect the launcher identity without opening the GUI:

`$ise = Get-Item -LiteralPath (Get-Command powershell_ise.exe -CommandType Application).Source; $ise.VersionInfo | Select-Object FileVersionRaw, FileVersion, ProductVersionRaw, ProductVersion; Get-AuthenticodeSignature -LiteralPath $ise.FullName`

- Open an isolated ISE session without loading its profiles:

`Start-Process powershell_ise.exe -ArgumentList '-NoProfile'`

- Open one reviewed script for editing without loading ISE profiles:

`Start-Process powershell_ise.exe -ArgumentList @('-NoProfile', '-File', '"{{C:\Scripts\review.ps1}}"')`

- Use the supported PowerShell 7 editor command after installing VS Code and its PowerShell extension:

`code "{{C:\Scripts\review.ps1}}"`
<!-- mant:tldr:end -->

# powershell_ise.exe

## Overview

`powershell_ise.exe` starts Windows PowerShell Integrated Scripting Environment,
a graphical editor, console, and debugger for Windows PowerShell. It provides
IntelliSense, selective execution, snippets, debugging, and context-sensitive
help. It runs the Windows PowerShell 5.1 engine, not `pwsh.exe` or PowerShell 7.
Microsoft recommends Visual Studio Code with the PowerShell extension as the
supported scripting environment for PowerShell 7.

## Launcher options

<!-- mant:entries role=command case=insensitive -->
- `powershell_ise.exe`: Start the graphical Windows PowerShell 5.1 ISE host;
  it never selects the PowerShell 7 engine.

The launcher accepts a small option surface. The ISE requires a graphical
Windows installation and interactive desktop and does not run on Server Core.

<!-- mant:entries role=option case=insensitive -->
- `-File`: Open the following supported script, module, manifest, or text path.
- `-NoProfile`: Skip Windows PowerShell profile scripts for this ISE launch.
- `-Help`, `-?`, `/?`: Display launcher help.

## Common mistakes

### Assuming ISE uses the PowerShell 7 installed on the same computer

The process name and blue console do not establish edition. Check
`$PSVersionTable.PSEdition` inside the host. Code that succeeds in ISE can fail
under PowerShell 7 because modules, .NET APIs, parsing, encoding, remoting, and
native-command behavior differ.

### Debugging the wrong profile state

ISE has its own host-specific profile, such as
`Microsoft.PowerShellISE_profile.ps1`; the console host's profile is not the
same file. Reproduce with `-NoProfile`, inspect `$PROFILE` variants, and add
shared behavior only to the intended AllHosts profile.

### Pressing F8 on an unsafe selection

F8 runs the selection or current line. A partial pipeline, block, here-string,
or multi-line expression can have different meaning from the full script.
Review the exact selection and use a disposable/test target for mutating code.

### Pasting downloaded code into the console pane

Opening text does not make it trusted. Inspect provenance, signatures,
parameters, expansion, credentials, network targets, persistence, and cleanup
before any selection or script is executed.

### Treating ISE success as unattended-host evidence

ISE supplies an interactive GUI host and does not accurately reproduce Task
Scheduler, service, remoting, constrained-language, noninteractive, redirected
stream, or headless execution. Test in the real host and security context.

## PowerShell boundaries

The launcher is a native GUI executable, so starting successfully does not mean
the opened script ran or finished. Use `Start-Process -Wait -PassThru` only when
waiting for the entire editor process is genuinely intended. Quote file paths
as one native argument and do not construct them from untrusted text.

## Version and platform differences

ISE is a Windows PowerShell component and optional Windows feature. It is not a
PowerShell 6/7 host, is not available on macOS/Linux, and requires a GUI. It is
not receiving new features; Visual Studio Code plus the PowerShell extension is
the supported PowerShell 7 editing/debugging route.

On the recorded Windows NT `10.0.26200.0` host, the 64-bit ISE launcher
resolved from `C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe`,
not the System32 root. Fixed and string file/product versions all reported
`10.0.26100.8875`; the exact file had a valid Microsoft Windows signature and
SHA-256
`B4B1A489F51C8D7E4FE69DB4D4D1AB1F92CAF2973BE3C770E185EBC157EF52EB`.
A separate 32-bit launcher was present below SysWOW64. Neither GUI was started
and no profile or script was loaded for this evidence.

## Runtime evidence

On Windows NT `10.0.26200.0`, the read-only file-identity audit under Windows
PowerShell `5.1.26100.8875` and PowerShell `7.6.4` resolved the exact entry
point to `C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell_ise.exe`. Its
fixed numeric file version was `10.0.26100.8875`. Both collectors reported the
same result.

The audit invoked no discovered command, opened no window, contacted no remote
endpoint, and changed no state. This proves only this host's entry-point
availability and file identity; it does not prove that the UI loads, the
current user is authorized, an optional snap-in or component is functional, or
any displayed or requested operation succeeds.

## Related documents
- `mant powershell --source pwsh51`: Windows PowerShell launcher behavior.
- `mant pwsh --source pwsh7`: PowerShell 7 launcher behavior.
- `mant pwsh51 --source pwsh51`: broad Windows PowerShell 5.1 shell manual.

## Sources and license

This original guide was adapted from Microsoft's official
[PowerShell ISE command reference](https://learn.microsoft.com/windows-server/administration/windows-commands/powershell_ise),
[ISE overview](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_windows_powershell_ise?view=powershell-5.1),
and [PowerShell 5.1-to-7 migration guidance](https://learn.microsoft.com/powershell/scripting/whats-new/migrating-from-windows-powershell-51-to-powershell-7).
A recurring [Microsoft Q&A question about PowerShell 7 ISE](https://learn.microsoft.com/en-ie/answers/questions/306631/powershell-7-ise-not-visible-in-windows-10)
was used to prioritize the edition warning. Exact provenance is recorded in
`upstream/windows-tools.json`. Microsoft-hosted material and this adaptation are licensed
under CC BY 4.0.
