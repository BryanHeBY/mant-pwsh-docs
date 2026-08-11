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
mant windows-tools --source windows-tools --outline
mant cross-platform-tools --source cross-platform-tools --outline
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

## Tool platforms

On Windows, run and record supported versions of:

```powershell
winget --version
wsl --status
where.exe winget
robocopy.exe /?
schtasks.exe /query /fo CSV /v
schtasks.exe /query /tn "\\Microsoft\\Windows\\Defrag\\ScheduledDefrag" /fo LIST /v
schtasks.exe /query /tn "\\Microsoft\\Windows\\Defrag\\ScheduledDefrag" /xml
Get-Command sc -All -ErrorAction SilentlyContinue
sc.exe query state= all
sc.exe query EventLog
sc.exe qc EventLog
sc.exe queryex EventLog
sc.exe enumdepend EventLog
net.exe help
net.exe user
net.exe localgroup
net.exe accounts
net.exe use
net.exe share
net.exe session
net.exe file
net.exe start
net.exe view
query.exe user
query.exe session
query.exe process *
query.exe session /counter
quser.exe
qwinsta.exe
qprocess.exe *
qappsrv.exe /continue
msg.exe /?
tsdiscon.exe /?
logoff.exe /?
rwinsta.exe /?
tscon.exe /?
shadow.exe /?
tskill.exe /?
change.exe logon /query
change.exe port /query
change.exe user /query
flattemp.exe /query
tsecimp.exe /d
tsprof.exe /q /local "$approvedLocalRdsTestUser"
winrm.exe help
winrm.exe get winrm/config/client
winrm.exe get winrm/config/service
winrm.exe enumerate winrm/config/listener
winrm.exe enumerate winrm/config/plugin
winrs.exe /?
wevtutil.exe enum-logs
wevtutil.exe get-log System /f:xml
wevtutil.exe query-events System /c:20 /rd:true /f:RenderedXml /e:Events
wevtutil.exe enum-publishers
wecutil.exe /?
sc.exe query Wecsvc
eventcreate.exe /?
logman.exe query
logman.exe query providers
typeperf.exe -q
typeperf.exe -qx
relog.exe /?
tracerpt.exe /?
lodctr.exe /q
unlodctr.exe /?
Get-Command perfmon.exe, msinfo32.exe, cleanmgr.exe, shutdown.exe, tzutil.exe, verifier.exe -All
shutdown.exe /?
tzutil.exe /g
tzutil.exe /l
verifier.exe /querysettings
verifier.exe /query
w32tm.exe /query /status /verbose
w32tm.exe /query /source
w32tm.exe /query /configuration
powercfg.exe /getactivescheme
powercfg.exe /list
powercfg.exe /requests
powercfg.exe /availablesleepstates
reagentc.exe /info
Get-Command dxdiag.exe -All
Get-Command taskmgr.exe, resmon.exe, eventvwr.exe, mmc.exe -All
Get-Item "$env:SystemRoot\System32\eventvwr.msc", "$env:SystemRoot\System32\compmgmt.msc"
Get-Item "$env:SystemRoot\System32\devmgmt.msc", "$env:SystemRoot\System32\diskmgmt.msc", "$env:SystemRoot\System32\services.msc"
Get-Command optionalfeatures.exe -All
Get-Command msconfig.exe, SystemPropertiesAdvanced.exe, magnify.exe, narrator.exe, osk.exe -All
Get-Item "$env:SystemRoot\System32\gpedit.msc" -ErrorAction SilentlyContinue
Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location, User
gpresult.exe /scope user /r
[Environment]::GetEnvironmentVariable('Path', 'User')
[Environment]::GetEnvironmentVariable('Path', 'Machine')
Get-Command setx.exe, cscript.exe, wscript.exe, regsvr32.exe, wmic.exe, mstsc.exe, sxstrace.exe -All -ErrorAction SilentlyContinue
setx.exe /?
cscript.exe //?
wscript.exe //?
regsvr32.exe /?
Get-WindowsCapability -Online | Where-Object Name -Like 'WMIC*'
mstsc.exe /?
mstsc.exe /l
sxstrace.exe -?
Get-Command format.exe, recover.exe, pktmon.exe, tpmtool.exe, makecab.exe, diantz.exe, expand.exe -All -ErrorAction SilentlyContinue
format.exe /?
recover.exe /?
pktmon.exe status
pktmon.exe list --json
pktmon.exe filter list
tpmtool.exe getdeviceinformation
makecab.exe /?
diantz.exe /?
expand.exe /?
Get-Command chcp.com, doskey.exe, more.com, comp.exe, replace.exe, label.exe, waitfor.exe -All -ErrorAction SilentlyContinue
Get-Command more -All -ErrorAction SilentlyContinue
chcp.com
doskey.exe /?
more.com /?
comp.exe /?
replace.exe /?
label.exe /?
waitfor.exe /?
cmd.exe /d /c "vol C:"
cmd.exe /d /c "help echo"
cmd.exe /d /c "help rem"
cmd.exe /d /c "help goto"
cmd.exe /d /c "help shift"
cmd.exe /d /c "help pause"
cmd.exe /d /c "help prompt"
cmd.exe /d /c "help cls"
cmd.exe /d /c "color /?"
cmd.exe /d /c help
cmd.exe /d /c "help help"
cmd.exe /d /c ver
cmd.exe /d /c verify
cmd.exe /d /c "help break"
cmd.exe /d /c "date /t"
cmd.exe /d /c "time /t"
Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, OSArchitecture
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | Select-Object ProductName, DisplayVersion, CurrentBuildNumber, UBR
Get-Command at.exe, cacls.exe, icacls.exe, bootcfg.exe, bcdedit.exe, bitsadmin.exe -All -ErrorAction SilentlyContinue
at.exe /?
at.exe
cacls.exe /?
icacls.exe /?
bootcfg.exe /?
bootcfg.exe /query
bcdedit.exe /enum all /v
bitsadmin.exe /?
bitsadmin.exe /list /verbose
Get-BitsTransfer -ErrorAction SilentlyContinue
mode.com /?
mode.com
mode.com con codepage /status
Get-PnpDevice -Class Ports -PresentOnly -ErrorAction SilentlyContinue
print.exe /?
Get-Printer -ErrorAction SilentlyContinue
Get-ChildItem -LiteralPath "$env:WINDIR\System32\Printing_Admin_Scripts" -Filter '*.vbs' -Recurse
Get-PrinterDriver -ErrorAction SilentlyContinue
Get-PrinterPort -ErrorAction SilentlyContinue
Get-PrintJob -PrinterName $approvedQueue -ErrorAction SilentlyContinue
Get-Command PushPrinterConnections.exe -ErrorAction SilentlyContinue
rundll32.exe printui.dll,PrintUIEntry /?
rundll32.exe printui.dll,PrintUIEntry /ge
Get-Command ftp.exe, tftp.exe, telnet.exe, finger.exe -All -ErrorAction SilentlyContinue
ftp.exe -?
Get-WindowsOptionalFeature -Online -FeatureName TFTP
tftp.exe /?
Get-WindowsOptionalFeature -Online -FeatureName TelnetClient
telnet.exe /?
finger.exe /?
Get-Command nfsadmin.exe, nfsshare.exe, nfsstat.exe, showmount.exe, rpcinfo.exe, rpcping.exe -All -ErrorAction SilentlyContinue
nfsadmin.exe server config
nfsadmin.exe server -l
nfsadmin.exe client config
nfsshare.exe
nfsstat.exe
nfsstat.exe -m
showmount.exe -e $approvedNfsServer
rpcinfo.exe /p $approvedNfsServer
rpcping.exe /?
rpcping.exe /t ncacn_ip_tcp /s $approvedRpcServer /i 1 /v 2
Get-Command dcdiag.exe, repadmin.exe, nltest.exe, netdom.exe -All -ErrorAction SilentlyContinue
dcdiag.exe /?
repadmin.exe /?
nltest.exe /?
netdom.exe help
dcdiag.exe /s:"dc01.example.com" /test:Connectivity /v
dcdiag.exe /s:"dc01.example.com" /test:DNS /DnsBasic /v
dcdiag.exe /s:"dc01.example.com" /test:Replications /v
repadmin.exe /replsummary "dc01.example.com" /bysrc /bydest
repadmin.exe /showrepl "dc01.example.com" /all /verbose
repadmin.exe /queue "dc01.example.com"
nltest.exe /dsgetsite
nltest.exe /dsgetdc:"example.com"
nltest.exe /dclist:"example.com"
nltest.exe /sc_query:"example.com"
netdom.exe query /domain:"example.com" DC
netdom.exe query /domain:"example.com" FSMO
netdom.exe query /domain:"example.com" TRUST
netdom.exe verify "member01.example.com" /domain:"example.com"
Get-Command dcgpofix.exe, dcpromo.exe, gpfixup.exe -All -ErrorAction SilentlyContinue
dcgpofix.exe /?
dcpromo.exe /?:Promotion
gpfixup.exe /?
Get-Command -Module ADDSDeployment -Name 'Install-ADDS*','Uninstall-ADDS*','Test-ADDS*' -ErrorAction SilentlyContinue
Get-Command Get-ADRootDSE, Get-ADObject, Get-ADDomain, Get-ADDomainController -ErrorAction SilentlyContinue
Get-Command Get-GPO, Get-GPOReport, Backup-GPO -ErrorAction SilentlyContinue
Get-Command dnscmd.exe, dfsdiag.exe, dfsrmig.exe, ntfrsutl.exe -All -ErrorAction SilentlyContinue
dnscmd.exe "dns01.example.com" /enumzones
dnscmd.exe "dns01.example.com" /zoneinfo "example.com"
dnscmd.exe "dns01.example.com" /enumrecords "example.com" "www" /detail
dnscmd.exe "dns01.example.com" /enumdirectorypartitions
dfsdiag.exe /testsites /machine:"fileserver01.example.com"
dfsdiag.exe /testdfsconfig /DFSRoot:"\\example.com\shares"
dfsdiag.exe /testdfsintegrity /DFSRoot:"\\example.com\shares"
dfsdiag.exe /testreferral /DFSPath:"\\example.com\shares\team" /full
$pdc = (Get-ADDomain -Identity "example.com").PDCEmulator
Invoke-Command -ComputerName $pdc -ScriptBlock { dfsrmig.exe /getglobalstate }
Invoke-Command -ComputerName $pdc -ScriptBlock { dfsrmig.exe /getmigrationstate }
ntfrsutl.exe version "dc01.example.com"
ntfrsutl.exe sets "dc01.example.com"
ntfrsutl.exe poll "dc01.example.com"
Get-Command echo, cls, prompt -All -ErrorAction SilentlyContinue
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

For this query-only evidence pass, do not format or dismount any volume; run
`recover` on any file; add/remove Packet Monitor filters, capture packets,
reset/unload Packet Monitor, or collect TPM logs/traces; and do not create or
extract cabinets. Record absence and version-specific help differences rather
than mutating a host to make an example pass. Any later fixture-based packet,
TPM, Cabinet, format, or recovery test requires its separately approved
isolated procedure and the cleanup/evidence gates in the corresponding page.

Do not change the active code page in the shared evidence session, export
history or macros without a data-handling review, launch an interactive pager
or comparator against real data, replace files, modify a volume label, or start/
send a WAITFOR signal merely for evidence. Any fixture test must use an isolated
child console, disposable files/volume, collision-resistant signal with finite
timeout, explicit host, and before/after verification.

Do not change VERIFY state, system date/time, time zone, Windows Time service,
source, policy, or synchronization merely for evidence; do not run BREAK with
output redirection. Record localized display and missing inventory fields as
observations rather than changing the host to match an example.

Do not create, edit, run or delete an AT/Task Scheduler job; mutate any ACL,
ownership or inheritance; edit Boot.ini/BCD/firmware; or create, resume,
complete, cancel, reset, take ownership of, or otherwise mutate a BITS job merely
for evidence. BITS all-users inventory also requires a separate data-handling
review because URLs, paths, owners and headers can be sensitive.

Do not reconfigure a serial/LPT device, console code page/dimensions/typematic
state, or submit any print/raw-device job merely for evidence. Query only an
approved inactive COM port; protect printer and BITS inventory as potentially
sensitive operational data.
Discover localized Printing Administration scripts rather than assuming an
`en-US` path, and keep them to help/list/get forms. Do not add/configure/rename/
delete a queue, connection, driver or port; set a default; pause/resume/cancel
a job or queue; purge jobs; print a test page; publish to AD; pass `-w`; run
PushPrinterConnections interactively; change deployed-printer policy; or use
PrintUI to install/delete/restore/quietly mutate anything merely for evidence.
Record user versus computer/session scope, exact server/queue/job/driver/port,
script language, RSoP and potentially sensitive output.

Do not enable TFTP/Telnet features, start an FTP/TFTP/Telnet/Finger connection,
send credentials or input, transfer/delete/rename a file, query remote users, or
create a plaintext protocol transcript merely for evidence. Approved TCP
reachability checks do not establish protocol, authentication, encryption,
authorization, data-channel or application health.

Do not install NFS features merely for evidence. Where already installed, keep
NfsAdmin to config display/lock list, NfsShare to list/get, and NfsStat free of
`-z`; do not release locks, restart/reconfigure services, change mappings,
exports, root/anonymous access, counters, mounts, ACLs or firewall rules. Resolve
`mount.exe` and run it without arguments only; do not create or remove a mount.
Query Showmount/RpcInfo only against exact approved NFS servers and protect exported
paths/client/mount/program metadata; never broadcast. Keep RpcPing to help and
one approved exact-server, single-iteration verbose Endpoint Mapper call with
no alternate/proxy credentials, UI, quiet mode or guessed service claim. Record
that TCP 135 success does not prove the target interface/dynamic endpoint.

For LPR/LPD, resolve `lpq.exe` and `lpr.exe`, capture local help, and limit
remote evidence to `lpq` against one exact approved server and queue. Do not
submit or retry a print job merely for evidence. Record uppercase native switch
spelling, queue/device identity, TCP 515 reachability separately, and protect
remote job metadata. For `tlntadmn`, query local settings and at most one exact
approved server/session list; do not install, enable, start, stop, configure,
message or end anything, and never pass a password. For deprecated `rexec` and
retired `rsh`, runtime evidence is executable resolution, signature/version,
and local help only—never connect to or enable a legacy daemon.

Replace every AD placeholder only with an approved lab or production target
whose owner has authorized the exact read-only collection. Do not run DCDiag
`/fix`, `/c`, CutoffServers or Intersite; Repadmin synchronization, KCC,
configuration, or recovery families; NLTest verify/reset/password/DNS/debug
families; or Netdom membership, rename, reset/password, trust-change, or reboot
families merely for evidence. Protect DC, site, trust, partner, SPN, account,
event, and replication output as sensitive topology. A separate reviewed
procedure is required before broad site/enterprise/forest selection or any
operation that initiates replication or changes AD/host state.

For Adprep, Dcpromo, DcgpoFix, and Gpfixup, shared runtime evidence is limited to
binary/module/help discovery and the explicitly approved read-only AD/GPO
inventory above. Do not prepare a schema/forest/domain/RODC, promote/demote a
DC, install/remove AD DS binaries, recreate either default GPO, bypass a schema
check, or rewrite any GPO/link/software reference merely for evidence. Inspect
an Adprep binary only from approved target-version installation media, and do
not copy secrets from Dcpromo examples into a command, answer file, transcript,
or repository. GPO backup creation requires an approved protected directory and
data-handling plan; it is not performed by this generic checklist.

Replace DNS/DFS/DC placeholders only with approved exact targets. Do not add,
delete, age, scavenge, sign, pause, reload, move, export/import, clear, or
configure any DNS server/zone/record/partition merely for evidence; Dnscmd
inventory can expose sensitive names and topology. Do not recurse across a DFS
namespace until the target count and load are approved, and do not confuse a
successful referral with DFSR or file-access health. For SYSVOL, run the global
query on the confirmed PDC Emulator and do not set a migration state, create or
delete migration objects, force AD/DFSR/FRS polling, start legacy FRS, or use
authoritative/non-authoritative recovery recipes. State 3 is irreversible.

Keep Cmd builtin verification to `help` and PowerShell resolution in the shared
evidence session. Do not pause for input, change a persistent/current prompt or
color, clear useful evidence, or execute synthetic control-flow/argument loops
merely to prove the pages exist. Any parser fixture must be a reviewed inert
batch file in a disposable directory and record its exact bytes/code page.

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
netcfg.exe /s n
netcfg.exe /q MS_Server
cmstp.exe /?
msiexec.exe /?
dism.exe /Online /Get-Features /Format:Table
dism.exe /Online /Cleanup-Image /CheckHealth
sfc.exe /verifyonly
pnputil.exe /enum-drivers
pnputil.exe /enum-devices /connected /problem
pnpunattend.exe auditsystem /s /l
wdsutil.exe /?
wdsutil.exe /Get-Server /Server:"wds01.example.com" /Show:Config
wdsutil.exe /Verbose /Get-Server /Server:"wds01.example.com" /Show:Images /Detailed
dispdiag.exe -?
msdt.exe /?
dtrace.exe -V
dtrace.exe -l -P syscall
auditpol.exe /get /category:* /r
gpresult.exe /scope user /r
klist.exe tickets
setspn.exe -Q "host/$env:COMPUTERNAME"
ksetup.exe /dumpstate
ksetup.exe /listrealmflags
ktpass.exe /?
rdpsign.exe /?
scwcmd.exe /?
cmdkey.exe /list
gpresult.exe /scope user /r
secedit.exe /validate $approvedTemplate
icacls.exe $testRoot
cipher.exe /C $approvedEfsFixture
cipher.exe /U /N
certreq.exe -new -?
certutil.exe -?
certutil.exe -dump $approvedCertificateFixture
certutil.exe -hashfile $approvedHashFixture SHA256
certutil.exe -user -store My
certutil.exe -verify $approvedCertificateFixture
bcdboot.exe /?
bcdedit.exe /enum active /v
bcdedit.exe /enum osloader /v
bcdedit.exe /enum firmware /v
chkdsk.exe C:
chkntfs.exe C:
chkntfs.exe /t
defrag.exe C: /A /U /V
compact.exe $testRoot
compact.exe /CompactOS:query
manage-bde.exe -status
manage-bde.exe -status C: -protectionaserrorlevel
manage-bde.exe -protectors -get C:
mountvol.exe
mountvol.exe C:\ /L
diskpart.exe /?
fsutil.exe fsinfo drives
fsutil.exe fsinfo volumeinfo C:
fsutil.exe dirty query C:
fsutil.exe behavior query DisableDeleteNotify
vssadmin.exe list writers
vssadmin.exe list providers
vssadmin.exe list shadowstorage
vssadmin.exe list shadows
diskshadow.exe /?
wbadmin.exe get status
wbadmin.exe get disks
wbadmin.exe get versions
bdehdcfg.exe /?
bdehdcfg.exe -driveinfo C:
refsutil.exe
```

Keep VSS and backup validation query-only. Do not create, expose, import,
break, mask, revert, resize, or delete shadows, and do not start/stop a backup,
recovery, schedule, or catalog mutation merely to satisfy this checklist.
Record the installed DiskShadow platform/help discrepancy when the executable
is absent on a Microsoft page's nominally listed client release.
Keep BdeHdCfg validation to help and drive information; do not target, shrink,
merge, activate, letter, or restart a partition. Record RefsUtil family/help
availability on the build. Run its query and diagnosis modes only against a
disposable representative ReFS fixture with separate disposable work/target
storage; never create corruption or mutate unique data for validation.

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
Keep CMSTP to executable/help discovery; do not run any INF/package, install or
uninstall a profile, or use silent mode merely for evidence. Keep NetCfg to
component query/list and a new protected binding-map artifact; never run `/i`,
`/u`, `/winpe`, `/d`, or `/x`. Run PnPUnattend only with `/s` and `/l` so it
searches without installation; do not add driver paths, alter PATH/registry,
stage/install a driver, reboot, or change a device merely for validation.
Keep WDSUtil to help plus exact approved-server configuration/image inventory.
Do not initialize/uninitialize, authorize, approve/reject/prestage or change a
device; add/remove/replace/copy/set an image, group, driver, filter, namespace
or multicast transmission; change server/transport/PXE/DHCP/TFTP/unattended
policy; start/stop services or sessions; expose secrets; enable insecure
hands-free deployment; or reboot merely for evidence. Record role/build, full
server FQDN, current boot.wim support status, April 2026 hardening state, active
clients/deployments and sensitive output handling.
Keep security/authentication checks read-only except for `auditpol /backup` to
a protected temporary path. Do not clear/restore policy, refresh Group Policy,
purge/request Kerberos tickets, change KDC bindings, or add/delete/reset SPNs
merely for verification. Record elevation, user/computer target, logon-session
LUID, domain/forest scope, timestamps, and report sensitivity.
Keep Ksetup validation to dump/list/get operations and Ktpass to help plus
separate read-only AD/SPN inventory. Do not change realm/KDC/password-server/
host mappings, flags, encryption attributes, user/computer passwords, SPNs,
UPNs, account keys, or create a keytab merely for release evidence. Trial
RdpSign only with `/l`, one reviewed disposable RDP file, and an approved
nonproduction signing identity; never overwrite a production file or change
publisher policy. Keep Scwcmd to help or an approved single-target analysis
and existing-XML view; do not configure, roll back, register, transform,
fan out to an OU/list, pass a plaintext alternate password, log test events,
or create/link a GPO merely for verification.
Do not add/delete stored credentials, refresh policy, or configure/import a
security template merely for verification. If an approved template fixture is
available, validate it only; protect exported reports and record which user,
database, areas, log paths, and policy authority are involved.
Keep certificate verification read-only unless a lab CA and disposable
enrollment identity are explicitly approved. For `certreq`, record local
verb help and inspect an approved existing request; do not generate a private
key, submit, retrieve, renew, or accept merely to satisfy this checklist.
For `certutil`, compare the SHA-256 result with `Get-FileHash`, record user
versus machine store context, and protect subject/provider/store output. Do
not import/delete/repair certificates, export private keys, change trust,
flush retrieval caches, or run CA-management verbs merely for verification.
Keep boot verification query-only. Record firmware mode, Secure Boot,
BitLocker protection, elevation, and the current system store; do not run
BCDBoot, export/import a BCD store, or change boot entries/order merely to
satisfy this checklist. Quote BCD identifiers in PowerShell, and record an
unsupported `/enum firmware` as not applicable on BIOS systems rather than a
documentation failure.
Keep filesystem/storage maintenance read-only during release verification.
Record exact volume identity, filesystem, media type, dirty state, free space,
elevation, storage ownership, command, output, and `$LASTEXITCODE`. Do not
repair or surface-scan a filesystem, schedule/exclude a startup check, optimize
or retrim storage, or change NTFS/CompactOS compression merely to satisfy this
checklist. Treat a read-only CHKDSK finding on an active volume as evidence to
investigate, not authorization for automatic repair.
Keep BitLocker and mount-point checks query-only and protect all output as
storage/recovery topology. Record stable volume, disk, partition, protector,
and mount identities; do not enable/disable/decrypt/unlock/lock BitLocker,
change protectors or auto-unlock, expose the ESP, create/delete mount points,
take volumes offline, clean stale mappings, or change automount merely for
verification. Interpret `-protectionaserrorlevel` 0/1 as protected/unprotected
status rather than generic command success/failure.
Keep DiskPart and FSUtil verification query-only. In an elevated DiskPart
session run `list disk`, `list volume`, select only a lab-approved object,
`detail` it, then `exit`; do not clean, format, convert, resize, change IDs,
attach/merge VHDs, or alter online/SAN/automount state. For FSUtil, do not set
global/filesystem behavior, dirty state, ranges, VDL/EOF, links/reparse data,
quotas, repair policy, journals, tiers, resources, or volume state. Record
filesystem/build-specific help and interpret `DisableDeleteNotify = 0` as
notifications enabled, not proof that a particular device honored TRIM.
Use a disposable NTFS test tree to display, verify, and save ACLs; do not reset,
grant, deny, remove, restore, recurse ownership, encrypt/decrypt, rekey, or wipe
free space merely for validation. Run the EFS check only when an approved
encrypted fixture and recovery key exist, and record link policy, owner/DACL,
certificate thumbprint, target volume, and exact scope.

Review Windows-only commands on a non-production target. In particular, use
`robocopy /L` before any real copy, query an existing known task before task
changes, and query a known service before `sc.exe` configuration work.
Record how `sc` resolves in both Windows PowerShell 5.1 and PowerShell 7, then
invoke `sc.exe` explicitly. Keep service, task, Net account/SMB, and discovery
validation query-only; do not start, stop, create, configure, overwrite, run,
end, or delete a real service or
task, change account/group/policy/share/connection state, disconnect a session,
close an open file, or set the clock merely for evidence. Record `net.exe`
direction, logon/token identity, local versus domain scope, Server/Workstation
service state, and any permission-denied or unavailable family as target-host
evidence. Keep Remote Desktop session checks query-only. Record the `>` marker
for the current session, blank/listener rows, session versus process IDs,
caller rights,
native exit status, locale, and collection time; do not parse a zero-row result
from failed text, or log off, disconnect, reset, connect, shadow, message, or
terminate anything for validation. Use an approved disposable fixture for
mutations. For `msg`, `tsdiscon`, `logoff`, and `rwinsta`, runtime release
verification is help/discovery-only unless a separately approved disposable
RDS test session, test user, saved-work confirmation, and rollback/recovery
record exist; never message real users or disconnect/delete a real session just
to satisfy the checklist.
Treat `tscon`, `shadow`, and `tskill` as help-only for normal release
verification. Do not attach a session to another transport/console, request or
suppress shadow consent, view/control a user's screen, prompt for another
user's password, or terminate a process merely for evidence. Any mutation test
requires a separately approved disposable host/session/process, privacy and
physical-console review, exact identity revalidation, and recovery plan.
Keep `change` to `logon /query`, `port /query`, and `user /query`; do not alter
admission, COM mappings or install mode merely for evidence. Query FlatTemp and
effective paths only. Keep TSecImp to `/d` plus `/f <approved-copy> /v`; never
import assignments or use production identity XML. Keep TSProf to `/q` for one
approved local/domain test user; do not update/copy fields or migrate profile
files merely for evidence. Protect session, user, path, TAPI and line metadata.
Keep WinRM/WinRS verification local and query/help-only by default. Record
client versus service direction, listeners, transport/port/address/certificate,
authentication, TrustedHosts, plugins/endpoint ACLs, shells, firewall/network
profile, and policy ownership. Do not run quickconfig, start/reconfigure the
service, create/set/delete listeners/plugins/trust, enable weak authentication/
unencrypted traffic/delegation, open firewall rules, or execute a remote command
merely for evidence. A remote test requires an approved disposable endpoint,
exact identity and transport validation, allowlisted harmless command, and
remote process/result/audit verification.
Keep eventing verification query/help-only. Preserve channel configuration,
raw XML/EVTX, query/time/locale, collector subscription configuration and
runtime status separately. Do not clear a log, overwrite/archive evidence into
an unsafe path, set channel retention/size/access/isolation, install/uninstall
manifests, quick-configure/start Wecsvc, create/set/delete/retry subscriptions,
change WEF credentials/authorization/delivery, or create even a test marker
merely for evidence. Marker/forwarding mutation tests require a disposable
source/collector, unique `TEST ONLY` identity and correlation ID, capacity/
retention/security review, and end-to-end cleanup/verification plan.
Keep performance-counter and tracing verification inventory/help-only: do not
create, import, update, start, stop, or delete a collector; run an unbounded
sample; overwrite/SQL-export evidence; globally rebuild counter registration;
or register, unregister, enable, or disable a provider merely for validation.
Bounded sampling or conversion requires an approved fixture/host and a new
explicit output. Record locale, exact counter formula and instances, interval,
sample count, clock, provider identity/status, native status, and artifact hash.
For DTrace, record absence/version differences, list an exact provider and use
`-e` for any script compilation. Do not change BCD/BitLocker/Secure Boot/VBS,
reboot, enable probes, run a target command, trace a real PID, add `-w`, permit
destructive actions, capture memory/live dumps, or collect sensitive output
merely for release evidence.
Keep system-diagnostics/maintenance verification nonmutating. GUI entry points
may be opened and closed manually in an interactive session; do not start a
diagnostic report collector or treat GUI text as structured evidence. A scoped
`msinfo32` export is allowed only to a new protected fixture path, with process
wait plus artifact/content verification. Do not execute a cleanup profile or
automatic cleanup, schedule/cancel/sign out/hibernate/restart/shut down a real
host, change its time zone/DST policy, or enable/reset/reconfigure Driver
Verifier merely for release evidence. Driver Verifier mutation requires a
dedicated test computer, debugger/dumps, exact driver/flags, console/recovery,
stop criteria, rollback, reboot, and post-boot verification plan.
Keep DispDiag to help unless a new protected output path and data-handling plan
are approved; do not add `-d` or run the interactive ACPI key test merely for
evidence. Keep MSDT to resolution/help and current Settings/Get Help inventory;
do not run a built-in or external package/CAB, supply a passkey/parameters, or
accept a resolution merely for validation.
Keep time/power/recovery/DirectX verification query-only. Do not resync or
reconfigure W32Time, alter peers/hierarchy/reliability/service registration,
change schemes/settings/requests/overrides/wake/hibernation, enable/disable/
relocate/customize WinRE or set its next boot, or run DxDiag signature/report
collection merely for evidence. Bounded offset/report tests require an approved
endpoint or new protected path, exact target identity, wait/content checks, and
privacy/retention review. Recovery mutation additionally requires offline target,
disk/BCD/image/encryption evidence, console/media, rollback and boot testing.
GUI management entry verification is existence/manual launch-and-close only in
an interactive session. Do not end/suspend/reprioritize a process, change startup,
clear/configure logs, or mutate any Computer Management snap-in merely for evidence.
Do not enable/disable/uninstall/update/rescan devices; initialize/format/delete/
resize/convert/offline disks or volumes; control/reconfigure services; or add/
remove features/capabilities merely for GUI-entry verification.
Keep System Configuration, Local Group Policy and Advanced System Properties
verification query/manual-launch-only. Do not alter startup/service/boot state,
refresh or edit policy, change environment variables, virtual memory, performance,
profiles, dumps, startup or recovery merely for evidence. Record Windows edition,
user/computer scope and management authority; verify effective policy with RSoP.
Launch Magnifier, Narrator and OSK only in a disposable interactive test session
with audio/privacy/accessibility impact understood, then close them through their
normal UI or documented shortcut. Do not change automatic-start settings, force-
terminate assistive tools, automate user input/secrets, or rename/delete/take
ownership/change ACLs/redirect protected accessibility executables for validation.
Keep `setx` verification to help and persistent User/Machine value reads; do not
write/delete a variable, touch Path, pass remote credentials or test truncation
merely for evidence. Keep WSH verification to host help unless an approved inert
fixture is code-reviewed and run without elevation, persistence, network or COM
side effects. Do not change the default script host or saved WSH options.
Keep Regsvr32 verification help-only: do not load/register/unregister/install any
DLL/OCX merely for evidence. Record WMIC executable and FoD availability without
installing the deprecated capability, and validate new examples through typed CIM.
Keep Autochk, AutoConv, AutoFmt and FveUpdate verification to supported read-only
front-end inventory; never invoke the internal executables. Keep DiskCopy help-only
unless dedicated disposable floppy media is approved, and never write evidence
media. Keep KtmUtil to help/list operations: do not resolve, force or forget a
transaction merely for evidence. Query page-file configuration, runtime usage and
automatic management separately without changing settings or rebooting. Do not
enable PentNT emulation. DiskPerf changes require a separately approved restart;
FreeDisk checks must use an explicit unit and current credentials without `/p`.
Keep PowerShell ISE verification to a no-profile Windows PowerShell 5.1 GUI
session; never execute a script or selection merely for evidence. Inventory
Sysmon implementation, service, configuration, schema and existing events only;
do not install/reconfigure/uninstall either built-in or standalone delivery.
Keep TpmVscMgr to help and read-only TPM/reader/certificate inventory; never
create/destroy a card or expose PIN/PUK/admin keys. Do not change PwLauncher or
reboot for evidence. Keep RegIni to help/export/ACL/input/hash review and WinSAT
to help unless a disposable idle benchmark host and trusted media are approved.
Keep EvntCmd to help/service/file/provider inventory, JetPack to role/file/temp
inventory, and MSMQ to feature/service/help/queue/new-path inventory; do not
apply traps, compact databases, launch service images, stop services, delete
backup targets, or back up/restore messages merely for evidence. Keep NlbMgr to
help/tool/host-list and an empty GUI session without contacting hosts. Do not
open untrusted phone books. Keep TapiCfg to `show` and TcmSetup to help/domain/
DNS inventory; do not mutate AD partitions/SCPs/defaults or TAPI server lists.
Keep Winnt/Winnt32/RiSetup/SysOcMgr to copied artifact metadata, hashes and
current deployment inventory; never start legacy Setup or service an image for
evidence. Keep NTBackup to copied BKF metadata/hash/ACL and current WbAdmin
inventory; never install/launch a legacy restore utility on a production host.
Keep ServerManagerCmd to version/query/XML review and current typed feature
inventory/WhatIf. Query Server CEIP/WER only. Do not launch HelpCtr or alter
NTVDM, Config.nt, PIF, TSR, telemetry, role/feature, backup or restart state.
Keep Append to resolution/list/environment reads, ATMADM to adapter and `/c`/
`/a`/`/s` reads, and Graftabl to `/status` plus encoding reads. Do not alter
data/executable search paths, ATM state, graphics/console/file encodings or
fonts. Keep Edit/GetType to resolution and copied artifact/script inspection;
do not acquire or execute unknown legacy binaries or rewrite production files.
Keep IPXRoute to binding/config/SAP/resolve inventory and IrFTP to resolution/
source hashing; do not alter IPX routes/broadcasts/bindings/drivers or enable a
device/link, launch transfer UI, or send files merely for evidence. Keep
Macfile to copied tree/ACL/fork/hash inventory and MapAdmin to settings/list/
domain-list/current-store reads; do not expose credentials or mutate service,
mapping, identity, permission, fork, server, volume, guest or access state.
Keep DiskRaid to help/list/select/detail/exit on an explicitly approved
nonproduction VDS provider: never change LUN/plex/drive, host access, HBA/iSCSI
path/session/authentication, cache/controller/provider, capacity, redundancy or
online state merely for evidence. Keep Extrac32 to resolution/help and `/D`
listing of an approved inert CAB; extraction requires a separately approved new
empty disposable directory, path review and independent manifest/hash checks.
Keep MSTSC to help/local-monitor inventory: do not connect, authenticate, open an
untrusted RDP file, redirect resources or shadow/control a session for evidence.
Keep SxSTrace to help-only unless a disposable failing application and new protected
paths are approved; any capture must be stopped in cleanup and preserved before parse.

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
| Windows-only tool pages | required | not applicable | not applicable |
| Cross-platform tool pages | required | required | required |
| ManT source update and representative queries | required | required | required |

Once every required cell has recorded evidence, change only pages with direct
runtime evidence from `reviewed` to `verified`, run the three release commands
again, update the changelog with the final tag date, and create the annotated
v1 tag.
