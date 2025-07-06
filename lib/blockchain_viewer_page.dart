import 'package:flutter/material.dart';
import '../core/blockchain/blockchain.dart';
import '../core/blockchain/block.dart';

class BlockchainViewerPage extends StatefulWidget {
  final Blockchain blockchain;

  const BlockchainViewerPage({super.key, required this.blockchain});

  @override
  State<BlockchainViewerPage> createState() => _BlockchainViewerPageState();
}

class _BlockchainViewerPageState extends State<BlockchainViewerPage> {
  late List<Block> _chain;

  @override
  void initState() {
    super.initState();
    _chain = widget.blockchain.chain;
  }

  void _mine() {
    setState(() {
      widget.blockchain.mineBlock();
      _chain = widget.blockchain.chain;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local Blockchain Viewer')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mine,
        icon: const Icon(Icons.gavel),
        label: const Text('Mine Block'),
      ),
      body: ListView.builder(
        itemCount: _chain.length,
        itemBuilder: (context, index) {
          final block = _chain[index];
          return ExpansionTile(
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
              ...block.transactions.map((tx) => ListTile(
                    title: Text('Transaction: ${tx.type.name}'),
                    subtitle: Text(tx.data.toString()),
                  )),
            ],
          );
        },
      ),
    );
  }
}
