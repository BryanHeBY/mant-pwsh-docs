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

## Global options

<!-- mant:entries role=option case=sensitive -->
- `-C PATH`: Run as if Git started in `PATH`; repeated relative values are resolved from the preceding `-C` location.
- `-c`: Override one `NAME=VALUE` configuration value for this invocation; omitting `=` means true, while an empty value is distinct.
- `--config-env`: Read a temporary `NAME=ENVVAR` configuration value from an environment variable instead of exposing the value directly in the command line.
- `-p`, `--paginate`: Send terminal output through the configured pager.
- `-P`, `--no-pager`: Disable paging for this invocation, which is usually preferable in automation.
- `--git-dir=PATH`: Set the repository metadata directory and disable normal `.git` discovery.
- `--work-tree=PATH`: Set the working-tree root; do not confuse it with the metadata directory.
- `--bare`: Treat the selected repository directory as a bare repository.
- `--no-optional-locks`: Avoid optional locks intended only for refresh or maintenance; it does not make modifying commands read-only.
- `--no-replace-objects`: Ignore replacement refs for this invocation.
- `-v`, `--version`: Print Git suite version information.
- `-h`, `--help`: Show common commands or the selected subcommand's help.

## Common commands

<!-- mant:entries role=command case=sensitive -->
- `status`: Report working-tree, index, branch, and conflict state without changing them.
- `diff`: Compare selected trees, index, or working files; `--quiet` uses status 1 to mean differences were found.
- `log`: Traverse and display commit history according to revision and path limits.
- `show`: Display an object or commit plus its associated changes.
- `add`: Stage selected working-tree content in the index; it does not create a commit.
- `restore`: Restore working-tree or index content from a selected source; it can discard uncommitted changes.
- `commit`: Record staged index content as a new commit after hooks and policy run.
- `branch`: List, create, rename, copy, or delete branch refs; deletion does not switch branches.
- `switch`: Change branches or create a branch with an explicit creation option.
- `fetch`: Download refs and objects without integrating them into the current branch.
- `pull`: Fetch and then integrate according to configured merge or rebase policy.
- `push`: Update refs in another repository subject to refspec, lease, authentication, and server policy.
- `merge`: Join another history into the current branch and can leave conflicts to resolve.
- `rebase`: Replay commits onto another base and rewrites commit identities.
- `reset`: Move refs and optionally the index or working tree; mode selection determines data-loss risk.
- `clone`: Create a new repository and working tree from another repository.
- `config`: Read or change configuration at an explicit scope and show provenance when requested.
- `worktree`: Manage additional working trees attached to one repository.
- `submodule`: Initialize, update, inspect, or synchronize nested repositories recorded by the superproject.
- `help`: Open installed documentation for a command or concept.

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

## Version and platform differences

This page follows current Git documentation and was runtime-checked with Git
2.55.0 on Linux. Installed Git versions, credential helpers, filesystem case
behavior, symlink support, line-ending policy, shell hooks, and bundled SSH
vary across Windows, macOS, and Linux.

On Windows NT `10.0.26200.0`, Windows PowerShell 5.1 resolved three Git
applications: Git for Windows `2.44.0.windows.1` under both `cmd` and `bin`,
plus Codex's bundled `2.53.0.windows.3`. The selected
`C:\Program Files\Git\cmd\git.exe` returned 0 with one stdout version line;
`-h` returned 0 with 37 nonempty stdout help lines. No repository, working
tree, configuration, hook, credential helper, pager, network, or file changed.
Automation that depends on one distribution must pin the resolved executable,
not merely assume the first `git` on `PATH` is universal.

## Common mistakes

### Running against the wrong repository or worktree

Use `-C`, inspect `rev-parse --show-toplevel`, and confirm branch/worktree
state before modifying refs or files. A prompt path is not an API.

### Treating every nonzero code as execution failure

Commands such as `diff --quiet` use status to report a normal comparison
result. Interpret the documented contract of the selected subcommand.

### Confusing working tree, index, and commit state

`add`, `restore`, `reset`, and `commit` affect different layers. Inspect both
`status` and the exact diff before using a destructive mode.

## Runtime evidence

The repeatable Windows cross-platform fixture preserved all three discovered
`git.exe` Application candidates, selected
`C:\Program Files\Git\cmd\git.exe`, and ran only `--version` plus top-level
`-h` under Windows PowerShell 5.1 and PowerShell 7.6.4. Both returned status
`0` with expected version/usage text. No repository, working tree, config,
hook, credential helper, pager, network, or file operation ran; macOS and
repository-scoped command behavior remain pending.

## Related documents

- [ssh](ssh.md)
- [Cross-platform tools for PowerShell](cross-platform-tools.md)
- On Windows, query executable lookup with
  `mant where --source windows-tools`.

## Sources and license

This original ManT-oriented guide was adapted from the official
[Git documentation](https://git-scm.com/docs/git). It emphasizes explicit
repository context, configuration provenance, and native exit-code handling.
Exact upstream revision and path are recorded in `upstream/cross-platform-tools.json`.

The cited documentation is licensed under GPL-2.0-only. This adaptation is
licensed under CC BY 4.0.
