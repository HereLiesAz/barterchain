// lib/block_blockchain.dart
import 'dart:convert';
import 'package:crypto/crypto.dart'; // For SHA-256 hashing

// A simple Block class representing a single block in our blockchain.
// Each block will contain a list of transactions (in our case, Barter Offers or Contract updates).
class Block {
  final int index;
  final DateTime timestamp;
  final String previousHash;
  final String hash;
  final List<Map<String, dynamic>> transactions; // Data stored in the block

  Block({
    required this.index,
    required this.timestamp,
    required this.previousHash,
    required this.transactions,
    required this.hash, // Hash is calculated externally and passed in
  });

  // Factory constructor to create a Block from a JSON map (e.g., from Firestore)
  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      index: json['index'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      previousHash: json['previousHash'] as String,
      transactions: List<Map<String, dynamic>>.from(json['transactions'] as List),
      hash: json['hash'] as String,
    );
  }

  // Convert a Block object to a JSON map for storage (e.g., in Firestore)
  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'timestamp': timestamp.toIso8601String(),
      'previousHash': previousHash,
      'transactions': transactions,
      'hash': hash,
    };
  }
}

// The Blockchain class manages the chain of blocks.
// Each app instance will maintain its own copy of this blockchain.
class Blockchain {
  List<Block> chain = [];
  List<Map<String, dynamic>> pendingTransactions = []; // Transactions waiting to be added to a block

  Blockchain() {
    // Create the genesis block when the blockchain is initialized
    _createGenesisBlock();
  }

  // Creates the very first block in the chain.
  void _createGenesisBlock() {
    addBlock(Block(
      index: 0,
      timestamp: DateTime.now(),
      previousHash: '0', // Genesis block has no previous hash
      transactions: [], // No transactions in the genesis block
      hash: _calculateHash(0, DateTime.now(), '0', []), // Calculate its own hash
    ));
    print('Genesis block created.');
  }

  // Calculates the SHA-256 hash of a block's content.
  String _calculateHash(int index, DateTime timestamp, String previousHash, List<Map<String, dynamic>> transactions) {
    final bytes = utf8.encode('$index$timestamp$previousHash${jsonEncode(transactions)}');
    return sha256.convert(bytes).toString();
  }

  // Adds a new block to the chain.
  void addBlock(Block block) {
    chain.add(block);
  }

  // Gets the latest block in the chain.
  Block getLatestBlock() {
    return chain.last;
  }

  // Adds a new transaction to the list of pending transactions.
  void addTransaction(Map<String, dynamic> transaction) {
    pendingTransactions.add(transaction);
    print('Transaction added to pending: $transaction');
  }

  // Mines a new block, adding all pending transactions to it.
  // In a real decentralized system, this would involve consensus.
  // Here, it's a local operation that then needs to be "broadcast."
  Block minePendingTransactions() {
    if (pendingTransactions.isEmpty) {
      print('No pending transactions to mine.');
      return getLatestBlock(); // Return the latest block if nothing to mine
    }

    final int newIndex = getLatestBlock().index + 1;
    final DateTime newTimestamp = DateTime.now();
    final String newPreviousHash = getLatestBlock().hash;
    final List<Map<String, dynamic>> transactionsToMine = List.from(pendingTransactions); // Copy pending transactions

    final String newHash = _calculateHash(newIndex, newTimestamp, newPreviousHash, transactionsToMine);

    final Block newBlock = Block(
      index: newIndex,
      timestamp: newTimestamp,
      previousHash: newPreviousHash,
      transactions: transactionsToMine,
      hash: newHash,
    );

    addBlock(newBlock);
    pendingTransactions = []; // Clear pending transactions after mining
    print('New block mined: ${newBlock.hash} with ${transactionsToMine.length} transactions.');
    return newBlock;
  }

  // Validates the entire blockchain.
  bool isChainValid() {
    for (int i = 1; i < chain.length; i++) {
      final Block currentBlock = chain[i];
      final Block previousBlock = chain[i - 1];

      // Check if the current block's hash is correct
      if (currentBlock.hash != _calculateHash(
        currentBlock.index,
        currentBlock.timestamp,
        currentBlock.previousHash,
        currentBlock.transactions,
      )) {
        print('Block ${currentBlock.index} has been tampered with (hash mismatch).');
        return false;
      }

      // Check if the current block's previousHash points to the actual previous block's hash
      if (currentBlock.previousHash != previousBlock.hash) {
        print('Block ${currentBlock.index} has been tampered with (previous hash mismatch).');
        return false;
      }
    }
    print('Blockchain is valid.');
    return true;
  }

  // For demonstration: replace local chain with a longer valid chain received from another "node"
  void replaceChain(List<Block> newChain) {
    if (newChain.length <= chain.length) {
      print('Received chain is not longer than current chain. Not replacing.');
      return;
    }
    // Temporarily set the chain to the new one to validate it
    List<Block> tempChain = chain;
    chain = newChain;

    if (!isChainValid()) {
      print('Received chain is invalid. Not replacing.');
      chain = tempChain; // Revert to original chain
      return;
    }

    print('Replacing chain with new, longer, valid chain.');
    chain = newChain;
    pendingTransactions = []; // Clear pending transactions as they might be included in the new chain
  }
}
