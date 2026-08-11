# Version 1 runtime verification

This checklist records the runtime evidence required by
[V1-SCOPE.md](../V1-SCOPE.md) before creating the final v1 tag. It is separate
from portable repository validation: a passing `npm run validate:release`
proves document structure, ManT parsing, release inventory, and reviewed
provenance, but not the behavior of an operating-system-specific executable.

## Common preparation

On every target host, install or use the intended ManT build, add the sources
from [sources.example.toml](../sources.example.toml), and run:

```text
mant --update-docs
mant pwsh7 --source pwsh7 --outline
mant pwsh-cli --source pwsh-cli --outline
```

Record the host operating-system version, architecture, ManT version, shell
version, and relevant CLI versions. Run the repository checks from a clean
checkout:

```text
npm run validate
npm run validate:release
npm run validate:upstream
```

The last command requires network access and `curl`; the normal validation
commands remain offline except for ManT itself.

## PowerShell 7

Run on Windows, macOS, and Linux with the supported PowerShell 7 release:

```powershell
$PSVersionTable
Get-Command irm, iwr, iex -All
Get-Command irx -All -ErrorAction SilentlyContinue
Get-Command curl -All
pwsh -NoProfile -Command 'Get-ChildItem | Select-Object -First 1'
```

Confirm the documented alias and native-command resolution on each host. Test
the launcher, parsing/quoting, pipelines/redirection, profiles, functions,
`Get-Command`, `Get-Help`, object cmdlets, module import, and the PowerShell
7/Windows PowerShell compatibility guide against the local version.

## Windows PowerShell 5.1

Run on Windows with `powershell.exe` (not only `pwsh`):

```powershell
$PSVersionTable
powershell.exe -NoProfile -Command '$PSVersionTable.PSEdition'
Get-Command irm, iwr, iex, curl -All
Get-Command irx -All -ErrorAction SilentlyContinue
```

Confirm `PSEdition` is `Desktop`; validate legacy web-request behavior,
Windows command precedence, UTF-16LE redirection defaults, native command
exit-code handling, profiles, providers, and the PowerShell 7 migration guide.

## CLI platforms

On Windows, run and record supported versions of:

```powershell
winget --version
wsl --status
where.exe winget
robocopy.exe /?
schtasks.exe /query
sc.exe query
cmd.exe /d /c ver
reg.exe query HKCU\Environment
Get-Command explorer.exe, control.exe, mmc.exe, rundll32.exe -All
cmd.exe /d /v:on /c "set MANT_TEST=value & if not !MANT_TEST!==value exit /b 1"
choice.exe /?
timeout.exe /?
```

Review Windows-only commands on a non-production target. In particular, use
`robocopy /L` before any real copy, query an existing known task before task
changes, and query a known service before `sc.exe` configuration work.

On Windows, macOS, and Linux where declared by the document, record:

```text
git --version
ssh -V
curl --version
tar --version
dotnet --info
```

Verify source/platform variations such as PowerShell's `curl` alias on Windows,
the installed tar implementation, available .NET SDKs, and the configured SSH
client. Do not claim an unavailable command has passed; record it as an
environmental exception and decide whether the v1 scope or test host must
change.

## Acceptance record

Before tagging, attach or link a record with these outcomes:

| Requirement | Windows | macOS | Linux |
| --- | --- | --- | --- |
| PowerShell 7 | required | required | required |
| Windows PowerShell 5.1 | required | not applicable | not applicable |
| Windows-only CLI pages | required | not applicable | not applicable |
| Cross-platform CLI pages | required | required | required |
| ManT source update and representative queries | required | required | required |

Once every required cell has recorded evidence, change only pages with direct
runtime evidence from `reviewed` to `verified`, run the three release commands
again, update the changelog with the final tag date, and create the annotated
v1 tag.
