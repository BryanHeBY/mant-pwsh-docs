<!-- mant:tldr:start -->
# Start-Process

> Start a local Windows process with explicit window, credential, verb, or wait controls.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.management/start-process?view=powershell-5.1.

- Start an application asynchronously:

`Start-Process -FilePath {{app.exe}} -ArgumentList '{{argument1}} {{argument2}}'`

- Wait and capture the process exit code:

`$process = Start-Process -FilePath {{app.exe}} -ArgumentList '{{arguments}}' -Wait -PassThru; $process.ExitCode`

- Open a document or URL with its registered Windows handler:

`Start-Process -FilePath '{{https://example.com}}'`

- Start an elevated Windows PowerShell process:

`Start-Process -FilePath {{powershell.exe}} -Verb RunAs`
<!-- mant:tldr:end -->

# Start-Process

## Synopsis

`Start-Process` starts one or more local Windows processes. Use it when launch
settings matter; invoke a native console executable directly when ordinary
pipeline, stream, and `$LASTEXITCODE` behavior is sufficient.

## Syntax

```powershell
Start-Process [-FilePath] <string> [[-ArgumentList] <string[]>]
  [-Credential <pscredential>] [-WorkingDirectory <string>]
  [-LoadUserProfile] [-NoNewWindow] [-PassThru]
  [-RedirectStandardError <string>] [-RedirectStandardInput <string>]
  [-RedirectStandardOutput <string>] [-UseNewEnvironment]
  [-Wait] [-WindowStyle <ProcessWindowStyle>] [<CommonParameters>]

Start-Process [-FilePath] <string> [[-ArgumentList] <string[]>]
  [-WorkingDirectory <string>] [-PassThru] [-Verb <string>]
  [-Wait] [-WindowStyle <ProcessWindowStyle>] [<CommonParameters>]
```

## Important parameters

<!-- mant:entries role=option case=insensitive -->
- `-FilePath PATH`: Specify an executable, script, or registered document/URL.
- `-ArgumentList ARGUMENTS`: Supply the target command line. Windows PowerShell
  joins an array into a space-separated string; one carefully quoted string is
  often clearer when embedded quotes are required.
- `-WorkingDirectory PATH`: Set the process working directory.
- `-Wait`: Wait for the process and its descendants.
- `-PassThru`: Return a `System.Diagnostics.Process` object; default output is
  empty.
- `-Verb VERB`: Use a registered shell verb such as `RunAs`.
- `-Credential CREDENTIAL`: Start with an approved alternate Windows account
  in the applicable parameter set.
- `-LoadUserProfile`: Load the specified account's Windows user profile.
- `-UseNewEnvironment`: On Windows, use only the machine-scope default
  environment instead of inheriting the current process or adding user-scope
  variables. The resulting `USERNAME` value is `SYSTEM`; this does not mean
  the process runs as the SYSTEM account.
- `-RedirectStandardInput`, `-RedirectStandardOutput`,
  `-RedirectStandardError`: Redirect a standard stream to or from a file.
- `-NoNewWindow`: Reuse the current console window.
- `-WindowStyle STYLE`: Use Normal, Hidden, Minimized, or Maximized; it cannot
  be combined with `-NoNewWindow`.

## Direct invocation versus process launch

Direct invocation keeps normal native stdout in the PowerShell pipeline and
sets `$LASTEXITCODE`:

```powershell
& where.exe git
if ($LASTEXITCODE -ne 0) {
    throw "where.exe failed with exit code $LASTEXITCODE"
}
```

Use `Start-Process` for process lifecycle controls, a separate/elevated window,
credentials, a shell verb, or file redirection.

If lower-level `[System.Diagnostics.Process]` code redirects both stdout and
stderr into memory, do not call synchronous `ReadToEnd()` on one stream and
only then start reading the other. A child that fills the unread pipe can block
while the parent waits for the first stream to close. Start asynchronous reads
for both streams (or at least one, as the .NET contract requires), impose a
finite wait, handle `Start()` failure separately from process exit, and clean
up only a process that actually started. `Start-Process` file redirection does
not require this in-memory dual-pipe pattern.

## Common mistakes

### Expecting a process object without `-PassThru`

Add `-PassThru` when a PID or exit code is required, and use `-Wait` or another
explicit wait before reading `ExitCode`.

### Treating `-ArgumentList` as structured argv

The target receives a Windows command-line string after another parsing layer.
Batch variables such as `%~dp0` do not become valid PowerShell variables, and
nested MSI/cmd/PowerShell quotes must be designed for every parser involved.

Do not confuse this cmdlet parameter with the similarly named .NET
`ProcessStartInfo.ArgumentList` property. Windows PowerShell 5.1's .NET
Framework `ProcessStartInfo` has the string property `Arguments` but no
`ArgumentList` property. Calling `$psi.ArgumentList.Add(...)` therefore fails;
if the error is nonterminating and ignored, the child can still start with no
arguments and produce dangerously misleading evidence. Inspect the property,
set and validate `Arguments` for this runtime, and fail before `Start()` when
argument construction did not succeed.

### Assuming `-Wait` proves the requested state

A launcher can delegate to an existing process or service; a descendant can
also stay alive indefinitely. Verify the installed product, output file, GUI
state, or configuration separately.

### Using `Start-Process` for every console command

It complicates stream and exit-code handling. Prefer `& executable arguments`
unless a launch option is actually required.

### Reading two redirected .NET process streams sequentially

Sequential synchronous reads can deadlock when the child fills the stream that
the parent has not begun to drain. This can look like a hung native tool even
though the capture harness is blocked. Read the streams concurrently and keep
start errors, timeout, exit code, stdout, and stderr as separate evidence.

### Copying PowerShell 7 parameters

Windows PowerShell 5.1 does not support PowerShell 7.4's `-Environment`
hashtable. Use only the 5.1 syntax shown by installed help.

### Treating `-UseNewEnvironment` as a clean copy of the current environment

On Windows it starts from machine-scope defaults, omits user-scope variables,
and reports `USERNAME=SYSTEM` even though the security identity was not changed.
Inspect and pass every required variable explicitly when environment contents
are part of the process contract.

## Version and platform differences

This page is specific to Windows PowerShell 5.1 on Windows. Both `saps` and
`start` are built-in aliases in a default 5.1 session. Windows policy,
credentials, desktop/session state, and file associations affect behavior.

## Runtime evidence

Windows PowerShell 5.1.26100.8875 confirmed complete documented parameter
metadata and the absence of `-WhatIf`. Runtime type metadata also confirmed
that .NET Framework `ProcessStartInfo` has `Arguments` but no `ArgumentList`
property; no process was launched for that check. A bounded .NET harness reproduced the
dual-redirected-stream sequential-read deadlock pattern; concurrent reads
completed the same no-operand usage probe and kept start failure, timeout,
exit, stdout, and stderr separate. No operational target, credentials, desktop
handler, or persistent environment was changed. `-Wait`, verbs, credentials,
window state, and real application lifetimes remain outstanding.

## Related documents

- [start alias](start.md)
- [Invoke-Item](Invoke-Item.md)
- [native commands](native-commands.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Start-Process reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/start-process?view=powershell-5.1).
The recurring wait behavior is also informed by the community discussion
[How to tell PowerShell to wait for each command to end](https://stackoverflow.com/questions/1741490/how-to-tell-powershell-to-wait-for-each-command-to-end-before-starting-the-next).
The lower-level dual-stream warning follows Microsoft's
[System.Diagnostics.Process.StandardOutput contract](https://learn.microsoft.com/dotnet/api/system.diagnostics.process.standardoutput?view=netframework-4.8.1).
Exact sources and licenses are recorded in `upstream/pwsh51.json`.

The Microsoft documentation is licensed under CC BY 4.0 and Stack Overflow
content under CC BY-SA 4.0. This adaptation is licensed under CC BY 4.0; no
Stack Overflow answer text is reproduced.
