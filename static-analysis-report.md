# Static Analysis Report

Generated with [Slither](https://github.com/crytic/slither) v0.11.5 and [Aderyn](https://github.com/Cyfrin/aderyn) v0.6.8 against `src/Fields.sol` (the `ExampleToken` mock now lives in `test/mocks/` and is out of scope).

No high or medium severity issues were found in project code (findings from vendored `lib/` dependencies were excluded as out of scope).

## Summary

| Tool | High | Medium | Low | Informational |
| --- | --- | --- | --- | --- |
| Slither (project scope) | 0 | 0 | 0 | 0 |
| Aderyn | 0 | 0 | 3 | 0 |

## Slither Findings

No findings in project scope.

## Aderyn Findings

### L-1: Centralization Risk
Contracts have owners with privileged rights to perform admin tasks and need to be trusted to not perform malicious updates or drain funds.
- `src/Fields.sol#L28` — `contract Fields is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable`
- `src/Fields.sol#L96` — `function addAssets(bytes32[] memory assets) external onlyOwner`
- `src/Fields.sol#L139` — `function toggleMintStatus() external onlyOwner`
- `src/Fields.sol#L159` — `function withdrawAll() external onlyOwner`
- `src/Fields.sol#L168` — `function withdrawAllERC20(IERC20 erc20Token) external onlyOwner`

Accepted: inherent to the curated allow-list design (owner controls the asset list, pause, and withdrawals).

### L-2: Costly Operations Inside Loop
Invoking `SSTORE` operations in loops may waste gas.
- `src/Fields.sol#L182` (loop inside `_flagForSale`, called from `addAssets` and the constructor)

Partially addressed: `collectionSize` used to be re-written on every iteration (`collectionSize = collectionSize + 1`) — it's now accumulated in a local variable and written once after the loop. The remaining `isForSale[assets[i]] = true` write is unavoidable, since each asset needs its own storage slot flagged; the detector flags any SSTORE inside a loop regardless.

### L-3: Loop Contains `require`/`revert`
Avoid `require`/`revert` inside a loop — a single bad item causes the whole transaction to fail.
- `src/Fields.sol#L182` (loop inside `_flagForSale`)

Accepted: the revert-on-duplicate is intentional — `addAssets` is meant to be all-or-nothing so a bad batch never partially registers. `MAX_SUPPLY` bounds the loop to 256 owner-supplied items, so griefing/gas-DoS risk is not a concern.

## Notes

- `MAX_SUPPLY` was raised from 10 to 256.
- No reentrancy, access-control, or arithmetic vulnerabilities were flagged in project code.
