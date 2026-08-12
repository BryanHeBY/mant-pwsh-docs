<!-- mant:tldr:start -->
# esentutl.exe

> Inspect, recover, copy, or repair Extensible Storage Engine database files.
> More information: https://learn.microsoft.com/windows/win32/extensible-storage-engine/extensible-storage-engine-files.

- Display the top-level modes supported by this Windows build:

`esentutl.exe /?`

- Display help for integrity checking before touching a copied database:

`esentutl.exe /g?`

- Check checksums only on an offline copied file after product-specific approval:

`esentutl.exe /k {{database-copy.edb}}`
<!-- mant:tldr:end -->

# esentutl.exe

## Overview

`esentutl.exe` is the low-level utility for Extensible Storage Engine (ESE,
also called JET Blue) databases, logs, and checkpoints. Windows Search, Active
Directory and other Windows/products can use ESE, but their databases have
different ownership, shutdown, backup, recovery, and repair procedures. A valid
Esentutl mode is not permission to run it against a live product database.

## Syntax

```text
esentutl.exe MODE [mode-specific arguments]
```

Append `?` to an installed mode spelling, for example `/g?`, to display its
mode-specific help before use.

## Modes

<!-- mant:entries role=option case=insensitive -->
- `/d`: Defragment an offline database into a compacted copy; this is not Windows drive defragmentation.
- `/r`: Perform soft recovery by replaying a consistent ESE transaction-log set.
- `/g`: Check logical database integrity without repairing it.
- `/k`: Verify page checksums for an ESE database or related file.
- `/p`: Perform hard repair that can discard damaged pages/data; use only under the owning product's explicit last-resort procedure.
- `/m`: Dump file/header metadata using a mode modifier supported by the installed build.
- `/y`: Copy a file using Esentutl's copy mode.
- `/c`: Restore/recover from an ESE backup set using a mode modifier supported by the installed build.

Modes have overlapping letters as their own sub-options and different required
log base names, paths, temporary database locations, page-size switches, and
recovery rules. ManT registers the stable top-level selectors; use
`esentutl.exe /MODE?` for every exact mode-specific option on the target.

## Establish database ownership

Before even an integrity check, identify:

- which Windows role/application owns the `.edb` and its supported recovery
  tool (for example, Active Directory procedures use `ntdsutil` and system-state
  backups, not an improvised generic Esentutl recipe);
- database, checkpoint, reserved-log, current-log, and numbered-log paths plus
  their common generation/base name;
- whether the owning service is stopped cleanly and the database state is
  clean shutdown or dirty shutdown;
- a restorable product-aware backup and a byte-for-byte evidence copy;
- sufficient temporary and destination storage and a rollback/rebuild path.

Never infer that an `.edb` file is self-contained. Recovery can require the
exact matching checkpoint and log generation sequence.

## Inspection-first workflow

Work only on an approved offline copy unless product documentation says
otherwise. Start by recording file hashes and installed mode help:

```powershell
$copy = (Resolve-Path .\database-copy.edb).Path
Get-FileHash -LiteralPath $copy -Algorithm SHA256

esentutl.exe /m $copy
$headerCode = $LASTEXITCODE
esentutl.exe /k $copy
$checksumCode = $LASTEXITCODE

[pscustomobject]@{
    HeaderExitCode = $headerCode
    ChecksumExitCode = $checksumCode
}
```

Even read-only modes can contend with a live owner or give misleading results
on an inconsistent copy. Coordinate service/VSS/product snapshot semantics and
preserve the original before analysis.

## Recovery, defragmentation, and repair

Soft recovery (`/r`) replays logs and depends on exact log base/path/state.
Defragmentation (`/d`) writes a replacement database and requires free space,
ownership/ACL preservation, and a product-supported swap procedure. Hard repair
(`/p`) can restore structural usability by deleting unrecoverable data; it is
not lossless and can leave application-level inconsistency requiring semantic
repair or rebuild.

Do not publish or automate a generic `/r` or `/p` command for arbitrary ESE
databases. Follow the owning product's supported sequence, capture every file,
test on copies, and prefer restore or rebuild when available.

## PowerShell considerations

Arguments are native paths and mode-specific strings. Resolve paths explicitly,
avoid wildcard expansion, capture stdout/stderr, and check `$LASTEXITCODE`
after each invocation. Output is localized diagnostic text and may expose
database paths or identifiers; protect it as support evidence.

## Common mistakes

### Running `/p` because `/g` reports corruption

Hard repair can delete data and invalidate product semantics. Preserve evidence,
try supported restore/soft recovery, and obtain product-owner approval first.

### Running against a live database file

File access can fail, or the result can be inconsistent with memory and logs.
Use the owning product's clean shutdown or snapshot procedure and a copy.

### Mixing logs from another backup or generation

Names can look compatible while signatures/generations are not. Keep the exact
database, checkpoint, and complete log sequence together and let the supported
recovery procedure validate them.

### Treating `/d` like `defrag.exe`

Esentutl `/d` compacts an ESE database and replaces data artifacts; it does not
optimize a volume. Plan free space, ACLs, backup, and application downtime.

## Version and availability

Esentutl ships with Windows, but file formats, page sizes, mode modifiers, and
product support rules vary by OS and database owner. Use the Esentutl binary
from the target system, its `/MODE?` output, and the product's exact-version
recovery documentation.

## Verification boundary

Microsoft ESE file contracts and product recovery warnings were reviewed. No
database, log, checkpoint, service, backup, copy, checksum, integrity check,
recovery, defragmentation, restore, or hard repair ran.

## Related documents

- Active Directory `ntdsutil.exe`
- [vssadmin.exe](vssadmin.exe.md)
- [wbadmin.exe](wbadmin.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[ESE file reference](https://learn.microsoft.com/windows/win32/extensible-storage-engine/extensible-storage-engine-files)
and Microsoft Support Active Directory recovery guidance. Exact upstream
revisions and paths are recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
