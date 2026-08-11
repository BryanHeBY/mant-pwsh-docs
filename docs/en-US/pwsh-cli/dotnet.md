<!-- mant:tldr:start -->
# dotnet

> Inspect and run the .NET CLI from PowerShell with explicit SDK and project context.
> More information: https://learn.microsoft.com/dotnet/core/tools/dotnet.

- Show SDK, runtime, and environment information:

`dotnet --info`

- List SDKs available to the selected executable:

`dotnet --list-sdks`

- Build an explicit project:

`dotnet build {{path/to/project.csproj}}`
<!-- mant:tldr:end -->

# dotnet

## Synopsis

```text
dotnet [--info | --version | --list-sdks | --list-runtimes]
dotnet <command> [arguments]
dotnet <application.dll> [arguments]
```

The `dotnet` driver exposes .NET SDK commands and runs .NET applications. It
is a native executable whose chosen SDK can depend on the current directory,
`global.json`, architecture, environment, and installed SDKs.

## Establish the selected environment

Capture `dotnet --info` and `dotnet --list-sdks` when diagnosing or reproducing
a build. `dotnet --version` reports the SDK selected for the current directory;
it can differ after moving into a repository that contains `global.json`.

```powershell
dotnet --info
dotnet --version
dotnet build .\src\App\App.csproj
if ($LASTEXITCODE -ne 0) {
    throw "dotnet build failed with exit code $LASTEXITCODE"
}
```

Use an explicit solution or project path in automation instead of depending on
the PowerShell current location. Pin an SDK policy through source-controlled
`global.json` only after testing it on each intended developer and CI host.

## Restore, build, run, and publish

Subcommands have separate arguments and restore behavior. `dotnet restore`,
`build`, `test`, `run`, and `publish` can access package feeds, execute build
targets, and create outputs. Treat project files, NuGet configuration, SDK
workloads, and build scripts as code and supply-chain inputs; do not run an
unreviewed repository with credentials or elevated privileges.

Package sources and caches can affect repeatability. Use approved feeds,
locked dependency policies where appropriate, and explicit output paths for
release automation. Record the SDK/runtime version together with build logs.

## PowerShell use

Pass project paths and arguments separately, check `$LASTEXITCODE`, and avoid
parsing human-formatted output as a stable API. Use `dotnet --help` and a
specific subcommand's `--help` for installed-version options; not every .NET
SDK supports the same switches.

The currently available PowerShell 7 test environment for this repository does
not include `dotnet`; this document remains draft until runtime verification
covers the intended Windows, macOS, and Linux SDK environments.

## Related documents

- [git](git.md)
- [winget](winget.md)
- [Command-line tools for PowerShell](pwsh-cli.md)

## Sources and license

This original ManT-oriented guide was adapted from the official
[dotnet command documentation](https://learn.microsoft.com/dotnet/core/tools/dotnet).
It emphasizes SDK selection, source-controlled project context, and native
process handling. Exact upstream revision and path are recorded in
`upstream/cli.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
