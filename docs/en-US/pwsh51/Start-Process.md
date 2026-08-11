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
- `-UseNewEnvironment`: Use the machine-defined environment instead of
  inheriting the current process environment.
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

## Common mistakes

### Expecting a process object without `-PassThru`

Add `-PassThru` when a PID or exit code is required, and use `-Wait` or another
explicit wait before reading `ExitCode`.

### Treating `-ArgumentList` as structured argv

The target receives a Windows command-line string after another parsing layer.
Batch variables such as `%~dp0` do not become valid PowerShell variables, and
nested MSI/cmd/PowerShell quotes must be designed for every parser involved.

### Assuming `-Wait` proves the requested state

A launcher can delegate to an existing process or service; a descendant can
also stay alive indefinitely. Verify the installed product, output file, GUI
state, or configuration separately.

### Using `Start-Process` for every console command

It complicates stream and exit-code handling. Prefer `& executable arguments`
unless a launch option is actually required.

### Copying PowerShell 7 parameters

Windows PowerShell 5.1 does not support PowerShell 7.4's `-Environment`
hashtable. Use only the 5.1 syntax shown by installed help.

## Version and platform differences

This page is specific to Windows PowerShell 5.1 on Windows. Both `saps` and
`start` are built-in aliases in a default 5.1 session. Windows policy,
credentials, desktop/session state, and file associations affect behavior.

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
Exact sources and licenses are recorded in `upstream/pwsh51.json`.

The Microsoft documentation is licensed under CC BY 4.0 and Stack Overflow
content under CC BY-SA 4.0. This adaptation is licensed under CC BY 4.0; no
Stack Overflow answer text is reproduced.
