# 🎬 Video Royalty Distribution Protocol

> Automatically splits streaming income among collaborators transparently on Stacks blockchain

## 📖 Overview

The Video Royalty Distribution Protocol is a Clarity smart contract that enables creators to register videos with multiple collaborators and automatically distribute streaming revenue based on predefined percentage splits. All transactions are transparent and immutable on the blockchain.

## ✨ Features

- 🎥 **Video Registration** - Register videos with multiple collaborators and their revenue shares
- 💰 **Automated Distribution** - Deposit streaming revenue that's automatically split based on percentages
- 💸 **Withdrawals** - Collaborators can withdraw their earnings anytime
- 📊 **Transparent Tracking** - All earnings and withdrawals are tracked on-chain
- 🔒 **Secure** - Creator-only controls for video status and percentage updates
- 🎯 **Flexible** - Support up to 20 collaborators per video

## 🚀 Quick Start

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for deployment

### Installation

```bash
git clone https://github.com/innocezty/Video-Royalty-Distribution-Protocol
cd Video-Royalty-Distribution-Protocol
clarinet check
```

## 📝 Usage

### Register a Video

Register a new video with collaborators and their percentage splits (must total 10000 = 100%):

```clarity
(contract-call? .Video-Royalty-Distribution-Protocol register-video
  "My Amazing Video"
  (list
    { addr: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM, pct: u5000 }
    { addr: 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5, pct: u3000 }
    { addr: 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG, pct: u2000 }
  )
)
```

### Deposit Streaming Revenue

Deposit streaming income to a video (requires video ID):

```clarity
(contract-call? .Video-Royalty-Distribution-Protocol deposit-streaming-revenue
  u1
  u1000000
)
```

### Withdraw Earnings

Collaborators can withdraw their share of accumulated earnings:

```clarity
(contract-call? .Video-Royalty-Distribution-Protocol withdraw-earnings u1)
```

### Check Pending Earnings

View pending earnings for a collaborator:

```clarity
(contract-call? .Video-Royalty-Distribution-Protocol get-pending-earnings
  u1
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
)
```

### Get Video Stats

Retrieve comprehensive video statistics:

```clarity
(contract-call? .Video-Royalty-Distribution-Protocol get-video-stats u1)
```

## 🔧 Public Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| `register-video` | Register new video with collaborators | title, collaborator-list |
| `deposit-streaming-revenue` | Deposit revenue to video balance | video-id, amount |
| `withdraw-earnings` | Withdraw collaborator earnings | video-id |
| `update-video-status` | Toggle video active status (creator only) | video-id, status |
| `update-collaborator-percentage` | Update collaborator percentage (creator only) | video-id, collaborator, new-percentage |

## 🔍 Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-video` | Get video details |
| `get-collaborator` | Get collaborator details |
| `get-video-balance` | Get current video balance |
| `get-pending-earnings` | Calculate pending earnings |
| `get-total-earnings` | Get total withdrawn by collaborator |
| `get-video-stats` | Get comprehensive video statistics |
| `get-video-nonce` | Get current video count |

## 💡 Example Workflow

1. **Creator registers video** with 3 collaborators:
   - Director: 50%
   - Producer: 30%
   - Editor: 20%

2. **Platform deposits** streaming revenue of 1,000 STX to the video

3. **Automatic split calculation**:
   - Director: 500 STX (50%)
   - Producer: 300 STX (30%)
   - Editor: 200 STX (20%)

4. **Collaborators withdraw** their earnings independently

## ⚠️ Error Codes

- `u100` - Owner only operation
- `u101` - Video/collaborator not found
- `u102` - Already exists
- `u103` - Invalid percentage (must total 10000)
- `u104` - Unauthorized access
- `u105` - Invalid amount
- `u106` - Transfer failed
- `u107` - Invalid collaborators
- `u108` - No balance to withdraw

## 🧪 Testing

```bash
clarinet test
```

## 📄 License

MIT License - See LICENSE file for details

## 🤝 Contributing

Contributions welcome! Please open an issue or submit a pull request.

## 🔗 Links

- [Stacks Documentation](https://docs.stacks.co/)
- [Clarity Language Reference](https://docs.stacks.co/clarity/)
- [Clarinet Documentation](https://github.com/hirosystems/clarinet)

---

Built with ❤️ on Stacks blockchain
