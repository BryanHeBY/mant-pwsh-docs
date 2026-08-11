<!-- mant:tldr:start -->
# about_Profiles

> Customize Windows PowerShell 5.1 startup with profile scripts while keeping automation reproducible.
> More information: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-5.1.

- Show the current-host profile path:

`$PROFILE`

- Test whether it exists:

`Test-Path -LiteralPath $PROFILE`

- Start without loading profiles:

`powershell.exe -NoProfile`
<!-- mant:tldr:end -->

# about_Profiles

## Short description

A profile is a PowerShell script that runs as a Windows PowerShell session
starts. Profiles can define prompts, aliases, functions, imported modules,
helper variables, and preferences. They are personal interactive configuration,
not an automation dependency.

## Profile locations

`$PROFILE` contains the path for the current user and current host. It has
properties for the other standard combinations of current user or all users,
and current host or all hosts. The four logical scopes are:

- current user, current host;
- current user, all hosts;
- all users, current host;
- all users, all hosts.

The actual path depends on the Windows version and host. The console host and
Windows PowerShell ISE use different host-specific profile names. Inspect the
installed host rather than copying a path from another machine:

```powershell
$PROFILE |
    Get-Member -MemberType NoteProperty |
    ForEach-Object { '{0}: {1}' -f $_.Name, $PROFILE.($_.Name) }
```

## Creating a profile

Profiles are ordinary PowerShell scripts. Create the parent directory and file
only after reviewing the chosen target. Keep profile work fast and predictable:

```powershell
if (-not (Test-Path -LiteralPath $PROFILE)) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $PROFILE) -Force |
        Out-Null
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}
```

Put substantial reusable behavior in a source-controlled module rather than a
profile. A profile should improve an interactive shell, not silently configure
build, deployment, or security behavior.

## Loading order and hosts

Windows PowerShell loads applicable all-users profiles before current-user
profiles. Host-specific profiles and all-hosts profiles are distinct. A console
window, Windows PowerShell ISE, remoting endpoint, Task Scheduler task, or a
third-party host can therefore start with different profile state.

A profile path does not prove it will load. Startup options, execution policy,
file permissions, host policy, endpoint configuration, and user identity can
prevent loading.

## Automation and troubleshooting

Use `powershell.exe -NoProfile` for scripts, scheduled tasks, CI jobs, bug
reports, and performance investigations. It avoids aliases, functions, modules,
prompts, and preference changes introduced by local customization.

```powershell
powershell.exe -NoLogo -NoProfile -NonInteractive -File .\build.ps1
```

When an interactive command behaves differently from automation, compare
`Get-Command NAME -All`, `$PSModulePath`, `$env:PATH`, and relevant preference
variables with and without profiles.

## Security

Treat a profile as executable code. Do not paste unreviewed snippets, store
secrets in profile text, or use a profile to bypass a controlled endpoint.
All-users profile changes can affect other users. Use least privilege and a
reviewable configuration process.

Execution policy is not a security boundary. It can affect profile loading but
does not make untrusted source safe to execute.

## Related documents

- [powershell](powershell.md)
- [about_Automatic_Variables](about_Automatic_Variables.md)
- [Windows PowerShell 5.1 shell and language](pwsh51.md)

## Sources and license

This original ManT-oriented page was adapted from the official
[about_Profiles reference](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-5.1).
It emphasizes Windows-host discovery, reproducible automation, and profile
security. Exact upstream revision and path are recorded in `upstream/pwsh51.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
