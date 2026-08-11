<!-- mant:tldr:start -->
# more

> Page text interactively one screen at a time; use `more.com` to bypass PowerShell's edition-dependent `more` function and never page binary or secret output casually.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/more.

- Resolve every command named `more` before choosing the native Windows pager:

`Get-Command more -All -ErrorAction SilentlyContinue`

- Page one exact text file with the native Windows pager:

`more.com "{{C:\Logs\report.txt}}"`

- Begin display at an exact one-based line number:

`more.com +{{100}} "{{C:\Logs\report.txt}}"`

- Page already formatted PowerShell text without pretending native output is still objects:

`{{command}} | Out-String -Stream | more.com`

<!-- mant:tldr:end -->

# more

## Overview

`more.com` is the native Windows forward-only interactive pager. It accepts
files, redirected input, or piped text and pauses at `-- More --`. Space shows
another screen, Enter one line, `q` quits, `f` advances to another input file,
and prompt commands can show/skip/display a requested number of lines.

This is presentation, not filtering, durable logging, object pagination, or a
replacement for bounded queries. The producer continues or blocks according to
pipe buffering, so paging a live/unbounded command can hold processes and
resources open.

## Common mistakes

### Assuming bare `more` always means `more.com`

Windows PowerShell 5.1 commonly defines a wrapper function named `more`, while
PowerShell 7 and other environments can resolve differently. Use `Get-Command
more -All`; invoke `more.com` for the native utility and `Out-Host -Paging` or
another explicitly selected pager when that is the intended behavior.

### Using a pager in unattended automation

The pager waits for keystrokes and can hang CI, remoting, scheduled tasks, and
redirected sessions. Bound or write output to a protected file, then inspect it
separately. Do not pipe `q` or synthetic keystrokes as an automation protocol.

### Expecting backward search and navigation like `less`

Windows More is a small forward pager. It is not GNU `less`, and familiar keys
from another pager may be treated differently. Press `?` at the More prompt to
see target-local controls.

### Sending PowerShell objects directly

Native stdin is text. PowerShell first formats/encodes pipeline objects, which
can truncate properties or change layout. Select properties and render the
intended text explicitly before paging; retain structured objects for logic.

### Ignoring encoding and code-page mismatches

`more.com`, the console code page, `$OutputEncoding`, console encodings, the
file bytes, PowerShell edition, and terminal can disagree. Mojibake or even
misleading errors are not proof of corrupt data. Test the exact path with known
Unicode fixtures and use a Unicode-aware viewer when needed.

### Paging binary, enormous, live, or sensitive data

Binary control bytes can disrupt display. An unbounded producer can block or
consume resources, and secrets become terminal/scrollback data. Identify file
type and size, limit producer output, and protect terminal logs and history.

### Misreading `/S`, `/P`, or `/Tn`

`/S` collapses repeated blank lines, `/P` expands form feeds, and `/Tn` changes
tab display. They transform presentation and can make evidence differ from the
original. Preserve the source and record every display option.

## PowerShell behavior

Use `more.com` for deterministic native resolution. Capture or select data
before paging because the interactive process is a terminal endpoint, not an
object-pipeline stage. `$LASTEXITCODE` describes the pager process, not the
producer's success or completeness; preserve both results separately.

## Version and platform differences

`more.com` is Windows-only and also has a different Recovery Environment form.
PowerShell command resolution, native-pipeline encoding, console code page,
terminal behavior, screen size, and available prompt keys vary by environment.

## Related documents

- [chcp](chcp.md)
- [type](type.md)
- [pwsh-cli](pwsh-cli.md)

## Sources and license

This original guide was adapted from Microsoft's official
[More reference](https://learn.microsoft.com/windows-server/administration/windows-commands/more).
PowerShell resolution, feature, and encoding pitfalls were cross-checked against
a detailed [pager discussion](https://stackoverflow.com/questions/59240742/powershell-less-tool)
and a [multi-byte encoding failure report](https://stackoverflow.com/questions/55248656/more-com-returns-not-enough-memory).
Exact sources and licenses are recorded in `upstream/cli.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
