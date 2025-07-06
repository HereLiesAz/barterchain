# Barterchain

Barterchain is a Flutter application designed to revolutionize the concept of exchange by returning to a blockchain-secured bartering system. It deconstructs the traditional notion of money as a scarce stand-in for value, instead focusing on direct, verifiable exchanges of goods and services.

## Project Overview

Inspired by the evolution of currency from bartering to complex financial instruments, Barterchain leverages blockchain technology not for creating a new digital currency, but for establishing an immutable ledger of agreements and their fulfillment. This eliminates the need for computationally difficult "mining" and focuses on trust and verifiable reputation.

## Core Concepts

* **Value Proposition Deconstructed:** Offers are described by their inherent utility, effort, or rarity, with value determined by mutual agreement, recorded as a *contract of perceived equivalence*.

* **Immutable Contracts:** All agreed-upon barters are enshrined as smart contracts on a distributed, client-side blockchain, defining the specific exchange of goods or services.

* **Escrow of Expectations:** For services or physical goods, contracts enter an escrow state, holding the *obligation* until fulfillment is mutually confirmed.

* **Reputation as Wealth:** A user's "wealth" is their cumulative history of successfully completed barters and positive peer reviews, forming an on-chain "Trust Score."

* **Decentralized Dispute Resolution:** A mechanism for resolving disagreements through a randomly selected, reputation-weighted panel of users.

## Blockchain Implementation (The Ledger)

Barterchain utilizes a **client-side, distributed blockchain**, where **each app instance acts as a node** and maintains its own local copy of the ledger. This approach distributes the burden of ledger maintenance across all active users. For practical synchronization between these individual app instances, **Firestore serves as a message broker**, facilitating the broadcast and reception of new blocks. The consensus mechanism is a simplified "longest chain wins" rule.

### Key Transaction Types:

1.  **Offer Creation:** Records a user's `have` and `want` as a public declaration of intent.

2.  **Contract Acceptance:** Links an `offerId` to a `contractId`, signifying mutual agreement and triggering conceptual smart contract terms (including escrow and fulfillment conditions).

3.  **Contract Fulfillment/Completion:** Records the successful completion of a barter, updating the contract status to 'completed'.

4.  **Dispute Initiation/Resolution:** Marks a contract as 'disputed' and records the outcome of the on-chain arbitration process.

5.  **Review Submission:** Records peer feedback (rating and text), directly influencing Trust Scores.

### Data Storage:

* **On-Chain (within each app's local blockchain):** Critical, immutable data (e.g., `offerId`, `contractId`, `proposerId`, `accepterId`, `status`, `review_submission` details including rating and text hash, `Trust Score` updates).

* **Off-Chain (Firestore for auxiliary data):** User bios and chat messages are stored in Firestore, leveraging its real-time capabilities for dynamic, non-core ledger data. Their integrity is secured by Firebase's authentication and security rules, separate from the blockchain's cryptographic immutability.

## App Features

* **Propose a Barter:** Create and submit new barter offers, which are then added to the distributed ledger.

* **Browse Offers:** View existing barter offers from other users, dynamically updated from the synchronized blockchain.

* **My Barters:** Track your active offers and review your barter history, all sourced from your local blockchain copy.

* **My Profile:** View your unique User ID, dynamically calculated Trust Score, barter statistics, and edit your personal bio (stored in Firestore). Also displays reviews you've received.

* **Chat:** Communicate with counterparties for negotiation or clarification, with persistent messages stored in Firestore.

* **Settings:** Configure app preferences.

* **Help & Support:** Access FAQs and contact support.

* **Blockchain Plan Documentation:** Transparently view the underlying blockchain architecture and logic within the app.

* **Barterchain Manifesto:** Read the philosophical underpinnings and core principles of the Barterchain project.

* **View Raw Blockchain:** Examine the raw, immutable blocks and transactions of your local ledger.

## Getting Started

To run the Barterchain Flutter application:

1.  **Clone the repository (if applicable):**
    ```bash
    git clone <repository-url>
    cd barterchain
    ```
2.  **Create the Flutter project (if starting from scratch):**
    ```bash
    flutter create barterchain --org com.hereliesaz.barterchain
    ```
3.  **Add dependencies:**
    Open `pubspec.yaml` and ensure the following dependencies are present under `dependencies:`:
    ```yaml
    dependencies:
      flutter:
        sdk: flutter
      cupertino_icons: ^1.0.2
      flutter_markdown: ^0.6.20
      firebase_core: ^2.32.0
      firebase_auth: ^4.10.0
      cloud_firestore: ^4.10.0
      crypto: ^3.0.3 # For SHA-256 hashing in blockchain
      uuid: ^4.4.0 # For generating unique IDs
    ```
4.  **Create `assets` folder and Markdown files:**
    In the root of your project, create a folder named `assets`. Inside `assets`, create `blockchain_plan.md` and `manifesto.md` and paste their respective content (as provided in previous responses).
5.  **Ensure `pubspec.yaml` includes assets:**
    Verify that `pubspec.yaml` has the `assets:` section configured to include the `assets/` folder:
    ```yaml
    flutter:
      uses-material-design: true
      assets:
        - assets/
    ```
6.  **Run `flutter pub get`:**
    ```bash
    flutter pub get
    ```
7.  **Place the provided Dart files:**
    Ensure all `.dart` files (`main.dart`, `create_offer_page.dart`, `browse_offers_page.dart`, `offer_detail_page.dart`, `my_barters_page.dart`, `user_profile_page.dart`, `settings_page.dart`, `help_support_page.dart`, `review_rating_page.dart`, `chat_page.dart`, `markdown_viewer_page.dart`, `block_blockchain.dart`, `blockchain_service.dart`, `blockchain_viewer_page.dart`, `models.dart`) are correctly placed in the `lib/` directory.
8.  **Configure Firestore Security Rules:**
    In your Firebase project's Firestore console, navigate to the "Rules" tab and update them to allow authenticated users to read/write to their own profile/chat data and to the public blockchain blocks. An example rule set was provided previously.
9.  **Run the application:**
    ```bash
    flutter run
    ```

This will launch the Barterchain app on your connected device or emulator.