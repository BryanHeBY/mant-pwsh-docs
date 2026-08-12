# Tests

`npm run validate` is the portable structural test suite. It covers document
structure, provenance, links, filename portability, and ManT JSON diagnostics
across supported host platforms.

The GitHub Actions workflow runs the portable check on Linux, macOS, and
Windows for pushes, pull requests, and manual dispatches. It installs the
public ManT 0.6.1 crate. The Windows job additionally runs the version-neutral
Cmd builtin fixture through both Windows PowerShell and pwsh. Edition-specific
PowerShell smoke tests remain separate because the PowerShell 7 suite targets
7.6 semantics while hosted-runner versions can float.

The Windows PowerShell 5.1 smoke test is intentionally separate and
nonmutating outside a uniquely named temporary directory:

```powershell
powershell.exe -NoProfile -File .\tests\runtime\pwsh51-smoke.ps1
```

It checks the documented edition, representative aliases and commands,
object-pipeline behavior, default redirection encodings, native exit-code
capture, literal child source, collection-versus-pipeline binding,
formatting-object boundaries, sort contracts, advanced-function output, and a
trusted temporary module's NoClobber/Prefix behavior. A
passing smoke test is runtime evidence for those facts, not a substitute for
page-level editorial review or platform-specific integration tests.

Cmd builtins have a separate protected-fixture smoke test because their parser,
environment, location stack, and filesystem semantics belong to a child
`cmd.exe`, not to the calling PowerShell runtime:

```powershell
powershell.exe -NoProfile -File .\tests\runtime\cmd-builtins-smoke.ps1
pwsh -NoProfile -File .\tests\runtime\cmd-builtins-smoke.ps1
```

It validates percent versus delayed expansion, CALL's second expansion pass,
`IF ERRORLEVEL` threshold behavior, `EXIT /B`, the narrow same-line
`ENDLOCAL` transfer idiom, `FOR /F` whole-nonblank-line behavior, same-process
`PUSHD`/`POPD`, binary `COPY` concatenation, command-extension intermediate
directory creation, in-place `REN`, junction link/target order, five
query-only DATE/TIME/VER/VERIFY/ECHO results, and HELP's valid nonzero discovery
status. A fixed task-owned subroutine also verifies `SHIFT /2`, unchanged `%*`,
plain REM behavior, and `GOTO :EOF` return-status preservation. Every artifact
is created below a GUID-named system temporary directory, whose
resolved path and prefix are checked before recursive cleanup. It does not use
network paths, user data, the registry, persistent environment variables, or
real shell/UI state. The suite also invokes only Cmd's static `HELP` dispatcher
for BREAK, CLS, PAUSE, PROMPT, and START; it never executes those five actions.
Exact local help line counts are collector metadata rather than a cross-build
gate.

After installing PowerShell 7, run the Windows-specific PowerShell 7.6 smoke
test separately:

```powershell
pwsh -NoProfile -File .\tests\runtime\pwsh7-windows-smoke.ps1
```

It adds PowerShell 7 command precedence and parameter metadata, UTF-8 without a
BOM, native stdout byte preservation, modern `$?` expression behavior, and
native argument-passing checks. It also exercises the shared object/function/
module checks and a bounded parallel-runspace caller-scope boundary. It uses
the same isolated temporary-directory
and cleanup safeguards as the Windows PowerShell 5.1 test.

For editorial coverage review, the read-only command-option audit compares the
semantic option entries with canonical runtime metadata and reports parameters
that aren't represented as entries:

```powershell
powershell.exe -NoProfile -File .\tests\runtime\audit-command-option-coverage.ps1 -Source pwsh51
pwsh -NoProfile -File .\tests\runtime\audit-command-option-coverage.ps1 -Source pwsh7
```

Missing entries are a review queue, not an automatic failure: command pages can
intentionally summarize a large interface and link the complete reference.
Unknown documented parameters remain failures in the edition-specific smoke
tests because they are false metadata rather than a coverage choice.

The audit reads wrapped continuation lines as part of the same semantic bullet.
It excludes common parameters and the 5.1 `curl.md` command-resolution guide,
which has no option declaration and directs cmdlet users to `iwr.md`.

The read-only snippet audit parses every body `powershell` code fence with the
runtime edition documented by its source. It skips `Synopsis` and `Syntax`
fences because those contain command-help notation rather than executable
PowerShell source:

```powershell
powershell.exe -NoProfile -File .\tests\runtime\audit-powershell-snippets.ps1 -Source pwsh51
pwsh -NoProfile -File .\tests\runtime\audit-powershell-snippets.ps1 -Source pwsh7
```

This catches malformed examples without executing them. A passing parse does
not prove command availability, side-effect safety, or runtime semantics; those
remain separate review and smoke-test responsibilities.

The Windows command-identity smoke test catches filename assumptions that
PowerShell command discovery can otherwise hide:

```powershell
powershell.exe -NoProfile -File .\tests\runtime\windows-command-identity-smoke.ps1
pwsh -NoProfile -File .\tests\runtime\windows-command-identity-smoke.ps1
```

It confirms that Windows supplies `format.com` rather than `format.exe`,
`winrm.cmd` plus `winrm.vbs` rather than `winrm.exe`, the System32
`convert.exe` File System Conversion Utility, and signed `extrac32.exe` rather
than historical `extract.exe`. It reads the tiny WinRM wrapper and invokes only
`format.com /?`, `convert.exe /?`, `extrac32.exe /?` through `more`, and local
`winrm.cmd help`; no storage/cabinet/destination target, conversion,
extraction, WinRM configuration mutation, service operation, or remote
endpoint is involved. WinRM help is decoded with the current culture's OEM
console code page and the caller's original output encoding is restored in
`finally`.

For a full, read-only availability inventory of Windows entry-point pages, run:

```powershell
powershell.exe -NoProfile -File .\tests\runtime\audit-windows-command-identity.ps1
pwsh -NoProfile -File .\tests\runtime\audit-windows-command-identity.ps1
```

The JSON report distinguishes exact filename matches, locally absent optional
or legacy commands, and the higher-priority case where an absent exact name's
bare stem resolves to another command. Absence is an editorial review queue,
not a test failure: Windows roles, editions, optional features, RSAT, and
deprecated components intentionally vary. The audit invokes no discovered
command and changes no system state. Explicit command-family mappings cover
pages whose filename cannot express every executable identity; `extract.md`
includes historical `extract.exe` and modern `extrac32.exe` rows.

For repeatable behavior evidence on high-frequency read-only Windows CLIs, run:

```powershell
powershell.exe -NoProfile -File .\tests\runtime\windows-readonly-cli-smoke.ps1
pwsh -NoProfile -File .\tests\runtime\windows-readonly-cli-smoke.ps1
```

This suite resolves eight fixed System32 executables, captures localized help
with bounded concurrent stdout/stderr reads, and performs only local snapshots
of processes, the current token SID, system information, adapters, TCP/PIDs,
PATH lookup, plus one-request/one-hop IPv4 loopback probes. It never truncates
an active native pipeline, emits no captured identity/process/network payload,
contacts no remote or external network target, and changes no state. Exact
path and filename establish executable identity; localized version resources
are recorded separately and are not required to repeat the executable name.

For privacy-bounded local host and network inventory, run:

```powershell
powershell.exe -NoProfile -File .\tests\runtime\windows-host-network-inventory-smoke.ps1
pwsh -NoProfile -File .\tests\runtime\windows-host-network-inventory-smoke.ps1
```

This suite resolves exact System32 Hostname, GetMac, DriverQuery, ARP, and
Route executables, checks their command-specific help status, and fully captures
only local read-only query forms. Its JSON exposes counts and structure only:
the host name, MAC/transport rows, driver rows, ARP cache, and route table are
never emitted. It supplies no remote host, credential, external target, or
mutation selector.

For isolated Windows file and text behavior, run:

```powershell
powershell.exe -NoProfile -File .\tests\runtime\windows-file-text-smoke.ps1
pwsh -NoProfile -File .\tests\runtime\windows-file-text-smoke.ps1
```

The suite creates only fixed ASCII text and fixed six-byte binary inputs below
a validated GUID system-temporary root. It checks query-only Attrib; FIND and
FINDSTR match/no-match status; stdout-only Sort and Cmd TYPE; FC binary
same/different status; bounded TREE filename inclusion; and XCOPY `/L` against
a distinct absent sibling destination. It emits no fixture payload, performs no
attribute or copy mutation, uses no user data or network path, and validates
the root again before recursive cleanup.

For local-only identity and top-level help evidence on remote-management
entry points, run:

```powershell
powershell.exe -NoProfile -File .\tests\runtime\windows-remote-management-help-smoke.ps1
pwsh -NoProfile -File .\tests\runtime\windows-remote-management-help-smoke.ps1
```

The suite resolves exact local WinRS, RPCPing, SC, SchTasks, W32Time, WECUtil,
WEvtUtil, and Netsh files; checks each command's own help status; inspects the
tiny `winrm.cmd` wrapper; and confirms that a built-in `winrm.exe` is absent.
It supplies no host, credential, resource, service, task, event, subscription,
network context, or configuration operand, emits no help payload, and performs
no query or mutation against a managed target.

For Windows PowerShell provider and dynamic-parameter boundaries, run each
edition in its own fresh profile-free process:

```powershell
powershell.exe -NoProfile -File .\tests\runtime\powershell-provider-readonly-smoke.ps1
pwsh -NoProfile -File .\tests\runtime\powershell-provider-readonly-smoke.ps1
```

The suite inspects only fixed built-in FileSystem, Alias, Environment,
Function, Variable, Registry, and Certificate paths. It verifies object types,
session-loading order, FileSystem-versus-Registry-versus-Certificate dynamic
parameters, and provider-customized help. Its JSON emits no environment value,
registry data, certificate, or user path; it performs no provider write,
network access, profile load, recursion, or content enumeration.

For the Windows boundary of the cross-platform Git, OpenSSH, curl, tar, and
dotnet pages, run:

```powershell
powershell.exe -NoProfile -File .\tests\runtime\cross-platform-tools-windows-smoke.ps1
pwsh -NoProfile -File .\tests\runtime\cross-platform-tools-windows-smoke.ps1
```

The suite preserves every exact Application candidate before selecting the
preferred Windows implementation, records the 5.1-versus-7 bare-`curl`
resolution difference, and runs version/help probes without a repository,
remote destination, URL, archive, or project. OpenSSH version text is required
on stderr and its `-?` form remains an error/usage diagnostic rather than a
generic help success. Missing dotnet is an explicit skipped behavior probe, not
success evidence; when an SDK is present, only `--version` runs with telemetry
and first-time experience disabled in a verified GUID temporary CLI home that
is removed afterward.

For a deeper read-only identity inventory, including executable layout,
version-resource forms, Authenticode status, and optional hashes, run:

```powershell
powershell.exe -NoProfile -File .\tests\runtime\audit-windows-file-identity.ps1
pwsh -NoProfile -File .\tests\runtime\audit-windows-file-identity.ps1 -IncludeHash
```

Add `-FailOnIdentityError` for CI or a release gate that should fail when an
exactly discovered file cannot be inspected. Locally absent role-, edition-,
optional-feature-, RSAT-, or legacy-specific entry points remain reported
without failing. The JSON also reports candidate and observed unique-document
counts plus missing/unexpected document keys. Check those coverage fields
before filtering rows: an empty filtered array does not prove that a command is
absent when the requested document key was never collected. The fail-closed
switch rejects either identity errors or catalog/row coverage gaps. The same
explicit command-family mapping covers both `extract.exe` and `extrac32.exe`
under `extract.md`; filename-shaped coverage alone is not proof that every
semantic command identity in a family page was audited.
Optional absence remains availability evidence rather than a failure. The
report includes a dedicated GUI summary and still never launches any
discovered entry point.

The report deliberately keeps the collector-selected
`FileVersion`/`ProductVersion` strings separate from the numeric fixed version
resource assembled from the `*MajorPart`, `*MinorPart`, `*BuildPart`, and
`*PrivatePart` properties. The string selection can vary by language/code page
and by PowerShell/.NET collector runtime for the same file; Windows servicing
can also make the two forms differ. Use the fixed value for numeric comparison,
retain the string as displayed metadata from a named collector, and bind either
claim to path, signature, hash, architecture, and collection time. `Get-Command` supplies the actual layout rather than assuming
that every Windows entry point lives in System32. The audit never invokes a
discovered command; `-IncludeHash` only reads ordinary file bytes and can take
longer.

Each row retains the catalog `kind`, so reviewers can derive a complete batch
without maintaining another filename list. For example, after converting the
JSON report to `$audit`, select all GUI-backed entry points with:

```powershell
$audit.identities | Where-Object kind -In 'windows-gui-entrypoint','windows-gui-cli'
```

The audit tests the numeric parts directly before constructing a fixed value;
it does not use the presence of a string table as a proxy for a fixed resource.
When `FileVersionInfo` exposes four zero parts and no string, the audit retains
`null` rather than claiming a meaningful `0.0.0.0`. Distinguishing an absent
fixed resource from an intentionally all-zero fixed resource would require a
lower-level Win32 resource-presence check and is outside this audit.

An application under `%LOCALAPPDATA%\Microsoft\WindowsApps` can instead be an
MSIX app execution alias: a per-user reparse point that activates a registered
package rather than an ordinary PE file whose version, Authenticode signature,
and hash should be read from that alias path. The audit labels these rows as
`appExecutionAlias`, deliberately skips those three file-identity fields, and
does not count the omission as an identity error. Verify the installed product
through a read-only product query such as `winget --version` or `wsl --version`
and, when package registration itself matters, `Get-AppxPackage`.

WinGet is serviced independently through App Installer, so its local option
surface can drift between repository reviews. This read-only audit invokes
only `winget --version`, top-level/`mcp` help, and each selected subcommand's
`--help`, then compares top-level commands plus scoped long options with ManT's
semantic entries in the working tree:

```powershell
powershell.exe -NoProfile -File .\tests\runtime\audit-winget-option-coverage.ps1
pwsh -NoProfile -File .\tests\runtime\audit-winget-option-coverage.ps1
```

Differences are an editorial review queue by default. Add
`-FailOnDifference` when verifying a deliberately synchronized local client
and draft. The audit does not enumerate sources or installed packages and
does not enable/disable MCP functionality, install, upgrade, uninstall,
authenticate, open logs, or access the network.
