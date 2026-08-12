<!-- mant:tldr:start -->
# format.exe

> Resolve `format.exe` before use: Windows ships the destructive formatter as `format.com`, not `format.exe`.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/format.

- Confirm that the explicit `.exe` name is absent on the current host:

`Get-Command format.exe -All -ErrorAction SilentlyContinue`

- Resolve the actual Windows formatter without invoking it:

`Get-Command format.com -CommandType Application -ErrorAction Stop`

- Read installed formatter syntax without selecting a volume:

`format.com /?`
<!-- mant:tldr:end -->

# format.exe

## Meaning and resolution

Windows ships its filesystem formatter as `format.com`. It does not ship a
`format.exe`, and explicitly asking PowerShell for `format.exe` does not use
`PATHEXT` to substitute the `.com` extension. If that name resolves, another
package, script, function, alias, or executable supplied it; do not assume it
has the Windows formatter's identity or contract.

<!-- mant:entries role=command case=insensitive -->
- `format.exe`: Non-built-in name; resolve and verify its provenance before any use.
- `format.com`: Actual Windows filesystem formatter; every formatting mode is destructive and has no dry run.
- `format`: Ambient name that can resolve the system `.com` file or an earlier alias, function, script, batch file, or application.

## Why the extension matters

PowerShell command resolution and `PATHEXT` apply when the name has no
extension. An explicit extension selects that exact command name. On developer
machines, package directories can add an unrelated `format.bat` or other
command earlier in `PATH`, so even bare `format` is not a durable identity.

Use `Get-Command format -All` for diagnosis and `format.com` only after the
storage target, restore path, workload outage, and destructive change have been
independently approved. Merely correcting the extension is not authorization
to format a volume.

## PowerShell boundaries

`Get-Command format.exe` requests the explicit `.exe` name; PowerShell does not
replace that suffix with `.com`. By contrast, bare `format` searches aliases,
functions, scripts, and applications and can return several matches. Use
`Get-Command format -All`, verify the selected path and provenance, and keep the
`.com` suffix in any approved Windows formatter invocation.

## Version and platform differences

The recorded Windows NT `10.0.26200.0` host supplies
`C:\Windows\System32\format.com` version `10.0.26100.1` and no built-in
`format.exe`. Windows editions, recovery environments, and filesystem support
can expose different formatter options; non-Windows systems have unrelated
formatting tools. Re-run exact command discovery on the target host instead of
generalizing this file version or option set.

## Common mistakes

### Treating every Windows command as an `.exe`

Windows also ships `.com`, `.cmd`, and script entry points. Inventing an `.exe`
suffix can turn a known system command into a not-found error or, worse, select
an unrelated third-party binary that happens to use that name.

### Falling back to bare `format` without checking precedence

`format` can be shadowed. Inspect every match and invoke the verified full path
or `format.com`; never choose a destructive tool from the first ambient match.

## Full command

See [format.com](format.com.md) for destructive behavior, target-identity
gates, options, exit codes, sanitization limits, and storage recovery planning.

## Runtime evidence

On the recorded Windows host, exact discovery found
`C:\Windows\System32\format.com`, 69,632 bytes, file version
`10.0.26100.1`, and no built-in `format.exe`. Bare `format` discovery also
returned third-party `format.bat` candidates, so an extensionless name is not
an identity gate. Exact `format.com /?` printed 88 help lines and returned 0
without a storage target. This establishes resolution and help behavior only;
no filesystem or media state was read or changed.

## Related documents
- [diskpart.exe](diskpart.exe.md)
- [mountvol.exe](mountvol.exe.md)
- [manage-bde.exe](manage-bde.exe.md)

## Sources and license

This command-resolution guide is based on the official
[Format reference](https://learn.microsoft.com/windows-server/administration/windows-commands/format)
and read-only command discovery on the recorded Windows host. Exact source and
runtime evidence are recorded in `upstream/windows-tools.json` and `release/`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
