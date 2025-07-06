// lib/browse_offers_page.dart
import 'package:flutter/material.dart';
import 'package:barterchain/offer_detail_page.dart';
import 'package:barterchain/models.dart'; // Import the Offer model
import 'package:barterchain/main.dart'; // Import main.dart to access global blockchainService
import 'package:barterchain/block_blockchain.dart'; // Import Block for StreamBuilder type

class BrowseOffersPage extends StatefulWidget {
  const BrowseOffersPage({super.key});

  @override
  State<BrowseOffersPage> createState() => _BrowseOffersPageState();
}

class _BrowseOffersPageState extends State<BrowseOffersPage> {
  List<Offer> _availableOffers = [];

  @override
  void initState() {
    super.initState();
    // Listen to blockchain updates to refresh offers
    blockchainService.blockchainUpdates.listen((blockchain) {
      _updateOffers(blockchain);
    });
    // Initialize offers from the current blockchain state
    _updateOffers(localBlockchain);
  }

  void _updateOffers(Blockchain blockchain) {
    List<Offer> offers = [];
    // A map to keep track of the latest status of each offer
    Map<String, Offer> latestOffers = {};

    for (var block in blockchain.chain) {
      for (var transaction in block.transactions) {
        if (transaction['type'] == 'offer_creation') {
          final offer = Offer.fromJson(transaction['offer']);
          latestOffers[offer.id] = offer; // Add or update with the initial offer
        } else if (transaction['type'] == 'offer_acceptance' ||
                   transaction['type'] == 'contract_completion' ||
                   transaction['type'] == 'contract_dispute') {
          final String offerId = transaction['offer_id'];
          if (latestOffers.containsKey(offerId)) {
            // Update the status of the existing offer
            final currentOffer = latestOffers[offerId]!;
            latestOffers[offerId] = Offer(
              id: currentOffer.id,
              have: currentOffer.have,
              want: currentOffer.want,
              proposerId: currentOffer.proposerId,
              status: transaction['status_update'] ?? currentOffer.status,
            );
          }
        }
      }
    }

    // Filter for 'open' offers to display
    offers = latestOffers.values.where((offer) => offer.status == 'open').toList();

    if (mounted) { // Guard with mounted check
      setState(() {
        _availableOffers = offers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Barter Offers'),
      ),
      body: StreamBuilder<Blockchain>(
        stream: blockchainService.blockchainUpdates,
        initialData: localBlockchain, // Provide initial data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.redAccent)));
          }
          // Data is available, _updateOffers has already been called by the listener
          // or initialData. So we just use _availableOffers.
          if (_availableOffers.isEmpty) {
            return Center(
              child: Text(
                'No offers yet. The market is truly free.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _availableOffers.length,
            itemBuilder: (context, index) {
              final offer = _availableOffers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'I have:',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer.have,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'I want:',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer.want,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OfferDetailPage(offer: offer),
                                  ),
                                );
                              },
                              child: const Text('View Details'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                // TODO: Implement logic to accept offer (would involve smart contract interaction)
                                // print('Accept Offer ID: ${offer.id}'); // Avoid print
                                final String accepterId = blockchainService.userId;
                                if (accepterId == offer.proposerId) {
                                  if (mounted) { // Guard with mounted check
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Cannot accept your own offer, you narcissist.'),
                                        backgroundColor: Colors.red[700],
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        margin: const EdgeInsets.all(16.0),
                                      ),
                                    );
                                  }
                                  return;
                                }

                                try {
                                  await blockchainService.addTransactionAndMine({
                                    'type': 'offer_acceptance',
                                    'offer_id': offer.id,
                                    'proposer_id': offer.proposerId,
                                    'accepter_id': accepterId,
                                    'timestamp': DateTime.now().toIso8601String(),
                                    'status_update': 'accepted', // Mark as accepted
                                  });

                                  if (mounted) { // Guard with mounted check
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Offer accepted! Initiating contract for ${offer.proposerId}...'),
                                        backgroundColor: Colors.green[700],
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        margin: const EdgeInsets.all(16.0),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  // print('Error accepting offer: $e'); // Avoid print
                                  if (mounted) { // Guard with mounted check
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to accept offer: $e'),
                                        backgroundColor: Colors.red[700],
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        margin: const EdgeInsets.all(16.0),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                              ),
                              child: const Text('Accept Offer'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}