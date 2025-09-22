Voting-STX
A decentralized voting contract built with Clarity on the Stacks blockchain.
It enables users to create proposals and vote using their STX, with votes weighted by the amount of tokens locked.

Features
Create and manage proposals
STX-weighted voting power
Prevents double voting
On-chain proposal closure & result tally
Transparent event logs

Technical Overview
Language: Clarity
Core Functions:
create-proposal – start a new proposal with description & duration
vote – cast vote (for/against/abstain) using STX weight
close-proposal – finalize voting after expiration
get-results – retrieve outcome of a proposal

Installation & Usage
Clone repository:
git clone https://github.com/your-repo/voting-stx.git
cd voting-stx
Deploy with Clarinet:
clarinet contract deploy voting-stx
Run tests:
clarinet test

Roadmap
Add quadratic voting model
Enable SIP-010 token-based voting
DAO treasury integration
Build governance dashboard front-end

License
MIT License – free to use, modify, and distribute.
