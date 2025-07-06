import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'transaction.dart';

class Block {
  final int index;
  final DateTime timestamp;
  final List<Transaction> transactions;
  final String previousHash;
  final String hash;
  final int nonce;

  Block({
    required this.index,
    required this.timestamp,
    required this.transactions,
    required this.previousHash,
    required this.hash,
    required this.nonce,
  });

  factory Block.genesis() {
    return Block(
      index: 0,
      timestamp: DateTime.now(),
      transactions: [],
      previousHash: '0',
      hash: '',
      nonce: 0,
    ).copyWith(hash: 'GENESIS_HASH');
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'timestamp': timestamp.toIso8601String(),
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'previousHash': previousHash,
        'hash': hash,
        'nonce': nonce,
      };

  factory Block.fromJson(Map<String, dynamic> json) => Block(
        index: json['index'],
        timestamp: DateTime.parse(json['timestamp']),
        transactions: (json['transactions'] as List)
            .map((t) => Transaction.fromJson(t))
            .toList(),
        previousHash: json['previousHash'],
        hash: json['hash'],
        nonce: json['nonce'],
      );

  String computeHash() {
    final input = jsonEncode({
      'index': index,
      'timestamp': timestamp.toIso8601String(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'previousHash': previousHash,
      'nonce': nonce,
    });
    return sha256.convert(utf8.encode(input)).toString();
  }

  Block copyWith({String? hash}) {
    return Block(
      index: index,
      timestamp: timestamp,
      transactions: transactions,
      previousHash: previousHash,
      hash: hash ?? this.hash,
      nonce: nonce,
    );
  }
}
