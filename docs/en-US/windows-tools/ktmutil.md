<!-- mant:tldr:start -->
# ktmutil

> Inspect Kernel Transaction Manager state; never resolve or force an in-doubt transaction without the owning resource manager's recovery decision.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/ktmutil.

- Display the installed subcommands without changing transaction state:

`ktmutil.exe`

- List transaction managers before narrowing the investigation:

`ktmutil.exe list tms`

- List all visible transactions and preserve the output as evidence:

`ktmutil.exe list transactions`

- List transactions for one verified transaction-manager GUID:

`ktmutil.exe list transactions {{'{TM-GUID}'}}`
<!-- mant:tldr:end -->

# ktmutil

## Overview

`ktmutil.exe` starts the Kernel Transaction Manager utility. Its `list`
operations inspect transaction managers and transactions. `resolve complete`,
`resolve commit`, `resolve rollback`, `force commit`, `force rollback`, and
`forget` participate in recovery and can decide or discard transaction state.
Those operations are not generic cleanup commands.

## Syntax map

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

## PowerShell behavior

KtmUtil returns native text, not transaction objects. Preserve stdout, stderr,
time, host, executable version, exact command, and `$LASTEXITCODE`. Braces in
literal GUID arguments can be single-quoted as shown to make intent clear.

## Version and platform differences

This is Windows-only low-level recovery tooling. Installed resource managers,
transaction protocols, permissions, application versions, and failover state
govern safe use; never transfer a recovery decision between environments.

## Related documents

- [wevtutil](wevtutil.md)
- [sc](sc.md)

## Sources and license

This original guide was adapted from Microsoft's official
[KtmUtil reference](https://learn.microsoft.com/windows-server/administration/windows-commands/ktmutil)
and [Kernel Transaction Manager transaction model](https://learn.microsoft.com/windows/win32/ktm/transactions).
Exact provenance is recorded in `upstream/windows-tools.json`. Microsoft documentation
and this adaptation are licensed under CC BY 4.0.
