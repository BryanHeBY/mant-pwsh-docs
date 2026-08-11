<!-- mant:tldr:start -->
# waitfor

> Wait for or send a named best-effort synchronization signal; always use a finite timeout, unique signal name, and explicit target.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/waitfor.

- Wait at most 30 seconds for one collision-resistant signal name:

`waitfor.exe /T 30 "{{mant.build.20260811.001}}"; $waitExitCode = $LASTEXITCODE`

- Send a signal to one explicit computer instead of relying on domain broadcast:

`waitfor.exe /S "{{HOST01}}" /SI "{{mant.build.20260811.001}}"; $sendExitCode = $LASTEXITCODE`

- Display target-local syntax without creating a listener or signal:

`waitfor.exe /?`

- Use a PowerShell process wait for one local child process rather than misusing a network signal:

`Wait-Process -Id {{pid}} -Timeout {{30}}`

<!-- mant:tldr:end -->

# waitfor

## Overview

`waitfor.exe` waits for a named signal or sends one locally/across a Windows
domain. Wait mode accepts `/T seconds`; without it, the process waits
indefinitely. Send mode uses `/SI`, optionally `/S computer` and remote
credentials. If `/S` is omitted, Microsoft says the signal is broadcast to
systems in the domain.

WAITFOR transports only a signal name. It carries no payload, durable queue,
authenticated business event, success record, retry protocol, or exactly-once
guarantee. Use a real orchestrator, service, queue, event, or process primitive
when those properties matter.

## Common mistakes

### Omitting `/T` in unattended work

The default wait is indefinite and can consume an agent, task, pipeline, or
deployment slot forever. Set a finite timeout, capture the result immediately,
log start/end/target/signal, and define timeout recovery and cancellation.

### Sending before the listener is ready

A named signal is not a retained message queue. Coordinate listener readiness
through an independently verifiable mechanism, use bounded retries only if the
workflow is idempotent, and never equate “signal sent” with work completed.

### Omitting `/S` and broadcasting unexpectedly

Microsoft documents domain broadcast when no target is supplied. Always specify
the intended computer for remote synchronization and revalidate its identity;
do not use broad signaling as a discovery mechanism.

### Reusing a common signal name

Only one instance on a computer can wait for a given name, and unrelated jobs
can collide or release the wrong waiter. Include application, environment,
run/correlation ID, and purpose within the 225-character limit; treat names as
operational metadata, not secrets.

### Putting a password on the command line

`/P password` can expose credentials through process inspection, logs, history,
and telemetry. Prefer current approved identity or a protected prompt/credential
mechanism, and do not weaken firewall/domain policy merely to make WAITFOR work.

### Assuming cross-domain, workgroup, firewall, or name resolution support

Microsoft states receivers must be in the same domain as the sender. Network
policy, RPC/service dependencies, authentication, DNS, firewalls, and endpoint
state can still prevent delivery. Record the exact failure and use supported
diagnostics instead of disabling controls broadly.

### Treating signal receipt as remote task success

The sender does not receive a business result. The waiter should validate the
actual artifact/state after release and publish a separate trustworthy result;
otherwise stale or malicious signals can advance the workflow incorrectly.

## PowerShell behavior

Invoke `waitfor.exe` explicitly, pass target and signal as separate arguments,
and capture `$LASTEXITCODE` immediately. Do not use `Start-Process -Wait` for a
network signal or WAITFOR for a local child-process handle; choose the primitive
that represents the real dependency.

## Version and platform differences

This Windows-only utility is documented on supported Windows client and server
releases. Domain membership, permissions, services, firewall/network policy,
name resolution, locale, remote credential policy, and target build affect it.

## Related documents

- [timeout](timeout.md)
- [ping](ping.md)
- [schtasks](schtasks.md)

## Sources and license

This original guide was adapted from Microsoft's official
[WaitFor reference](https://learn.microsoft.com/windows-server/administration/windows-commands/waitfor).
Practical send/listen and same-host confusion was cross-checked against a
[practitioner question](https://stackoverflow.com/questions/45675500/how-to-use-the-windows-waitfor-utility);
Microsoft's reference governs syntax and support boundaries. Exact sources and
licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
