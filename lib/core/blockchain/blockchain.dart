import 'block.dart';
import 'transaction.dart';

class Blockchain {
  final List<Block> _chain;
  final List<Transaction> _pendingTransactions = [];

  Blockchain() : _chain = [Block.genesis()];

  List<Block> get chain => List.unmodifiable(_chain);
  List<Transaction> get pendingTransactions => List.unmodifiable(_pendingTransactions);

  Block get latestBlock => _chain.last;

  void addTransaction(Transaction tx) {
    _pendingTransactions.add(tx);
  }

  // This method now simply creates a block and calculates its hash, without a PoW loop.
  // This aligns with the project documentation.
  Block minePendingTransactions() {
    if (_pendingTransactions.isEmpty) {
      // In a real app, you might throw an exception or return null.
      // For this project, returning the latest block is safe if no transactions are pending.
      return latestBlock;
    }

    final newIndex = latestBlock.index + 1;
    final newTimestamp = DateTime.now();
    final newPreviousHash = latestBlock.hash;
    final transactionsToMine = List<Transaction>.from(_pendingTransactions);

    final newHash = Block.calculateHash(newIndex, newTimestamp, newPreviousHash, transactionsToMine);

    final newBlock = Block(
      index: newIndex,
      timestamp: newTimestamp,
      transactions: transactionsToMine,
      previousHash: newPreviousHash,
      hash: newHash,
    );

    _chain.add(newBlock);
    _pendingTransactions.clear();
    return newBlock;
  }

  // Validates the entire blockchain's integrity.
  bool isChainValid() {
    // Start from the second block since the first is the genesis block.
    for (int i = 1; i < _chain.length; i++) {
      final currentBlock = _chain[i];
      final previousBlock = _chain[i - 1];

      // 1. Verify the hash of the current block.
      if (!currentBlock.isHashValid()) {
        return false;
      }

      // 2. Verify the link to the previous block.
      if (currentBlock.previousHash != previousBlock.hash) {
        return false;
      }
    }
    return true;
  }

  // Replaces the current chain with a new one if it's longer and valid.
  // This is the "longest chain wins" consensus rule.
  void replaceChain(List<Block> newChain) {
    if (newChain.length <= _chain.length) {
      // The new chain is not longer, so no action is needed.
      return;
    }

    // Create a temporary blockchain to validate the new chain.
    final tempBlockchain = Blockchain();
    tempBlockchain._chain.clear();
    tempBlockchain._chain.addAll(newChain);

    if (!tempBlockchain.isChainValid()) {
      // The new chain is invalid.
      return;
    }

    // If the new chain is both longer and valid, replace the current chain.
    _chain.clear();
    _chain.addAll(newChain);
    _pendingTransactions.clear(); // Clear pending transactions as they are now part of the new chain.
  }
}
