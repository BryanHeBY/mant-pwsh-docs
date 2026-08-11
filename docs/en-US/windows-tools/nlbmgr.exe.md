<!-- mant:tldr:start -->
# nlbmgr.exe

> Open the deprecated Network Load Balancing Manager only after inventorying clusters, hosts, reachability, and management scope.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/nlbmgr.

- Check whether NLB tools and cmdlets are installed without adding the feature:

`Get-Command nlbmgr.exe -ErrorAction SilentlyContinue; Get-Command -Module NetworkLoadBalancingClusters -ErrorAction SilentlyContinue`

- Read launcher help without connecting to a cluster:

`nlbmgr.exe /?`

- Review and hash a host-list file before allowing the GUI to contact it:

`Get-Content -LiteralPath "{{C:\Ops\nlb-hosts.txt}}"; Get-FileHash -LiteralPath "{{C:\Ops\nlb-hosts.txt}}" -Algorithm SHA256`

- Open the GUI without importing hosts or enabling auto-refresh:

`Start-Process nlbmgr.exe`
<!-- mant:tldr:end -->

# nlbmgr.exe

## Overview

`nlbmgr.exe` launches Network Load Balancing Manager. `/hostlist <file>` loads
management targets, `/autorefresh <seconds>` polls them, and `/noping` skips the
pre-WMI ICMP check. The GUI can manage clusters/hosts and replicate
configuration. Microsoft marks Windows NLB deprecated and recommends Software
Load Balancer for SDN as an alternative.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `nlbmgr.exe`: Launch the deprecated Network Load Balancing Manager GUI.

Command-line operands only seed interactive manager behavior; they do not
provide transactional cluster automation.

<!-- mant:entries role=option case=insensitive -->
- `/hostlist`: Load management targets from a reviewed host-list file.
- `/autorefresh`: Poll displayed hosts at the supplied interval in seconds.
- `/noping`: Skip preliminary ping without fixing RPC/NLB connectivity.
- `/?`: Display installed syntax.

## Common mistakes

### Treating a host list as passive bookmarks

Opening/importing it causes network management activity, and the GUI can mutate
every listed host. Review each identity, environment, owner, cluster membership,
credential context, and change scope before loading it.

### Using `/noping` to fix connectivity

It suppresses one preliminary test and can make unavailable hosts slower to
fail. It does not fix WMI, firewall, DNS, routing, authentication, or NLB health.

### Replicating one host's configuration blindly

Interface identity, dedicated/cluster IPs, port rules, affinity, priorities,
MAC/network mode, drain state, and application readiness can differ. Export and
review the cluster-wide plan and preserve rollback.

### Starting new architecture on a deprecated feature

Deprecation is not immediate removal, but new designs should evaluate supported
load balancers and application health/HA requirements instead of copying NLB.

## PowerShell boundaries

The launcher exits independently of work performed later in its GUI. Prefer
typed NLB cmdlets for reviewed automation when available, with exact cluster and
host scope; do not treat successful GUI launch as connectivity or health.

## Version and platform differences

Windows NLB is deprecated but remains supported within applicable Windows
Server lifecycles. Feature/cmdlet/GUI availability, remote WMI, networking,
virtualization, and alternative SDN capabilities differ by release.

## Related documents

- [ping.exe](ping.exe.md)
- [sc.exe](sc.exe.md)

## Sources and license

Adapted as an original guide from Microsoft's [NlbMgr reference](https://learn.microsoft.com/windows-server/administration/windows-commands/nlbmgr)
and [Windows Server removed/deprecated features](https://learn.microsoft.com/windows-server/get-started/removed-deprecated-features-windows-server).
Exact provenance is in `upstream/windows-tools.json`. Microsoft documentation and this
adaptation are licensed under CC BY 4.0.
