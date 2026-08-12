<!-- mant:tldr:start -->
# defrag.exe

> Analyze one local volume, then let Windows select media-appropriate optimization instead of assuming every device needs traditional defragmentation.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/defrag.
> Microsoft documents local Administrators membership or equivalent as the
> minimum requirement; record elevation and access failures even for analysis.

- Analyze one exact volume and print progress plus detailed statistics:

`defrag.exe "{{C:}}" /A /U /V`

- Apply the optimization Windows considers appropriate for that volume's media type:

`defrag.exe "{{C:}}" /O /U /V`

- Request retrim only on one exact supported thin-provisioned or solid-state volume:

`defrag.exe "{{C:}}" /L /U /V`

- Track an optimization already running on one exact volume:

`defrag.exe "{{C:}}" /T`
<!-- mant:tldr:end -->

# defrag.exe

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

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `defrag.exe`: Analyze or optimize one or more Windows volumes.

Specify an exact drive letter, mount point, or volume path unless intentionally
using all-volume scope. Operation availability depends on the storage stack.

<!-- mant:entries role=option case=insensitive -->
- `/a`, `/analyze`: Analyze selected volumes without optimizing them.
- `/b`, `/bootoptimize`: Optimize boot files to improve startup performance
  where supported.
- `/c`, `/allvolumes`: Select every eligible local volume.
- `/d`, `/defrag`: Perform traditional file defragmentation.
- `/e`, `/volumesexcept`: Exclude the listed volumes from all-volume scope.
- `/g`, `/tieroptimize`: Optimize storage tiers on supported tiered volumes.
- `/h`, `/normalpriority`: Run at normal instead of default low priority.
- `/i`, `/maxruntime`: Limit the seconds spent on each tier during tier
  optimization.
- `/k`, `/slabconsolidate`: Perform slab consolidation on supported thinly
  provisioned volumes.
- `/l`, `/retrim`: Send retrim hints for free blocks on supported storage.
- `/m`, `/multithread`: Run selected volumes in parallel, optionally limiting
  tier-optimization thread count.
- `/o`, `/optimize`: Choose the operation appropriate for the detected media
  type.
- `/t`, `/trackprogress`: Track an optimization already running on one
  selected volume.
- `/u`, `/printprogress`: Display progress on screen.
- `/v`, `/verbose`: Display detailed analysis and operation statistics.
- `/x`, `/freespaceconsolidate`: Consolidate free space on selected volumes.
- `/file`: With `/defrag`, restrict mutation to the following explicit paths
  or wildcard patterns on builds that expose this option.
- `/filelist`: With `/defrag`, read paths or wildcard patterns from the
  following list file on builds that expose this option.
- `/layoutfile`: With `/bootoptimize`, use the following layout file instead of
  the default `%windir%\Prefetch\layout.ini`.
- `/onlymetadata`: With `/defrag` on NTFS, target supported metadata such as
  the MFT and USN journal that ordinary Defrag otherwise ignores.
- `/onlypreferred`: For explicitly named volumes, run only operations Windows
  considers preferred from the requested operation list.
- `/simple`: With `/defrag`, request the installed command's simple-defrag
  mode.
- `/?`: Display syntax supported by the installed executable.

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
| `/file`, `/filelist` | Selected-file traditional defrag | Current-build capability; wildcards/list contents define mutation scope. |
| `/layoutfile` | Boot optimization using an explicit layout | Validate provenance, encoding, paths, and exact build support. |
| `/onlymetadata`, `/simple` | Specialized traditional defrag | NTFS/build/operation restrictions apply; neither is analysis-only. |
| `/onlypreferred` | Filter requested operations by Windows preference | Applies to explicitly named volumes; record which operations actually ran. |

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

### Treating `/File` or `/FileList` as analysis filters

Current installed help makes both available only with `/Defrag`. They select
files for a mutation, and wildcard expansion or an unexpected list-file line
can broaden scope. Resolve every path against an approved volume, inspect the
list as data, reject untrusted or changing input, and do not use either option
to emulate `/Analyze`.

### Assuming current long names and specialized modes exist everywhere

Windows build `10.0.26200` help exposes long aliases plus `/File`, `/FileList`,
`/LayoutFile`, `/OnlyMetadata`, `/OnlyPreferred`, and `/Simple`; Microsoft's
current online Defrag page lists only the traditional short interface. Gate
these forms on installed help and test the exact Windows build instead of
silently falling back to a broader/default operation.

## PowerShell boundaries

Defrag emits native progress and report text. Quote mount-point paths, save
output, and check `$LASTEXITCODE`; do not parse localized report layout as a
stable API. For structured automation, evaluate the supported
`Optimize-Volume` cmdlet and storage APIs for the target Windows version.

## Version and platform differences

This Windows-only administrative command applies to supported Windows client
and server releases. Filesystem, media detection, TRIM/UNMAP, tiering, thin
provisioning, cluster ownership, scheduled-maintenance policy, and Windows
version determine valid operations. Long aliases and the specialized
file/layout/metadata/preference modes listed above are installed-build
capabilities, not a promise for every supported release.

## Runtime evidence

Installed help returned 0 with no volume and exposed long aliases plus /File,
/FileList, /LayoutFile, /OnlyMetadata, /OnlyPreferred, and /Simple beyond the
current general page. No volume, analysis, defrag, retrim, consolidation, tier,
file, or layout operation ran; media-specific disposable-volume verification
remains pending.

## Related documents
- [chkdsk.exe](chkdsk.exe.md)
- [compact.exe](compact.exe.md)
- [systeminfo.exe](systeminfo.exe.md)

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
