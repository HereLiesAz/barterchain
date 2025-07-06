import 'block.dart';
import 'transaction.dart';

class Blockchain {
  final List<Block> _chain = [Block.genesis()];
  final List<Transaction> _pending = [];

  List<Block> get chain => List.unmodifiable(_chain);

  void addTransaction(Transaction tx) {
    _pending.add(tx);
  }

  Block mineBlock() {
    final prev = _chain.last;
    final block = Block(
      index: prev.index + 1,
      timestamp: DateTime.now(),
      transactions: List.from(_pending),
      previousHash: prev.hash,
      hash: '',
      nonce: 0,
    );

    final mined = _mine(block);
    _chain.add(mined);
    _pending.clear();
    return mined;
  }

  Block _mine(Block block) {
    int nonce = 0;
    String hash;
    do {
      final candidate = block.copyWith(hash: '');
      final input = candidate.computeHash().replaceAll('\n', '');
      hash = input;
      nonce++;
    } while (!hash.startsWith('0000')); // Proof-of-concept PoW

    return block.copyWith(hash: hash);
  }

  bool isValid() {
    for (int i = 1; i < _chain.length; i++) {
      final current = _chain[i];
      final previous = _chain[i - 1];

      if (current.previousHash != previous.hash) return false;
      if (current.computeHash() != current.hash) return false;
    }
    return true;
  }

  void replaceChain(List<Block> newChain) {
    if (newChain.length > _chain.length && _validate(newChain)) {
      _chain
        ..clear()
        ..addAll(newChain);
    }
  }

  bool _validate(List<Block> chain) {
    for (int i = 1; i < chain.length; i++) {
      final current = chain[i];
      final previous = chain[i - 1];

      if (current.previousHash != previous.hash) return false;
      if (current.computeHash() != current.hash) return false;
    }
    return true;
  }
}
