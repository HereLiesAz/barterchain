import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'transaction.dart';

class Block {
  final int index;
  final DateTime timestamp;
  final List<Transaction> transactions;
  final String previousHash;
  final String hash;

  Block({
    required this.index,
    required this.timestamp,
    required this.transactions,
    required this.previousHash,
    required this.hash,
  });

  factory Block.genesis() {
    // The hash of the genesis block is often hardcoded or simple.
    // For this implementation, we'll calculate it like any other block, but with fixed inputs.
    final genesisTimestamp = DateTime.fromMillisecondsSinceEpoch(0);
    final genesisTransactions = <Transaction>[];
    final genesisPreviousHash = '0';

    String hash = Block.calculateHash(0, genesisTimestamp, genesisPreviousHash, genesisTransactions);

    return Block(
      index: 0,
      timestamp: genesisTimestamp,
      transactions: genesisTransactions,
      previousHash: genesisPreviousHash,
      hash: hash,
    );
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'timestamp': timestamp.toIso8601String(),
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'previousHash': previousHash,
        'hash': hash,
      };

  factory Block.fromJson(Map<String, dynamic> json) => Block(
        index: json['index'],
        timestamp: DateTime.parse(json['timestamp']),
        transactions: (json['transactions'] as List)
            .map((t) => Transaction.fromJson(t))
            .toList(),
        previousHash: json['previousHash'],
        hash: json['hash'],
      );

  // Static method to calculate hash, making it reusable and stateless
  static String calculateHash(int index, DateTime timestamp, String previousHash, List<Transaction> transactions) {
    final input = jsonEncode({
      'index': index,
      'timestamp': timestamp.toIso8601String(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'previousHash': previousHash,
    });
    return sha256.convert(utf8.encode(input)).toString();
  }

  // A simple method to verify the block's own integrity
  bool isHashValid() {
    return hash == calculateHash(index, timestamp, previousHash, transactions);
  }
}
