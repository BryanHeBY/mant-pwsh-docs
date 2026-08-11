<!-- mant:tldr:start -->
# git

> Track source code and inspect repository state from PowerShell.
> More information: https://git-scm.com/docs/git.

- Show the repository status without profiles or aliases affecting Git:

`git status --short`

- Run Git against an explicit repository directory:

`git -C {{path/to/repository}} status --short`

- Inspect the installed Git version:

`git --version`
<!-- mant:tldr:end -->

# git

## Synopsis

```text
git [-C PATH] [-c NAME=VALUE] <command> [arguments]
```

Git is a distributed version-control system. It is a native executable in
PowerShell, not a cmdlet: its text output, configuration, authentication, and
exit code form its interface.

## Establish repository context

Use `git status --short` for a concise view of changed, staged, untracked, and
conflicted paths. Use `-C PATH` when automation must not rely on PowerShell's
current location:

```powershell
git -C C:\src\project status --short
if ($LASTEXITCODE -ne 0) {
    throw "Git status failed with exit code $LASTEXITCODE"
}
```

Do not treat a bare directory name or a display prompt as proof of repository
context. Submodules, worktrees, linked repositories, and a changed current
location can alter what Git operates on.

## Configuration and credentials

Git reads system, global, and repository configuration. A per-command
`-c NAME=VALUE` override is useful for a controlled temporary setting, but do
not place secrets in command lines, shell history, or scripts. Use approved
credential helpers and SSH keys with suitable permissions.

Before automating a modifying command, inspect the effective repository state,
remote URL, branch or detached-HEAD state, hooks, and policy. `git config
--show-origin --list` helps diagnose a surprising setting without changing it.

## PowerShell boundaries

Git paths and revision syntax are parsed by Git after PowerShell passes the
arguments. Keep command and argument values separate, quote paths containing
spaces, and avoid `Invoke-Expression`. Use `git --` before a pathspec when a
path could look like a revision or option:

```powershell
git diff -- .\path-that-starts-with-a-dash
```

Exit-code meanings are command-specific. For example, `git diff --quiet` uses
nonzero to report a difference, not necessarily an execution failure. Read the
specific subcommand's documentation before treating every nonzero value alike.

## Related documents

- [ssh](ssh.md)
- [where](where.md)
- [Command-line tools for PowerShell](pwsh-cli.md)

## Sources and license

This original ManT-oriented guide was adapted from the official
[Git documentation](https://git-scm.com/docs/git). It emphasizes explicit
repository context, configuration provenance, and native exit-code handling.
Exact upstream revision and path are recorded in `upstream/cli.json`.

The cited documentation is licensed under GPL-2.0-only. This adaptation is
licensed under CC BY 4.0.
