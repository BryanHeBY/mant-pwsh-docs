<!-- mant:tldr:start -->
# reg.exe

> Query, export, and carefully modify the Windows Registry with `reg.exe`.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/reg.

- Query one value without changing the registry:

`reg.exe query '{{HKCU\Software\Vendor\Product}}' /v {{ValueName}}`

- Export a local key to a new protected path before a reviewed change:

`$key = '{{HKCU\Software\Vendor\Product}}'; $backup = '{{C:\backup\product.reg}}'; if (Test-Path -LiteralPath $backup) { throw "Refusing to replace $backup" }; reg.exe export $key $backup; if ($LASTEXITCODE -ne 0) { throw "Registry export failed: $LASTEXITCODE" }; Get-Item -LiteralPath $backup`

- Query an explicit registry view:

`reg.exe query '{{HKLM\Software\Vendor\Product}}' {{[/reg:32|/reg:64]}}`

- Query registry-virtualization flags for one exact local key without changing them:

`reg.exe flags '{{HKLM\Software\Vendor\Product}}' query {{[/reg:32|/reg:64]}}`

- Add a reviewed value after backup:

`reg.exe add '{{HKCU\Software\Vendor\Product}}' /v {{ValueName}} /t {{REG_SZ}} /d '{{data}}'`

- Search key names, value names, and data recursively:

`reg.exe query '{{HKCU\Software}}' /f '{{pattern}}' /s`

- Display top-level registry operations:

`reg.exe /?`

- Display syntax for one registry operation:

`reg.exe {{query|add|delete|copy|save|restore|load|unload|export|import|compare}} /?`
<!-- mant:tldr:end -->

# reg.exe

## Overview

`reg.exe` reads and changes Windows Registry keys and values. It supports local
operations and a limited set of remote operations. Direct registry editing
bypasses safeguards exposed by supported applications, policy tools, Control
Panel, Settings, and MMC; use those interfaces when they exist.

Back up the narrow target, record its original value and type, and define a
rollback before any change. Registry mistakes can break applications, user
profiles, security policy, startup, or Windows itself.

## Command families

```text
reg.exe add
reg.exe compare
reg.exe copy
reg.exe delete
reg.exe export
reg.exe flags
reg.exe import
reg.exe load
reg.exe query
reg.exe restore
reg.exe save
reg.exe unload
```

<!-- mant:entries role=command case=insensitive -->
- `query`: Read keys and values or search recursively.
- `add`: Create a key or set a named/default value and data type.
- `delete`: Delete a key, one value, the default value, or all values.
- `compare`, `copy`: Compare or copy registry subtrees.
- `export`, `import`: Transfer local registry content in `.reg` text format.
- `save`, `restore`: Save or restore registry data in hive format.
- `load`, `unload`: Temporarily mount or unmount a saved hive under HKLM or HKU.
- `flags`: Query or replace registry-virtualization flags for an exact local key below `HKLM\Software`.

## Query parameters

```text
reg.exe query KEY [/v VALUE | /ve] [/s] [/se SEPARATOR] [/f DATA]
              [/k | /d] [/c] [/e] [/t TYPE] [/z] [/reg:32 | /reg:64]
```

<!-- mant:entries role=option case=insensitive -->
- `/v NAME`: Query a named value.
- `/ve`: Query the unnamed default value.
- `/s`: Recurse through all subkeys and values.
- `/se SEPARATOR`: Set the single-character separator used when displaying
  `REG_MULTI_SZ` data; the default separator is `\0`.
- `/k`: Restrict a `/f` search to key names; the context-dependent `/d`
  selector restricts the same search to value data.
- `/c`: Make search matching case-sensitive.
- `/e`: Require an exact match.
- `/t TYPE`: Restrict search to a registry data type.
- `/z`: Include the numeric type identifier.
- `/reg:32`, `/reg:64`: Select the 32-bit or 64-bit registry view.

`reg query` returns native exit code `0` for success and `1` for failure. It
emits formatted text, not PowerShell registry objects.

## Add and delete parameters

```text
reg.exe add KEY [/v NAME | /ve] [/t TYPE] [/s SEPARATOR] [/d DATA]
            [/f] [/reg:32 | /reg:64]
reg.exe delete KEY [/v NAME | /ve | /va] [/f]
```

For `add`, specify the data type rather than relying on a default when the
consumer expects `REG_DWORD`, `REG_EXPAND_SZ`, `REG_MULTI_SZ`, `REG_BINARY`, or
another exact type. `/f` suppresses confirmation and therefore requires an
already verified key, view, value name, type, data, and rollback.

<!-- mant:entries role=option case=insensitive -->
- `/va`: For `reg delete`, delete all values in the key but retain its subkeys.
- `/y`: For supported copy/export/save/restore operations, overwrite without prompting; inspect the exact subcommand contract first.

## Context-dependent parameters

The meaning of these selectors is owned by the selected `reg` subcommand.
Inspect the complete command family before constructing an invocation.

<!-- mant:entries role=option case=insensitive -->
- `/f`: With `query`, search for the following data pattern (default `*`);
  with `add` or `delete`, suppress confirmation without validating the target
  or creating rollback.
- `/d`: With `query /f`, restrict matching to value data; with `add`, supply
  the new value data using the selected registry type and separator.

For `delete`, omitting `/v`, `/ve`, and `/va` deletes the named key and its
subkeys and values. `/va` deletes all values in the key but not its subkeys.
Never construct a delete target from unvalidated input.

## Registry virtualization flags

```text
reg.exe flags KEY query [/reg:32 | /reg:64]
reg.exe flags KEY set [DONT_VIRTUALIZE] [DONT_SILENT_FAIL] [RECURSE_FLAG]
                     [/reg:32 | /reg:64]
```

`flags query` is read-only. `flags set` is a replacement operation: flags
listed on the command line are set and omitted flags are cleared. It applies
only to local keys below `HKLM\Software` and changes legacy registry
virtualization behavior, not ordinary key ACLs or the selected 32/64-bit view.

`DONT_VIRTUALIZE` disables write virtualization, `DONT_SILENT_FAIL` disables
the fallback reopen behavior, and `RECURSE_FLAG` makes the flags propagate to
new descendant keys. Microsoft states that changing `RECURSE_FLAG` does not
retroactively set or clear flags on existing descendants. Installed help on
the recorded build shows a `/s` example for applying `set` to subkeys even
though `/s` is absent from its formal syntax line; treat that as a
build-dependent help discrepancy and do not use it without disposable-fixture
verification and a complete before-state.

## PowerShell boundaries

Call `reg.exe` explicitly. PowerShell's Registry provider returns typed items
and properties, while `reg.exe` emits localized text and uses native exit
codes. Quote registry paths, distinguish the 32-bit and 64-bit views, and
check `$LASTEXITCODE` immediately.

## Export and import

```powershell
$key = 'HKCU\Software\Vendor\Product'
$backup = Join-Path $env:TEMP (
    'product-backup-' + [guid]::NewGuid().ToString('N') + '.reg'
)

if (Test-Path -LiteralPath $backup) {
    throw "Refusing to replace $backup"
}

reg.exe export $key $backup
if ($LASTEXITCODE -ne 0) {
    throw "Registry export failed with exit code $LASTEXITCODE"
}
```

`reg export` is local-only and writes a `.reg` file; `/y` overwrites an existing
file without prompting, while omitting `/y` can stop unattended automation for
an overwrite prompt. Use a new protected path and verify the artifact. Registry
exports can contain credentials, tokens, paths, identities, and application
configuration. `reg import` changes the local registry from a file created in
advance and supports `/reg:32` or `/reg:64`. Inspect the complete file and target
view before importing.

## Remote and root-key limits

Local key names can use HKLM, HKCU, HKCR, HKU, and HKCC. For operations that
support a remote key name such as `\\COMPUTER\HKLM\...`, Microsoft documents
only HKLM and HKU as valid remote roots. Individual subcommands have different
remote limitations; do not assume an operation is remote-capable because
`query` is.

## Common mistakes

### Omitting the registry view

On 64-bit Windows, 32-bit and 64-bit views can expose different keys and
values. Record the caller architecture and use `/reg:32` or `/reg:64` whenever
the consumer's view matters.

### Confusing keys, values, and the default value

A key is a container. `/v NAME` addresses a named value, while `/ve` addresses
the unnamed default value. Omitting these selectors from `reg delete` can
delete the entire key subtree.

### Using the wrong data type

Text that looks like a number is not interchangeable with `REG_DWORD`, and a
literal `%SystemRoot%` stored as `REG_SZ` does not behave like
`REG_EXPAND_SZ`. Verify both type and data after a write.

### Assuming PowerShell objects are accepted as native arguments

Pass a pathname or string property, not a `FileInfo`, RegistryKey, or other
formatted object. Native output is text; use the PowerShell Registry provider
when typed object processing is more important than `reg.exe` compatibility.

### Using `/f`, `/y`, import, or restore without a backup

These forms remove confirmation or replace persistent state. A command exit
code cannot prove that applications will accept the new configuration. Query
the value afterward and test the consuming feature.

### Reusing an export path in unattended automation

Without `/y`, an existing target can produce an interactive overwrite prompt;
with `/y`, it is replaced. Neither behavior is a safe no-clobber default. Select
a new protected path, reject an existing file before invoking `reg export`,
check `$LASTEXITCODE`, and verify the resulting backup before changing state.

### Treating `reg flags set` as additive

Every omitted virtualization flag is cleared. Query the exact key and registry
view first, preserve all three flag states, and avoid `set` unless the complete
replacement state and compatibility impact are approved. Do not confuse the
command's `RECURSE_FLAG`—which affects propagation to newly created
descendants—with the installed help's separately shown `/s` example.

## Version and platform differences

`reg.exe` is Windows-only. This page targets supported Windows 10, Windows 11,
and Windows Server versions. Registry keys, value meanings, permissions,
virtualization, views, and remote-service requirements are product- and
version-specific. Registry virtualization is an interim compatibility feature
for eligible 32-bit interactive processes and keys; modern applications should
not depend on it.

## Runtime evidence

Windows NT 10.0.26200.0 top-level help exposed FLAGS. Its SET syntax clears
omitted flags; installed help also shows a /s example that is absent from the
formal syntax line, so the page records /s as a build-dependent discrepancy
rather than recommending it.

## Related documents
- [control.exe](control.exe.md)
- [mmc.exe](mmc.exe.md)
- [cmd.exe](cmd.exe.md)
- [Windows tools for PowerShell](windows-tools.md)

## Sources and license

This original guide was adapted from Microsoft's official
[reg command family](https://learn.microsoft.com/windows-server/administration/windows-commands/reg),
including the references for
[reg query](https://learn.microsoft.com/windows-server/administration/windows-commands/reg-query),
[reg add](https://learn.microsoft.com/windows-server/administration/windows-commands/reg-add),
[reg delete](https://learn.microsoft.com/windows-server/administration/windows-commands/reg-delete),
[reg export](https://learn.microsoft.com/windows-server/administration/windows-commands/reg-export),
and [reg import](https://learn.microsoft.com/windows-server/administration/windows-commands/reg-import).
The `flags` family follows Microsoft's
[Registry virtualization](https://learn.microsoft.com/windows/win32/sysinfo/registry-virtualization)
contract and the syntax installed on the recorded host.
The 32-bit/64-bit view trap is also evidenced by the community discussion
[How to access the 64-bit registry from a 32-bit PowerShell instance?](https://stackoverflow.com/questions/630382/how-to-access-the-64-bit-registry-from-a-32-bit-powershell-instance).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation is licensed under CC BY 4.0 and Stack Overflow
content under CC BY-SA 4.0. This adaptation is licensed under CC BY 4.0; no
Stack Overflow answer text is reproduced.
