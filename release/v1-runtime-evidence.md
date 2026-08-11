# Version 1 runtime evidence

This record captures evidence actually collected during the v1 preparation.
It complements [v1-runtime.md](v1-runtime.md); an unchecked platform remains
pending and must not be inferred from another operating system.

## Linux evidence — 2026-08-11

Environment: Linux authoring host, PowerShell 7.6.3 (`Core` edition), ManT
source cache at repository revision `e6e7c9f54a2944ddff86181e038395949581db41`.

`mant --update-docs` reported these installed document counts:

These are historical counts for the recorded repository revision. The source
then named `pwsh-cli` was later replaced by `windows-tools` and
`cross-platform-tools`; the names and queries below are preserved as evidence
of what was actually tested. Pages added or moved after that revision still
require fresh platform evidence even though this earlier run remains valid for
the documents it exercised.

| Source | Documents |
| --- | ---: |
| `pwsh7` | 26 |
| `pwsh51` | 26 |
| `pwsh-cli` | 19 |

Representative ManT queries succeeded:

```text
mant pwsh7 --source pwsh7 --outline=sections
mant irx --source pwsh7 --outline=sections
mant winget --source pwsh-cli --outline=sections
```

PowerShell runtime checks returned:

```json
{
  "version": "7.6.3",
  "edition": "Core",
  "aliases": {
    "irm": "Invoke-RestMethod",
    "iwr": "Invoke-WebRequest",
    "iex": "Invoke-Expression"
  },
  "irx": [],
  "curl": "/usr/bin/curl",
  "pipelineFirstObjectType": "DirectoryInfo"
}
```

This confirms the documented Linux alias resolution: `irm`, `iwr`, and `iex`
are aliases; `irx` is not a built-in command; and bare `curl` is the native
application in this host. A basic `Get-ChildItem | Select-Object -First 1`
pipeline returned a `DirectoryInfo` object.

Installed native-tool versions were:

| Tool | Result |
| --- | --- |
| Git | 2.55.0 |
| OpenSSH | 10.4p1, OpenSSL 3.6.3 |
| curl | 8.21.0 |
| tar | GNU tar 1.35 |
| dotnet | unavailable on this host |

## Pending evidence

| Requirement | State |
| --- | --- |
| PowerShell 7 on Windows | pending |
| PowerShell 7 on macOS | pending |
| Windows PowerShell 5.1 | pending Windows host |
| Windows-only tool pages | pending Windows host |
| Cross-platform tool pages on Windows | pending Windows host |
| Cross-platform tool pages on macOS | pending macOS host |
| dotnet CLI on all declared platforms | pending compatible SDK hosts |

The repository's portable release checks and upstream audit pass, but this
partial Linux evidence is not sufficient to create the final v1 tag. Complete
the remaining rows in [v1-runtime.md](v1-runtime.md), then update this record
with command output or durable CI/job links.
