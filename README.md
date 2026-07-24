# Fields

An ERC721 NFT collection with a curated allow-list. Assets are pre-approved on-chain as `keccak256` hashes of
their IPFS CIDs, so only owner-approved content can ever be minted.

## How it works

1. Deploy with an initial set of asset hashes (`keccak256` of each IPFS CID)
2. The owner can add more assets later via `addAssets()`, up to `MAX_SUPPLY` (10)
3. Anyone can `safeMint(uri)` an approved asset by paying `MINT_PRICE` (0.1 ETH) — the URI is hashed and
   checked against the allow-list, then removed to prevent double-minting
4. The owner withdraws collected funds via `withdrawAll()` (ETH) or `withdrawAllERC20()`

Built with [Foundry](https://book.getfoundry.sh/) on top of OpenZeppelin's `ERC721`, `ERC721Enumerable`,
`ERC721URIStorage`, and `Ownable`.

## Usage

```sh
forge build              # compile
forge test                # run tests
forge test --gas-report   # gas usage
forge coverage             # coverage report
forge fmt                 # format Solidity
npm run lint               # lint Solidity + check formatting
```

Deploying requires a `MNEMONIC` environment variable set to a valid
[BIP39 mnemonic](https://iancoleman.io/bip39/):

```sh
forge script script/DeployFields.s.sol --broadcast --fork-url <RPC_URL>
```

## License

MIT
