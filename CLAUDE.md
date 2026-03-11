# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

- Build: `forge build`
- Test: `forge test`
- Test single file: `forge test --match-path test/Fields__Mint.t.sol`
- Test single function: `forge test --match-test testMintRevertMintWithoutValue`
- Test with verbosity: `forge test -vvv`
- Gas report: `forge test --gas-report`
- Coverage: `forge coverage`
- Lint: `yarn lint`
- Format Solidity: `forge fmt`
- Clean: `yarn clean`

## Architecture

### Core Contract: `Fields` (`src/Fields.sol`)

ERC721 NFT collection with a curated allow-list mechanism. Key design: assets are pre-approved as `bytes32` hashes of their IPFS CIDs before users can mint them. This prevents arbitrary minting — only the owner-approved content can be minted.

**Flow:**
1. Deploy with initial `bytes32[]` of asset hashes (keccak256 of IPFS CID strings)
2. Owner can `addAssets()` up to `MAX_SUPPLY` (10) total
3. Users call `safeMint(uri)` with exactly `MINT_PRICE` (0.1 ether) — the URI is hashed and checked against `isForSale`
4. Owner withdraws via `withdrawAll()` (ETH) or `withdrawAllERC20()`

**Inheritance chain:** `ERC721` + `ERC721Enumerable` + `ERC721URIStorage` + `Ownable` (OpenZeppelin)

**Token IDs:** Start at 0, increment via `Counters.Counter`. `_baseURI()` returns `"ipfs://"`.

### Test Structure

Tests are in `test/Fields__<Feature>.t.sol` files. Each test contract inherits from `forge-std/Test.sol` and uses `DeployFields` script in `setUp()`. The deploy script seeds 3 specific asset hashes — tests reference their IPFS CIDs directly.

### Asset Registration

Assets are stored as `keccak256(abi.encodePacked(uri))` in the `isForSale` mapping. When minting, the contract hashes the provided URI and looks it up. After minting, the hash is set to `false` to prevent double-minting.

## Code Style Guidelines

- Solidity version: 0.8.19
- Error handling: custom errors (not `require` with strings), except `burn()` which still uses `require`
- Function order: external/public/internal/private
- Line length: 120 characters, 4-space tabs, double quotes
- Documentation: NatSpec on all public functions and contracts
- State variable groups: errors → state variables → events → constructor → external → internal → overrides
