# Static Analysis Report

Generated with [Slither](https://github.com/crytic/slither) v0.11.5 and [Aderyn](https://github.com/Cyfrin/aderyn) v0.6.8 against `src/Fields.sol` and `src/ExampleToken.sol`.

No high or medium severity issues were found in project code (findings from vendored `lib/` dependencies were excluded as out of scope).

## Summary

| Tool | High | Medium | Low | Informational |
| --- | --- | --- | --- | --- |
| Slither (project scope) | 0 | 0 | 0 | 3 |
| Aderyn | 0 | 0 | 6 | 0 |

## Slither Findings

**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.

### solc-version (Informational)
Version constraint `^0.8.19` contains known severe issues (VerbatimInvalidDeduplication, FullInlinerNonExpressionSplitArgumentEvaluationOrder, MissingSideEffectsOnSelectorAccess).
- `src/ExampleToken.sol#L2`
- `src/Fields.sol#L2`

### naming-convention (Informational)
Parameter `Fields.withdrawAllERC20(IERC20)._erc20Token` is not in mixedCase.
- `src/Fields.sol#L161`

### unindexed-event-address (Informational)
Event `Fields.Mint(address,string,uint256)` has address parameters but no indexed parameters.
- `src/Fields.sol#L59`

## Aderyn Findings

### L-1: Centralization Risk
Contracts have owners with privileged rights to perform admin tasks and need to be trusted to not perform malicious updates or drain funds.
- `src/ExampleToken.sol#L7` — `contract ExampleToken is ERC20, Ownable`
- `src/ExampleToken.sol#L10` — `function mint(address to, uint256 amount) public onlyOwner`
- `src/Fields.sol#L28` — `contract Fields is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable`
- `src/Fields.sol#L90` — `function addAssets(bytes32[] memory assets) external onlyOwner`
- `src/Fields.sol#L133` — `function toggleMintStatus() external onlyOwner`
- `src/Fields.sol#L152` — `function withdrawAll() public onlyOwner`
- `src/Fields.sol#L161` — `function withdrawAllERC20(IERC20 _erc20Token) external onlyOwner`

### L-2: Costly Operations Inside Loop
Invoking `SSTORE` operations in loops may waste gas. Use a local variable to hold the loop computation result.
- `src/Fields.sol#L175` (loop inside `addAssets`)

### L-3: Loop Contains `require`/`revert`
Avoid `require`/`revert` inside a loop — a single bad item causes the whole transaction to fail.
- `src/Fields.sol#L175` (loop inside `addAssets`)

### L-4: State Change Without Event
State variable changes without a corresponding event, hindering offchain indexing.
- `src/Fields.sol#L133` — `toggleMintStatus()`

### L-5: Unspecific Solidity Pragma
Consider pinning to an exact Solidity version instead of `^0.8.19`.
- `src/ExampleToken.sol#L2`
- `src/Fields.sol#L2`

### L-6: Public Function Not Used Internally
Functions marked `public` but never called internally could be `external` to save gas.
- `src/ExampleToken.sol#L10` — `mint(address,uint256)`
- `src/Fields.sol#L142` — `burn(uint256)`
- `src/Fields.sol#L152` — `withdrawAll()`

## Notes

- `src/ExampleToken.sol` appears to be a leftover template file unrelated to the `Fields` contract — worth confirming whether it should be removed.
- No reentrancy, access-control, or arithmetic vulnerabilities were flagged in project code.
- Consider addressing L-4 (missing event on `toggleMintStatus`) and L-6 (tighten visibility) as low-cost cleanups.
