<!-- mant:tldr:start -->
# ktmutil.exe

> Inspect Kernel Transaction Manager state; never resolve or force an in-doubt transaction without the owning resource manager's recovery decision.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/ktmutil.

- Request the installed subcommand list from an elevated diagnostic shell; an
  ordinary token can be rejected before listing it:

`ktmutil.exe`

- List transaction managers before narrowing the investigation:

`ktmutil.exe list tms`

- List all visible transactions and preserve the output as evidence:

`ktmutil.exe list transactions`

- List transactions for one verified transaction-manager GUID:

`ktmutil.exe list transactions {{'{TM-GUID}'}}`
<!-- mant:tldr:end -->

# ktmutil.exe

## Overview

`ktmutil.exe` starts the Kernel Transaction Manager utility. Its `list`
operations inspect transaction managers and transactions. `resolve complete`,
`resolve commit`, `resolve rollback`, `force commit`, `force rollback`, and
`forget` participate in recovery and can decide or discard transaction state.
Those operations are not generic cleanup commands.

## Syntax map

<!-- mant:entries role=command case=insensitive -->
- `ktmutil.exe`: Inspect or resolve Windows Kernel Transaction Manager state.
- `list`: List transaction managers, transactions, or enlistments.
- `tm`: Select transaction-manager operations.
- `tx`: Select transaction operations.
- `en`: Select enlistment operations.
- `resolve`: Force a reviewed in-doubt transaction outcome.
- `commit`: Resolve the selected transaction as committed.
- `rollback`: Resolve the selected transaction as rolled back.
- `complete`: Complete an enlistment's recovery processing.
- `forget`: Discard remembered transaction recovery information.

```text
ktmutil list tms
ktmutil list transactions [{TmGUID}]
ktmutil resolve complete {TmGUID} {RmGUID} {EnGUID}
ktmutil resolve commit {TxGUID}
ktmutil resolve rollback {TxGUID}
ktmutil force commit {GUID}
ktmutil force rollback {GUID}
ktmutil forget
```

## Common mistakes

### Forcing the outcome because a transaction is old

Age does not establish the correct atomic outcome. A forced commit can publish
partial work; rollback can discard work another participant considers
committed. Identify the application, transaction manager, resource managers,
enlistments, logs, backup/recovery state, and vendor procedure first.

### Guessing which GUID a subcommand expects

TM, RM, enlistment, and transaction GUIDs are different identities. Preserve
the listing and map each GUID to its role; do not paste the only GUID visible
into a destructive form.

### Using `forget` as garbage collection

Forgetting recovery information can make reconciliation impossible. It needs
the same owner authorization and evidence preservation as force/resolve.

### Assuming list output is an application-consistent diagnosis

KTM state is only one layer. Correlate it with the owning service/database,
resource-manager logs, event timestamps, cluster/failover state, and supported
recovery documentation.

## PowerShell boundaries

KtmUtil returns native text, not transaction objects. Preserve stdout, stderr,
time, host, executable version, exact command, and `$LASTEXITCODE`. Braces in
literal GUID arguments can be single-quoted as shown to make intent clear.

## Version and platform differences

This is Windows-only low-level recovery tooling. Installed resource managers,
transaction protocols, permissions, application versions, and failover state
govern safe use; never transfer a recovery decision between environments.

On Windows NT `10.0.26200.0`, exact System32 file version `10.0.26100.1` did
not list subcommands for the recorded ordinary token. A bare invocation printed
one localized standard-output line requiring administrator privileges, no
standard-error lines, and returned 1. This is access evidence only, not help or
transaction inventory. No manager, transaction, enlistment, GUID, service,
database, recovery decision, resolve, force, commit, rollback, complete, or
forget operation ran.

## Runtime evidence

On Windows NT 10.0.26200.0, exact System32 file version 10.0.26100.1 bare
invocation under the recorded ordinary token returned 1 with one localized
stdout line requiring administrator privileges and no stderr. This is access
evidence, not the documented subcommand list; no transaction inventory or
resolve/force/forget/recovery mutation ran.

## Related documents
- [wevtutil.exe](wevtutil.exe.md)
- [sc.exe](sc.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[KtmUtil reference](https://learn.microsoft.com/windows-server/administration/windows-commands/ktmutil)
and [Kernel Transaction Manager transaction model](https://learn.microsoft.com/windows/win32/ktm/transactions).
Exact provenance is recorded in `upstream/windows-tools.json`. Microsoft documentation
and this adaptation are licensed under CC BY 4.0.
