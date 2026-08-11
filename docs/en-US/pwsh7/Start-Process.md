<!-- mant:tldr:start -->
# Start-Process

> Start a local process with explicit window, environment, verb, or wait controls.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.management/start-process?view=powershell-7.6.

- Start an application asynchronously:

`Start-Process -FilePath {{app.exe}} -ArgumentList '{{argument1}} {{argument2}}'`

- Wait and capture the process exit code:

`$process = Start-Process -FilePath {{app.exe}} -ArgumentList '{{arguments}}' -Wait -PassThru; $process.ExitCode`

- Open a document or URI with its registered handler:

`Start-Process -FilePath '{{https://example.com}}'`

- Start an elevated process on Windows:

`Start-Process -FilePath {{pwsh.exe}} -Verb RunAs`
<!-- mant:tldr:end -->

# Start-Process

## Synopsis

`Start-Process` starts one or more local processes. Use it when process launch
settings matter; invoke a native executable directly when ordinary synchronous
pipeline, stream, and `$LASTEXITCODE` behavior is sufficient.

## Syntax

```powershell
Start-Process [-FilePath] <string> [[-ArgumentList] <string[]>]
  [-Credential <pscredential>] [-WorkingDirectory <string>]
  [-LoadUserProfile] [-NoNewWindow] [-PassThru] [-Wait]
  [-RedirectStandardInput <string>] [-RedirectStandardOutput <string>]
  [-RedirectStandardError <string>] [-UseNewEnvironment]
  [-WindowStyle <ProcessWindowStyle>] [-Environment <hashtable>]
  [-WhatIf] [-Confirm]
  [<CommonParameters>]

Start-Process [-FilePath] <string> [[-ArgumentList] <string[]>]
  [-WorkingDirectory <string>] [-PassThru] [-Wait] [-Verb <string>]
  [-WindowStyle <ProcessWindowStyle>] [-Environment <hashtable>]
  [-WhatIf] [-Confirm]
  [<CommonParameters>]
```

The credential, profile, verb, and window-related parameters are Windows-only
or have no useful non-Windows effect. Installed platform help is authoritative
for the exact behavior of the current PowerShell build.

## Important parameters

- `-FilePath PATH`: Specify an executable, script, or a file whose registered
  handler should open it.
- `-ArgumentList ARGUMENTS`: Supply the target command line. PowerShell joins an
  array into a single space-separated string; use one carefully quoted string
  when the target requires embedded quotes.
- `-WorkingDirectory PATH`: Set the new process working directory.
- `-Wait`: Wait for the process and, for a local launch, its descendants.
- `-PassThru`: Return a `System.Diagnostics.Process` object. Without it, the
  cmdlet normally has no output.
- `-Verb VERB`: Use a registered shell verb such as `RunAs` on Windows.
- `-RedirectStandardInput`, `-RedirectStandardOutput`,
  `-RedirectStandardError`: Redirect a standard stream to or from a file.
- `-NoNewWindow`: Reuse the current console window where supported.
- `-WindowStyle STYLE`: Select Normal, Hidden, Minimized, or Maximized on
  Windows. It cannot be combined with `-NoNewWindow`.
- `-Environment TABLE`: Override or remove environment variables for the new
  process. This parameter was added in PowerShell 7.4.
- `-Credential`, `-LoadUserProfile`, `-UseNewEnvironment`: Select Windows
  account/profile behavior in the default parameter set.
- `-WhatIf`, `-Confirm`: Preview or confirm process creation. These parameters
  were added to `Start-Process` in PowerShell 6.

## Arguments and streams

`Start-Process` does not provide the same pipeline integration as direct
invocation. If the goal is to consume stdout as PowerShell pipeline input, run
the executable directly:

```powershell
& git.exe status --short | ForEach-Object { $_ }
if ($LASTEXITCODE -ne 0) {
    throw "git failed with exit code $LASTEXITCODE"
}
```

Use `Start-Process` for a new window, a shell verb, explicit redirection,
credentials, an environment override, or process lifecycle control.

## Common mistakes

### Expecting a process object without `-PassThru`

`$process = Start-Process app.exe` normally assigns no object. Add `-PassThru`
when the PID, state, or exit code is required, and wait before reading
`ExitCode`.

### Treating `-ArgumentList` as structured argv

The arguments are joined into one command-line string. Nested quotes required
by MSI properties, cmd strings, or another PowerShell process must survive both
PowerShell parsing and the target parser. Keep nesting shallow and inspect the
target's actual syntax.

### Using `-Wait` as proof that work completed

Some launchers hand work to an existing process or service and exit. Conversely,
`-Wait` can wait for descendant processes that intentionally remain alive.
Verify the requested artifact or state, not just the launcher process.

### Using `Start-Process` for every native command

It can hide normal stdout/stderr flow and complicate exit-code capture. Direct
invocation is clearer unless a launch-control feature is needed.

### Assuming `start` is portable

PowerShell 7 provides `saps` as an all-platform alias. The `start` alias is
Windows-only and also conflicts conceptually with the cmd builtin. Use the full
cmdlet name in shared scripts.

## Version and platform differences

PowerShell 7 supports `Start-Process` on Windows, Linux, and macOS, but window
styles, credentials, verbs, detachment, and desktop handlers are
platform-specific. On non-Windows systems, a launched process attached to the
current terminal can terminate when that terminal closes unless the command is
started with appropriate platform detachment.

The `-Environment` parameter requires PowerShell 7.4 or later. This page targets
PowerShell 7.6; check installed help when supporting earlier 7.x releases.

## Related documents

- [start alias](start.md)
- [Invoke-Item](Invoke-Item.md)
- [native commands](native-commands.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Start-Process reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/start-process?view=powershell-7.6).
The recurring wait behavior is also informed by the community discussion
[How to tell PowerShell to wait for each command to end](https://stackoverflow.com/questions/1741490/how-to-tell-powershell-to-wait-for-each-command-to-end-before-starting-the-next).
Exact sources and licenses are recorded in `upstream/pwsh7.json`.

The Microsoft documentation is licensed under CC BY 4.0 and Stack Overflow
content under CC BY-SA 4.0. This adaptation is licensed under CC BY 4.0; no
Stack Overflow answer text is reproduced.
