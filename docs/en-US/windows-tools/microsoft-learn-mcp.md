<!-- mant:tldr:start -->
# microsoft-learn-mcp

> Use the optional Microsoft Learn MCP server to find current official documentation for Microsoft command-line tools.
> More information: https://github.com/MicrosoftDocs/mcp.

- Add the remote server in a compatible MCP client:

`{{client}} mcp add microsoft-learn --url https://learn.microsoft.com/api/mcp`

- Ask the client to search current official docs:

`Search Microsoft Learn for winget install exact package ID options.`

- Ask the client to fetch and summarize an official page it found:

`Fetch the Microsoft Learn page for {{tool}} and explain {{option}}.`
<!-- mant:tldr:end -->

# Microsoft Learn MCP queries

## Purpose and scope

The Microsoft Learn MCP server is an optional research channel for compatible
AI clients. It exposes a remote Streamable HTTP endpoint:

```text
https://learn.microsoft.com/api/mcp
```

It is useful when a ManT page needs current details about a Microsoft command,
such as Windows Package Manager, Windows commands, WSL, or .NET. ManT itself
does not need the MCP server: published pages remain readable offline after
their normal ManT source update.

Do not open the endpoint in a normal browser; it is for MCP clients and can
return HTTP 405 to browser-style requests.

## Connect in a compatible client

Use the configuration form required by the MCP client. A typical remote-server
entry is:

```json
{
  "servers": {
    "microsoft-learn": {
      "type": "http",
      "url": "https://learn.microsoft.com/api/mcp"
    }
  }
}
```

For example, a current Codex CLI configuration command is:

```text
codex mcp add microsoft-learn --url https://learn.microsoft.com/api/mcp
```

Client configuration, authentication behavior, and tool names can change.
Follow the current documentation for the chosen client; do not make
installation of this optional server a prerequisite for reading or validating
this repository.

## Query a Microsoft CLI

Ask for a narrow task, product, and version context. Good requests name the
command, subcommand, desired option, Windows version when relevant, and the
kind of answer needed:

```text
Search official Microsoft Learn documentation for winget install.
Explain --id, --exact, --source, and noninteractive installation behavior.

Find the current Windows command documentation for robocopy exit codes.
Return the official page URL and distinguish success, warning, and failure ranges.

Find Microsoft documentation for WSL distribution installation and the current
meaning of wsl --install options on Windows 11.
```

At the locked upstream revision for this project, the server advertises search,
page-fetch, and code-sample-search capabilities. A custom MCP client must
discover tool definitions dynamically instead of hard-coding those names or
input schemas.

## Turn a response into maintainable documentation

Treat MCP output as discovery, not as the final source of record:

1. Open or fetch the official Microsoft Learn page returned by the client.
2. Check product version, platform, prerequisites, defaults, security notes,
   and the date or upstream revision that applies.
3. Write an original ManT-oriented explanation; do not copy a long upstream page.
4. Record the actual returned documentation page or upstream file in
   `upstream/windows-tools.json`, with its license and baseline revision.
5. Keep the page's `Sources and license` section reader-facing and run the
   repository validator before committing.

The MCP response can change as the service index changes. A stable source
catalog must point to the underlying official page, not only to a transient
search result.

## Safety and limitations

Microsoft Learn MCP narrows discovery to Microsoft documentation; it does not
make every recommendation suitable for a specific production environment.
Review package identifiers, URLs, scripts, privileges, and destructive options
before running a command. For non-Microsoft tools such as Git, OpenSSH, curl,
or tar, use their own vendor documentation as the source of record.

## Version and availability

The Microsoft Learn MCP server is an optional external information channel,
not a dependency of this repository or ManT. Server tools, client setup, and
returned documentation can evolve; inspect the connected server's advertised
capabilities and validate every answer against the target product and version.

## Related documents

- [Windows tools for PowerShell](windows-tools.md)
- [winget.exe](winget.exe.md)

## Sources and license

This original guide is informed by the official
[Microsoft Learn MCP repository](https://github.com/MicrosoftDocs/mcp) and
its documented remote endpoint. It deliberately treats MCP as optional
discovery infrastructure rather than a ManT runtime dependency. Exact upstream
revision and path are recorded in `upstream/windows-tools.json`.

The cited documentation is licensed under CC BY 4.0. This adaptation is
licensed under CC BY 4.0.
