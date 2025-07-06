// lib/my_barters_page.dart
import 'package:flutter/material.dart';
import 'package:barterchain/models.dart'; // Import the Offer model
import 'package:barterchain/contract_management_page.dart';
import 'package:barterchain/main.dart'; // Import main.dart to access global blockchainService
import 'package:barterchain/block_blockchain.dart'; // Import Block for StreamBuilder type

class MyBartersPage extends StatefulWidget {
  const MyBartersPage({super.key});

  @override
  State<MyBartersPage> createState() => _MyBartersPageState();
}

class _MyBartersPageState extends State<MyBartersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Offer> _myOffers = [];
  List<Offer> _barterHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen to blockchain updates to refresh my offers and history
    blockchainService.blockchainUpdates.listen((blockchain) {
      _updateMyBarters(blockchain);
    });
    // Initialize my offers and history from the current blockchain state
    _updateMyBarters(localBlockchain);
  }

  void _updateMyBarters(Blockchain blockchain) {
    final String currentUserId = blockchainService.userId;
    Map<String, Offer> myOffersMap = {}; // Use map to easily update status
    Map<String, Offer> barterHistoryMap = {}; // Use map to easily update status

    for (var block in blockchain.chain) {
      for (var transaction in block.transactions) {
        if (transaction['type'] == 'offer_creation') {
          final offer = Offer.fromJson(transaction['offer']);
          if (offer.proposerId == currentUserId) {
            myOffersMap[offer.id] = offer; // Track my own offers
          }
        } else if (transaction['type'] == 'offer_acceptance' ||
                   transaction['type'] == 'contract_completion' ||
                   transaction['type'] == 'contract_dispute') {
          final String offerId = transaction['offer_id'];
          final String proposerId = transaction['proposer_id'];
          final String accepterId = transaction['accepter_id'];
          final String status = transaction['status_update'] ?? 'accepted';

          // If this is my offer being accepted OR I am accepting someone else's offer
          if (proposerId == currentUserId || accepterId == currentUserId) {
            // Find the original offer details from the blockchain
            Offer? originalOffer;
            for (var b in blockchain.chain) {
              for (var t in b.transactions) {
                if (t['type'] == 'offer_creation' && t['offer']['id'] == offerId) {
                  originalOffer = Offer.fromJson(t['offer']);
                  break;
                }
              }
              if (originalOffer != null) break;
            }

            if (originalOffer != null) {
              final contract = Offer(
                id: originalOffer.id,
                have: originalOffer.have,
                want: originalOffer.want,
                proposerId: originalOffer.proposerId,
                status: status,
              );
              barterHistoryMap[contract.id] = contract; // Add/update in history
              myOffersMap.remove(contract.id); // Remove from 'My Offers' if it's now a contract
            }
          }
        }
      }
    }

    if (mounted) { // Guard with mounted check
      setState(() {
        _myOffers = myOffersMap.values.toList();
        _barterHistory = barterHistoryMap.values.toList();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Barters'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Offers'),
            Tab(text: 'Barter History'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: My Offers
          _myOffers.isEmpty
              ? Center(
                  child: Text(
                    'No active offers. Time to propose some value.',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _myOffers.length,
                  itemBuilder: (context, index) {
                    final offer = _myOffers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('You offered:', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text(offer.have, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 12),
                            Text('You wanted:', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text(offer.want, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO: Implement logic to edit offer
                                      // print('Edit Offer ID: ${offer.id}'); // Avoid print
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Editing offer: ${offer.id}'),
                                          backgroundColor: Colors.grey[800],
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          margin: const EdgeInsets.all(16.0),
                                        ),
                                      );
                                    },
                                    child: const Text('Edit Offer'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO: Implement logic to cancel offer
                                      // print('Cancel Offer ID: ${offer.id}'); // Avoid print
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Cancelling offer: ${offer.id}'),
                                          backgroundColor: Colors.red[700],
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          margin: const EdgeInsets.all(16.0),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
                                    child: const Text('Cancel Offer'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

          // Tab 2: Barter History
          _barterHistory.isEmpty
              ? Center(
                  child: Text(
                    'No completed barters yet. The past is unwritten.',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _barterHistory.length,
                  itemBuilder: (context, index) {
                    final transaction = _barterHistory[index];
                    Color statusColor;
                    switch (transaction.status) {
                      case 'open':
                        statusColor = Colors.blueAccent;
                        break;
                      case 'accepted':
                        statusColor = Colors.orangeAccent;
                        break;
                      case 'completed':
                        statusColor = Colors.greenAccent;
                        break;
                      case 'disputed':
                        statusColor = Colors.redAccent;
                        break;
                      default:
                        statusColor = Colors.white70;
                    }
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('You gave:', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text(transaction.have, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 12),
                            Text('You received:', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text(transaction.want, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 12),
                            Text(
                              'Status: ${transaction.status.toUpperCase()}',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement logic to view transaction details or dispute resolution
                                  // print('Manage Contract ID: ${transaction.id}'); // Avoid print
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ContractManagementPage(contract: transaction),
                                    ),
                                  );
                                },
                                child: const Text('Manage Contract'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}