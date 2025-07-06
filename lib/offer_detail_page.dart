// lib/offer_detail_page.dart
import 'package:flutter/material.dart';
import 'package:barterchain/models.dart'; // Import the Offer model
import 'package:barterchain/chat_page.dart';
import 'package:barterchain/main.dart'; // Import main.dart to access global blockchainService

class OfferDetailPage extends StatelessWidget {
  final Offer offer;

  const OfferDetailPage({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'What I Have:',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  offer.have,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(height: 30, thickness: 1, color: Colors.white12),

                Text(
                  'What I Want:',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  offer.want,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(height: 30, thickness: 1, color: Colors.white12),

                Text(
                  'Proposer:',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white54),
                ),
                const SizedBox(height: 4),
                Text(
                  offer.proposerId,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),

                Center(
                  child: Wrap(
                    spacing: 12.0,
                    runSpacing: 12.0,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(recipientId: offer.proposerId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text('Propose Counter-Offer'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // print('Accept Offer ID: ${offer.id}'); // Avoid print
                          final String accepterId = blockchainService.userId;
                          if (accepterId == offer.proposerId) {
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
                          } catch (e) {
                            // print('Error accepting offer: $e'); // Avoid print
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text('Accept Offer'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}