<!-- mant:tldr:start -->
# bitsadmin

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

# bitsadmin

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

- Discovery: `/list`, `/info`, `/listfiles`, `/getstate`, `/geterror`, progress,
  byte/file counts, owner, timestamps, type, priority and timeout getters.
- Lifecycle: `/create`, `/addfile`, `/addfileset`, ranged files, `/resume`,
  `/suspend`, `/complete`, `/cancel`, `/transfer`, and `/reset`.
- Network/authentication: proxy, credentials, client certificates, custom HTTP
  headers, HTTP method, security flags, validation and reply upload data.
- Execution/ownership: notification flags/command line/interface, helper token,
  ownership and ACL flags.
- Peer/cache/service utilities: peer caching, peers, cache administration,
  analytic channel, IE proxy inspection/configuration and service repair.

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

## PowerShell behavior

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

## Related documents

- [curl](curl.md)
- PowerShell `Invoke-WebRequest`: use the edition-specific `pwsh7` or `pwsh51` source.
- [certutil](certutil.md)
- [schtasks](schtasks.md)

## Sources and license

This original guide was adapted from Microsoft's official
[BITSAdmin reference](https://learn.microsoft.com/windows-server/administration/windows-commands/bitsadmin)
and its linked switch/API documentation. Completion and stale-state failures
were cross-checked against practitioner discussions of
[why completion is required](https://stackoverflow.com/questions/20993417/what-is-the-purpose-of-the-complete-bitstransfer-cmdlet)
and [jobs that do not complete](https://stackoverflow.com/questions/15751498/powershell-bitstransfer-does-not-complete).
Microsoft sources govern supported behavior. Exact sources and licenses are
recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
