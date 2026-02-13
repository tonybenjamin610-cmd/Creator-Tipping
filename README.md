# 💰 WattShare - Creator Tipping Smart Contract

A decentralized tipping platform for content creators built on the Stacks blockchain using Clarity smart contracts. WattShare enables creators to receive tips with automatic distribution to multiple collaborators based on predefined percentage splits.

## ✨ Features

- 🎯 **Automatic Tip Distribution** - Tips are automatically split among collaborators based on configured percentages
- 👥 **Multi-Recipient Support** - Support up to 10 recipients per creator
- 💸 **Platform Fees** - Configurable platform fee (default 5%) to sustain the ecosystem
- 🔒 **Creator Control** - Creators can activate/deactivate their accounts and manage recipients
- 📊 **Transparent Tracking** - Full visibility of tip counts and amounts received
- ⚡ **Instant Settlements** - Tips are distributed immediately on-chain

## 🚀 Getting Started

### For Creators

**1. Register as a Creator**
```clarity
(contract-call? .wattshare register-creator)
```

**2. Add Recipients**
```clarity
(contract-call? .wattshare add-recipient 'ST1RECIPIENT-ADDRESS u40)
(contract-call? .wattshare add-recipient 'ST2RECIPIENT-ADDRESS u30)
(contract-call? .wattshare add-recipient 'ST3RECIPIENT-ADDRESS u30)
```

**3. Start Receiving Tips!**

Your fans can now send tips that will be automatically distributed according to your configured splits.

### For Supporters

**Send a Tip**
```clarity
(contract-call? .wattshare send-tip 'ST-CREATOR-ADDRESS u1000000)
```

The amount should be in microSTX (1 STX = 1,000,000 microSTX).

## 📖 Usage Guide

### Creator Functions

#### Register Creator
```clarity
(contract-call? .wattshare register-creator)
```
Creates a new creator profile. Must be called before adding recipients.

#### Add Recipient
```clarity
(contract-call? .wattshare add-recipient <recipient-principal> <percentage>)
```
- `recipient-principal`: The Stacks address of the collaborator
- `percentage`: Percentage of tips (1-100)

**Example**: Add a collaborator who receives 25% of tips
```clarity
(contract-call? .wattshare add-recipient 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u25)
```

#### Update Recipient Percentage
```clarity
(contract-call? .wattshare update-recipient-percentage <recipient-id> <new-percentage>)
```
- `recipient-id`: The ID of the recipient (starts from 0)
- `new-percentage`: New percentage allocation (1-100)

#### Deactivate Account
```clarity
(contract-call? .wattshare deactivate-creator)
```
Temporarily disable receiving tips.

#### Reactivate Account
```clarity
(contract-call? .wattshare reactivate-creator)
```
Re-enable tip receiving after deactivation.

### Supporter Functions

#### Send Tip
```clarity
(contract-call? .wattshare send-tip <creator-principal> <amount>)
```
- `creator-principal`: The creator's Stacks address
- `amount`: Tip amount in microSTX

**Example**: Tip 10 STX
```clarity
(contract-call? .wattshare send-tip 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG u10000000)
```

### Read-Only Functions

#### Get Creator Info
```clarity
(contract-call? .wattshare get-creator-info 'ST-CREATOR-ADDRESS)
```
Returns creator's total received, tip count, and active status.

#### Get Recipient Info
```clarity
(contract-call? .wattshare get-recipient-info 'ST-CREATOR-ADDRESS u0)
```
Returns recipient details for a specific recipient ID.

#### Get Recipient Count
```clarity
(contract-call? .wattshare get-recipient-count 'ST-CREATOR-ADDRESS)
```
Returns the number of recipients for a creator.

## 💡 How It Works

1. **Creator Registration**: Creators register on the platform and add their collaborators with percentage splits
2. **Tip Submission**: Supporters send tips to creators using their Stacks address
3. **Automatic Distribution**: The smart contract automatically:
   - Deducts platform fee (default 5%)
   - Calculates each recipient's share based on their percentage
   - Transfers STX to all recipients in a single transaction
4. **Tracking**: All transactions are recorded on-chain for complete transparency

## 🔧 Configuration

### Platform Fee Management (Owner Only)

**Update Platform Fee Percentage**
```clarity
(contract-call? .wattshare set-platform-fee-percentage u3)
```
Maximum: 20%

**Update Platform Fee Recipient**
```clarity
(contract-call? .wattshare set-platform-fee-recipient 'ST-NEW-ADDRESS)
```

## ⚠️ Error Codes

- `u100` - Owner-only function
- `u101` - Invalid percentage (must be 1-100 or ≤20 for platform fee)
- `u102` - Creator not found
- `u103` - No recipients configured
- `u104` - Insufficient tip amount
- `u105` - Transfer failed
- `u106` - Creator already exists
- `u107` - Unauthorized (account deactivated)
- `u108` - Recipient limit reached (max 10)

## 📝 Examples

### Complete Creator Setup
```clarity
;; Step 1: Register
(contract-call? .wattshare register-creator)

;; Step 2: Add collaborators
(contract-call? .wattshare add-recipient 'ST1VIDEOGRAPHER u50)
(contract-call? .wattshare add-recipient 'ST2EDITOR u30)
(contract-call? .wattshare add-recipient 'ST3MUSICIAN u20)

;; Step 3: Share your address with supporters!
```

### Send a Tip (Supporter)
```clarity
;; Tip 5 STX to creator
(contract-call? .wattshare send-tip 'ST-CREATOR-ADDRESS u5000000)

;; Distribution example with 5% platform fee:
;; - Platform: 0.25 STX (5%)
;; - Videographer: 2.375 STX (50% of 4.75)
;; - Editor: 1.425 STX (30% of 4.75)
;; - Musician: 0.95 STX (20% of 4.75)
```

## 🛠️ Development

Built with Clarinet for the Stacks blockchain.

### Contract Details
- **Language**: Clarity
- **Blockchain**: Stacks
- **Max Recipients**: 10 per creator
- **Default Platform Fee**: 5%

## 📄 License

MIT License - feel free to use and modify for your projects!

---

Built with ❤️ for creators and their communities on the Stacks blockchain 🚀
