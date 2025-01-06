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

# Debug: Check if variables are loaded (will be masked for security)
echo "Checking environment variables..."
echo "RPC URL length: ${#OPTIMISM_SEPOLIA_RPC}"
echo "Private key length: ${#PRIVATE_KEY}"
echo "Etherscan key length: ${#ETHERSCAN_API_KEY}"

# Validate private key format
if [[ ! $PRIVATE_KEY =~ ^0x[0-9a-fA-F]{64}$ ]]; then
    echo "Error: Invalid private key format"
    echo "Private key should be 64 hexadecimal characters with '0x' prefix"
    exit 1
fi

# Deploy the contract
echo "Starting deployment..."
forge script script/PointsRecord.s.sol:DeployPointsRecord \
    --rpc-url "$OPTIMISM_SEPOLIA_RPC" \
    --private-key "$PRIVATE_KEY" \
    --broadcast \
    --verify \
    --etherscan-api-key "$ETHERSCAN_API_KEY" \
    --verifier-url "https://api-sepolia-optimistic.etherscan.io/api" \
    -vvvv 