# History

## 6th Jan 2025

deploy points record contract:
```
./deploy.sh                          1 ↵
Checking environment variables...
RPC URL length: 69
Private key length: 66
Etherscan key length: 34
Starting deployment...
[⠒] Compiling...
[⠒] Compiling 1 files with Solc 0.8.23
[⠢] Solc 0.8.23 finished in 3.96s
Compiler run successful!
Traces:
  [1248865] DeployPointsRecord::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return] 
    ├─ [1208601] → new CommunityPointsRecord@0xcC71483eF01c809A08A57a6Af25D3E38ca3c06A9
    │   ├─ emit AdminAdded(admin: 0xF44b8DE7a3747162a3f04feb432C2b1F0cBB6F18)
    │   ├─ emit MemberAdded(member: 0xF44b8DE7a3747162a3f04feb432C2b1F0cBB6F18)
    │   └─ ← [Return] 5570 bytes of code
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return] 
    ├─ [0] console::log("CommunityPointsRecord deployed to:", CommunityPointsRecord: [0xcC71483eF01c809A08A57a6Af25D3E38ca3c06A9]) [staticcall]
    │   └─ ← [Stop] 
    └─ ← [Stop] 


Script ran successfully.

== Logs ==
  CommunityPointsRecord deployed to: 0xcC71483eF01c809A08A57a6Af25D3E38ca3c06A9

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [1208601] → new CommunityPointsRecord@0xcC71483eF01c809A08A57a6Af25D3E38ca3c06A9
    ├─ emit AdminAdded(admin: 0xF44b8DE7a3747162a3f04feb432C2b1F0cBB6F18)
    ├─ emit MemberAdded(member: 0xF44b8DE7a3747162a3f04feb432C2b1F0cBB6F18)
    └─ ← [Return] 5570 bytes of code


==========================

Chain 11155420

Estimated gas price: 0.000000759 gwei

Estimated total gas used for script: 1760014

Estimated amount required: 0.000000001335850626 ETH

==========================

##### optimism-sepolia
✅  [Success]Hash: 0xce50f444dda195cef9e2694955fc85604af620cb3e839b931674b602ac7f2f48
Contract Address: 0xcC71483eF01c809A08A57a6Af25D3E38ca3c06A9
Block: 22179122
Paid: 0.000000000685238862 ETH (1354227 gas * 0.000000506 gwei)

✅ Sequence #1 on optimism-sepolia | Total Paid: 0.000000000685238862 ETH (1354227 gas * avg 0.000000506 gwei)
                                                           

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
##
Start verification for (1) contracts
Start verifying contract `0xcC71483eF01c809A08A57a6Af25D3E38ca3c06A9` deployed on optimism-sepolia

Submitting verification for [src/points-record.sol:CommunityPointsRecord] 0xcC71483eF01c809A08A57a6Af25D3E38ca3c06A9.
Encountered an error verifying this contract:
Response: `NOTOK`
Details: `Invalid API Key (#err2)|OP1-`
```

验证验证状态：
curl "https://api-sepolia-optimistic.etherscan.io/api?module=contract&action=checkverifystatus&guid=YOUR_GUID&apikey=$ETHERSCAN_API_KEY"

## Verify contract

endpoint url:
Network
URL
Documentation
Mainnet

https://api.etherscan.io/api

https://docs.etherscan.io/

Goerli

https://api-goerli.etherscan.io/api

https://docs.etherscan.io/v/goerli-etherscan

Sepolia

https://api-sepolia.etherscan.io/api

https://docs.etherscan.io/v/sepolia-etherscan/

**verify failed cause of no service endpoint on optimistic sepolia**