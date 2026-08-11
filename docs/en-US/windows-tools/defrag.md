<!-- mant:tldr:start -->
# defrag

> Analyze one local volume, then let Windows select media-appropriate optimization instead of assuming every device needs traditional defragmentation.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/defrag.

- Analyze one exact volume and print progress plus detailed statistics:

`defrag.exe "{{C:}}" /A /U /V`

- Apply the optimization Windows considers appropriate for that volume's media type:

`defrag.exe "{{C:}}" /O /U /V`

- Request retrim only on one exact supported thin-provisioned or solid-state volume:

`defrag.exe "{{C:}}" /L /U /V`

- Track an optimization already running on one exact volume:

`defrag.exe "{{C:}}" /T`
<!-- mant:tldr:end -->

# defrag

## Overview

`defrag.exe` is the Windows Storage Optimizer command-line interface. It can
analyze fragmentation, perform traditional file defragmentation, retrim
supported storage, consolidate free space or slabs, and optimize storage tiers.
`/o` selects the operation appropriate for the detected media type. Scheduled
Windows maintenance applies its own SSD policy, including retrim and periodic
traditional optimization when Windows determines it is appropriate.

This is I/O-intensive maintenance, not a universal speed fix. Start with one
exact volume and `/a`, confirm storage technology and ownership, then choose
the smallest supported operation during a maintenance window.

## Operation map

| Option | Operation | Boundary |
| --- | --- | --- |
| `/a` | Analysis only | Report age and live workload can affect interpretation. |
| `/o` | Media-type-appropriate optimization | Preferred general operation when Windows detection is trusted. |
| `/d` | Traditional defragmentation | Default manual operation; do not equate it with SSD retrim. |
| `/l` | Retrim | Requires storage support; trim affects deleted-block recovery expectations. |
| `/g`, `/i:n` | Storage-tier optimization and time limit | Use only for known tiered volumes and workload policy. |
| `/k` | Slab consolidation | Relevant to supported thin/dynamic storage, not ordinary file fragmentation. |
| `/x` | Free-space consolidation | Can be lengthy and is not the same as `/d`. |
| `/c`, `/e` | All volumes or all except listed | Broad scope; enumerate volumes and exclusions first. |
| `/h`, `/m[:n]` | Normal priority or parallel background work | Can increase interference across storage paths. |

## Common mistakes

### Applying the slogan “never defragment an SSD” mechanically

Windows distinguishes traditional defrag, retrim, and media-appropriate
optimization. Its scheduled policy can occasionally perform traditional SSD
optimization as well as retrim. Prefer `/o` or supported scheduled maintenance
instead of forcing `/d` repeatedly or disabling optimization based on folklore.

### Assuming `/l` and `/d` are synonyms

`/l` sends retrim for supported storage; `/d` moves file extents for
traditional defragmentation. Record which operation ran. Retrim may reduce the
chance of recovering deleted blocks and is not a fragmentation repair.

### Running `/c /h /m` as a harmless cleanup

That combination broadens to all volumes, raises priority, and can run work in
parallel. It can overload shared controllers, SAN paths, virtual disks, and
production workloads. Optimize exact volumes sequentially unless the storage
owner approves broader concurrency.

### Ignoring dirty state and free space

Defrag refuses some dirty/locked volumes; diagnose and handle filesystem
health rather than bypassing it. Microsoft notes that roughly 15% free space
is needed for complete traditional defragmentation, though partial progress is
possible. Lack of space can be a capacity problem, not an optimizer defect.

### Treating analysis percentages as application performance proof

Fragmentation statistics do not measure database layout, latency, queue depth,
cache behavior, storage-array optimization, or application response time.
Correlate with workload and storage evidence before and after maintenance.

### Duplicating the scheduled optimizer

Windows already runs Storage Optimizer as scheduled maintenance subject to
power, idle, and media policies. Check task history and Optimize Drives state
before adding another scheduler; overlapping CLI and GUI runs are mutually
exclusive and can fail or distort timing.

### Using the wrong operation on tiered or virtual storage

Storage Spaces, thin provisioning, ReFS, VHD/VHDX, SAN, cloud, cluster, and
vendor-managed volumes can require owner-specific maintenance. Determine the
filesystem, media, allocation unit, tiering, trim/unmap support, and cluster or
hypervisor guidance before manual optimization.

## PowerShell behavior

Defrag emits native progress and report text. Quote mount-point paths, save
output, and check `$LASTEXITCODE`; do not parse localized report layout as a
stable API. For structured automation, evaluate the supported
`Optimize-Volume` cmdlet and storage APIs for the target Windows version.

## Version and platform differences

This Windows-only administrative command applies to supported Windows client
and server releases. Filesystem, media detection, TRIM/UNMAP, tiering, thin
provisioning, cluster ownership, scheduled-maintenance policy, and Windows
version determine valid operations.

## Related documents

- [chkdsk](chkdsk.md)
- [compact](compact.md)
- [systeminfo](systeminfo.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Defrag reference](https://learn.microsoft.com/windows-server/administration/windows-commands/defrag).
The recurring SSD optimization question was cross-checked against
[practitioner discussion](https://superuser.com/questions/1150641/should-i-defragment-my-ssd),
then resolved using Microsoft's current documented `/d`, `/l`, `/o`, and
scheduled-SSD behavior. Exact sources and licenses are recorded in
`upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY
4.0. Super User contributions are licensed under CC BY-SA 4.0.
