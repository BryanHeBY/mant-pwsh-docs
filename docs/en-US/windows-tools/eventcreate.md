<!-- mant:tldr:start -->
# eventcreate

> Create an explicitly labeled test/operational marker in Application or System only; never use it to fabricate Security audit evidence or impersonate a product source.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/eventcreate.

- Display target-host syntax and the supported log/type/ID limits:

`eventcreate.exe /?`

- In a disposable approved test, create a uniquely labeled Application marker with an ID from 1 through 1000:

`eventcreate.exe /l APPLICATION /so MantDocsTest /t INFORMATION /id {{900}} /d "{{TEST ONLY ticket=CHG123 host=server01 action=forwarding-validation}}"`

- Immediately query the newest matching source and ID to verify what was actually stored:

`wevtutil.exe query-events Application '/q:*[System[Provider[@Name="MantDocsTest"] and EventID={{900}}]]' /c:{{5}} /rd:true /f:RenderedXml /e:Events`

- Create a remote marker using the caller's approved identity; the server operand has no leading backslashes:

`eventcreate.exe /s "{{server}}" /l APPLICATION /so MantDocsTest /t INFORMATION /id {{900}} /d "{{TEST ONLY ticket=CHG123 forwarding-validation}}"`
<!-- mant:tldr:end -->

# eventcreate

## Overview

`eventcreate.exe` lets an administrator create a custom event in Application or
System, locally or remotely. `/source:` supplies a source string, `/type:` a
severity/audit-like label, `/id:` must be 1–1000, and `/description:` supplies
text. Microsoft explicitly states custom events cannot be written to Security.

Use it only for approved test markers or a deliberately designed operational
marker. A product should use a registered manifest/provider or supported logging/
telemetry API so schema, message resources, identity, versioning, ACL, retention,
and observability are managed correctly.

## Common mistakes

### Treating a created event as trustworthy audit evidence

An administrator can choose source text, ID, type, and description. The record
proves Event Log accepted input under a context—not that the named product/action
occurred. Label tests unmistakably, include an external change/correlation ID,
restrict rights, retain process/security/change evidence, and never mimic a real
security/product provider.

### Trying to write Security or simulate audit policy

Security is not a supported destination. `SUCCESSAUDIT`/`FAILUREAUDIT` are type
choices, not genuine Security auditing, policy evaluation, or kernel/LSA event
provenance. Validate audit policy with real controlled actions and authoritative
Security events under an approved test plan.

### Reusing a real provider/source name

Source is a string, not proof of publisher registration or message schema.
Impersonating a product makes triage/detection unreliable and may create
message-rendering ambiguity. Use a unique organization-owned test source and prefix every
description with `TEST ONLY`; clean up through documented provider lifecycle,
not by clearing logs.

### Omitting remote target identity or exposing `/password:`

`/server` accepts a name/IP without leading backslashes and uses the caller by
default. Inline `/password` leaks; prefer the approved caller identity and
management channel. Bind the event description to the actual target hostname
and verify remotely stored XML, not only local process success.

### Treating one marker as end-to-end collection proof

It validates only the path the marker actually traverses. Record source log/
provider/filter, timestamp/clock, WEF subscription/runtime/bookmark, collector
destination, latency, downstream pipeline, deduplication, and final alert/search.
Use a unique correlation ID and confirm no false matches.

### Building description text from untrusted input

Event descriptions can contain misleading content, secrets, personal data, or
control characters and are replicated into collectors/SIEM/backups. Allowlist
fields, escape/length-bound them, exclude secrets, and do not use
`Invoke-Expression` or a compound shell string.

### Ignoring ID/type/log limits and localization

Valid IDs are 1–1000 and logs are Application or System. Type labels do not map
to every modern Event Log level/keyword schema. Query the resulting XML and test
rendering/forwarding on representative builds/locales rather than assuming the
command line becomes a stable provider contract.

## PowerShell behavior

Call `eventcreate.exe` explicitly, pass the complete description as one scalar
argument, and capture stdout/stderr plus `$LASTEXITCODE`. Re-query exact host,
channel, source, ID, time, and correlation text. For application code, prefer
structured supported logging APIs rather than spawning this utility.

## Version and platform differences

`eventcreate.exe` is Windows-only. Remote access, event source behavior,
rendering, permissions, channel retention/forwarding, localization, and security
monitoring vary by build, edition, policy, and installed collection stack.

## Related documents

- [wevtutil](wevtutil.md)
- [wecutil](wecutil.md)
- [winrm.exe](winrm.md)
- [whoami](whoami.md)

## Sources and license

This original guide was adapted from Microsoft's official
[eventcreate reference](https://learn.microsoft.com/windows-server/administration/windows-commands/eventcreate).
Exact locked provenance is recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
