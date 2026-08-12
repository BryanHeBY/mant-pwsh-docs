<!-- mant:tldr:start -->
# winget-hash

> Compute WinGet manifest SHA-256 values for a local installer.
> More information: https://learn.microsoft.com/windows/package-manager/winget/hash.

- Compute an installer's SHA-256 manifest value:

`winget hash --file {{installer.exe}}`

- Compute installer and MSIX signature hashes:

`winget hash --file {{package.msix}} --msix`

- Independently compare the file hash in PowerShell:

`Get-FileHash -Algorithm SHA256 {{installer.exe}}`
<!-- mant:tldr:end -->

# winget hash

## Synopsis

```text
winget hash --file FILE [--msix] [options]
```

`winget hash` computes the SHA-256 value used in WinGet installer manifests.
For MSIX input, `--msix` also emits the package signature hash used by the
manifest format. Hash calculation does not authenticate the publisher or prove
that the file is safe.

## Options

<!-- mant:entries role=option case=insensitive -->
- `-f FILE`, `--file FILE`: Hash the exact local installer at `FILE`.
- `-m`, `--msix`: Also compute the MSIX `SignatureSha256` value.
- `-?`, `--help`: Display command help.
- `--wait`: Wait for a key press before exit.
- `--logs`, `--open-logs`: Open WinGet's log directory.
- `--verbose`, `--verbose-logs`: Enable verbose logging for this invocation.
- `--nowarn`, `--ignore-warnings`: Suppress warning display.
- `--disable-interactivity`: Fail instead of waiting for input.

## Manifest-authoring workflow

```powershell
$file = (Resolve-Path .\installer.exe).Path
$identity = Get-Item -LiteralPath $file
$signature = Get-AuthenticodeSignature -LiteralPath $file
$independent = Get-FileHash -LiteralPath $file -Algorithm SHA256

$wingetHash = winget hash --file $file
if ($LASTEXITCODE -ne 0) { throw "winget hash failed: $LASTEXITCODE" }

$identity | Select-Object FullName, Length, LastWriteTimeUtc
$signature | Select-Object Status, SignerCertificate
$independent
$wingetHash
```

Record the download URL, publisher, file size, signature, source retrieval time,
and independent hash with the manifest. Recalculate after any file change; a
hash belongs to exact bytes, not merely a version label.

## PowerShell considerations

WinGet prints display text, whereas `Get-FileHash` returns an object. Do not
silently scrape a localized line; check `$LASTEXITCODE`, capture output, and
compare a normalized hexadecimal value under an explicit parser/test.

## Common mistakes

### Treating matching hashes as publisher trust

Two tools can agree about bytes that are still malicious. Verify acquisition,
Authenticode/package signature, publisher identity, and review policy.

### Hashing a URL or shortcut

The command hashes a local file. Resolve the exact artifact, avoid wildcard
selection, and record size/path before hashing.

## Version and availability

The stable installer SHA-256 behavior is part of WinGet manifest authoring;
MSIX signature handling and display format depend on client/package format.
Use the client and schema version used to validate the final manifest.

## Verification boundary

Official hash and MSIX options were reviewed. No artifact was downloaded,
opened, signed, hashed, or submitted and no manifest was changed.

## Related documents

- [winget validate](winget-validate.md)
- [winget download](winget-download.md)
- [certutil.exe](certutil.exe.md)

## Sources and license

This original guide was adapted from the official
[winget hash documentation](https://learn.microsoft.com/windows/package-manager/winget/hash).
Exact upstream revision and path are recorded in `upstream/windows-tools.json`.

The cited WinGet documentation is licensed under MIT. This adaptation is
licensed under CC BY 4.0.
