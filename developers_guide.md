# Barterchain Developer Guide

Welcome to the Barterchain developer guide. This document outlines the current architecture, project status, and development roadmap for contributors building this post-scarcity, reputation-driven blockchain app.

---

## Overview

Barterchain is a Flutter-based mobile/web application that reimagines value exchange through blockchain-secured bartering. The system uses a **client-side blockchain**, with **Firestore as a synchronization broker**, and treats **Trust Score** as the only true wealth.

---

## Current State

The project is fully scaffolded:

* ✅ All UI pages are implemented: offer creation, browsing, contract management, reviews, profiles, and blockchain viewer.
* ✅ The `pubspec.yaml` includes required dependencies for Firebase, hashing (`crypto`), UUIDs, and markdown rendering.
* ✅ Firebase is configured and linked to the project.
* ✅ Core assets and documentation (manifesto, blockchain plan) are included and rendered in-app.

---

## Next Steps

### 1. Blockchain Engine

* Implement `Block`, `Transaction`, and `Blockchain` classes.
* Include:

  * SHA256 hashing via `crypto`.
  * Genesis block creation.
  * Chain validation logic.
  * Methods for adding offers, contracts, reviews as transactions.
* Integrate JSON viewer for raw blockchain inspection.

#### ✅ Implementation Plan

* Create `block.dart`, `transaction.dart`, and `blockchain.dart` in `lib/core/blockchain/`.
* Define a `Transaction` class with types: `offer`, `contract`, `review`, `dispute`, and metadata.
* Define a `Block` class with timestamp, list of transactions, previousHash, and hash.
* `Blockchain` manages a list of `Block`s and methods for:

  * Adding new transactions
  * Mining blocks
  * Verifying chain integrity

### 2. Firestore Synchronization Layer

* Create Firestore listener for new blocks.
* Broadcast new blocks upon creation.
* Validate and merge remote chains using "longest chain wins."

### 3. Trust Score Calculation

* Traverse the local blockchain to compute each user's score.
* Display on `user_profile_page.dart`.
* Cache scores with automatic invalidation on new blocks.

### 4. Dispute Resolution Mechanism

* Add UI to initiate disputes.
* Select dispute panel (random + reputation-weighted).
* Record results as on-chain transactions.

### 5. Chat and User Bios

* Create Firestore collections for:

  * `/chats/{chatId}`
  * `/users/{userId}/bio`
* Display chats and bios using Markdown.

### 6. Testing & Validation

* Unit tests for blockchain logic.
* Widget tests for barter flows.
* Simulate:

  * Chain desynchronization
  * Dispute workflows

---

## Optional Enhancements

* IPFS integration for off-chain data hashes.
* End-to-end encrypted chat.
* PWA optimizations for web.
* Federated login or walletless Web3 onboarding.

---

## How to Contribute

1. Clone the repo and run the app using:

   ```bash
   flutter pub get
   flutter run
   ```
2. Implement your feature in a new branch.
3. Submit a pull request with clear description and test coverage.

---

## Contact & Philosophy

This is more than an app. It's a public notary for mutual obligation, where *reputation is the only currency*. The code you write upholds the social fabric of a post-scarcity exchange system. Build accordingly.
