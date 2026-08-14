<!-- mant:tldr:start -->
# slmgr.vbs

> Inspect and manage Windows Software Protection licensing and activation.
> More information: https://learn.microsoft.com/windows-server/get-started/activation-slmgr-vbs-options.

- Display concise local Windows licensing information in the console:

`cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /dli`

- Display detailed licensing information for all installed products:

`cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /dlv All`

- Show activation expiration for the active Windows edition:

`cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /xpr`

- Display the installation ID used by an approved offline-activation workflow:

`cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /dti`

- List installed token-based activation issuance licenses:

`cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /lil`

- List valid token-based activation certificates:

`cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /ltc`

- List Active Directory activation objects visible to this computer:

`cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /ao-list`

- Display detailed information for one exact activation ID:

`cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /dlv {{activation-id}}`
<!-- mant:tldr:end -->

# slmgr.vbs

## Overview

`slmgr.vbs` manages Windows licensing through the Software Protection Platform.
Use `cscript.exe` for console output; launching the script through its default
`wscript.exe` association can display modal dialogs that block automation.

## Syntax

```text
slmgr.vbs [COMPUTER [USER PASSWORD]] OPTION [arguments]
```

For console use, prefix this script grammar with `cscript.exe //nologo` and the
absolute `%SystemRoot%\System32\slmgr.vbs` path.

Remote inline credentials are observable and cross-version remote use has
compatibility limits. Prefer Volume Activation Management Tool or supported
management/WMI workflows for remote fleets.

## Read-only information options

<!-- mant:entries role=option case=insensitive -->
- `/dli`: Display concise license information for the active Windows edition, an optional activation ID, or `All` products.
- `/dlv`: Display detailed licensing information, optionally for one activation ID or `All`.
- `/xpr`: Display activation expiration, optionally for one activation ID; most relevant to KMS clients.
- `/dti`: Display the installation ID used by an offline activation workflow, optionally for one activation ID.
- `/lil`: List installed token-based activation issuance licenses.
- `/ltc`: List valid token-based activation certificates.
- `/ao-list`: List Active Directory activation objects visible to the local computer.

## Product key and license options

<!-- mant:entries role=option case=insensitive -->
- `/ipk PRODUCT-KEY`: Install and replace the current applicable 5-by-5 product key; protect the key from logs and command history.
- `/ato`: Request online, MAK, or KMS activation according to the installed key and activation type; accepts an optional activation ID.
- `/upk`: Uninstall a product key, optionally for one activation ID; after restart the product can be unlicensed unless a replacement is installed.
- `/cpky`: Remove the product key from the registry where applicable to reduce disclosure.
- `/ilc LICENSE-FILE`: Install a license file; Slmgr does not itself establish the license file's trustworthiness.
- `/rilc`: Reinstall known-good licenses stored in Windows licensing directories.
- `/rearm`: Reset activation timers where policy/state permits; Sysprep also uses this operation.
- `/rearm-app APPLICATION-ID`: Reset licensing status for one application.
- `/rearm-sku APPLICATION-ID`: Reset licensing status for one SKU.
- `/atp CONFIRMATION-ID`: Complete offline activation using a supplied confirmation ID.

Most mutations require elevation or explicit Standard User Operations policy.
Changing a key, uninstalling it, reinstalling licenses, or rearming can affect
activation and restart requirements; capture `/dlv` state and recovery material
first.

## KMS client options

<!-- mant:entries role=option case=insensitive -->
- `/skms`: Set one KMS host with optional port and activation ID, disabling DNS autodiscovery for that target.
- `/skms-domain`: Set the DNS domain in which to discover KMS SRV records, optionally for one activation ID.
- `/ckms`: Remove an explicit KMS host and restore autodiscovery, optionally for one activation ID.
- `/skhc`: Enable KMS host caching.
- `/ckhc`: Disable KMS host caching so discovery runs for each attempt.
- `/act-type`: Restrict activation to `0` any, `1` Active Directory, `2` KMS, or `3` token based, optionally for one activation ID.

## KMS host options

<!-- mant:entries role=option case=insensitive -->
- `/sai MINUTES`: Set the unactivated-client retry interval from 15 minutes to 30 days.
- `/sri MINUTES`: Set the activated-client renewal interval from 15 minutes to 30 days.
- `/sprt PORT`: Set the KMS listener port; the default is TCP 1688.
- `/sdns`: Enable KMS DNS publishing.
- `/cdns`: Disable KMS DNS publishing.
- `/spri`: Set normal KMS host priority.
- `/cpri`: Set low KMS host priority; use carefully on a co-hosted server.

## Token and Active Directory activation options

<!-- mant:entries role=option case=insensitive -->
- `/ril`: Remove an installed token-based issuance license identified by ILID and ILvID.
- `/stao`: Legacy Token-based Activation Only flag; removed in Windows 8.1/Server 2012 R2 in favor of `/act-type`.
- `/ctao`: Clear the legacy token-only flag; removed in Windows 8.1/Server 2012 R2.
- `/fta`: Force token-based activation with one certificate thumbprint and optional PIN; avoid exposing a PIN in process arguments.
- `/ad-activation-online`: Create/start Active Directory forest activation using a product key, current forest credentials, and optional object name.
- `/ad-activation-get-IID PRODUCT-KEY`: Obtain the installation ID for phone-based forest activation.
- `/ad-activation-apply-cid`: Apply a product key, confirmation ID, and optional object name to complete forest activation.
- `/name:OBJECT-NAME`: Set an optional Active Directory activation-object name where supported.
- `/del-ao OBJECT-DN`: Delete an Active Directory activation object by distinguished or relative distinguished name.

Forest activation options affect directory-wide objects and require the
applicable root-domain permissions. Treat product keys, confirmation IDs, PINs,
and inline remote passwords as secrets.

## PowerShell usage

Invoke the script through console host explicitly and capture all lines before
reading `$LASTEXITCODE`:

```powershell
$script = Join-Path $env:SystemRoot 'System32\slmgr.vbs'
$output = & cscript.exe //nologo $script /dlv All 2>&1
$code = $LASTEXITCODE
$output
if ($code -ne 0) { throw "Slmgr failed: $code" }
```

Output is localized text, not typed licensing state. For durable management,
use supported activation/WMI/VAMT contracts and restrict logs containing
identifiers or partial keys.

## Common mistakes

### Running `slmgr.vbs` directly in unattended PowerShell

File association can select `wscript.exe` and show dialogs. Use `cscript.exe
//nologo` and the absolute System32 script path.

### Putting a product key or PIN in reusable automation

Arguments can appear in histories, logs, process telemetry, and transcripts.
Use approved secret delivery and redact outputs.

### Using `/upk` before a replacement and recovery plan exists

The system can restart unlicensed. Inventory exact activation IDs, escrow the
authorized replacement, and schedule the change through activation operations.

## Version and availability

Options depend on Windows edition, channel, activation model, installed
products, and Software Protection Platform version. Legacy token-only switches
were removed in Windows 8.1/Server 2012 R2. Use the installed script help and
the documentation for each non-Windows product it manages.

## Verification boundary

The complete current Microsoft option reference was reviewed. No licensing
query, key/license change, activation attempt, rearm, KMS/AD configuration,
secret, remote connection, or directory mutation ran.

## Related documents

- [cscript.exe](cscript.exe.md)
- [wscript.exe](wscript.exe.md)
- [whoami.exe](whoami.exe.md)

## Sources and license

This original guide was adapted from Microsoft's
[Slmgr.vbs option reference](https://learn.microsoft.com/windows-server/get-started/activation-slmgr-vbs-options).
Exact upstream revision and path are recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
