<!-- mant:tldr:start -->
# sc

> Query and manage Windows service configuration through `sc.exe`.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/sc-query.

- Query one service:

`sc.exe query {{service-name}}`

- Inspect service configuration:

`sc.exe qc {{service-name}}`

- Change a reviewed service setting:

`sc.exe config {{service-name}} start= {{demand}}`
<!-- mant:tldr:end -->

# sc

## Synopsis

```text
sc.exe query [service-name]
sc.exe qc <service-name>
sc.exe config <service-name> <option>= <value>
```

`sc.exe` communicates with the Windows Service Control Manager. It can query,
create, configure, start, stop, and delete services. Service changes can alter
privilege, startup, availability, persistence, and security boundaries.

## Use the executable explicitly

PowerShell can have a different `sc` alias or function in a configured session.
Use `sc.exe` to require the Windows Service Controller, then inspect command
resolution with `Get-Command sc -All` if behavior is unexpected.

```powershell
sc.exe query w32time
sc.exe qc w32time
```

Confirm the exact service name, not only its display name. Review binary path,
account, start type, dependencies, recovery policy, and organization policy
before a configuration change.

## Common mistakes

### Calling `sc` instead of `sc.exe`

In Windows PowerShell, `sc` is normally an alias for `Set-Content`. A command
copied as `sc query w32time` can therefore invoke the wrong command. Use
`sc.exe` and inspect ambiguity with `Get-Command sc -All`.

### Removing the required space after `=`

`sc.exe config w32time start=auto` is not the documented syntax. The native
parser expects `start= auto`; this is unrelated to PowerShell named
parameters.

### Assuming process success proves the requested service state

A successful control request does not prove that a service reached its target
state or stayed there. Check `$LASTEXITCODE`, then query the service again.

## Syntax hazards and destructive operations

The `sc.exe` syntax requires a space after an option name and before its value,
for example `start= demand`. This unusual syntax is not PowerShell parameter
binding. Keep every input explicit and test with the exact installed executable.

`sc.exe create`, `config`, and `delete` can create persistence, break a
workload, or remove a service definition. Use the least-privileged approved
context, capture prior configuration, scope names precisely, and require a
rollback plan. Do not issue bulk service changes from a broad query result.

## Status and automation

`sc.exe` emits text and a native exit code. Check `$LASTEXITCODE` immediately
and query the service afterward to verify the actual state. For typed Windows
PowerShell automation, `Get-Service`, `Set-Service`, and CIM cmdlets can be
clearer where they provide the required feature and permissions.

## Related documents

- [schtasks](schtasks.md)
- [where](where.md)
- [Command-line tools for PowerShell](pwsh-cli.md)

## Sources and license

This original command guide was adapted from official Windows command
documentation for [sc query](https://learn.microsoft.com/windows-server/administration/windows-commands/sc-query),
[sc config](https://learn.microsoft.com/windows-server/administration/windows-commands/sc-config),
and [sc create](https://learn.microsoft.com/windows-server/administration/windows-commands/sc-create).
It emphasizes the executable's distinct syntax and service-change safety.
Exact upstream revision and paths are recorded in `upstream/cli.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
