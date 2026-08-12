<!-- mant:tldr:start -->
# tar

> Create, inspect, and extract archive files while checking the installed tar implementation.
> More information: https://www.gnu.org/software/tar/manual/tar.html.

- Identify the installed implementation and version:

`tar --version`

- List archive contents before extraction:

`tar -tf {{archive.tar}}`

- Extract into a dedicated destination directory:

`tar -xf {{archive.tar}} -C {{destination-directory}}`
<!-- mant:tldr:end -->

# tar

## Synopsis

```text
tar -c|-t|-x [options] archive [paths...]
```

`tar` creates, lists, and extracts archives. Its behavior is implementation-
and build-dependent: GNU tar, BSD tar/libarchive, and Windows-distributed
variants do not necessarily support identical options, compression formats, or
security defaults. Begin with `tar --version` on the target host.

## Common operations and implementation-specific options

The short mode and archive-selection forms below are broadly recognizable,
but even their edge cases vary. Every long spelling is conditional on the
selected implementation unless its installed help confirms it.

<!-- mant:entries role=option case=sensitive -->
- `-c`, `--create`: Create a new archive from the selected input paths.
- `-t`, `--list`: List archive members without extracting them.
- `-x`, `--extract`, `--get`: Extract archive members; preflight names and links before writing them.
- `-f ARCHIVE`, `--file ARCHIVE`: Read or write the named archive instead of the implementation's default device or stream.
- `-C DIRECTORY`, `--directory DIRECTORY`: Change directory before processing following names; placement semantics can matter.
- `-v`, `--verbose`: List processed members; verbose output is diagnostic text, not a stable machine interface.
- `-z`, `--gzip`: Filter the archive through gzip when the installed implementation supports the option.
- `-j`, `--bzip2`: Filter the archive through bzip2 when supported.
- `-J`, `--xz`: Filter the archive through xz when supported.
- `--strip-components COUNT`: Remove leading path components during extraction; verify support and the resulting names first.
- `--exclude PATTERN`: Exclude matching names; pattern rules and option ordering vary by implementation.
- `--files-from FILE`, `-T FILE`: Read member names from a file; quoting, null delimiters, and option handling require implementation-specific review.
- `--no-recursion`: Do not recursively descend into directory arguments during archive creation.
- `--keep-old-files`: Refuse to replace existing files during extraction where supported.
- `--skip-old-files`: Skip existing files without treating each one as a fatal extraction error where supported.
- `--no-same-owner`: Do not attempt to restore archived ownership; especially relevant when extracting with elevated privilege.
- `--no-same-permissions`: Apply the current permission policy instead of restoring all archived mode bits where supported.
- `--warning KEYWORD`: Control GNU tar warning classes; this is not a portable tar option.

GNU tar documents the long forms above. The recorded Windows bsdtar 3.8.4
help instead displays `-c`, `-r`, `-t`, `-u`, `-x`, `-b`, `-f`, `-v`, `-w`,
`-z`, `-j`, `-J`, `--lzma`, `--format`, `--exclude`, `--mtime`,
`--clamp-mtime`, `-C`, archive-list input as `@ARCHIVE`, and extraction forms
`-k`, `-m`, `-O`, and `-p`:

<!-- mant:entries role=option case=sensitive -->
- `-r`: Add or replace archive members in the recorded Windows bsdtar.
- `-u`: Update archive members in the recorded Windows bsdtar.
- `-b BLOCKS`: Set 512-byte records per I/O block in that implementation.
- `-w`: Prompt interactively before actions; unsuitable for unattended runs.
- `--lzma`: Compress a created archive with LZMA where that bsdtar build supports it.
- `--format FORMAT`: Select the recorded bsdtar create format from its installed set.
- `--mtime DATE`: Set modification times stored for added members.
- `--clamp-mtime`: Change only member times newer than the accompanying `--mtime` boundary.
- `-k`: Refuse to overwrite existing files during extraction.
- `-m`: Do not restore archived modification times during extraction.
- `-O`: Write extracted member bytes to stdout instead of restoring them to disk.
- `-p`: Restore permissions including ACLs, owner, and file flags during extraction.

These spellings and meanings must not be projected onto GNU tar or another
bsdtar release without its own help.

A standalone `--` ends option parsing before a member name that begins with
`-` when the installed implementation supports this convention.

## Inspect before extraction

List contents before extracting an untrusted or newly received archive:

```powershell
tar -tf .\release.tar
if ($LASTEXITCODE -ne 0) {
    throw "Archive listing failed with exit code $LASTEXITCODE"
}
```

Review unexpected absolute paths, `..` path traversal components, duplicate
names, symlinks, hard links, executable files, and unusually large contents.
Extract only into a new or deliberately dedicated directory, never a broad root
or production application path.

## Create and extract deliberately

Use explicit archive and input paths. For example:

```powershell
tar -cf .\backup.tar .\project
tar -xf .\backup.tar -C .\restore
```

Compression flags and automatic format detection vary. Do not copy a GNU tar
option into Windows or macOS automation without checking the installed
implementation's help. Preserve files and permissions only as required by the
target platform and backup policy.

## PowerShell boundaries

`tar` consumes filesystem paths and writes native output. It does not accept
PowerShell provider paths or object pipeline input. Use literal, bounded paths,
check `$LASTEXITCODE`, and keep archive names separate from data that could be
interpreted as options. Validate archive integrity and origin before extraction;
archive traversal protection is an input-validation concern, not a substitute
for a trusted source.

## Version and platform differences

The concrete option descriptions use GNU tar 1.35 as the checked baseline.
macOS and many Windows installations provide bsdtar/libarchive instead, and
some Windows environments expose a different build through another toolchain.
Confirm `tar --version` and installed help before using long or compression
options in portable automation.

On Windows NT `10.0.26200.0`, Windows PowerShell 5.1 resolved both System32
`tar.exe` and Git's bundled `tar.exe`. Exact System32 file version `3.8.4`
reported `bsdtar 3.8.4 - libarchive 3.8.4`; `--version` returned 0 with one
stdout line and `--help` returned 0 with 26 nonempty stdout lines. Of the long
GNU spellings indexed above, that installed help displayed only `--exclude`;
this is a discovery boundary, not proof that every undisplayed token is
rejected. No archive,
member, path, directory, compression filter, input stream, output stream,
filesystem metadata, read, or write was supplied. GNU-only options in this page
remain conditional even though the same `tar` name resolves successfully.

## Common mistakes

### Extracting before inspecting member paths and links

List the archive first and reject absolute paths, traversal, unexpected links,
device files, or excessive expansion. Extract into a new bounded directory.

### Assuming the same `tar` implementation on every platform

GNU tar, bsdtar, and other builds overlap but do not share an identical
interface. Gate implementation-specific options on detected help/version.

### Treating `-p` as a harmless preservation default

On the recorded Windows bsdtar, `-p` restores ACLs, owner, and file flags in
addition to ordinary permissions. Elevated extraction can therefore apply
security identities or metadata that are inappropriate on the destination.
Inspect the archive and extract with least privilege; omit metadata restoration
unless the backup/restore contract explicitly requires it.

### Restoring ownership or permissions unnecessarily

Elevated extraction can apply archived metadata with broader consequences.
Use the least privilege and the implementation's ownership/permission limits
when exact restoration is not required.

## Runtime evidence

The repeatable Windows cross-platform fixture preserved both discovered
`tar.exe` Application candidates and selected exact System32 bsdtar under both
PowerShell collectors. `--version` returned one implementation/version line
and `--help` returned 26 nonempty lines, both with status `0`. No archive,
member, path, compression filter, input/output stream, filesystem read, write,
or metadata restoration occurred. GNU behavior, macOS behavior, and safe
extraction against an approved adversarial fixture remain pending.

## Related documents

- [curl](curl.md)
- [Cross-platform tools for PowerShell](cross-platform-tools.md)
- On Windows, query `mant wsl --source windows-tools` and
  `mant robocopy --source windows-tools`.

## Sources and license

This original portability guide was informed by the
[GNU tar manual](https://www.gnu.org/software/tar/manual/tar.html). It does
not claim GNU tar options apply to every `tar` executable; it requires runtime
version inspection. The web source and license are recorded in
`upstream/cross-platform-tools.json`.

The cited GNU manual is licensed under GFDL-1.3-or-later. This adaptation is
licensed under CC BY 4.0.
