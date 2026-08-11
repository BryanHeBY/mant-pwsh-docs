<!-- mant:tldr:start -->
# finger

> Recognize a legacy remote-user information query; do not enumerate users or
> treat unauthenticated remote text as authoritative identity.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/finger.

- Resolve the exact Windows executable and record its version:

`Get-Command finger.exe -All -ErrorAction SilentlyContinue | Format-List Source, Version`

- Display local syntax without querying a remote service:

`finger.exe /?`

- Resolve an approved target's DNS records before any separately authorized query:

`Resolve-DnsName -Name "{{host}}" -Type A -DnsOnly; Resolve-DnsName -Name "{{host}}" -Type AAAA -DnsOnly`

- Test only TCP reachability to the traditional service port; this does not request user data:

`Test-NetConnection -ComputerName "{{host}}" -Port {{79}} -InformationLevel Detailed`

<!-- mant:tldr:end -->

# finger

## Overview

`finger.exe [-l] [user] [@host]...` asks a remote Finger service, typically on a
Unix-like system, for user information. The remote service chooses the returned
format/content. Omitting `user` requests information about all users on the
specified host, and `-l` requests a longer listing.

This is a legacy information-disclosure protocol, not a trustworthy directory,
presence, authentication or authorization system. Use an organization-approved
identity/directory API for current information. Retain Finger only for a known
legacy dependency with explicit owner, scope and privacy approval.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `finger.exe`: Request user information from a remote Finger service.

The positional form is `user@host`; omitting `user` requests information about
all users and can materially broaden disclosure.

<!-- mant:entries role=option case=insensitive -->
- `-l`: Request the remote service's long-list form.
- `/?`: Display installed syntax; Finger options otherwise require `-`, not `/`.

## Common mistakes

### Querying `@host` without a username

Microsoft documents that omission requests all users. That can create privacy,
security-monitoring and enumeration impact. The TLDR deliberately performs no
Finger query. Bind one approved user and host, minimize fields with no `-l`, and
record purpose/retention before any query.

### Treating returned text as verified identity or presence

The remote daemon controls the text, which may be stale, forged, incomplete,
localized or mapped from legacy account data. Do not use it for access control,
incident attribution, employment status, online presence or automated targeting.

### Displaying untrusted control characters

Remote text can include unexpected bytes, terminal sequences and multiline
content. Collect only in an isolated text-safe workflow with size/time limits;
escape control characters before display/logging and never execute or interpolate
returned fields into commands.

### Assuming `/` option style or Unix-client behavior

Microsoft requires hyphens for Finger parameters and allows multiple
`user@host` operands. Use `finger.exe` explicitly and target-local help; do not
copy a Unix implementation's options or default local-user behavior.

### Opening port 79 broadly to restore a legacy query

Reachability does not justify exposing user enumeration. Identify the service
owner, segment source/destination, restrict ACLs, log access and plan removal.
Prefer removing the dependency rather than enabling an Internet-facing daemon.

## PowerShell boundaries

Invoke `finger.exe` explicitly; `finger` may resolve differently on systems with
third-party Unix tools. Its output is unstructured remote-controlled text.
Capture `$LASTEXITCODE` immediately but treat both output and success status as
untrusted evidence requiring corroboration.

## Version and platform differences

The Microsoft client is Windows-only and requires TCP/IP. Executable presence,
remote daemon availability, output format, encoding, privacy policy and network
controls vary. The current Microsoft page lists supported Windows builds, but
that does not imply a Finger server is installed or appropriate.

## Related documents

- [whoami](whoami.md)
- [nslookup](nslookup.md)
- [netstat](netstat.md)
- [telnet](telnet.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Finger reference](https://learn.microsoft.com/windows-server/administration/windows-commands/finger),
including its remote-defined output and all-users omission semantics. Exact
sources and licenses are recorded in `upstream/windows-tools.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
