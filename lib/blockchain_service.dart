// lib/blockchain_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:barterchain/block_blockchain.dart';
import 'dart:async';
import 'dart:convert'; // For JSON encoding/decoding

// This service acts as the bridge between our local Blockchain instance
// and Firestore, simulating the "broadcast" and "reception" of blocks
// among different app instances acting as nodes.
class BlockchainService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Blockchain _localBlockchain;
  final String _appId; // The unique ID for this application instance

  // Stream controller to notify listeners about blockchain updates
  final StreamController<Blockchain> _blockchainUpdateController =
      StreamController<Blockchain>.broadcast();
  Stream<Blockchain> get blockchainUpdates => _blockchainUpdateController.stream;

  BlockchainService(this._firestore, this._auth, this._localBlockchain, this._appId) {
    _listenForRemoteBlocks();
  }

  // Gets the current user's ID. If not authenticated, generates a random one.
  // This is used for Firestore paths.
  String get userId {
    return _auth.currentUser?.uid ?? 'anonymous_user_${_appId.substring(0, 8)}';
  }

  // Firestore collection path for public blockchain data
  // /artifacts/{appId}/public/blockchain/blocks
  CollectionReference get _blockchainCollection {
    return _firestore.collection('artifacts')
                     .doc(_appId)
                     .collection('public')
                     .doc('blockchain')
                     .collection('blocks');
  }

  // Listen for new blocks broadcast by other "nodes" (app instances) via Firestore.
  void _listenForRemoteBlocks() {
    _blockchainCollection.orderBy('index', descending: false).snapshots().listen(
      (snapshot) {
        if (snapshot.docs.isEmpty && _localBlockchain.chain.length == 1 && _localBlockchain.chain.first.index == 0) {
          // If Firestore is empty and only genesis block exists locally, do nothing.
          // This prevents replacing a valid local genesis with an empty remote.
          return;
        }

        List<Block> remoteChain = [];
        for (var doc in snapshot.docs) {
          try {
            remoteChain.add(Block.fromJson(doc.data() as Map<String, dynamic>));
          } catch (e) {
            print('Error parsing remote block from Firestore: $e, data: ${doc.data()}');
            // Continue processing other blocks even if one fails
          }
        }

        // Only attempt to replace if the remote chain is potentially longer or different
        if (remoteChain.length > _localBlockchain.chain.length ||
            (remoteChain.isNotEmpty && _localBlockchain.chain.isNotEmpty &&
             remoteChain.last.hash != _localBlockchain.getLatestBlock().hash)) {
          print('Received a new chain from Firestore. Length: ${remoteChain.length}');
          _localBlockchain.replaceChain(remoteChain);
          _blockchainUpdateController.add(_localBlockchain); // Notify listeners of update
        }
      },
      onError: (error) {
        print("Error listening for remote blocks: $error");
      },
    );
  }

  // Broadcasts a newly mined block to other "nodes" via Firestore.
  Future<void> broadcastBlock(Block block) async {
    try {
      // Use set instead of add to ensure block uniqueness by ID (index)
      // This also allows for idempotent writes if a block is broadcast multiple times.
      await _blockchainCollection.doc(block.index.toString()).set(block.toJson());
      print('Block ${block.index} broadcast to Firestore.');
    } catch (e) {
      print('Error broadcasting block to Firestore: $e');
    }
  }

  // Adds a transaction to the local pending list and then mines a block.
  // This mined block is then broadcast.
  Future<void> addTransactionAndMine(Map<String, dynamic> transaction) async {
    _localBlockchain.addTransaction(transaction);
    final Block newBlock = _localBlockchain.minePendingTransactions();
    await broadcastBlock(newBlock);
    _blockchainUpdateController.add(_localBlockchain); // Notify listeners of update
  }

  // Disposes the stream controller when the service is no longer needed
  void dispose() {
    _blockchainUpdateController.close();
  }
}
