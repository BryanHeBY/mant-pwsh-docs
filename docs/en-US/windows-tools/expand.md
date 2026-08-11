<!-- mant:tldr:start -->
# expand

> List a Cabinet before extracting selected reviewed members into a new isolated directory; `expand.exe` handles CAB/compressed distribution files, not ZIP archives.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/expand.

- Display syntax for the installed Windows or recovery environment:

`expand.exe /?`

- List every member of a CAB without extracting it:

`expand.exe -d "{{C:\Incoming\package.cab}}"`

- List only members matching a reviewed selection pattern without extraction:

`expand.exe -d "{{C:\Incoming\package.cab}}" -F:"{{*.inf}}"`

- Extract one exact reviewed member into an existing, new, isolated directory:

`expand.exe "{{C:\Incoming\package.cab}}" -F:"{{driver.inf}}" "{{C:\Analysis\package-001}}"`

<!-- mant:tldr:end -->

# expand

## Overview

`expand.exe` expands compressed distribution files and selected members of a
Microsoft Cabinet (`.cab`). `-D` lists CAB members without extracting them;
`-F:files` selects CAB members and supports wildcards. `-R` renames expanded
files, while `-I` renames them and ignores directory structure.

It is not PowerShell's `Expand-Archive`, which handles ZIP archives. It also
does not validate publisher trust, authorize installation, or guarantee that
an archive's files are harmless.

## Syntax and parameters

<!-- mant:entries role=command case=insensitive -->
- `expand.exe`: List or expand Microsoft-compressed distribution files and CAB members.

This command handles Microsoft Cabinet/distribution compression, not ZIP.

<!-- mant:entries role=option case=insensitive -->
- `-d`: List CAB members without extracting them.
- `-f`: Select one or more CAB member names or wildcards for extraction.
- `-r`: Rename expanded files according to stored distribution names.
- `-i`: Rename expanded files while ignoring stored directory structure.
- `/?`: Display installed syntax.

## Safe extraction workflow

1. Preserve and hash the original CAB; determine its source, signature, and
   intended consumer before opening it.
2. Run `expand.exe -d` and record the complete member list. Review names,
   types, duplicate basenames, expected count, and size/capacity implications.
3. Create a new empty directory on a non-system, non-application path with
   appropriate ACLs and no reparse points beneath it.
4. Extract the smallest exact selection required, then enumerate the actual
   resulting paths, links/reparse points, hashes, signatures, and file types.
5. Analyze content with least privilege. Do not execute or install it merely
   because extraction succeeded.

## Common mistakes

### Extracting `*` directly over Windows or an application

Wildcards can select more members than expected, and collisions or archive
layout can replace existing files. Extract to a new isolated directory, compare
the result with the recorded listing, then use the owning product's supported
deployment process.

### Skipping `-D` because it looks like an extraction switch

`-D` is the safe list-only operation. Use it before `-F`; record output rather
than assuming a CAB contains only the one filename visible in its download name.

### Assuming `-I` preserves the archive's directories

Microsoft says `-I` ignores directory structure while renaming expanded files.
That can collapse names or change the expected layout. Test on disposable input
and reject collisions, missing members, or unexpected output paths.

### Confusing `-R` with recursion or overwrite control

`-R` means rename expanded files. It is not a recursive-directory switch and
does not make extraction a safe overwrite transaction. Read target-local help
before interpreting single-letter options.

### Treating a CAB like a ZIP

`Expand-Archive` is not the native CAB extraction equivalent, and `expand.exe`
does not provide ZIP semantics. Identify the container from trusted metadata
and content, not only its extension.

### Rebuilding or installing a signed update after extraction

Editing and repackaging changes content and invalidates the original signature
and provenance. Windows Update, drivers, DISM, and MSI have product-specific
verification and servicing rules; use their supported workflow.

### Trusting archive member names or contents

Treat untrusted archives as hostile input. Use a patched host, isolated output,
capacity quotas, malware/content scanning, and explicit path verification.
Never pipe a listed or extracted filename directly into execution.

## PowerShell boundaries

Call `expand.exe` explicitly, because command resolution may include functions
or scripts with the same bare name. Quote source and destination separately;
keep `/F:` or `-F:` joined to its pattern. Capture raw output and
`$LASTEXITCODE`, then verify the filesystem result rather than trusting text
alone.

## Version and platform differences

This Windows-only utility is documented for supported Windows client and server
releases. Windows Recovery Environment exposes different parameters. Option
forms, compression formats, path rules, and servicing use depend on the target
build, so check installed help in the actual environment.

## Related documents

- [makecab](makecab.md)
- [diantz](diantz.md)
- [dism](dism.md)

## Sources and license

This original guide was adapted from Microsoft's official
[Expand reference](https://learn.microsoft.com/windows-server/administration/windows-commands/expand).
Recurring rebuild, directory-layout, and signature confusion was cross-checked
against a high-demand
[CAB extraction and rebuild question](https://stackoverflow.com/questions/24034003/how-to-extract-modify-and-rebuild-a-cabinet-file);
syntax and supported behavior follow Microsoft's reference. Exact sources and
licenses are recorded in `upstream/windows-tools.json`.

The Microsoft documentation and this adaptation are licensed under CC BY 4.0.
Stack Overflow contributions are licensed under CC BY-SA 4.0.
