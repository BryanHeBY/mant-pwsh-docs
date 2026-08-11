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

## Environment and driver options

<!-- mant:entries role=option case=sensitive -->
- `--info`: Print detailed SDK, runtime, workload, operating-system, architecture, and environment information.
- `--version`: Print the SDK selected for the current directory; selection can be affected by `global.json`.
- `--list-sdks`: List SDKs visible to the selected `dotnet` architecture.
- `--list-runtimes`: List runtimes visible to the selected `dotnet` architecture.
- `--arch ARCH`: With supported .NET 10-or-later listing operations, inspect another installed architecture.
- `-d`, `--diagnostics`: Enable driver diagnostic output for a command.
- `-v LEVEL`, `--verbosity LEVEL`: Select supported command verbosity; availability and accepted values belong to the subcommand.
- `-h`, `--help`: Show driver or selected-command help for the installed SDK.
- `--roll-forward SETTING`: When running an application DLL, control compatible runtime roll-forward policy.
- `--fx-version VERSION`: Override the first framework reference used to run an application; unsafe as a general multi-framework override.

## Common SDK commands

<!-- mant:entries role=command case=sensitive -->
- `new`: Create a project, solution, or other artifact from an installed template.
- `restore`: Resolve and download project dependencies without performing a later build target intentionally.
- `build`: Restore when needed and compile a project or solution.
- `test`: Build when needed and run tests through the selected SDK and test infrastructure.
- `run`: Build and run a source project; arguments after `--` belong to the application.
- `publish`: Produce deployable output for a selected configuration, runtime, and deployment mode.
- `pack`: Build a NuGet package from a packable project.
- `clean`: Remove outputs created by earlier builds for the selected configuration.
- `sln`: Inspect or modify projects in a solution file.
- `add`: Add a package, project reference, or other supported item to a project.
- `remove`: Remove a package or project reference from a project.
- `tool`: Install, update, restore, list, run, or uninstall .NET tools.
- `workload`: Inspect, install, update, repair, or remove optional SDK workloads.
- `nuget`: Run supported NuGet client operations through the SDK.
- `exec`: Run an application with explicit runtime configuration and dependency files.

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

## PowerShell usage

Pass project paths and arguments separately, check `$LASTEXITCODE`, and avoid
parsing human-formatted output as a stable API. Use `dotnet --help` and a
specific subcommand's `--help` for installed-version options; not every .NET
SDK supports the same switches.

The currently available PowerShell 7 test environment for this repository does
not include `dotnet`; this document remains draft until runtime verification
covers the intended Windows, macOS, and Linux SDK environments.

## Version and platform differences

The baseline covers .NET 6 SDK and later, while individual commands and
options evolve with the selected SDK. `--arch` on SDK/runtime listing is a
.NET 10-or-later behavior. Workload availability, paths, native assets, and
code-signing or publishing requirements vary by operating system and
architecture.

## Common mistakes

### Reading `--version` as the newest installed SDK

It reports the SDK selected in the current directory, not necessarily the
highest installed version. Inspect `--list-sdks` and the governing
`global.json`.

### Passing application arguments to `dotnet run` as CLI options

Use `--` to separate arguments intended for the application from arguments
consumed by `dotnet run`.

### Assuming restore and build are inert

Project targets, analyzers, packages, workloads, and NuGet configuration can
execute code or access networks. Review the repository and feeds before using
credentials or elevated privileges.

## Related documents

- [git](git.md)
- [Cross-platform tools for PowerShell](cross-platform-tools.md)
- On Windows, query package management with
  `mant winget --source windows-tools`.

## Sources and license

This original ManT-oriented guide was adapted from the official
[dotnet command documentation](https://learn.microsoft.com/dotnet/core/tools/dotnet).
It emphasizes SDK selection, source-controlled project context, and native
process handling. Exact upstream revision and path are recorded in
`upstream/cross-platform-tools.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
