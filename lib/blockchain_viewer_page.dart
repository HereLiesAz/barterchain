import 'dart:async';
import 'package:flutter/material.dart';
import 'package:barterchain/main.dart'; // To get access to the global blockchainService
import 'package:barterchain/core/blockchain/blockchain.dart';
import 'package:barterchain/core/blockchain/block.dart';
import 'package:barterchain/core/blockchain/transaction.dart';

// A dedicated widget to format and display transaction payloads neatly.
class TransactionPayloadViewer extends StatelessWidget {
  final TransactionPayload payload;

  const TransactionPayloadViewer({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    final data = payload.toJson();
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((entry) {
          return Text.rich(
            TextSpan(
              style: textTheme.bodyMedium,
              children: [
                TextSpan(text: '${entry.key}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: entry.value.toString()),
              ]
            )
          );
        }).toList(),
      ),
    );
  }
}

class BlockchainViewerPage extends StatefulWidget {
  // No longer takes a blockchain in the constructor, uses the global one.
  const BlockchainViewerPage({super.key});

  @override
  State<BlockchainViewerPage> createState() => _BlockchainViewerPageState();
}

class _BlockchainViewerPageState extends State<BlockchainViewerPage> {
  late Blockchain _blockchain;
  late StreamSubscription<Blockchain> _blockchainSubscription;

  @override
  void initState() {
    super.initState();
    // Initialize with the current state of the global blockchain
    _blockchain = localBlockchain;
    // Listen for updates from the service
    _blockchainSubscription = blockchainService.blockchainUpdates.listen((updatedBlockchain) {
      if (mounted) {
        setState(() {
          _blockchain = updatedBlockchain;
        });
      }
    });
  }

  @override
  void dispose() {
    // Clean up the subscription to avoid memory leaks
    _blockchainSubscription.cancel();
    super.dispose();
  }

  // Mine pending transactions using the service
  void _mine() {
    // This will trigger the service to mine, broadcast, and then update the stream
    blockchainService.addTransactionAndMine(
      Transaction(
        type: TransactionType.createOffer, // Example transaction for manual mining
        payload: CreateOfferPayload(
          proposerId: blockchainService.userId,
          have: 'Debug Coin',
          want: 'Test Coverage',
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use a local variable for the chain to ensure consistency during the build
    final chain = _blockchain.chain;

    return Scaffold(
      appBar: AppBar(title: const Text('Local Blockchain Viewer')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mine,
        icon: const Icon(Icons.gavel),
        label: const Text('Mine Debug Block'),
      ),
      body: ListView.builder(
        // Reverse the list to show the newest block at the top
        itemCount: chain.length,
        itemBuilder: (context, index) {
          final block = chain[chain.length - 1 - index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ExpansionTile(
              title: Text('Block ${block.index}'),
              subtitle: Text('Hash: ${block.hash.substring(0, 16)}...'),
              children: [
                ListTile(
                  title: const Text('Previous Hash'),
                  subtitle: Text(block.previousHash),
                ),
                ListTile(
                  title: const Text('Timestamp'),
                  subtitle: Text(block.timestamp.toIso8601String()),
                ),
                const Divider(),
                if (block.transactions.isEmpty)
                  const ListTile(title: Text('No Transactions'))
                else
                  ...block.transactions.map((tx) {
                    return ExpansionTile(
                      title: Text('Transaction: ${tx.type.name}'),
                      subtitle: Text('ID: ${tx.id.substring(0, 16)}...'),
                      children: [
                        TransactionPayloadViewer(payload: tx.payload),
                      ],
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
