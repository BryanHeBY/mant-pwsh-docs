<!-- mant:tldr:start -->
# powershell

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
<!-- mant:tldr:end -->

# powershell

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

Prefer `-File` for repeatable automation. It is easier to review, quote, test,
sign, and run with a controlled working directory than a nested command string.
Use `-EncodedCommand` only when a host integration requires a UTF-16LE
Base64-encoded command.

## Common options

- `-Command COMMAND`, `-c COMMAND`: Execute PowerShell source and then exit unless `-NoExit` is present.
- `-File PATH`, `-f PATH`: Run a Windows PowerShell script file with remaining arguments passed to that script.
- `-NoProfile`, `-nop`: Do not load any Windows PowerShell profile scripts.
- `-NonInteractive`, `-noni`: Do not prompt for interactive input; unsuitable prompts become errors.
- `-NoLogo`, `-nol`: Suppress the startup banner.
- `-NoExit`, `-noe`: Keep the session open after startup commands finish.
- `-ExecutionPolicy POLICY`, `-ep POLICY`: Set process-scope execution policy without changing persisted policy.
- `-EncodedCommand BASE64`, `-e BASE64`: Run a UTF-16LE Base64-encoded command.
- `-InputFormat FORMAT`, `-if FORMAT`: Select text or CLIXML input from the parent process.
- `-OutputFormat FORMAT`, `-of FORMAT`: Select text or CLIXML output for the parent process.
- `-STA`, `-MTA`: Select the apartment state of the session thread.
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
powershell.exe -NoProfile -Command 'robocopy.exe .\source .\target /E; exit $LASTEXITCODE'
```

Interpret native exit codes according to the tool's own documentation. For
example, `robocopy.exe` uses ranges that are not simple success/failure values.

## Profiles and reproducibility

Profiles can import modules, define aliases and functions, and change
preferences. They are useful interactively but create hidden dependencies in
automation. Use `-NoProfile` for scheduled tasks, CI jobs, troubleshooting,
and migration testing. Add `-NonInteractive` when no one can answer a prompt.

## Windows-specific behavior

Windows PowerShell 5.1 is installed and serviced with Windows. It uses the
Desktop edition, Windows providers, .NET Framework, and the Windows process
model. It is not the same executable or edition as PowerShell 7's `pwsh`.
Use `$PSVersionTable` to record the actual runtime in diagnostic output.

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
