<!-- mant:tldr:start -->
# cleanmgr

> Review Disk Cleanup categories interactively, store one numbered profile deliberately, and remember that running the profile can delete selected data across every enumerated drive without a dry run.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/cleanmgr.

- Display installed cleanup modes before selecting any deletion behavior:

`cleanmgr.exe /?`

- Open interactive Disk Cleanup for one drive and review candidates before confirmation:

`cleanmgr.exe /d {{C}}`

- Interactively define numbered profile 101 for the selected drive/context:

`cleanmgr.exe /d {{C}} /sageset:{{101}}`

- After reviewing the stored profile and every affected drive, run profile 101:

`cleanmgr.exe /sagerun:{{101}}`
<!-- mant:tldr:end -->

# cleanmgr

## Overview

`cleanmgr.exe` is the legacy Windows Disk Cleanup UI/runner. `/sageset:n` stores
selected cleanup handlers in registry state, `/sagerun:n` executes that profile
against enumerated drives, `/tuneup:n` configures and runs it, and `/lowdisk`,
`/verylowdisk`, and `/autoclean` select increasingly automatic behaviors.

## Common mistakes

- Assuming `/d C` limits `/sagerun:n`; Microsoft documents that `/d` is not used
  with `/sagerun`, which enumerates all drives. Inspect removable/data volumes.
- Treating the profile number as a portable definition. Its registry selections,
  handlers, defaults, elevation, user/machine context, and availability can vary.
- Using `/verylowdisk`, `/autoclean`, `/tuneup`, or a scheduled `/sagerun` without
  an approval, category inventory, backup/rollback, and post-clean verification.
- Assuming there is a reliable dry run or that estimated bytes equal recoverable
  bytes. Open files, hard links, compression, updates, and concurrent work differ.
- Selecting Recycle Bin, upgrade/installation rollback, dumps, logs, caches,
  offline files, or delivery/update artifacts without retention/support review.
- Editing `VolumeCaches`/`StateFlags` registry values copied from web scripts.
  Handlers and meanings are build/product specific and can expand future scope.

## PowerShell behavior

Use `cleanmgr.exe` explicitly; `/sageset` is interactive and stored state is not
a PowerShell object. Record profile ID, caller/elevation, handler selections,
drives, free space before/after, files/categories removed, native status, and
events. Do not use `Invoke-Expression` or directly delete guessed cache trees.

## Version and platform differences

`cleanmgr.exe` is Windows-only and legacy. Its presence, handlers, UI, defaults,
system-file elevation, profile registry state, and relationship with Storage
Sense vary by build, edition, installed features/products, language, and policy.

## Related documents

- [ms-settings](ms-settings.md)
- [dism](dism.md)
- [defrag](defrag.md)
- [fsutil](fsutil.md)

## Sources and license

This original guide was adapted from Microsoft's official
[cleanmgr reference](https://learn.microsoft.com/windows-server/administration/windows-commands/cleanmgr).
Drive/profile scope was cross-checked against practitioner questions about
[automating Disk Cleanup](https://superuser.com/questions/131281/automating-disk-cleanup-on-windows-using-commandline)
and a [profile unexpectedly touching USB drives](https://superuser.com/questions/1720643/disk-cleanup-powershell-script).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Super User contributions are licensed under CC BY-SA 4.0.
