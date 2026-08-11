<!-- mant:tldr:start -->
# hostname

> Print the Windows host-name portion visible to the current process.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/hostname.

- Print the short host name:

`hostname.exe`

- Inspect the computer name through a typed Windows management property:

`Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Name, Domain, PartOfDomain`

- Inspect the process environment value separately:

`$env:COMPUTERNAME`

- Resolve the local DNS host entry when a DNS-qualified identity is needed:

`[System.Net.Dns]::GetHostEntry([System.Net.Dns]::GetHostName()).HostName`
<!-- mant:tldr:end -->

# hostname

## Overview

`hostname.exe` prints the host-name portion of the computer's full name. It is
a small display command, not a rename or DNS-validation tool. In cluster-aware
contexts, the `_CLUSTER_NETWORK_NAME_` environment variable can cause it to
report a cluster network name rather than the physical node name.

## Common mistakes

### Treating a short name as a DNS FQDN

A host name, DNS suffix, DNS alias, directory-domain membership, and cluster
virtual name answer different identity questions. Choose and label the field
that the consumer needs instead of appending a guessed suffix.

### Assuming every source returns the same identity

`hostname.exe`, `$env:COMPUTERNAME`, CIM, DNS lookup, and cloud or cluster
metadata can legitimately differ. Capture the source and execution context.

### Passing a name as an argument

`hostname.exe` does not set the name; arguments other than help produce an
error. Renaming a machine is an administrative state change that requires a
separate supported management workflow and usually a restart.

### Ignoring DNS lookup failure or aliases

A reverse or local host-entry result depends on resolver configuration and
does not prove that other clients resolve the same name. Query the intended
DNS server and record the returned canonical name and addresses separately.

## Version and platform differences

This page documents Windows `hostname.exe`. PowerShell and .NET alternatives
have different platform support and identity semantics.

## Related documents

- [ipconfig](ipconfig.md)
- [nslookup](nslookup.md)
- [whoami](whoami.md)

## Sources and license

This original guide was adapted from Microsoft's official
[hostname reference](https://learn.microsoft.com/windows-server/administration/windows-commands/hostname).
Exact sources and licenses are recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
