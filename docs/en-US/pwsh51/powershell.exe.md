<!-- mant:tldr:start -->
# powershell.exe

> Start Windows PowerShell 5.1 or run a PowerShell command or script on Windows.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_powershell_exe?view=powershell-5.1.

- Start an interactive session without profiles:

`powershell.exe -NoProfile`

- Run one command and exit:

`powershell.exe -NoProfile -Command {{command}}`

- Run a script with its arguments:

`powershell.exe -NoProfile -File {{path\to\script.ps1}} {{arguments}}`

- Run non-interactive automation:

`powershell.exe -NoLogo -NoProfile -NonInteractive -File {{script.ps1}}`

- Run reviewed unattended automation without leaving a visible console window:

`powershell.exe -NoLogo -NoProfile -NonInteractive -WindowStyle Hidden -File {{script.ps1}}`
<!-- mant:tldr:end -->

# powershell.exe

## Synopsis

```text
powershell.exe [options]
powershell.exe [[-File] script.ps1 [arguments]]
powershell.exe -Command command [arguments]
```

`powershell.exe` starts Windows PowerShell 5.1, the Windows-only Desktop
edition based on .NET Framework. With no script or command, it opens an
interactive console session.

## Invocation forms

Use `-File` for a script file and place its path after launcher options.
Arguments after the path are passed to that script. Use `-Command` for short
PowerShell source from a calling process; the parent shell parses its own
quoting before Windows PowerShell sees the source.

Arguments after `-File` are literal strings after the calling shell processes
them. Windows PowerShell 5.1 can't pass an explicit Boolean value such as
`$false` to a script's `[switch]` parameter through this native boundary, and
it can't pass a native argument as a PowerShell array. Design file-based entry
points around scalar values and the presence or absence of switches.

Prefer `-File` for repeatable automation. It is easier to review, quote, test,
sign, and run with a controlled working directory than a nested command string.
Use `-EncodedCommand` only when a host integration requires a UTF-16LE
Base64-encoded command.

## Common options

<!-- mant:entries role=option case=insensitive -->
- `-Command COMMAND`, `-c COMMAND`: Execute PowerShell source and then exit unless `-NoExit` is present.
- `-File PATH`, `-f PATH`: Run a Windows PowerShell script file with remaining arguments passed to that script.
- `-NoProfile`, `-nop`: Do not load any Windows PowerShell profile scripts.
- `-NonInteractive`, `-noni`: Do not prompt for interactive input; unsuitable
  prompts become errors. This option does not disable profile loading or hide
  the process window.
- `-NoLogo`, `-nol`: Suppress the startup banner.
- `-NoExit`, `-noe`: Keep the session open after startup commands finish.
- `-ExecutionPolicy POLICY`, `-ep POLICY`: Set process-scope execution policy without changing persisted policy.
- `-EncodedCommand BASE64`, `-e BASE64`: Run a UTF-16LE Base64-encoded command.
- `-InputFormat FORMAT`, `-if FORMAT`: Select text or CLIXML input from the parent process.
- `-OutputFormat FORMAT`, `-of FORMAT`: Select text or CLIXML output for the parent process.
- `-STA`, `-MTA`: Select the apartment state of the session thread.
- `-WorkingDirectory PATH`, `-wd PATH`: Set the initial PowerShell location.
- `-WindowStyle STYLE`: Start the Windows process as `Normal`, `Minimized`,
  `Maximized`, or `Hidden`; window style does not detach the process or change
  its exit-code and waiting contract.
- `-ConfigurationName NAME`: Run in a registered local session configuration endpoint.
- `-PSConsoleFile PATH`: Load a legacy `.psc1` console file created with `Export-Console`.
- `-Version VERSION`: Start a requested installed Windows PowerShell engine version; place this option before other launcher options.
- `-Help`, `-h`, `-?`: Display complete launcher help for the installed version.

Some behavior depends on whether the process is launched by `cmd.exe`, Task
Scheduler, a service, another PowerShell host, or a process API. Test the
actual production host, especially where quoting or standard input is used.

## Exit behavior

An explicit `exit NUMBER` sets the process exit code. A terminating error or
an interrupted command can produce a nonzero status, while non-terminating
errors can leave execution running. Define an explicit failure contract for
automation instead of relying on default host behavior.

Native programs place their code in `$LASTEXITCODE`. Forward it explicitly
when the caller needs the exact native result:

```powershell
powershell.exe -NoProfile -Command 'cmd.exe /d /c exit 7; exit $LASTEXITCODE'
```

The example makes no filesystem change and returns `7` to its caller. For real
tools, interpret native exit codes according to that tool's documentation;
some use ranges that are not simple success/failure values.

## Profiles and reproducibility

Profiles can import modules, define aliases and functions, and change
preferences. They are useful interactively but create hidden dependencies in
automation. Use `-NoProfile` for scheduled tasks, CI jobs, troubleshooting,
and migration testing. Add `-NonInteractive` when no one can answer a prompt.

## Windows-specific behavior

Windows PowerShell 5.1 is a Windows component and is serviced with Windows,
but it can be disabled as an optional feature on some systems. It uses the
Desktop edition, Windows providers, .NET Framework, and the Windows process
model. It is not the same executable or edition as PowerShell 7's `pwsh`.
Use `$PSVersionTable` to record the actual runtime in diagnostic output.

## Common mistakes

### Copying `pwsh` launcher options into `powershell.exe`

Windows PowerShell 5.1 does not implement every modern PowerShell launcher
option. Check `powershell.exe -Help` on the target Windows image.

In particular, `pwsh -Version` prints the current PowerShell version, whereas
`powershell.exe -Version VERSION` selects a requested installed engine and
must precede ordinary launcher options. Use `$PSVersionTable` inside a normal
5.1 session when you only need to report the version.

### Passing an explicit false switch through `-File`

Windows PowerShell 5.1 can't pass an explicit Boolean value to a script
`[switch]` parameter through `powershell.exe -File`. Omit the switch for false,
include it for true, or redesign the script parameter as a scalar value when
the caller must select both states explicitly. This limitation was removed in
PowerShell 6.

### Losing a native program's exit code

Read and explicitly forward `$LASTEXITCODE` when the parent process needs the
native result; interpret tool-specific success ranges before reducing them.

### Letting the parent expand child-process source

An expandable `-Command` string created in a PowerShell parent can substitute
`$variables` and `$()` expressions before `powershell.exe` receives it. Use a
literal string for fixed child source, pass a script block from a PowerShell
caller when appropriate, or prefer `-File` for substantial automation.

### Relying on profiles or interactive prompts

Use `-NoProfile -NonInteractive` for unattended work and load required state
explicitly.

### Treating non-interactive as hidden or detached

`-NonInteractive` converts prompts into errors; it does not hide a console.
On Windows, add `-WindowStyle Hidden` when a reviewed unattended task should
have no visible window. Hidden is a presentation setting, not a background-job
or detachment primitive: keep the launcher synchronous when Task Scheduler or
another supervisor must observe completion and propagate failure.

## Runtime evidence

The installed Windows PowerShell 5.1 launcher accepted `-Version 5.1` when the
selector appeared first and started the recorded 5.1.26100.8875 engine. A
fixed single-quoted `-Command` source preserved `$value` for child parsing and
returned `1`. Other smoke checks confirm `-NoProfile` edition metadata and
native exit-code boundaries. The probes do not cover every stdin, encoded
command, execution-policy, apartment, host, profile-loading, or failure-exit
combination.

## Related documents

- [Windows PowerShell 5.1 shell and language](pwsh51.md)
- [about_Parsing](about_Parsing.md)
- [about_Quoting_Rules](about_Quoting_Rules.md)
- [Windows PowerShell 5.1 documentation](windows-powershell-5.1-docs.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_PowerShell_exe reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_powershell_exe?view=powershell-5.1).
It is reorganized around reproducible automation and Windows-specific startup
boundaries. Exact upstream revision and path are recorded in
`upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
