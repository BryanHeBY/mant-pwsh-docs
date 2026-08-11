<!-- mant:tldr:start -->
# gettype

> Identify and retire an undocumented Windows Server 2003-era `gettype` dependency.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/gettype.

- Check whether this exact host resolves a native executable with that name:

`Get-Command gettype.exe -ErrorAction SilentlyContinue | Select-Object Name, CommandType, Source, Version`

- Preserve the binary's identity without running it:

`Get-Item -LiteralPath "{{C:\Windows\System32\gettype.exe}}" | Select-Object FullName, Length, LastWriteTime, VersionInfo; Get-AuthenticodeSignature -LiteralPath "{{C:\Windows\System32\gettype.exe}}"; Get-FileHash -LiteralPath "{{C:\Windows\System32\gettype.exe}}" -Algorithm SHA256`

- Search copied legacy scripts for the actual invocation and arguments:

`Get-ChildItem -LiteralPath "{{D:\LegacyScripts}}" -File -Recurse | Select-String -Pattern '(?i)(^|[^\w.-])gettype(?:\.exe)?([^\w.-]|$)'`

- Check local help only in an approved isolated legacy environment:

`gettype.exe /?`
<!-- mant:tldr:end -->

# gettype

## Overview

Microsoft's current catalog says only that `gettype` was included in Windows
Server 2003, is deprecated, and may not be supported in future releases. The
linked previous-version detail is no longer generally accessible and the
current page provides no syntax or semantic contract. This page therefore
documents safe identification and migration, not guessed behavior.

## Common mistakes

### Inventing syntax from the command name

`gettype` could be confused with .NET `GetType()`, a vendor program, a script
function, or similarly named subcommands. Do not let an AI or runbook infer
arguments or output from the name. Bind evidence to a specific signed/hash-
identified binary, OS image, local help, and captured historical invocation.

### Running an unknown legacy binary to discover it

First inspect path, signature, hash, version resource, acquisition provenance,
and the script that calls it. If execution is necessary, use an isolated copy
of the matching supported historical environment with no production secrets or
network trust.

### Treating the generated applicability banner as support

The body explicitly identifies Windows Server 2003 and deprecation. That is
stronger lifecycle evidence than a modern generic banner. Absence on a current
host is expected and should trigger migration, not an arbitrary download.

## PowerShell behavior

`Get-Command gettype.exe` disambiguates a native executable from PowerShell or
third-party names. Preserve `$LASTEXITCODE` and raw output only after the binary
has been authorized. Replacement depends on the observed purpose; use a typed
PowerShell/.NET/API query rather than emulating unknown output text.

## Version and platform differences

The only authoritative version statement in the available catalog is Windows
Server 2003-era and deprecated. Do not claim support on current Windows. Record
an environmental exception when the executable is absent.

## Related documents

- [where](where.md)
- [certutil](certutil.md)

## Sources and license

Adapted as an original migration guide from Microsoft's intentionally sparse
[gettype catalog entry](https://learn.microsoft.com/windows-server/administration/windows-commands/gettype).
The missing semantic detail is recorded rather than reconstructed. Exact
provenance is in `upstream/cli.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
