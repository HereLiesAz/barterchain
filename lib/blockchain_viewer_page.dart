// lib/blockchain_viewer_page.dart
import 'package:flutter/material.dart';
import 'package:barterchain/main.dart'; // To access global blockchainService and localBlockchain
import 'package:barterchain/block_blockchain.dart'; // For Block and Blockchain types

class BlockchainViewerPage extends StatefulWidget {
  const BlockchainViewerPage({super.key});

  @override
  State<BlockchainViewerPage> createState() => _BlockchainViewerPageState();
}

class _BlockchainViewerPageState extends State<BlockchainViewerPage> {
  Blockchain _currentBlockchain = localBlockchain;

  @override
  void initState() {
    super.initState();
    // Listen for updates to the blockchain
    blockchainService.blockchainUpdates.listen((blockchain) {
      if (mounted) { // Guard with mounted check
        setState(() {
          _currentBlockchain = blockchain;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blockchain Ledger'),
      ),
      body: _currentBlockchain.chain.isEmpty
          ? Center(
              child: Text(
                'The ledger is empty. Propose a barter to begin.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _currentBlockchain.chain.length,
              itemBuilder: (context, index) {
                final block = _currentBlockchain.chain[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Block #${block.index}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Timestamp: ${block.timestamp.toLocal().toString().split('.')[0]}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hash: ${block.hash.substring(0, 10)}...', // Show truncated hash
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Previous Hash: ${block.previousHash.substring(0, 10)}...', // Show truncated hash
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Transactions (${block.transactions.length}):',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        // Display transactions within the block
                        if (block.transactions.isEmpty)
                          Text(
                            'No transactions in this block.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ...block.transactions.map((tx) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                            child: Text(
                              '• Type: ${tx['type']} | ID: ${tx['offer']?['id']?.substring(0, 6) ?? tx['contract_id']?.substring(0, 6) ?? 'N/A'} | Status: ${tx['status_update'] ?? 'N/A'}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}