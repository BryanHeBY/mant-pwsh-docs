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

## Related documents

- [wsl](wsl.md)
- [curl](curl.md)
- [robocopy](robocopy.md)

## Sources and license

This original portability guide was informed by the
[GNU tar manual](https://www.gnu.org/software/tar/manual/tar.html). It does
not claim GNU tar options apply to every `tar` executable; it requires runtime
version inspection. The web source and license are recorded in
`upstream/cli.json`.

The cited GNU manual is licensed under GFDL-1.3-or-later. This adaptation is
licensed under CC BY 4.0.
