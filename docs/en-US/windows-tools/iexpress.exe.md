<!-- mant:tldr:start -->
# iexpress.exe

> Create a Windows self-extracting package interactively or from a reviewed Self Extraction Directive (`.sed`) file.
> More information: https://learn.microsoft.com/previous-versions/windows/internet-explorer/ie-it-pro/internet-explorer-11/ie11-ieak/iexpress-wizard-for-win-server.

- Open the interactive IExpress Wizard:

`iexpress.exe`

- Build from an existing reviewed SED file without reopening the wizard pages:

`iexpress.exe /N "{{C:\Build\package.sed}}"`

- Run the SED build minimized:

`iexpress.exe /N /M "{{C:\Build\package.sed}}"`

- Run the SED build quietly in administrator mode and fail on a nonzero exit status:

`iexpress.exe /N /Q:A "{{C:\Build\package.sed}}"; if ($LASTEXITCODE -ne 0) { throw "IExpress failed with exit code $LASTEXITCODE" }`
<!-- mant:tldr:end -->

# iexpress.exe

## Overview

`iexpress.exe` is the Windows IExpress Wizard. It creates self-extracting
packages and stores a package definition in a Self Extraction Directive
(`.sed`) file. Running it without arguments opens the graphical wizard;
automation reuses a reviewed SED file.

IExpress output is a Windows self-extracting executable backed by Cabinet and
setup technology, not a general-purpose ZIP archive. The SED can name files to
embed and commands to run after extraction. Treat it as executable build code:
review it, resolve every input and output path, and build only trusted content
in an isolated output directory.

## Syntax

```text
iexpress.exe [/N] [/Q[:A|U]] [/M] [SED-FILE]
```

The installed wizard remains the final authority for the exact syntax on a
particular Windows build. Microsoft's current discoverable Learn material is
archived IEAK documentation and does not provide a complete current-client
command reference.

## Common options

<!-- mant:entries role=option case=insensitive attached=fixed -->
- `/N`: Use the supplied SED file to build a package without stepping through the wizard pages.
- `/M`: Run the build process in a minimized window.
- `/Q:A`: Run quietly using administrator-oriented prompts and behavior defined by the package workflow.
- `/Q:U`: Run quietly using user-oriented prompts and behavior defined by the package workflow.

Use an absolute SED path. A relative SED path and relative paths inside that
file can bind to an unexpected working directory when an Agent, task, or build
runner launches IExpress.

## PowerShell usage

Resolve the native executable explicitly, pass each switch as its own argument,
and check both the process status and expected artifact. Do not build a command
string for `Invoke-Expression`.

```powershell
$iexpress = Join-Path $env:SystemRoot 'System32\iexpress.exe'
$sed = (Resolve-Path -LiteralPath '.\package.sed').Path

& $iexpress /N $sed
if ($LASTEXITCODE -ne 0) {
    throw "IExpress failed with exit code $LASTEXITCODE"
}
```

The SED chooses the output and can launch a packaged command. Before running
the build, inspect the file as text and verify all referenced sources. After
the build, verify the exact new artifact's path, hash, signature policy, and
contents in a disposable fixture before distribution or execution.

## Common mistakes

### Treating the output as a ZIP archive

IExpress produces a Windows self-extracting package, not a portable ZIP. Use
`Compress-Archive` or a dedicated archive tool when the consumer needs ZIP and
no embedded setup command.

### Reusing an untrusted SED file

A SED is not passive metadata: it controls embedded files, output, prompts,
and post-extraction execution. Do not run a downloaded or generated SED until
every directive and referenced path has been reviewed.

### Applying package runtime switches to the builder

Microsoft's archived IExpress package documentation lists switches such as
`/R`, `/T`, and `/C` for extraction and restart behavior of generated setup
packages. They are not a safe mechanical substitute for the builder syntax
above. First establish whether a switch belongs to `iexpress.exe`, the emitted
package, or the program that package launches.

### Assuming success proves a safe or distributable package

A zero exit status does not validate embedded content, signing, destination,
or post-extraction behavior. Check the intended artifact explicitly and test
it only in an approved disposable environment.

## Version and platform differences

IExpress is Windows-only. The wizard is present at
`%SystemRoot%\System32\iexpress.exe` on the recorded Windows 11 host, but its
legacy documentation and availability should not be treated as a guarantee
for every Windows edition or future build. Prefer a maintained installer or
packaging system when reproducibility, signing, repair, uninstall, or modern
deployment policy matters.

## Runtime evidence

On Windows NT 10.0.26200.0, PowerShell resolved exact System32
`iexpress.exe`. File metadata reported description `Wizard`, file/product
version `11.00.26100.1`, and length 196608 bytes. The GUI was not launched and
no SED, package, embedded file, setup command, extraction, restart, or output
artifact was created; build behavior remains bounded to an approved disposable
fixture.

## Related documents

- [makecab.exe](makecab.exe.md)
- [expand.exe](expand.exe.md)
- [msiexec.exe](msiexec.exe.md)

## Sources and license

This document was independently adapted from Microsoft's archived
[IExpress Wizard overview](https://learn.microsoft.com/previous-versions/windows/internet-explorer/ie-it-pro/internet-explorer-11/ie11-ieak/iexpress-wizard-for-win-server)
and [IExpress package command-line options](https://learn.microsoft.com/previous-versions/windows/internet-explorer/ie-it-pro/internet-explorer-11/ie11-ieak/iexpress-command-line-options),
plus the CC0 [tldr-pages IExpress page](https://github.com/tldr-pages/tldr/blob/main/pages/windows/iexpress.md).
The Microsoft documentation is licensed under CC BY 4.0; tldr-pages is
licensed under CC0 1.0. This adaptation corrects the archive-format wording,
separates builder options from emitted-package runtime options, and adds
PowerShell and Agent-oriented verification boundaries.
