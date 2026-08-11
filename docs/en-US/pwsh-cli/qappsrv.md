<!-- mant:tldr:start -->
# qappsrv

> Exact executable alias for `query termserver`; perform legacy Remote Desktop Session Host discovery without treating it as authoritative inventory.
> More information: https://learn.microsoft.com/windows-server/administration/windows-commands/qappsrv.

- Open the complete discovery-limit and session-family guide:

`mant query --source pwsh-cli`

- Search the current legacy network/domain scope and do not pause between screens:

`qappsrv.exe /continue`

- Search one exact domain and request returned addresses:

`qappsrv.exe /domain:"{{domain}}" /address /continue`

- Prefer the semantic dispatcher spelling in new procedures:

`query.exe termserver /domain:"{{domain}}" /address /continue`
<!-- mant:tldr:end -->

# qappsrv

## Meaning

`qappsrv.exe` performs the same operation as `query.exe termserver`: legacy
network/domain discovery of Remote Desktop Session Host servers. `/domain:`
sets discovery scope, `/address` adds network/node addresses, and `/continue`
suppresses pagination. Use [query.exe](query.md) for the full family map and
the reasons this result is not a complete deployment or asset inventory.

Discovery can be affected by role registration, historical browse mechanisms,
permissions, name resolution, segmentation, and build/configuration. Confirm
hosts through the authoritative RDS deployment and asset sources before acting.

## Common mistakes

- Reading the historical name as an inventory of installed applications.
- Treating no results as proof that no Session Host exists.
- Treating a discovered address as current identity or authorization.
- Using broad domain discovery when one known target answers the question.
- Parsing localized text as a stable machine schema.

## Sources and license

This original alias guide is based on Microsoft's official
[qappsrv](https://learn.microsoft.com/windows-server/administration/windows-commands/qappsrv)
and [query termserver](https://learn.microsoft.com/windows-server/administration/windows-commands/query-termserver)
references. Exact locked provenance is recorded in `upstream/cli.json`.

The cited documentation and this adaptation are licensed under CC BY 4.0.
