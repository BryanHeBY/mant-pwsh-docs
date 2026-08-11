<!-- mant:tldr:start -->
# about_Profiles

> Customize PowerShell 7 startup with profile scripts while keeping automation reproducible.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.6.

- Show the current-host profile path:

`$PROFILE`

- Test whether it exists:

`Test-Path -LiteralPath $PROFILE`

- Start without loading profiles:

`pwsh -NoProfile`
<!-- mant:tldr:end -->

# about_Profiles

## Short description

A PowerShell profile is a script that runs as an interactive session starts.
Profiles can define prompts, aliases, functions, imported modules, helper
variables, and preferences. They are useful personal configuration, but they
are not an automation dependency.

## Profile locations

`$PROFILE` contains the path for the current user and current host. It also
has properties for the other standard combinations of current user or all
users, and current host or all hosts. The four logical profile scopes are:

- current user, current host;
- current user, all hosts;
- all users, current host;
- all users, all hosts.

The concrete path depends on the operating system, PowerShell installation,
and host. Inspect the values rather than copying an example path from another
machine:

```powershell
$PROFILE |
    Get-Member -MemberType NoteProperty |
    ForEach-Object { "{0}: {1}" -f $_.Name, $PROFILE.($_.Name) }
```

## Creating a profile

Profiles are ordinary PowerShell scripts. Create the parent directory and file
only after reviewing the target path. Keep startup work fast and predictable:

```powershell
if (-not (Test-Path -LiteralPath $PROFILE)) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $PROFILE) -Force | Out-Null
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}
```

Use a source-controlled module for substantial reusable functions rather than
placing application logic in a profile. A profile should improve an interactive
experience, not silently configure build, deployment, or security behavior.

## Loading order and hosts

PowerShell loads applicable all-users profiles before current-user profiles.
Host-specific profiles are distinct from all-hosts profiles. A console host,
an integrated terminal, an editor host, and a remoting endpoint can therefore
have different profile behavior.

The profile path for a host does not prove that the host will load it. Startup
options, host policy, file permissions, execution policy on Windows, and
endpoint configuration can prevent loading.

## Automation and troubleshooting

Use `pwsh -NoProfile` for scripts, scheduled tasks, CI jobs, bug reports, and
performance investigations. It avoids aliases, functions, modules, prompts,
and preference changes introduced by local customization.

```powershell
pwsh -NoLogo -NoProfile -NonInteractive -File ./build.ps1
```

If behavior differs between an interactive prompt and automation, compare the
output of `Get-Command NAME -All`, `$PSModulePath`, `$env:PATH`, and relevant
preference variables with and without profiles.

## Security

Treat a profile as executable code. Do not paste unreviewed profile snippets,
store secrets in profile text, or use a profile to bypass a controlled
endpoint. On shared machines, all-users profile changes can affect other
users. Use least privilege and a reviewable configuration process.

Execution policy is not a security boundary. It can influence profile loading
on Windows, but it does not make untrusted source safe to run.

## Platform and version differences

PowerShell 7 supports profiles on Windows, macOS, and Linux, but default
locations, filesystem permissions, available hosts, and installed modules
differ. A profile that loads successfully on one platform can refer to tools
or paths that do not exist on another. Prefer platform guards and small,
separable configuration modules for cross-platform profiles.

## Related documents

- [pwsh](pwsh.md)
- [about_Automatic_Variables](about_Automatic_Variables.md)
- [PowerShell 7 shell and language](pwsh7.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_Profiles reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.6).
It emphasizes safe discovery, reproducible automation, and profile security.
Exact upstream revision and path are recorded in `upstream/pwsh7.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
