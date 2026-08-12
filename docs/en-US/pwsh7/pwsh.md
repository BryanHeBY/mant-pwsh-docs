<!-- mant:tldr:start -->
# pwsh

> Start PowerShell 7 or run a PowerShell command or script.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_pwsh?view=powershell-7.6.

- Start an interactive session without profiles:

`pwsh -NoProfile`

- Run one command and exit:

`pwsh -NoProfile -Command {{command}}`

- Run a script with its arguments:

`pwsh -NoProfile -File {{path/to/script.ps1}} {{arguments}}`

- Run a non-interactive automation script:

`pwsh -NoLogo -NoProfile -NonInteractive -File {{script.ps1}}`
<!-- mant:tldr:end -->

# pwsh

## Synopsis

```text
pwsh [options]
pwsh [[-File] script.ps1 [arguments]]
pwsh -Command command [arguments]
pwsh -CommandWithArgs command [arguments]
```

`pwsh` starts PowerShell 7. With no command or script argument, it opens an
interactive session. On Windows, `pwsh.exe` is the executable; PowerShell 7
also uses `pwsh` on Linux and macOS.

## Invocation forms

Use `-File` to run a script. The script path and every following argument are
passed to the script, so place `-File` after launcher options. This is the
preferred form for repeatable automation.

Use `-Command` for short PowerShell source supplied by the calling process.
The parent shell parses its own quoting before PowerShell parses the command.
When the command is a string, it normally consumes the rest of the command
line. Use a script file rather than accumulating nested quote escapes.

`-CommandWithArgs` exposes later launcher arguments through `$args`. It was
introduced as experimental in PowerShell 7.4 and became a mainstream feature
in 7.5-preview.5. Do not require it in scripts that must run on releases before
7.4. PowerShell 7.6.4's bundled `pwsh -Help` still displays a stale
`[Experimental]` label even though the current 7.6 reference records the
feature as mainstream.

## Common options

<!-- mant:entries role=option case=insensitive -->
- `-Command COMMAND`, `-c COMMAND`: Execute PowerShell source, then exit unless `-NoExit` is also present.
- `-CommandWithArgs COMMAND`, `-cwa COMMAND`: Execute a command and make following launcher arguments available as `$args`; available since 7.4 and mainstream since 7.5-preview.5.
- `-File PATH`, `-f PATH`: Run a PowerShell script file with remaining arguments passed to that script.
- `-NoProfile`, `-nop`: Do not load any PowerShell profile scripts.
- `-NonInteractive`, `-noni`: Do not prompt for interactive input; unsuitable
  prompts become errors. This option does not disable profile loading.
- `-NoLogo`, `-nol`: Suppress the startup banner.
- `-NoExit`, `-noe`: Keep the session open after startup commands finish.
- `-WorkingDirectory PATH`, `-wd PATH`: Set the initial filesystem working directory.
- `-ExecutionPolicy POLICY`, `-ep POLICY`: Set process-scope execution policy on Windows without changing persisted policy.
- `-EncodedCommand BASE64`, `-e BASE64`: Run a UTF-16LE Base64-encoded command; use only for integrations that require it.
- `-Login`, `-l`: Start a Unix-like login shell; this option must be the first argument.
- `-Version`, `-v`: Print the installed PowerShell version.
- `-Help`, `-h`, `-?`: Display complete launcher help for the installed version.

## Exit behavior

An explicit `exit NUMBER` sets the PowerShell process exit code. With
`-Command`, a successful final PowerShell command normally produces zero and a
failed one normally produces one. Native programs have their own exit code in
`$LASTEXITCODE`; preserve that exact value explicitly when a caller needs it:

```powershell
pwsh -NoProfile -Command 'git diff --quiet; exit $LASTEXITCODE'
```

For a script launched with `-File`, use `exit` from the script when its
caller needs a defined status. Treat Ctrl+C behavior and non-terminating errors
as host- and command-specific; use terminating errors or explicit exits for
automation contracts.

## Input and output formats

`-InputFormat` and `-OutputFormat` select text or serialized CLIXML when a
host integrates with PowerShell through redirected streams. They are not a
replacement for an application data format such as JSON. For ordinary shell
automation, write structured results as JSON deliberately and test the native
program's exit code before converting its output.

## Profiles and reproducibility

Profiles can add functions, aliases, modules, prompts, and preference values.
They are useful for interactive sessions but make an automation environment
less predictable. Use at least `-NoProfile` for scripts, scheduled tasks,
CI jobs, and troubleshooting reproductions. Combine it with `-NonInteractive`
when the caller cannot answer prompts safely.

## Platform differences

`pwsh` is cross-platform, but available modules, execution policy behavior,
paths, authentication, startup locations, and native tools differ by operating
system. `-Login` has Unix-like shell semantics and does nothing useful on
Windows. `-ExecutionPolicy` affects the process environment only on Windows.

Check `pwsh -Help` and `$PSVersionTable` on the target machine before relying
on an option added in a later PowerShell 7 release.

## Common mistakes

### Combining `-Command` and `-File`

They select different invocation modes and are not interchangeable. Choose
one boundary and pass the remaining arguments according to that mode.

### Assuming native failure becomes the process exit code

Forward `$LASTEXITCODE` explicitly when a caller needs the exact native
status. Non-terminating PowerShell errors also require an intentional failure
contract.

### Letting the parent expand child-process source

An expandable `-Command` string created in a PowerShell parent can substitute
`$variables` and `$()` expressions before `pwsh` receives it. Use a literal
string for fixed child source, pass a script block from a PowerShell caller
when appropriate, or prefer `-File` for substantial automation.

### Treating `-CommandWithArgs` as experimental in PowerShell 7.6

The bundled help in PowerShell 7.6.4 retains an `[Experimental]` marker, but
the current official 7.6 reference says the feature became mainstream in
7.5-preview.5. Check both the target runtime's behavior and the current
versioned reference when bundled help and release status disagree.

### Depending on profiles in automation

Use `-NoProfile` and normally `-NonInteractive`; load required modules and
configuration explicitly.

## Examples

Run an automation script from a neutral environment:

```powershell
pwsh -NoLogo -NoProfile -NonInteractive -File ./build.ps1 -Configuration Release
```

Read a script from standard input:

```powershell
Get-Content -Raw ./script.ps1 | pwsh -NoProfile -File -
```

Pass data to a short command without interpolating it into source code:

```powershell
$message = 'hello'
pwsh -NoProfile -Command { param($value) "value: $value" } -Args $message
```

The final example is reliable only when a PowerShell host passes the script
block as a script block. Use `-File` when invoking from another shell or a
process API that passes only strings.

## Runtime evidence

PowerShell 7.6.4 on Windows confirmed the installed launcher identity,
`-NoProfile` Core/Win32NT metadata, `-CommandWithArgs` preserving `alpha` and
`two words` as separate `$args`, and a literal child command returning `1`.
The bundled help still labeled `-CommandWithArgs` experimental while the
locked 7.6 reference records it as mainstream; the page preserves that
documented discrepancy. PowerShell 7.6.3 on Linux covered launcher help and
selected exit behavior. macOS, stdin, encoded commands, login shells,
execution policy, profiles, and all failure-exit combinations remain
outstanding.

## Related documents

- [PowerShell 7 shell and language](pwsh7.md)
- [about_Parsing](about_Parsing.md)
- [about_Quoting_Rules](about_Quoting_Rules.md)
- [PowerShell 7 documentation](powershell-7-docs.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_Pwsh reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_pwsh?view=powershell-7.6).
It reorganizes the launcher options around practical invocation and
automation scenarios. Exact upstream revision and path are recorded in
`upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
