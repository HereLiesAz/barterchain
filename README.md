# Barterchain

Barterchain is a Flutter application designed to revolutionize the concept of exchange by returning to a blockchain-secured bartering system. It deconstructs the traditional notion of money as a scarce stand-in for value, instead focusing on direct, verifiable exchanges of goods and services.

## Project Overview

Inspired by the evolution of currency from bartering to complex financial instruments, Barterchain leverages blockchain technology not for creating a new digital currency, but for establishing an immutable ledger of agreements and their fulfillment. This eliminates the need for computationally difficult "mining" and focuses on trust and verifiable reputation.

## Core Concepts

* **Value Proposition Deconstructed:** Offers are described by their inherent utility, effort, or rarity, with value determined by mutual agreement, recorded as a *contract of perceived equivalence*.

* **Immutable Contracts:** All agreed-upon barters are enshrined as smart contracts on a permissioned blockchain, defining the specific exchange of goods or services.

* **Escrow of Expectations:** For services or physical goods, contracts enter an escrow state, holding the *obligation* until fulfillment is mutually confirmed.

* **Reputation as Wealth:** A user's "wealth" is their cumulative history of successfully completed barters and positive peer reviews, forming an on-chain "Trust Score."

* **Decentralized Dispute Resolution:** A mechanism for resolving disagreements through a randomly selected, reputation-weighted panel of users.

## Blockchain Implementation (The Ledger)

Barterchain utilizes a **private or consortium blockchain** with a **Proof-of-Authority (PoA)** or **Delegated Byzantine Fault Tolerance (dBFT)** consensus mechanism. This choice ensures efficiency and scalability, as security is derived from the integrity of known validators rather than computational difficulty.

### Key Transaction Types:

1.  **Offer Creation:** Records a user's `have` and `want` as a public declaration of intent.

2.  **Contract Acceptance:** Links an `offerId` to a `contractId`, signifying mutual agreement and triggering smart contract terms (including escrow and fulfillment conditions).

3.  **Contract Fulfillment/Completion:** Records the successful completion of a barter, updating the contract status to 'completed'.

4.  **Dispute Initiation/Resolution:** Marks a contract as 'disputed' and records the outcome of the on-chain arbitration process.

### Data Storage:

* **On-Chain:** Critical, immutable data (e.g., `offerId`, `contractId`, `proposerId`, `accepterId`, `status`, `Trust Score` updates).

* **Off-Chain:** Large descriptive data (e.g., `have`/`want` descriptions, user bios, full review texts) are stored off-chain (e.g., IPFS or traditional database) with their cryptographic hashes on-chain for integrity.

## App Features

* **Propose a Barter:** Create and submit new barter offers.

* **Browse Offers:** View existing barter offers from other users.

* **My Barters:** Track your active offers and review your barter history.

* **My Profile:** View your Trust Score and barter statistics.

* **Chat:** Communicate with counterparties for negotiation or clarification.

* **Settings:** Configure app preferences.

* **Help & Support:** Access FAQs and contact support.

* **Blockchain Plan Documentation:** Transparently view the underlying blockchain architecture and logic within the app.

## Getting Started

To run the Barterchain Flutter application:

1.  **Clone the repository (if applicable):**

    ```
    git clone <repository-url>
    cd barterchain
    ```

2.  **Create the Flutter project (if starting from scratch):**

    ```
    flutter create barterchain --org com.hereliesaz.barterchain
    ```

3.  **Add `flutter_markdown` dependency:**
    Open `pubspec.yaml` and add the following under `dependencies:`:

    ```yaml
    dependencies:
      flutter:
        sdk: flutter
      cupertino_icons: ^1.0.2
      flutter_markdown: ^0.6.20
    ```

4.  **Create `assets` folder and `blockchain_plan.md`:**
    In the root of your project, create a folder named `assets`. Inside `assets`, create `blockchain_plan.md` and paste the content from the "Blockchain Plan: The Ledger" document.

5.  **Ensure `pubspec.yaml` includes assets:**
    Verify that `pubspec.yaml` has the `assets:` section configured to include the `assets/` folder:

    ```yaml
    flutter:
      uses-material-design: true
      assets:
        - assets/
    ```

6.  **Run `flutter pub get`:**

    ```
    flutter pub get
    ```

7.  **Place the provided Dart files:**
    Ensure all `.dart` files (`main.dart`, `create_offer_page.dart`, `browse_offers_page.dart`, `offer_detail_page.dart`, `my_barters_page.dart`, `user_profile_page.dart`, `settings_page.dart`, `help_support_page.dart`, `review_rating_page.dart`, `chat_page.dart`, `markdown_viewer_page.dart`) are correctly placed in the `lib/` directory.

8.  **Run the application:**

    ```
    flutter run
    ```

This will launch the Barterchain app on your connected device or emulator.
