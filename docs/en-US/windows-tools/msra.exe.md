<!-- mant:tldr:start -->
# msra.exe

> Open Windows Remote Assistance only for a consented, authenticated support session; verify invitation, helper, target, control level, policy, network path, and session end.
> More information: https://learn.microsoft.com/windows-hardware/customize/desktop/unattend/microsoft-windows-remoteassistance-exe.

- Resolve the exact executable without opening a session:

`Get-Command msra.exe -All`

- Open Windows Remote Assistance interactively:

`Start-Process msra.exe`

- Inspect the executable identity before a support workflow:

`Get-AuthenticodeSignature (Get-Command msra.exe).Source`
<!-- mant:tldr:end -->

# msra.exe

## Overview

`msra.exe` opens classic Windows Remote Assistance. A person requesting help
can create/accept an assistance workflow, and an approved helper can view or,
with further consent and policy permission, control the shared session.

Remote Assistance is distinct from Remote Desktop, Quick Assist, Remote Help,
PowerShell remoting, and unattended endpoint-management agents. It shares an
interactive user's session and carries privacy, credential, consent, network,
and social-engineering risks.

## Entry point

<!-- mant:entries role=command case=insensitive -->
- `msra.exe`: Open the interactive Windows Remote Assistance workflow for an explicitly approved requester and helper.

This page deliberately does not promise remembered or forum-derived command
switches. Use only a switch documented for the exact supported Windows build
and organizational workflow; otherwise use the interactive entry point.

## Session safeguards

Verify both people through a separate trusted channel. Record target device and
user, helper identity, ticket/invitation origin and expiry, view/control level,
policy owner, business purpose, start/end time, displayed consent, network path,
audit/support record, and the method used to terminate and revoke the session.

Treat invitation files and secrets as credentials. Transfer them only through
an approved channel, limit lifetime, and remove retained copies after the case.

## Common mistakes

- Accepting an unsolicited assistance request or trusting the display name,
  phone caller, email, link, or invitation without independent verification.
- Confusing permission to view with permission to control, or assuming initial
  invitation consent authorizes later elevation, credential entry, or changes.
- Exposing passwords or secrets on the shared desktop, clipboard, browser,
  terminal, notifications, password manager, or secure prompt.
- Disabling the firewall broadly when one policy/rule, identity, DCOM/RPC path,
  NAT/reachability, or product-support issue should be diagnosed narrowly.
- Assuming closing one visible window ended every process, connection, ticket,
  helper permission, policy grant, or support-agent session.
- Using Remote Assistance as silent/unattended administration or confusing it
  with RDP, which has different session and authentication behavior.

## PowerShell behavior

`Start-Process msra.exe` launches an interactive application; process creation
does not prove that a session connected, consent was granted, control began, or
the session ended. Do not automate UI prompts, invitation secrets, or consent.

## Version and platform differences

`msra.exe` is Windows-only. Availability, policy, firewall rules, invitation
methods, control behavior, enterprise offering, and network requirements vary
by Windows edition/build, domain/MDM policy, and environment. Re-evaluate modern
Microsoft assistance products separately rather than treating them as aliases.

## Runtime evidence

On Windows NT `10.0.26200.0`, the read-only file-identity audit under Windows
PowerShell `5.1.26100.8875` and PowerShell `7.6.4` resolved the exact entry
point to `C:\WINDOWS\system32\msra.exe`. Its fixed numeric file version was
`10.0.26100.8875`. Both collectors reported the same result.

The audit invoked no discovered command, opened no window, contacted no remote
endpoint, and changed no state. This proves only this host's entry-point
availability and file identity; it does not prove that the UI loads, the
current user is authorized, an optional snap-in or component is functional, or
any displayed or requested operation succeeds.

## Related documents
- [mstsc.exe](mstsc.exe.md)
- [winrm.cmd](winrm.cmd.md)
- [wf.msc](wf.msc.md)
- [eventvwr.msc](eventvwr.msc.md)

## Sources and license

This original guide was adapted from Microsoft's
[Windows Remote Assistance component guidance](https://learn.microsoft.com/windows-hardware/customize/desktop/unattend/microsoft-windows-remoteassistance-exe).
Exact sources and licenses are recorded in `upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0.
