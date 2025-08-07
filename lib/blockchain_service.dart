// lib/blockchain_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:barterchain/core/blockchain/blockchain.dart';
import 'package:barterchain/core/blockchain/block.dart';
import 'package:barterchain/core/blockchain/transaction.dart';

// This service acts as the bridge between our local Blockchain instance
// and Firestore, simulating the "broadcast" and "reception" of blocks
// among different app instances acting as nodes.
class BlockchainService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Blockchain _localBlockchain;
  final String _appId;

  final StreamController<Blockchain> _blockchainUpdateController =
      StreamController<Blockchain>.broadcast();
  Stream<Blockchain> get blockchainUpdates => _blockchainUpdateController.stream;

  BlockchainService(this._firestore, this._auth, this._localBlockchain, this._appId) {
    _listenForRemoteBlocks();
  }

  String get userId => _auth.currentUser?.uid ?? 'anonymous_user_${_appId.substring(0, 8)}';

  CollectionReference get _blockchainCollection {
    return _firestore.collection('artifacts')
                     .doc(_appId)
                     .collection('public')
                     .doc('blockchain')
                     .collection('blocks');
  }

  void _listenForRemoteBlocks() {
    _blockchainCollection.orderBy('index', descending: false).snapshots().listen(
      (snapshot) {
        if (snapshot.docs.isEmpty && _localBlockchain.chain.length == 1) {
          return;
        }

        List<Block> remoteChain = snapshot.docs.map((doc) {
          try {
            return Block.fromJson(doc.data() as Map<String, dynamic>);
          } catch (e) {
            // Log error or handle corrupted data
            return null;
          }
        }).whereType<Block>().toList(); // Filter out nulls from parsing errors

        if (remoteChain.length > _localBlockchain.chain.length) {
          _localBlockchain.replaceChain(remoteChain);
          _blockchainUpdateController.add(_localBlockchain);
        }
      },
      onError: (error) {
        // Log error
      },
    );
  }

  Future<void> broadcastBlock(Block block) async {
    try {
      await _blockchainCollection.doc(block.index.toString()).set(block.toJson());
    } catch (e) {
      // Log error
    }
  }

  // The method now accepts a strongly-typed Transaction object.
  Future<void> addTransactionAndMine(Transaction transaction) async {
    _localBlockchain.addTransaction(transaction);
    final Block newBlock = _localBlockchain.minePendingTransactions();

    // Only broadcast if a new block was actually mined
    if (newBlock.index > _localBlockchain.latestBlock.index || _localBlockchain.chain.length == 1) {
       await broadcastBlock(newBlock);
    }

    _blockchainUpdateController.add(_localBlockchain);
  }

  void dispose() {
    _blockchainUpdateController.close();
  }
}