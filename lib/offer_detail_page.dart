// lib/offer_detail_page.dart
import 'package:flutter/material.dart';
import 'package:barterchain/browse_offers_page.dart'; // Import to use the Offer class
import 'package:barterchain/chat_page.dart'; // Import the new chat page

class OfferDetailPage extends StatelessWidget {
  final Offer offer; // The offer object to display

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
          // Using a Card for a well-defined, visually appealing container
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Make the column take minimum space
              children: <Widget>[
                // Section for what the proposer has
                Text(
                  'What I Have:',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  offer.have,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(height: 30, thickness: 1, color: Colors.white12), // Visual separator

                // Section for what the proposer wants
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

                // Proposer information (mocked for now)
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

                // Action buttons for the offer
                Center(
                  child: Wrap(
                    spacing: 12.0, // Horizontal space between buttons
                    runSpacing: 12.0, // Vertical space between buttons if they wrap
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to the ChatPage to propose a counter-offer
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
                        onPressed: () {
                          // TODO: Implement logic to accept offer (blockchain interaction)
                          print('Accept Offer ID: ${offer.id}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Initiating contract for ${offer.proposerId}\'s offer...'),
                              backgroundColor: Colors.green[700],
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              margin: const EdgeInsets.all(16.0),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700], // Distinct color for acceptance
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
