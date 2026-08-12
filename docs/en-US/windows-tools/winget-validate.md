<!-- mant:tldr:start -->
# winget-validate

> Validate a local WinGet package manifest against the installed client schema.
> More information: https://learn.microsoft.com/windows/package-manager/winget/validate.

- Validate a manifest file or multi-file manifest directory:

`winget validate --manifest {{path}}`

- Stop a PowerShell workflow when validation fails:

`winget validate --manifest {{path}}; if ($LASTEXITCODE -ne 0) { throw 'Manifest validation failed' }`
<!-- mant:tldr:end -->

# winget validate

## Synopsis

```text
winget validate --manifest PATH [options]
```

`winget validate` checks a package manifest intended for the Windows Package
Manager Community Repository. It validates structure and client-known rules;
it does not establish publisher authorization, installer safety, URL durability,
license compliance, successful installation, or repository acceptance.

## Options

<!-- mant:entries role=option case=insensitive -->
- `--manifest PATH`: Validate the manifest file or multi-file manifest directory at `PATH`.
- `-?`, `--help`: Display command help.
- `--wait`: Wait for a key press before exit.
- `--logs`, `--open-logs`: Open WinGet's log directory.
- `--verbose`, `--verbose-logs`: Enable verbose logging for this invocation.
- `--nowarn`, `--ignore-warnings`: Suppress warnings; do not use this when warnings are review inputs.
- `--disable-interactivity`: Fail instead of waiting for input.

## Authoring workflow

Validate exact local content and preserve diagnostics:

```powershell
$manifest = (Resolve-Path .\manifests\x\Example\App\1.2.3).Path
$output = winget validate --manifest $manifest 2>&1
$code = $LASTEXITCODE
$output
if ($code -ne 0) { throw "Manifest validation failed: $code" }
```

Then independently review identifiers/version consistency, locale files,
installer URLs and hashes, architectures/scopes/types, silent switches, upgrade
and uninstall behavior, return codes, dependencies, agreements, release notes,
publisher proof, and a clean-fixture install/upgrade/uninstall sequence.

## PowerShell considerations

Diagnostics are native localized text and can span stdout/stderr. Capture both,
check `$LASTEXITCODE` immediately, and avoid using the absence of a particular
English phrase as the success condition.

## Common mistakes

### Calling schema-valid content trustworthy

Validation can accept syntactically valid URLs, hashes, and switches whose
meaning is wrong or malicious. Human/security review and runtime fixtures are
separate gates.

### Validating with a different client than CI/repository review

Client schemas and rules evolve. Pin/record the WinGet version and repeat with
the repository's current validation workflow before submission.

### Hiding warnings in authoring automation

Warnings often identify forward compatibility or quality problems. Preserve
them as review failures unless an explicit policy documents the exception.

## Version and availability

Accepted schemas and validation rules depend on the installed WinGet client and
the repository's current policy. Passing locally does not guarantee that a pull
request passes later service-side checks.

## Verification boundary

Official syntax and validation scope were reviewed. No manifest, installer,
URL, hash, repository submission, or runtime lifecycle test was validated.

## Related documents

- [winget hash](winget-hash.md)
- [winget install](winget-install.md)
- [Windows Package Manager](winget.exe.md)

## Sources and license

This original guide was adapted from the official
[winget validate documentation](https://learn.microsoft.com/windows/package-manager/winget/validate)
and WinGet manifest-authoring guidance. Exact upstream revision and paths are
recorded in `upstream/windows-tools.json`.

The cited WinGet documentation is licensed under MIT. This adaptation is
licensed under CC BY 4.0.
