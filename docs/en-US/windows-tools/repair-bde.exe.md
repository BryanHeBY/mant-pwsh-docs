<!-- mant:tldr:start -->
# repair-bde.exe

> Salvage data from a severely damaged BitLocker volume into a separate disposable output volume or image.
> The output volume is completely deleted and overwritten; never target the source, the only backup, or storage that has not been independently identified and approved.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/repair-bde.

- Display installed syntax without supplying a volume, key, password, image, or log path; installed help may return exit code 1:

`repair-bde.exe /?; $helpExitCode = $LASTEXITCODE`

- Record source and proposed output identities before a specialist-approved recovery; this does not authorize running the repair:

`Get-Volume | Select-Object DriveLetter, FileSystemLabel, FileSystemType, DriveType, HealthStatus, OperationalStatus, Size, SizeRemaining, UniqueId`

- Verify that an approved image-file parent exists and that neither output nor log already exists:

`$outputImage = [IO.Path]::GetFullPath("{{X:\approved-recovery\damaged-volume.img}}"); $logPath = [IO.Path]::GetFullPath("{{X:\approved-recovery\repair-bde.log}}"); if (-not (Test-Path -LiteralPath (Split-Path -LiteralPath $outputImage -Parent) -PathType Container) -or (Test-Path -LiteralPath $outputImage) -or (Test-Path -LiteralPath $logPath)) { throw 'Recovery parent must exist and output/log paths must be new.' }`
<!-- mant:tldr:end -->

# repair-bde.exe

## Overview

`repair-bde.exe` is a Windows BitLocker disaster-recovery tool. It attempts to
reconstruct critical metadata and decrypt recoverable content from one damaged
BitLocker input volume into a different output volume or image file. It is not
an in-place repair, ordinary unlock command, filesystem checker, undelete tool,
backup, or proof that every recovered file is intact.

The output is destructive. Microsoft states that an output volume is completely
deleted and overwritten by decrypted data from the damaged source. Use separate
spare storage, preserve the original whenever possible, and have a storage or
incident-recovery owner approve the exact source, destination, recovery material,
capacity, evidence-retention, and validation plan before execution.

## Syntax and options

```text
repair-bde.exe INPUT_VOLUME OUTPUT_VOLUME_OR_IMAGE
  (-RecoveryPassword NUMERICAL_PASSWORD | -RecoveryKey KEY_FILE | -Password)
  [-KeyPackage KEY_PACKAGE] [-LogFile LOG_FILE] [-Force] [-? | /?]
```

The installed help also says the tool first attempts a clear key when one is
present after interrupted encryption, decryption, or suspended protection. Do
not infer that this will work, or omit recovery-material preparation, merely
because the source was once unlocked.

<!-- mant:entries role=command case=insensitive -->
- `repair-bde.exe`: Recover readable BitLocker content from one damaged input volume into a separate destructive output volume or image.

The two positional operands establish the destructive source/output pair:

- `INPUT_VOLUME`: Select the exact damaged BitLocker volume by drive letter with colon or stable volume path.
- `OUTPUT_VOLUME_OR_IMAGE`: Select a different spare volume that will be completely overwritten, or a new image-file path with adequate healthy storage.

The remaining selectors choose recovery material, evidence output, and whether
the tool may force a dismount.

<!-- mant:entries role=option case=insensitive -->
- `-recoverypassword NUMERICAL_PASSWORD`, `-rp NUMERICAL_PASSWORD`: Supply the following 48-digit numerical recovery password; command-line use exposes a secret through process arguments and logs.
- `-recoverykey KEY_FILE`, `-rk KEY_FILE`: Read the following external `.bek` recovery-key file; protect the key and its storage.
- `-password`, `-pw`: Prompt for a password instead of placing it on the command line.
- `-keypackage KEY_PACKAGE`, `-kp KEY_PACKAGE`: Supply the matching backup key package when damaged BitLocker metadata requires it.
- `-logfile LOG_FILE`, `-lf LOG_FILE`: Write progress information to the following log path; preflight a new protected path and treat the log as sensitive recovery evidence.
- `-force`, `-f`: Force dismount when the source cannot be locked; this can interrupt users and applications and is not routine boilerplate.
- `-?`, `/?`: Display installed help; on the recorded Windows build this printed complete help and returned exit code 1.

Long and short option spellings are equivalent. The key package is bound to the
corresponding drive identifier; an unrelated package is not interchangeable.
Microsoft's current reference says corrupted BitLocker metadata can require the
matching key package in addition to a recovery password or recovery key.

## Recovery gates

Before any real recovery:

1. Stop ordinary writes and decide whether physical failure, RAID/Storage
   Spaces, evidence handling, or unique data requires imaging or a specialist.
2. Resolve the source by durable volume, disk, partition, and BitLocker
   identity—not drive letter alone—and preserve current health/error evidence.
3. Resolve the output independently. Prove it is not the input, a mounted
   source path, the only backup, an evidence master, or another required disk.
4. Confirm healthy capacity, power, connection, writeability, and whether an
   image file or whole spare volume is the approved destination.
5. Retrieve the correct recovery material through an approved secret channel.
   Protect key packages, `.bek` files, passwords, command history, process
   arguments, transcripts, logs, screenshots, and terminal output.
6. Use a new protected log path and record the exact executable, OS build,
   identities, approvals, arguments with secrets redacted, streams, exit code,
   and timestamps.
7. Validate recovered filesystem and file content independently. Preserve the
   original and recovery artifacts until the owner accepts the result.

## Common mistakes

### Reversing input and output

The second positional operand is not a harmless destination label. A volume
selected there is completely erased and overwritten. Compare stable disk,
partition, volume, and device identifiers immediately before execution; never
approve the pair from drive letters alone.

### Treating an image path like a no-clobber backup

The interface has no documented preview or no-clobber switch. Require a new
image and log path under an existing approved directory, verify free space and
storage health, and stop if either path already exists. A preflight reduces
accidental collision but is not an atomic reservation against another writer.

### Putting a recovery password in command arguments

`-rp` places the numerical password in the command line where process inventory,
history, transcripts, logs, or monitoring can capture it. Prefer an approved
key-file workflow or the interactive `-pw` prompt when applicable, and redact
all durable evidence. Do not paste secrets into tickets or Agent conversations.

### Adding `-Force` by default

`-Force` can dismount a volume that cannot be locked, interrupting open handles
and other users. Establish why locking failed and coordinate the outage; do not
use force to hide source-identity, access, application, or storage problems.

### Treating help exit 1 as a failed recovery

On Windows NT 10.0.26200.0, installed file version 10.0.26100.1 printed its
complete `/?` help and returned 1. That versioned help result does not define
the exit contract for a recovery operation. Preserve output, `$LASTEXITCODE`,
artifact state, and semantic validation separately.

### Assuming recovered bytes are valid data

A completed process can still yield partial or corrupt content. Mount or inspect
an image only through the approved recovery workflow, run filesystem and
format-aware checks on copies where appropriate, compare known hashes/backups,
and document unrecovered regions and files.

## PowerShell boundaries

Call `repair-bde.exe` explicitly. Do not use `Invoke-Expression`, interpolate
untrusted paths, or build one command string. Pass path operands as separate
arguments, and never print or serialize secret-bearing argument arrays. Capture
stdout, stderr, and `$LASTEXITCODE`; do not infer success from one of them alone.

PowerShell path preflights cannot prove durable volume identity, cannot reserve
a path atomically, and cannot make a destructive output volume safe. Re-resolve
identities at the execution boundary and verify the resulting artifact.

## Version and platform differences

This executable is Windows-only and requires BitLocker support plus appropriate
administrative access. Availability, accepted recovery material, prompts,
localized output, access, storage topology, and exit behavior can vary by OS
build and recovery condition. The current Microsoft reference applies to
supported Windows 10/11, Windows Server 2016–2025, and listed Azure Local
releases; confirm the installed help and supported platform for the actual host.

## Runtime evidence

On Windows NT 10.0.26200.0, signed installed file version 10.0.26100.1 printed
complete /? help and returned 1. Help also documents -Force in the parameter
section although its displayed Usage block omits that option. No volume, image,
key, password, key package, log path, or force selector was supplied.

## Related documents
- [manage-bde.exe](manage-bde.exe.md)
- [mountvol.exe](mountvol.exe.md)
- [diskpart.exe](diskpart.exe.md)
- [chkdsk.exe](chkdsk.exe.md)
- [recover.exe](recover.exe.md)
- [wbadmin.exe](wbadmin.exe.md)

## Sources and license

Behavior, syntax, key-package requirements, applicability, and the destructive
output warning come from Microsoft's CC BY 4.0
[repair-bde reference](https://learn.microsoft.com/windows-server/administration/windows-commands/repair-bde).
Exact provenance and the versioned local help observation are recorded in
`upstream/windows-tools.json` and `release/v0.7.0-runtime-evidence.md`.
