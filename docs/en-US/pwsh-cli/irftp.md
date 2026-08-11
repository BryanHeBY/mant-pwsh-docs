<!-- mant:tldr:start -->
# irftp

> Identify a legacy infrared file-transfer workflow and move it to an authenticated, integrity-checked transport.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/irftp.

- Confirm whether the legacy executable exists without opening its UI:

`Get-Command irftp.exe -ErrorAction SilentlyContinue | Select-Object Name, Source, Version`

- Hash a file before an approved transfer:

`Get-FileHash -LiteralPath "{{C:\Transfer\example.txt}}" -Algorithm SHA256`

- Send one explicitly named file over an already established infrared link:

`irftp.exe "{{C:\Transfer\example.txt}}"`

- Open the Wireless Link picker on a compatible interactive host:

`irftp.exe /s`
<!-- mant:tldr:end -->

# irftp

## Overview

`irftp.exe` sends one or more files through the legacy Windows infrared
Wireless Link facility. A file path sends named content, `/s` opens the picker,
and `/h` sends without displaying the dialog. The infrared hardware and link
must already be enabled and working.

## Common mistakes

### Treating proximity as authentication

An infrared link and visible peer are not sufficient authorization. Confirm the
receiving device/operator, data classification, physical environment, and
transfer policy. Hash the source and verify the received file independently.

### Using `/h` to hide operational uncertainty

Hidden mode suppresses the dialog; it does not prove the correct peer, success,
confidentiality, or integrity. Preserve explicit file names, return status, and
receiver confirmation. Never use wildcards for sensitive mixed directories.

### Assuming a modern banner guarantees infrared support

The command and Wireless Link UI are legacy and frequently absent even when a
Learn page lists current Windows releases. Check executable, device, driver,
link, and local help on the exact host.

### Replacing it with unauthenticated ad-hoc transfer

Migration should improve identity, encryption, integrity, logging, retention,
and least privilege. Use an approved SMB/SFTP/HTTPS/device-management channel,
not an arbitrary consumer sharing service.

## PowerShell behavior

Invoke `irftp.exe` explicitly and quote every path. It is a native GUI-aware
tool, so process exit and dialog completion may not alone prove receipt. Avoid
passing secrets or untrusted filenames on the command line.

## Version and platform differences

This is Windows-only legacy hardware/UI integration. Device capabilities,
drivers, interactive session, policy, and executable presence determine whether
it can run. Record absence as a migration signal rather than installing an
unverified copy.

## Related documents

- [ftp](ftp.md)
- [ssh](ssh.md)

## Sources and license

Adapted as an original migration guide from Microsoft's
[irftp reference](https://learn.microsoft.com/windows-server/administration/windows-commands/irftp).
Exact provenance is in `upstream/cli.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
