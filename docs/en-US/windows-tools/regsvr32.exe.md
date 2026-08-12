<!-- mant:tldr:start -->
# regsvr32.exe

> Register or unregister only a trusted, vendor-documented self-registering COM server after verifying file identity, signature, architecture, registry scope, elevation and rollback; loading the DLL executes its registration code.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/regsvr32.

- Inspect the exact RegSvr32 executable/version without opening its UI or
  supplying component code:

`Get-Item -LiteralPath "$env:SystemRoot\System32\regsvr32.exe" | Select-Object FullName, Length, @{n='FileVersionFixed';e={$_.VersionInfo.FileVersionRaw.ToString()}}, @{n='FileVersionString';e={$_.VersionInfo.FileVersion}}`

- Inspect a proposed local DLL's hash, signature and version before any registration:

`Get-Item -LiteralPath '.\component.dll' | Select-Object FullName, Length, VersionInfo, @{n='SHA256';e={(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash}}, @{n='Signature';e={(Get-AuthenticodeSignature -LiteralPath $_.FullName).Status}}`

- Register only when the component vendor explicitly documents self-registration:

`regsvr32.exe '{{C:\absolute\trusted\component.dll}}'`
<!-- mant:tldr:end -->

# regsvr32.exe

## Overview

`regsvr32.exe` loads a DLL/OCX and calls self-registration or installation
exports such as `DllRegisterServer`, `DllUnregisterServer` or `DllInstall`.
It is not a generic DLL installer, dependency repairer, copy tool or registration
query command. Target code runs with the caller's rights.

## Syntax

<!-- mant:entries role=command case=insensitive -->
- `regsvr32.exe`: Load a DLL/OCX and call its registration or installation export.

Registration executes target-controlled native code; it is not passive metadata import.

<!-- mant:entries role=option case=insensitive -->
- `/u`: Call the component's unregistration/uninstall behavior.
- `/s`: Suppress messages without suppressing code execution or side effects.
- `/n`: Skip `DllRegisterServer`; requires `/i`.
- `/i`: Pass optional text to `DllInstall`, or uninstall behavior with `/u`.
- `/?`: Display installed syntax.

```text
regsvr32 [/u] [/s] [/n] [/i[:COMMAND_LINE]] DLL
```

- `/u` calls unregistration behavior.
- `/s` suppresses messages; it does not suppress side effects or make them safe.
- `/n` skips `DllRegisterServer` and requires `/i`.
- `/i[:...]` passes text to `DllInstall`; with `/u`, it calls uninstall behavior.

## Common mistakes

- Registering every DLL named in a “module not found” error. Many DLLs are not
  COM servers and do not export self-registration; fix the supported package,
  dependency or application deployment instead.
- Downloading a missing DLL from a file site or registering an email/web
  attachment. `regsvr32` loads and executes target-controlled code.
- Omitting the absolute path and loading a same-named DLL from an unintended
  working/search directory.
- Ignoring bitness and registry view. On 64-bit Windows, `System32` contains
  64-bit system binaries and `SysWOW64` contains 32-bit binaries; verify the COM
  consumer, server architecture and actual registration view.
- Assuming `/u` is a complete rollback. The DLL controls its registration and
  unregistration code; either can leave shared or vendor-specific state.
- Using `/s` in deployment and treating silence or one exit code as proof that
  every class/type library/proxy registration is correct and usable.
- Using `/n /i` based on copied advice. It invokes component-specific install
  code whose accepted arguments and effects must come from the vendor.
- Registering in-place from a temporary/user-writable directory that will later
  be removed, replaced or become writable by a less-trusted principal.

## PowerShell boundaries

Resolve and inspect a `FileInfo`, but pass its absolute `.FullName` string to
`regsvr32.exe`. Use `Start-Process -Wait -PassThru` when an installer needs the
native process exit code, and capture before/after registry and application
health separately. Do not rely on PowerShell object formatting as an argument.

## Version and platform differences

`regsvr32.exe` is Windows-only. DLL architecture, COM registration view,
elevation, per-user/per-machine behavior and component exports vary by target.
The component vendor's installation contract is as important as Windows syntax.

On Windows NT `10.0.26200.0`, exact System32 file version `10.0.26100.1` was
confirmed from file metadata. A console-capture attempt produced no reliable
text payload and left no residual RegSvr32 process, so no help-output or status
claim is retained. Its help/error UI can be a dialog, and ordinary operation
requires a component path that loads code. Runtime verification therefore
remains an approved disposable component/UI fixture; no DLL or OCX was supplied,
loaded, installed, registered, unregistered, or executed merely for evidence.

## Runtime evidence

On Windows NT 10.0.26200.0, exact System32 file version 10.0.26100.1 was
confirmed from file metadata. A console-capture attempt produced no reliable
text payload and left no residual process; no help/status claim is retained.
Operation requires a component path that loads code, so an approved disposable
component/UI fixture remains required; no DLL/OCX load, register, unregister or
install action ran.

## Related documents
- [reg.exe](reg.exe.md)
- [where.exe](where.exe.md)
- [rundll32.exe](rundll32.exe.md)
- [msiexec.exe](msiexec.exe.md)

## Sources and license

Microsoft's official [regsvr32 reference](https://learn.microsoft.com/windows-server/administration/windows-commands/regsvr32)
defines the exports and switches. A
[Stack Overflow architecture question](https://stackoverflow.com/questions/18935163/registering-a-32-bit-dll-with-64-bit-regsvr32)
records recurring 32-bit/64-bit confusion; target behavior must still be verified
from Microsoft and vendor documentation. Exact sources and licenses are in
`upstream/windows-tools.json`.

Microsoft documentation and this adaptation are licensed under CC BY 4.0;
the community source remains CC BY-SA 4.0.
