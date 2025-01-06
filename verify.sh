#!/bin/bash

# Load environment variables
if [ -f .env ]; then
    set -a
    source .env
    set +a
else
    echo "Error: .env file not found"
    exit 1
fi

# Replace with your deployed contract address
CONTRACT_ADDRESS="0xcC71483eF01c809A08A57a6Af25D3E38ca3c06A9"

# 构建 API 请求
API_ENDPOINT="https://api-sepolia-optimistic.etherscan.io/api"
SOURCE_CODE=$(cat src/points-record.sol | sed 's/"/\\"/g' | tr -d '\n')

# 使用 curl 发送验证请求
curl -X POST "$API_ENDPOINT" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "apikey=$ETHERSCAN_API_KEY" \
  -d "module=contract" \
  -d "action=verifysourcecode" \
  -d "sourceCode=$SOURCE_CODE" \
  -d "contractaddress=$CONTRACT_ADDRESS" \
  -d "codeformat=solidity-single-file" \
  -d "contractname=CommunityPointsRecord" \
  -d "compilerversion=v0.8.19" \
  -d "optimizationUsed=1" \
  -d "runs=200" \
  -d "constructorArguments=" 