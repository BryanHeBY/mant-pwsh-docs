<!-- mant:tldr:start -->
# wt.exe

> Open or control Windows Terminal windows, tabs, and panes.
> More information: https://learn.microsoft.com/windows/terminal/command-line-arguments.

- Open a tab using a named profile and directory:

`wt.exe new-tab --profile {{profile}} --startingDirectory {{directory}}`

- Target the most recently used Terminal window:

`wt.exe --window last new-tab`

- Create two panes from PowerShell by escaping Terminal's semicolon:

`wt.exe new-tab `; split-pane --horizontal`
<!-- mant:tldr:end -->

# wt.exe

## Overview

`wt.exe` is the Windows Terminal command-line entry point. It creates or
targets Terminal windows and sequences tab/pane actions. It is commonly an App
Execution Alias, so resolve the exact application and package registration
instead of assuming a conventional System32 executable.

## Syntax

```text
wt.exe [window options] [new-tab options] [COMMANDLINE]
wt.exe [window options] ACTION [options] [; ACTION ...]
```

## Window and help options

<!-- mant:entries role=option case=sensitive -->
- `-h`, `--help`, `-?`, `/?`: Display command-line help.
- `-M`, `--maximized`: Launch the target Terminal window maximized.
- `-F`, `--fullscreen`: Launch it full screen.
- `-f`, `--focus`: Launch in focus mode; it can be combined with maximized.
- `--pos POSITION`: Set the initial `X,Y` window position; either coordinate may be omitted.
- `-w ID`, `--window ID`: Target a window by integer ID, name, or a reserved value such as `new`, `last`, or `0`.

At window scope, `--size C,R` sets initial columns and rows. The same exact
selector has different `split-pane` semantics below, so ManT registers the
selector once under pane options and keeps the window form in searchable prose
to avoid an ambiguous `--explain=--size` result.

## Actions

<!-- mant:entries role=command case=insensitive -->
- `new-tab`, `nt`: Create a tab; this action is implied when no action name is present.
- `split-pane`, `sp`: Split the active pane horizontally or vertically.
- `focus-tab`, `ft`: Focus a tab by zero-based index.
- `move-focus`, `mf`: Move focus in a direction such as `up`, `down`, `left`, or `right`.
- `move-pane`, `mp`: Move the active pane to another tab.
- `swap-pane`: Swap the active pane with the pane in a given direction.

## Tab and pane options

<!-- mant:entries role=option case=sensitive -->
- `-p PROFILE`, `--profile PROFILE`: Use a profile name or GUID.
- `-d DIRECTORY`, `--startingDirectory DIRECTORY`: Set the shell's starting directory.
- `--title TEXT`: Set the initial tab title.
- `--tabColor COLOR`: Set an initial `#RGB` or `#RRGGBB` tab color.
- `--suppressApplicationTitle`: Keep the supplied title instead of allowing the application to replace it.
- `--useApplicationTitle`: Allow the application title to replace the supplied title.
- `--colorScheme NAME`: Override the profile's color scheme.
- `--appendCommandLine`: Append the supplied command line to the profile default instead of replacing it.
- `--inheritEnvironment`: Inherit the Terminal server environment for a new session.
- `-H`, `--horizontal`: Split into panes arranged above/below each other.
- `-V`, `--vertical`: Split into panes arranged side by side.
- `-s FRACTION`, `--size FRACTION`: Allocate this fraction of the parent pane to a new split.
- `-D`, `--duplicate`: Duplicate the current pane when splitting.
- `-t INDEX`, `--target INDEX`: Select the zero-based tab for `focus-tab`.
- `--tab INDEX`: Select the destination tab for `move-pane`.

The literal negated spelling `!--reloadEnvironment` is also documented for the
environment-inheritance setting. ManT 0.7.0 does not accept `!` as a semantic
option prefix, so this exceptional token remains searchable prose rather than
an outline entry.

An action's trailing `COMMANDLINE` replaces or augments the profile command and
can include its own options. Position action options before that command line
to avoid assigning them to the child program.

## PowerShell considerations

Windows Terminal uses semicolons to separate actions, while PowerShell uses
them to separate statements. Escape each Terminal delimiter with a backtick:

```powershell
wt.exe new-tab -p 'Command Prompt' `;
    split-pane -p 'Windows PowerShell' -H `;
    split-pane wsl.exe
```

For a fully literal tail, PowerShell's stop-parsing token can be used only in a
direct native invocation:

```powershell
wt.exe --% new-tab cmd.exe ; split-pane -p "Windows PowerShell" ; split-pane -H wsl.exe
```

Everything after `--%` is literal, so PowerShell variables and expressions no
longer expand. Do not build either form from untrusted profile names, paths, or
child command text.

## Process and window behavior

Targeting an existing window sends an action to the Terminal application; a
new `wt.exe` process is not a durable owner of the created shell. PowerShell can
wait differently for packaged GUI applications than Cmd. Use application-
specific completion signals rather than `$LASTEXITCODE` to decide when a tab's
workload has finished.

## Common mistakes

### Leaving semicolons unescaped in PowerShell

PowerShell starts a new statement such as `split-pane`, which then fails command
resolution. Use `` `; `` between `wt.exe` actions or the direct `--%` form.

### Confusing window size with pane size

Top-level `--size C,R` uses columns and rows. `split-pane --size FRACTION` uses
a fractional share such as `0.4`.

### Assuming `wt.exe` is always on PATH

The alias can be disabled and Store installations can differ by context.
Inspect `Get-Command wt.exe -All -CommandType Application` and the Windows
Terminal package registration.

## Version and availability

Commands and options evolve with Windows Terminal, not the Windows kernel
alone. Preview and stable packages can differ, and a target window must belong
to a compatible Terminal instance. Check `wt.exe --help` and package version
on the actual user desktop.

## Verification boundary

Current options, actions, PowerShell delimiter rules, and packaged-application
behavior were reviewed against official Windows Terminal documentation. No GUI
window, tab, pane, profile, or child shell was launched.

## Related documents

- [start](start.md)
- [cmd.exe](cmd.exe.md)
- [wsl.exe](wsl.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[Windows Terminal command-line arguments](https://learn.microsoft.com/windows/terminal/command-line-arguments).
Exact upstream revision and path are recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
