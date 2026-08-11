<!-- mant:tldr:start -->
# schtasks

> Query and manage Windows Task Scheduler tasks from the command line.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/schtasks.

- List tasks verbosely:

`schtasks /query /fo list /v`

- Query one task by exact task name:

`schtasks /query /tn {{task-name}} /fo list /v`

- Start an existing reviewed task:

`schtasks /run /tn {{task-name}}`
<!-- mant:tldr:end -->

# schtasks

## Synopsis

```text
schtasks /query | /create | /change | /run | /end | /delete [options]
```

`schtasks.exe` queries and manages Windows Task Scheduler tasks. Task creation,
changes, runs, and deletions can affect privilege, persistence, credentials,
and production workloads; treat them as administrative changes.

## Inspect before change

Start by querying exact task identities and settings:

```powershell
schtasks.exe /query /tn '\Contoso\NightlyBackup' /fo list /v
```

Review the task path, principal, run level, trigger, executable, arguments,
working directory, and result history. A task can run under a different user
and environment than the PowerShell process that manages it.

## Create and change deliberately

Use `/create` or `/change` only with explicit task names, reviewed schedule
settings, and approved security context. Do not place secrets in a command
line or task definition when a managed credential mechanism is available.
Quote and test command arguments in the exact task-host context: Task Scheduler
does not inherit the interactive PowerShell profile or console environment.

Use `/run` to start a known task and `/end` or `/delete` only with a narrowly
confirmed task name. Deleting a task can remove a scheduled operational or
security function and may not be recoverable without exported configuration.

## Output and exit status

`schtasks.exe` emits text. `/fo list /v` is good for inspection but not a
stable API; use PowerShell scheduled-task cmdlets where their typed objects and
availability suit the host. Check `$LASTEXITCODE` after native invocations and
verify the Task Scheduler result separately from the command that requested it.

## Related documents

- [robocopy](robocopy.md)
- [sc](sc.md)
- [Command-line tools for PowerShell](pwsh-cli.md)

## Sources and license

This original command guide was adapted from the official
[schtasks documentation](https://learn.microsoft.com/windows-server/administration/windows-commands/schtasks)
and its linked subcommand references. It emphasizes exact task identity and
host-context review. Exact upstream revision and paths are recorded in
`upstream/cli.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
