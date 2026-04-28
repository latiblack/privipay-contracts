# PriviPay Contracts & Relayer

Confidential on-chain payroll system using Zama's Fully Homomorphic Encryption (FHE) on Ethereum.

## Overview

PriviPay enables organizations to manage employee payroll with cryptographic privacy. Salaries and bonuses are encrypted on-chain, ensuring that only the relevant employee (and the organization owner) can view sensitive compensation data.

### Key Features

- **Encrypted Salaries**: Employee compensation stored as encrypted data on-chain
- **Confidential Voting**: Anonymous voting system for bonus distribution
- **FHE Relayer**: Backend service for decrypting and processing FHE operations
- **Zama fhEVM**: Built on Zama's fully homomorphic encryption blockchain

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        PriviPay                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐         ┌──────────────┐                     │
│  │   Frontend   │────────▶│   Relayer    │                     │
│  │   (React)    │         │  (Express)   │                     │
│  └──────────────┘         └──────┬───────┘                     │
│                                  │                              │
│                                  ▼                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              ConfidentialPayroll.sol                      │  │
│  │         (Zama fhEVM Smart Contract)                       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Components

| Component | Description | Technology |
|-----------|-------------|------------|
| Smart Contract | Payroll logic with encrypted storage | Solidity + Zama TFHE |
| Relayer | FHE decryption & transaction relay | Node.js + Express + Viem |

## Quick Start

### Prerequisites

- **Node.js** v18+
- **Foundry** (for Solidity development)
- **npm** or **yarn**

### 1. Clone & Install

```bash
# Clone the repository
git clone https://github.com/latiblack/privipay-contracts.git
cd privipay-contracts

# Install relayer dependencies
cd relayer
npm install
cd ..

# Install contract dependencies (Foundry)
cd contracts
forge install
```

### 2. Configure Environment

```bash
# Copy example environment files
cp contracts/.env.example contracts/.env
cp relayer/.env.example relayer/.env  # If exists
```

Edit the environment files with your values:

**contracts/.env:**
```env
DEPLOYER_PRIVATE_KEY=0xyour_private_key_here
ZAMA_FHEVM_RPC_URL=https://sepolia.fheoma.zama.xyz
ZAMA_FHEVM_API_KEY=your_api_key
```

### 3. Deploy Contract

```bash
cd contracts
forge script script/Deploy.s.sol --rpc-url zama_fhevm_sepolia --broadcast --verify
```

### 4. Start Relayer

```bash
cd relayer
PORT=3001 npm start
```

## Project Structure

```
privipay-contracts/
├── contracts/                 # Solidity smart contracts
│   ├── src/
│   │   └── ConfidentialPayroll.sol   # Main payroll contract
│   ├── script/
│   │   └── Deploy.s.sol              # Deployment script
│   ├── lib/                  # Zama fhEVM libraries
│   ├── Makefile             # Deployment commands
│   └── README.md            # Contract-specific docs
│
├── relayer/                  # Node.js relayer service
│   ├── src/
│   │   └── index.ts         # Express server & routes
│   ├── package.json
│   └── tsconfig.json
│
└── README.md                 # This file
```

## Smart Contract API

### Employee Management

```solidity
// Request to join organization
payroll.requestJoin();

// Owner approves employee
payroll.approveJoin(userAddress);

// Remove employee
payroll.removeEmployee(employeeAddress);
```

### Salary Operations

```solidity
// Set employee salary (owner only) - amount in cents
payroll.setSalary(employeeAddress, 750000); // $7,500/month

// Get salary (employee or owner only)
uint256 salary = payroll.getSalary(employeeAddress);
```

### Bonus & Voting

```solidity
// Cast vote for an employee
payroll.castVoteFor(voterAddress, candidateAddress);

// Distribute bonuses based on votes
payroll.distributeBonuses(threshold);
```

### Withdrawal

```solidity
// Employee withdraws salary
payroll.withdrawSalary();
```

## Relayer API

### Health Check

```bash
GET /health
```

Response:
```json
{
  "status": "ok",
  "timestamp": "2026-04-28T12:00:00Z"
}
```

### Decrypt FHE Data

```bash
POST /api/relayer/decrypt
```

Request:
```json
{
  "contractAddress": "0x...",
  "encryptedData": "0x...",
  "userPublicKey": "0x...",
  "userAddress": "0x..."
}
```

Response:
```json
{
  "success": true,
  "decryptedValue": "7500.00"
}
```

### Process Withdrawal

```bash
POST /api/relayer/withdraw
```

Request:
```json
{
  "contractAddress": "0x...",
  "recipientAddress": "0x...",
  "amount": "750000",
  "userAddress": "0x...",
  "userSignature": "0x..."
}
```

Response:
```json
{
  "success": true,
  "transactionHash": "0x..."
}
```

## Networks

| Network | RPC URL | Explorer |
|---------|---------|----------|
| Zama Devnet | https://devnet.fheoma.zama.xyz | devnet.fheoma.zama.xyz |
| Zama Sepolia | https://sepolia.fheoma.zama.xyz | sepolia.fheoma.zama.xyz |
| Zama Mainnet | https://mainnet.fheoma.zama.xyz | mainnet.fheoma.zama.xyz |

## Development

### Running Tests

```bash
cd contracts
forge test
```

### Contract Documentation

See [`contracts/README.md`](contracts/README.md) for detailed FHE concepts and advanced usage.

## Security Considerations

1. **Re-encryption**: Users must prove ownership of their private key
2. **Relayer Trust**: The relayer handles decryption - use a trusted setup
3. **Key Management**: Never commit private keys to version control
4. **Production**: Consider threshold FHE for critical operations

## License

BSD-3-Clause-Clear - See Zama's license for TFHE library usage

## Related Links

- [Zama fhEVM Documentation](https://docs.zama.ai/fhevm)
- [TFHE Solidity Library](https://github.com/zama-ai/fhevm)
- [PriviPay Frontend](https://github.com/latiblack/chat-buddy-ai-894)