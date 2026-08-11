# Published documents

The English ManT document sources live below `docs/en-US/`. Each source
directory is directly publishable and is not a generated artifact.

- `pwsh7` covers PowerShell 7.
- `pwsh51` covers Windows PowerShell 5.1.
- `windows-tools` covers Windows-native, optional, GUI, URI, builtin, and
  legacy tools used from PowerShell.
- `cross-platform-tools` covers separately installed tools used from
  PowerShell on Windows, macOS, and Linux.

Windows executable, console, management-console, and script entry points keep
their real suffix in the registered document name. Examples include
`winget.exe.md`, `tree.com.md`, `services.msc.md`, and `prncnfg.vbs.md`.
PowerShell commands, Cmd builtins, URI entries, and topic or family pages stay
unsuffixed.
