<!-- mant:tldr:start -->
# cmstp

> Inspect and install or remove a reviewed Connection Manager service profile; an INF is active installation input, not harmless configuration text.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/cmstp.

- Resolve the Windows executable without invoking a profile:

`Get-Command cmstp.exe -All -ErrorAction SilentlyContinue | Select-Object Source,@{Name='FileVersion';Expression={$_.FileVersionInfo.FileVersion}}`

- Display local syntax without installing anything:

`cmstp.exe /?`

- Record the exact approved INF's identity and inspect it before execution:

`Get-Item -LiteralPath "{{C:\Approved\profile.inf}}" | Select-Object FullName,Length,LastWriteTime; Get-FileHash -LiteralPath "{{C:\Approved\profile.inf}}" -Algorithm SHA256; Get-Content -LiteralPath "{{C:\Approved\profile.inf}}"`

- Interactively install that reviewed profile only after approval and rollback planning:

`cmstp.exe "{{C:\Approved\profile.inf}}"; $LASTEXITCODE`
<!-- mant:tldr:end -->

# cmstp

## Overview

`cmstp.exe` installs or removes a Connection Manager service profile described
by an INF, optionally with packaged support files. No read-only profile-list
mode is documented. Treat invocation with an INF as code/configuration
deployment that can change networking and user or machine state.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `cmstp.exe`: Install or remove a verified Connection Manager service profile.

Self-extracting package `/q:a` and `/c:` options belong to an outer parser and
are not CMSTP switches.

<!-- mant:entries role=option case=insensitive -->
- `/s`: Suppress prompts and verification without sandboxing the INF.
- `/u`: Uninstall the selected profile; valid only with `/s`.
- `/nf`: Suppress creation of the support-files directory where supported.
- `/?`: Display installed syntax.

## Common mistakes

### Running an INF merely to discover what it does

Review the complete package offline, hash it, verify provenance, resolve every
referenced file/action and test in a disposable environment. An `.inf` suffix
does not make content passive or trusted.

### Treating `/s` as a safety switch

`/s` suppresses prompts and the verification message; it does not sandbox,
validate, dry-run, or reduce privilege. Silent execution removes an important
human checkpoint and must not be used to hide uncertainty.

### Losing user-versus-machine installation context

Official examples include single-user behavior, while effective scope also
depends on the package and token. Record the actual principal/session and
verify the profile in that same scope plus any intended machine scope.

### Guessing uninstall input or assuming it restores all state

Microsoft permits `/u` only with `/s`. Bind removal to the exact installed
profile/package identity, inventory dependent connections and support files,
and verify residual credentials, routes, services, files and policy.

### Combining the self-extracting-package syntax with an arbitrary directory

The packaged syntax expects execution from the directory containing the
profile executable. Prefer an explicit verified absolute path and do not rely
on current-directory search or a same-name file.

## PowerShell boundaries

Call `cmstp.exe` explicitly and inspect `$LASTEXITCODE` immediately. `/q:a` and
`/c:cmstp.exe` belong to the self-extracting package, while `/s`, `/u`, and
`/nf` belong to CMSTP; do not flatten both parser layers into one guessed
argument list. Quoting protects spaces, not trust.

## Version and platform differences

Windows-only legacy Connection Manager tooling. Broad Learn applicability does
not prove a particular profile technology, package extension, or enterprise
policy is supported on the current build. Test the exact signed/approved
package and migration plan.

## Related documents

- [netcfg](netcfg.md)
- [netsh](netsh.md)
- [certutil](certutil.md)
- [where](where.md)

## Sources and license

This original guide was adapted from Microsoft's official
[cmstp reference](https://learn.microsoft.com/windows-server/administration/windows-commands/cmstp).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
