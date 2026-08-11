# Version 1 runtime verification

This checklist records the runtime evidence required by
[V1-SCOPE.md](../V1-SCOPE.md) before creating the final v1 tag. It is separate
from portable repository validation: a passing `npm run validate:release`
proves document structure, ManT parsing, release inventory, and reviewed
provenance, but not the behavior of an operating-system-specific executable.

## Common preparation

On every target host, install or use the intended ManT build, add the sources
from [sources.example.toml](../sources.example.toml), and run:

```text
mant --update-docs
mant pwsh7 --source pwsh7 --outline
mant pwsh-cli --source pwsh-cli --outline
```

Record the host operating-system version, architecture, ManT version, shell
version, and relevant CLI versions. Run the repository checks from a clean
checkout:

```text
npm run validate
npm run validate:release
npm run validate:upstream
```

The last command requires network access and `curl`; the normal validation
commands remain offline except for ManT itself.

## PowerShell 7

Run on Windows, macOS, and Linux with the supported PowerShell 7 release:

```powershell
$PSVersionTable
Get-Command irm, iwr, iex -All
Get-Command irx -All -ErrorAction SilentlyContinue
Get-Command curl -All
pwsh -NoProfile -Command 'Get-ChildItem | Select-Object -First 1'
```

Confirm the documented alias and native-command resolution on each host. Test
the launcher, parsing/quoting, pipelines/redirection, profiles, functions,
`Get-Command`, `Get-Help`, object cmdlets, module import, and the PowerShell
7/Windows PowerShell compatibility guide against the local version.

## Windows PowerShell 5.1

Run on Windows with `powershell.exe` (not only `pwsh`):

```powershell
$PSVersionTable
powershell.exe -NoProfile -Command '$PSVersionTable.PSEdition'
Get-Command irm, iwr, iex, curl -All
Get-Command irx -All -ErrorAction SilentlyContinue
```

Confirm `PSEdition` is `Desktop`; validate legacy web-request behavior,
Windows command precedence, UTF-16LE redirection defaults, native command
exit-code handling, profiles, providers, and the PowerShell 7 migration guide.

## CLI platforms

On Windows, run and record supported versions of:

```powershell
winget --version
wsl --status
where.exe winget
robocopy.exe /?
schtasks.exe /query
sc.exe query
cmd.exe /d /c ver
reg.exe query HKCU\Environment
Get-Command explorer.exe, control.exe, mmc.exe, rundll32.exe -All
cmd.exe /d /v:on /c "set MANT_TEST=value & if not !MANT_TEST!==value exit /b 1"
choice.exe /?
timeout.exe /?
cmd.exe /d /c "for %N in (one two) do @echo %N"
cmd.exe /d /c "if 1 EQU 1 (exit /b 0) else (exit /b 1)"
cmd.exe /d /c "pushd %TEMP% & popd"
cmd.exe /d /c "assoc .txt & ftype txtfile"
cmd.exe /d /c "dir /b /a:-d %SystemRoot%\System32\cmd.exe"
cmd.exe /d /c "copy /? & del /? & rd /?"
```

Exercise directory creation, exact rename, move, and both `cd` spellings in a
fresh temporary directory, then inspect before removing that directory:

```powershell
$testRoot = Join-Path ([IO.Path]::GetTempPath()) "mant-cli-$([guid]::NewGuid())"
New-Item -ItemType Directory -Path $testRoot | Out-Null
Set-Content -LiteralPath (Join-Path $testRoot 'source.txt') -Value 'test'
$cmdLine = 'cd /d "{0}" && chdir && md nested\child && ren source.txt renamed.txt && move /-y renamed.txt target.txt' -f $testRoot
cmd.exe /d /c $cmdLine
Get-ChildItem -LiteralPath $testRoot -Recurse
Remove-Item -LiteralPath $testRoot -Recurse -Confirm
```

Confirm that cmd printed `$testRoot`, created `nested\child`, and left exactly
`target.txt`. Also run `Get-Command cd, chdir, move, md, mkdir, ren, rename -All`
in both target PowerShell editions and compare the results with the command-
resolution notes; `rename` is not a built-in PowerShell alias.

For native text tools, create representative ASCII, UTF-8, UTF-16, long-line,
and binary fixtures in the temporary directory, then record:

```powershell
Get-Command type, find.exe, findstr.exe, fc, fc.exe, sort, sort.exe, clip.exe -All
find.exe /i "test" $fixture; $LASTEXITCODE
findstr.exe /i /n /l /c:"test phrase" $fixture; $LASTEXITCODE
fc.exe /b $fixture $copy; $LASTEXITCODE
sort.exe $fixture /o $sorted
Get-Content -LiteralPath $fixture -Raw | Set-Clipboard
```

Verify match/no-match/error and identical/different/error separately, compare
non-ASCII and long-line results with `Select-String`, and do not paste secrets
or production data through the clipboard test.

In another isolated temporary tree, exercise filesystem metadata and link
scope before and after each operation:

```powershell
attrib.exe $fixture
forfiles.exe /p $testRoot /s /m "*" /d -1 /c "cmd.exe /d /c echo @isdir @path"
tree.com $testRoot /a /f
subst.exe
xcopy.exe "$testRoot\source\*" "$testRoot\copy\" /s /e /h /i /l
```

Use a currently unused drive letter for a `subst` create/query/remove cycle in
both normal and elevated shells. On a non-production NTFS test volume, create
and inspect each supported `mklink` type, then test whether `xcopy /b` copies
the link or the target as documented. Never infer recursive scope from the
rendered `tree` diagram alone.

On a non-production Windows host, record process and host inventory without
placing credentials on command lines:

```powershell
tasklist.exe /fi "PID eq $PID" /fo list
whoami.exe /user /fo csv
whoami.exe /groups /fo list
systeminfo.exe /fo csv
driverquery.exe /fo csv
openfiles.exe /local
openfiles.exe /query /fo csv /v
ipconfig.exe /all
ipconfig.exe /displaydns
ping.exe /4 /n 4 /w 1000 127.0.0.1
tracert.exe /d /4 /h 4 /w 1000 127.0.0.1
pathping.exe /n /4 /q 2 /p 100 127.0.0.1
hostname.exe
nslookup.exe -type=A localhost
netstat.exe -ano -p tcp
netstat.exe -ano -p udp
route.exe print
arp.exe -a
getmac.exe /v /fo csv
nbtstat.exe /n
nbtstat.exe /c
netsh.exe help
netsh.exe interface ipv4 show config
netsh.exe wlan show interfaces
netsh.exe winsock show catalog
msiexec.exe /?
dism.exe /Online /Get-Features /Format:Table
dism.exe /Online /Cleanup-Image /CheckHealth
sfc.exe /verifyonly
pnputil.exe /enum-drivers
pnputil.exe /enum-devices /connected /problem
```

Start a disposable process, record its PID/path/start time, preview
`Stop-Process -WhatIf`, terminate it without `/f` or `/t`, and verify it exited.
Test force/tree behavior only on an isolated process tree. Do not enable local
open-file tracking merely for validation because it requires a restart and can
affect performance; record the current setting and leave it unchanged.
For network diagnostics, also test a reviewed reachable host and an expected
unreachable target in the lab. Record the address family, DNS server, source
network, complete command, and timestamp. Do not flush DNS or release/renew
DHCP merely to satisfy verification, and do not interpret ICMP failure as
proof that an application service is unavailable.
Keep route and ARP verification query-only. Correlate a known disposable
listener with `Get-NetTCPConnection` and its current PID, distinguish TCP from
UDP endpoint semantics, and confirm physical and virtual adapter rows instead
of accepting the first MAC address.
Preserve `nbtstat` option case and skip purge/refresh operations. Discover the
installed Netsh contexts on the test host and keep interface, WLAN, and Winsock
checks read-only; do not export clear-text Wi-Fi keys, reset catalogs, change
interfaces, or enable persistent tracing merely for validation.
Keep servicing verification read-only: do not install/uninstall an MSI, repair
an image, replace protected files, change a device/driver, or enable a feature
merely to satisfy this checklist. Confirm current `pnputil /?` verbs on the
host, preserve DISM/SFC output and elevation context, and separately validate
the documented MSI argument/exit-code handling with an approved disposable
test package in an isolated Windows test environment.

Review Windows-only commands on a non-production target. In particular, use
`robocopy /L` before any real copy, query an existing known task before task
changes, and query a known service before `sc.exe` configuration work.

On Windows, macOS, and Linux where declared by the document, record:

```text
git --version
ssh -V
curl --version
tar --version
dotnet --info
```

Verify source/platform variations such as PowerShell's `curl` alias on Windows,
the installed tar implementation, available .NET SDKs, and the configured SSH
client. Do not claim an unavailable command has passed; record it as an
environmental exception and decide whether the v1 scope or test host must
change.

## Acceptance record

Before tagging, attach or link a record with these outcomes:

| Requirement | Windows | macOS | Linux |
| --- | --- | --- | --- |
| PowerShell 7 | required | required | required |
| Windows PowerShell 5.1 | required | not applicable | not applicable |
| Windows-only CLI pages | required | not applicable | not applicable |
| Cross-platform CLI pages | required | required | required |
| ManT source update and representative queries | required | required | required |

Once every required cell has recorded evidence, change only pages with direct
runtime evidence from `reviewed` to `verified`, run the three release commands
again, update the changelog with the final tag date, and create the annotated
v1 tag.
