<!-- mant:tldr:start -->
# gpfixup.exe

> Use Gpfixup only inside a supported Active Directory domain-rename runbook;
> inventory the new domain/DC identity and preserve every GPO before rewriting
> GPO links, SYSVOL paths, or software-installation references.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/gpfixup.

- Confirm the installed executable and display only its help:

`$cmd = Get-Command gpfixup.exe -ErrorAction Stop; $cmd | Select-Object Source, Version; & $cmd.Source '/?'`

- Verify the exact renamed-domain identity and FSMO owners from one explicit DC:

`Get-ADDomain -Identity "{{new.example.com}}" -Server "{{dc01.new.example.com}}" | Select-Object DNSRoot, NetBIOSName, DomainSID, PDCEmulator, InfrastructureMaster`

- Inventory every GPO GUID, name, state, and modification time in the renamed domain:

`Get-GPO -All -Domain "{{new.example.com}}" -Server "{{dc01.new.example.com}}" | Sort-Object Id | Select-Object DisplayName, Id, GpoStatus, ModificationTime`

- Back up all GPOs to a protected existing directory before the approved rewrite:

`Backup-GPO -All -Domain "{{new.example.com}}" -Server "{{dc01.new.example.com}}" -Path "{{D:\protected-gpo-backups}}" -Comment "Pre-gpfixup {{change-id}}"`

<!-- mant:tldr:end -->

# gpfixup.exe

## Overview

`gpfixup.exe` rewrites old DNS and/or NetBIOS domain-name dependencies in GPOs
and GPO links after a supported Active Directory domain rename. It requires the
Group Policy Management feature and is one step in the larger `rendom` domain-
rename workflow, not a general repair for Group Policy, DNS, RDP, or name-
resolution failures.

Gpfixup changes distributed AD and SYSVOL state. Record the domain-rename state,
old/new DNS and NetBIOS names, exact writable target DC, GPO inventory/backups,
replication health, and approved sequence before execution.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `gpfixup.exe`: Rewrite old domain-name dependencies in Group Policy after a
  supported AD domain rename.

There is no dry run. DNS and NetBIOS old/new options must be paired according
to the exact rename that occurred.

<!-- mant:entries role=option case=insensitive -->
- `/olddns`: Supply the pre-rename DNS domain name.
- `/newdns`: Supply the post-rename DNS domain name.
- `/oldnb`: Supply the pre-rename NetBIOS domain name.
- `/newnb`: Supply the post-rename NetBIOS domain name.
- `/dc`: Select one healthy writable DC in the renamed domain.
- `/sionly`: Mutate only managed Software Installation references, not preview them.
- `/v`: Emit verbose results.
- `/user`: Select an alternate execution identity.
- `/pwd`: Supply its password; use `*` to prompt instead of a literal secret.
- `/?`: Display installed syntax.

## Parameter map

- `/olddns` and `/newdns` must be paired when the DNS domain name changed.
- `/oldnb` and `/newnb` must be paired when the NetBIOS name changed.
- `/dc` selects a DC that hosts a writable replica of the renamed domain
  partition. Without it, target selection is implicit.
- `/sionly` updates only managed Software Installation references; it skips the
  general GPO-link and SYSVOL-path corrections.
- `/v` adds diagnostic output; it is not preview mode.
- `/user` changes execution identity; `/pwd:*` prompts. A literal password is
  unsafe and unnecessary in a reviewed interactive procedure.

There is no documented dry-run or rollback switch.

## Common mistakes

### Running Gpfixup outside the full domain-rename sequence

Domain rename includes forest/domain eligibility, DNS, `rendom` state and
uploads, DC preparation/execution, reboots, client/member changes, trust/SPN/
certificate/application dependencies, GPO repair, replication, and cleanup.
Running only Gpfixup cannot complete or reverse that process.

### Reversing old and new names

Write an approved mapping containing old/new DNS names and old/new NetBIOS
names. Verify it against the rename plan, `rendom` state, AD, DNS, and a second
operator. A syntactically successful reversed rewrite can corrupt otherwise
correct GPO references.

### Omitting `/dc` and accepting an arbitrary replica

Select one healthy writable DC in the renamed domain and confirm its site,
time, DNS, AD/SYSVOL replication, and rename state. Preserve the chosen DC in
the log. Do not allow locator cache or an RODC/stale replica to define the write
target accidentally.

### Treating `SUCCESS` as complete Group Policy repair

The tool targets specific domain-name dependencies. It does not prove DNS,
SYSVOL, ACLs, WMI filters, scripts, software shares, certificates, service
accounts, application configuration, RDP, or client secure channels are fixed.
Review changed GPOs and run representative user/computer RSoP and application
tests after replication.

### Using `/sionly` as a preview

`/sionly` still changes managed Software Installation references. Use it only
when the approved rename phase intentionally limits the fix to that extension,
with package/source availability and client deployment impact understood.

### Capturing a literal password or incomplete log

Use current credentials or `/pwd:*`; protect the prompt/transcript. Capture
verbose output, `$LASTEXITCODE`, timestamps, mappings, DC, GPO before/after
reports and backup IDs. Microsoft's redirection example is Cmd syntax; in
PowerShell use explicit stream capture and an encoding-aware protected file.

## PowerShell boundaries

Invoke `gpfixup.exe` explicitly and pass each `/<name>:<value>` token as one
argument. PowerShell's `2>&1` merges error output into the success stream, while
`>` encoding differs by PowerShell edition; do not copy a Cmd redirection line
without adapting and testing it. Avoid literal credentials and preserve raw
localized output before parsing.

## Version and platform differences

Gpfixup is Windows/AD DS tooling and depends on Group Policy Management. Domain-
rename support has product/application restrictions and differs by forest,
domain functional level, Server release, identity systems, hosted services, and
workloads. Verify that the entire environment supports rename before using the
command; a published syntax page does not establish workload compatibility.

## Runtime evidence

On Windows NT `10.0.26200.0`, the catalog identity audit found no
`gpfixup.exe` Application candidate under either PowerShell collector. No
feature, role, or compatibility component was installed merely to change
that result, and no same-named PATH substitute was used. This is target-host
command-resolution evidence, not proof that the tool is unsupported on every
applicable Windows environment.

Behavior verification remains help and explicitly approved read-only
domain/GPO inventory only; backup requires a protected path and no
GPO/link/SYSVOL/software reference, credential, DC selection, or domain-rename
state may be changed merely for evidence.

## Related documents
- [gpresult.exe](gpresult.exe.md)
- [gpupdate.exe](gpupdate.exe.md)
- [dcgpofix.exe](dcgpofix.exe.md)
- [repadmin.exe](repadmin.exe.md)
- [netdom.exe](netdom.exe.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Gpfixup reference](https://learn.microsoft.com/windows-server/administration/windows-commands/gpfixup)
and its linked domain-rename guidance. Post-rename “success but still broken”
demand was cross-checked against a
[Server Fault case](https://serverfault.com/questions/1070462/), which is used
only to identify verification gaps, not as a rename runbook. Microsoft product
documentation governs support and behavior. Exact sources and licenses are
recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Server Fault contributions are licensed under CC BY-SA 4.0.
