<!-- mant:tldr:start -->
# bitsadmin.exe

> Inventory Background Intelligent Transfer Service jobs by GUID before any
> lifecycle action; display names are not unique and transferred jobs still need
> explicit completion.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/bitsadmin.

- List only the current user's BITS jobs with verbose identity and state:

`bitsadmin.exe /list /verbose`

- Inspect one exact job GUID, including owner, state, progress, error, proxy, and notification data:

`bitsadmin.exe /info "{{job-guid}}" /verbose`

- List source and destination mappings for one exact job GUID:

`bitsadmin.exe /listfiles "{{job-guid}}"`

- Inspect the current user's jobs as typed PowerShell objects:

`Get-BitsTransfer | Select-Object JobId, DisplayName, OwnerAccount, JobState, FilesTransferred, FilesTotal, BytesTransferred, BytesTotal, ErrorContext, ErrorDescription`

<!-- mant:tldr:end -->

# bitsadmin.exe

## Overview

`bitsadmin.exe` manages Background Intelligent Transfer Service (BITS) download
and upload jobs. Jobs persist asynchronously, transfer under an owning identity,
and have a lifecycle: create/transfer definition, resume, progress or error,
transferred state, then explicit completion or cancellation. Display names are
not unique; use the GUID returned by create/list as operational identity.

Microsoft still publishes the tool on current Windows. For new PowerShell
automation, the BitsTransfer module provides typed objects and clearer parameter
binding, but it preserves the same lifecycle and security obligations. Do not
call BITSAdmin deprecated merely because old community posts do; discover the
target build and prefer the supported interface that fits the workflow.

## Command-family map

<!-- mant:entries role=command case=insensitive -->
- `bitsadmin.exe`: Inspect or administer legacy Background Intelligent Transfer Service jobs.

BITS jobs persist beyond the creating process and require an explicit terminal
decision; transferred data is not committed until completion.

Top-level help and rendering controls do not select a job.

<!-- mant:entries role=option case=insensitive -->
- `/help`, `/?`: Display the installed command-family inventory; use
  `/help SWITCH` and each family `/?` before relying on advanced syntax.
- `/rawreturn`: Remove normal formatting/newlines for supported create/get
  results; it does not turn native text into typed or secret-safe data.
- `/wrap`: Wrap output to the console width.
- `/nowrap`: Disable console-width wrapping for more stable capture.

Job discovery/getters are read-only with respect to BITS state, but their
output can expose identities, URLs, paths, proxy details, headers, certificates,
notification commands, temporary names, reply data, or peer topology.

<!-- mant:entries role=option case=insensitive -->
- `/list`: List visible jobs; under `/cache` or `/peers`, the parent family
  changes this to cache-entry or peer inventory.
- `/monitor`: Repeatedly display job progress until interrupted; always supply
  a finite external observation deadline.
- `/info`: Display detailed state for one exact job; under `/cache`, it selects
  one exact cache record instead.
- `/listfiles`: List remote/local file mappings for one exact job.
- `/gettype`: Display the job's download/upload/upload-reply type.
- `/getaclflags`: Display the job's ACL propagation mask.
- `/getbytestotal`: Display the expected job byte total.
- `/getbytestransferred`: Display the current transferred-byte count.
- `/getfilestotal`: Display the expected file count.
- `/getfilestransferred`: Display the current transferred-file count.
- `/getcreationtime`: Display the job creation time.
- `/getmodificationtime`: Display the most recent job modification time.
- `/getcompletiontime`: Display the completion time when defined.
- `/getstate`: Display the current lifecycle state.
- `/geterror`: Display detailed current error information.
- `/geterrorcount`: Display the job error count.
- `/getowner`: Display the owning identity.
- `/getdisplayname`: Display the nonunique job display name.
- `/getdescription`: Display the job description.
- `/getpriority`: Display the transfer priority.
- `/getnotifyflags`: Display notification behavior flags.
- `/getnotifyinterface`: Report whether an in-process notification interface is registered.
- `/getminretrydelay`: Display the minimum retry delay.
- `/getnoprogresstimeout`: Display the no-progress timeout.
- `/getmaxdownloadtime`: Display the maximum download time.
- `/getproxyusage`: Display the job proxy-selection mode.
- `/getproxylist`: Display configured job proxy endpoints.
- `/getproxybypasslist`: Display the job proxy bypass list.
- `/getnotifycmdline`: Display the persistent notification program and arguments.
- `/getcustomheaders`: Display custom HTTP headers unless they were made write-only.
- `/gethttpmethod`: Display the configured HTTP method.
- `/getclientcertificate`: Display client-certificate selection information.
- `/getsecurityflags`: Display the URL/certificate validation and redirect bitmask.
- `/getvalidationstate`: Display content-validation state for one zero-based job file index.
- `/gettemporaryname`: Display the temporary local filename for one zero-based job file index.
- `/getpeercachingflags`: Display per-job peer download/serving flags.
- `/getreplyfilename`: Display the upload-reply file path.
- `/getreplyprogress`: Display upload-reply size/progress.
- `/getreplydata`: Dump upload-reply bytes in hexadecimal; treat the payload as sensitive/untrusted.
- `/gethelpertokensid`: Display the SID of the job helper token when present.
- `/gethelpertokenflags`: Display which local/network resources use the helper token.
- `/getpeerstats`: Display origin-versus-peer statistics for one zero-based job file index.

Lifecycle operations act on persistent job state.

<!-- mant:entries role=option case=insensitive -->
- `/create`: Create a persistent BITS job.
- `/addfile`: Add one remote/local file pair to a job.
- `/addfileset`: Add reviewed file pairs from a set.
- `/addfilewithranges`: Add selected byte ranges from one remote/local file
  pair; verify offset/length coverage and output semantics.
- `/replaceremoteprefix`: Rewrite matching remote URL prefixes for every file
  in one job.
- `/resume`: Allow a suspended job to transfer.
- `/suspend`: Pause transfer without deleting job state.
- `/complete`: Commit transferred temporary files to destinations.
- `/cancel`: Delete one job and its temporary state.
- `/transfer`: Create, transfer, and complete a foreground command-line job.
- `/reset`: Cancel every job owned by the selected scope.
- `/takeownership`: Transfer ownership of another identity's job.
- `/allusers`: Broaden list/reset scope across user identities.
- `/download`: Select a download job type under supported create/transfer syntax.
- `/upload`: Select an upload job type and its distinct server requirements.
- `/upload-reply`: Select an upload job that also receives a server reply.
- `/priority`: Supply the transfer priority to the combined `/transfer` form.
- `/aclflags`: Select destination ACL propagation for supported transfer syntax.
- `/dynamic`: Relax supported server-side requirements for dynamic content;
  it changes validation/caching assumptions rather than merely performance.
- `/verbose`: Request more detailed output under the exact parent command.
- `/refresh`: Set the monitor refresh interval; it is not a global network refresh.

Job metadata, policy, authentication, execution hooks, and trust controls form
another mutation family.

<!-- mant:entries role=option case=insensitive -->
- `/setaclflags`: Change owner/group/DACL/SACL propagation flags; SACL handling
  also involves audit privilege and sensitive security metadata.
- `/setdisplayname`: Change the job's nonunique display name.
- `/setdescription`: Change the job description.
- `/setpriority`: Set foreground or background transfer priority.
- `/setnotifyflags`: Change which job events trigger notification behavior.
- `/setminretrydelay`: Change the retry delay.
- `/setnoprogresstimeout`: Change when no progress becomes a timeout.
- `/setmaxdownloadtime`: Change the maximum allowed download duration.
- `/setproxysettings`: Change proxy selection, endpoints, bypasses, or auto-configuration for one job.
- `/setnotifycmdline`: Configure a persistent post-transfer command surface.
- `/setcredentials`: Persist server/proxy credentials on a job; never place a
  password in shell history, logs, process inspection, or Agent transcripts.
- `/removecredentials`: Remove one target/authentication-scheme credential from a job.
- `/setcustomheaders`: Persist reviewed HTTP headers, which can contain secrets or alter server behavior.
- `/makecustomheaderswriteonly`: Irreversibly prevent later reading of the job's custom headers.
- `/sethttpmethod`: Change the HTTP verb used by the transfer.
- `/setclientcertificatebyid`: Bind a client certificate by store location/name and exact identifier.
- `/setclientcertificatebyname`: Bind by subject name, which can be nonunique; prefer exact certificate identity.
- `/removeclientcertificate`: Remove client-certificate selection from the job.
- `/setsecurityflags`: Change TLS certificate checks and redirect policy;
  multiple bits explicitly weaken validation or allow HTTPS-to-HTTP redirects.
- `/setvalidationstate`: Change content-validation state for one zero-based job file index.
- `/setpeercachingflags`: Change whether job data may be downloaded from or served to peers.
- `/setreplyfilename`: Change the local destination for upload-reply content.
- `/sethelpertoken`: Persist the current prompt's primary token as the job helper token.
- `/sethelpertokenflags`: Select whether that helper token is used for local filesystem, network, or both.

Four top-level family selectors expose machine/service-wide surfaces whose
nested command names are meaningful only together with their parent.

<!-- mant:entries role=option case=insensitive -->
- `/util`: Select BITS version, system-account Internet proxy, or analytic-channel utilities.
- `/peercaching`: Select computer-wide peer-caching configuration.
- `/cache`: Select local BITS cache inventory, deletion, limit, or expiration management.
- `/peers`: Select peer inventory, clearing, or discovery.
- `/getieproxy`: Under `/util`, display one system account's Internet proxy configuration.
- `/setieproxy`: Under `/util`, change LocalSystem/NetworkService/LocalService proxy configuration.
- `/version`: Under `/util`, display the active BITS service version.
- `/enableanalyticchannel`: Under `/util`, enable or disable the BITS Client Analytic event channel.
- `/conn`: Under a system-account proxy command, select one exact connection name.
- `/getconfigurationflags`: Under `/peercaching`, display computer-wide peer-caching flags.
- `/setconfigurationflags`: Under `/peercaching`, change client/server peer-caching behavior.
- `/delete`: Under `/cache`, delete one exact cache record.
- `/deleteurl`: Under `/cache`, delete every entry matching one exact URL.
- `/clear`: Under `/cache`, purge the local cache; under `/peers`, clear the peer list.
- `/getlimit`: Under `/cache`, display the cache size limit.
- `/setlimit`: Under `/cache`, change or reset its percentage limit.
- `/getexpirationtime`: Under `/cache`, display cache expiration time.
- `/setexpirationtime`: Under `/cache`, change or reset expiration time.
- `/discover`: Under `/peers`, trigger peer rediscovery.

Read `bitsadmin /help <switch>` and the corresponding BITS API documentation
before using an advanced switch; the top-level inventory is not a sufficient
behavior or security contract. Nested aliases such as `/list`, `/info`, and
`/clear` must always be interpreted with their `/cache` or `/peers` parent.

Read `bitsadmin /help <switch>` and the corresponding BITS API documentation
before using an advanced switch; the top-level switch list is not a sufficient
behavior or security contract.

## Common mistakes

### Selecting a job by display name

Names need not be unique. Record the GUID, owner SID/account, type, creation
time, source/destination mapping and expected application correlation. Requery
that exact GUID immediately before any complete, cancel, ownership or mutation.

### Treating `TRANSFERRED` as a committed destination file

An asynchronous download reaches transferred state before `Complete-BitsTransfer`
or `/complete` finalizes it. Handle every terminal/error state with a finite
deadline, inspect error context, validate expected length/hash/signature, then
complete exactly the intended job. Define cleanup for failure and cancellation.

### Polling a stale PowerShell job object forever

Requery the job by GUID inside a bounded loop; do not repeatedly inspect the
unchanged object returned at creation. Handle transient error, error, suspended,
cancelled/disappeared, transferred and timeout states, with exponential/bounded
polling rather than a tight loop.

### Using `/reset`, `/cancel`, or `/takeownership` as repair

Reset can cancel multiple jobs; all-users scope affects other owners and system
components. Taking ownership changes the security boundary and can expose job
data. Inventory all affected GUIDs/owners, identify the owning product/service,
preserve diagnostics, and use the product's recovery procedure.

### Ignoring persistence and execution surfaces

Notification command lines, helper tokens, credentials, client certificates,
custom headers, reply files and destinations can expose secrets or execute code
later under a different context. Treat unexpected BITS jobs as security evidence;
do not complete, resume, cancel, or execute their content before collection and
incident-response review.

### Trusting downloaded content because BITS succeeded

Transport completion is not publisher authenticity or safe content. Require an
approved HTTPS origin, redirect/proxy policy, exact destination, size limits,
trusted expected digest or signature/publisher validation, quarantine, and a
separate authorization before execution or installation.

### Querying `/allusers` casually

It requires elevation and can reveal sensitive URLs, paths, owners, headers and
application activity. Use current-user scope by default; protect collected
output and redact secrets without destroying evidence.

## PowerShell boundaries

Invoke `bitsadmin.exe` explicitly and capture `$LASTEXITCODE`. Prefer
`Get-BitsTransfer -JobId <guid>` and the other BitsTransfer cmdlets where the
module is supported. In PowerShell 7, verify module availability/compatibility
on the target rather than assuming Windows PowerShell module behavior.

Avoid `Invoke-WebRequest` as a mechanical replacement when the requirement is
background throttled/resumable transfer; conversely, do not choose BITS when a
bounded synchronous request or application package manager is the real model.

## Version and platform differences

BITSAdmin is Windows-only. Switches, service policy, proxy/authentication,
peer/cache features, security flags, PowerShell module compatibility and job
visibility vary by Windows build, identity, elevation and organization policy.
Jobs owned by an elevated token can appear read-only from a non-elevated shell.

## Runtime evidence

On Windows NT 10.0.26200.0, exact System32 BITSAdmin file version 7.8.26100.1
reported utility version 3.0. Top-level /? returned 196 nonempty stdout
lines/status 0; /util /?, /peercaching /?, /cache /?, and /peers /? returned
51, 11, 15, and seven lines, all status 0. The page now makes every installed
top-level getter/mutator and unique nested-family operation ManT-addressable
while preserving parent-context ambiguity and
credential/certificate/header/helper-token/TLS/peer/cache/system-proxy/analytic-channel
boundaries. Only static help ran; no job list/info,
URL/path/owner/header/credential/certificate/reply/peer/cache inventory,
create/add/transfer/lifecycle, ownership, notification, proxy, security,
helper-token, peer/cache or service mutation occurred.

## Related documents
- Native curl: query `mant curl --source cross-platform-tools`.
- PowerShell `Invoke-WebRequest`: use the edition-specific `pwsh7` or `pwsh51` source.
- [certutil.exe](certutil.exe.md)
- [schtasks.exe](schtasks.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[BITSAdmin reference](https://learn.microsoft.com/windows-server/administration/windows-commands/bitsadmin)
and its linked switch/API documentation. Completion and stale-state failures
were cross-checked against practitioner discussions of
[why completion is required](https://stackoverflow.com/questions/20993417/what-is-the-purpose-of-the-complete-bitstransfer-cmdlet)
and [jobs that do not complete](https://stackoverflow.com/questions/15751498/powershell-bitstransfer-does-not-complete).
Microsoft sources govern supported behavior. Exact sources and licenses are
recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
