<!-- mant:tldr:start -->
# rundll32

> Invoke only a documented DLL entry point explicitly designed for Rundll32.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/rundll32.

- Inspect the executable before using a documented integration:

`Get-Command rundll32.exe -All`

- Use a vendor- or Microsoft-documented Rundll32 entry point:

`rundll32.exe '{{C:\path\library.dll}},{{DocumentedEntryPoint}}' {{documented-arguments}}`

- Prefer a supported direct command or API when one exists:

`& {{supported-tool.exe}} {{argument}}`
<!-- mant:tldr:end -->

# rundll32

## Overview

`rundll32.exe` is a Windows compatibility host for DLL functions explicitly
written to the Rundll32 calling convention. It is not a general facility for
calling an arbitrary exported function, COM method, Win32 API, or .NET method.

Only use a command line documented by the owner of the exact Windows component
or signed DLL. Prefer a supported executable, PowerShell cmdlet, management
API, or URI when available.

## Syntax boundary

Microsoft's Windows command reference exposes Rundll32 through a DLL-specific
contract rather than a general option set:

```text
rundll32.exe DLL-NAME,ENTRY-POINT [DLL-SPECIFIC-ARGUMENTS]
```

The comma separates the DLL name and entry point. Arguments after that are
interpreted by the entry point, so their syntax, privileges, architecture, side
effects, and exit behavior cannot be inferred from `rundll32.exe` itself.

## Common mistakes

### Calling an arbitrary DLL export

A function appearing in a DLL export table is not enough. Its signature and
implementation must be explicitly compatible with Rundll32. Passing a normal
Win32 API such as `ShellExecute` can crash or corrupt the process.

### Copying an old shell-tweak recipe

Many historical commands target undocumented or compatibility entry points.
Their presence on one Windows build is not a support contract. Require a
current Microsoft or vendor page for the exact entry point and arguments.

### Ignoring 32-bit and 64-bit boundaries

The host architecture must be able to load the DLL architecture, and WOW64
filesystem redirection can change which system path is selected. Resolve the
exact host and DLL paths when architecture matters.

### Assuming a standard exit-code contract

The called entry point owns the operation. Rundll32 does not turn it into a
structured PowerShell command or guarantee that process exit means the desired
state was applied. Verify the resulting state through the supported subsystem.

### Treating elevation as universally required or sufficient

Privileges depend on the documented entry point and target state. Elevation
does not make an unsupported recipe correct; use least privilege and the
component's authorization guidance.

## Security considerations

Rundll32 loads code into a process. Validate the absolute DLL path, publisher,
signature, architecture, entry point, arguments, and provenance. Never pass an
untrusted download, user-controlled DLL path, or constructed entry-point name.

## Version and platform differences

Rundll32 is Windows-only. Individual entry points can change, disappear, or be
unsupported across Windows releases, editions, components, and architectures.
This page deliberately makes no claim that a copied component-specific recipe
is portable.

## Related documents

- [cmd](cmd.md)
- [control](control.md)
- [explorer](explorer.md)
- [where](where.md)

## Sources and license

This original safety-focused guide was adapted from Microsoft's official
[rundll32 reference](https://learn.microsoft.com/windows-server/administration/windows-commands/rundll32),
which states that only functions explicitly written for Rundll32 can be called.
The real-world arbitrary-export failure mode is illustrated by the community
question
[How to use Rundll32 to execute DLL Function?](https://stackoverflow.com/questions/3207365/how-to-use-rundll32-to-execute-dll-function).
Exact sources and licenses are recorded in `upstream/cli.json`.

The Microsoft documentation is licensed under CC BY 4.0 and Stack Overflow
content under CC BY-SA 4.0. This adaptation is licensed under CC BY 4.0; no
Stack Overflow answer text is reproduced.
