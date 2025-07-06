// lib/browse_offers_page.dart
import 'package:flutter/material.dart';
import 'package:barterchain/offer_detail_page.dart'; // Import the new detail page

// This is a placeholder for a real Offer data model.
// In a production app, this would likely come from a blockchain or database.
class Offer {
  final String id;
  final String have;
  final String want;
  final String proposerId; // Placeholder for user ID
  final String status; // e.g., 'open', 'accepted', 'completed', 'disputed'

  Offer({
    required this.id,
    required this.have,
    required this.want,
    required this.proposerId,
    this.status = 'open',
  });
}

class BrowseOffersPage extends StatefulWidget {
  const BrowseOffersPage({super.key});

  @override
  State<BrowseOffersPage> createState() => _BrowseOffersPageState();
}

class _BrowseOffersPageState extends State<BrowseOffersPage> {
  // Mock data for demonstration. In a real app, this would be fetched.
  final List<Offer> _offers = [
    Offer(
      id: '1',
      have: '3 hours of web design (front-end)',
      want: 'A custom-made ceramic mug or a hand-knitted scarf',
      proposerId: 'user_alpha',
    ),
    Offer(
      id: '2',
      have: 'Vintage record player (working condition)',
      want: 'A set of gardening tools or organic vegetables for a month',
      proposerId: 'user_beta',
    ),
    Offer(
      id: '3',
      have: 'Help moving furniture (2 hours, strong back)',
      want: 'Home-cooked meal for two or a good book recommendation',
      proposerId: 'user_gamma',
    ),
    Offer(
      id: '4',
      have: 'Expert advice on existential dread',
      want: 'The meaning of life, or at least a decent cup of coffee',
      proposerId: 'user_delta',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Barter Offers'),
      ),
      body: _offers.isEmpty
          ? Center(
              child: Text(
                'No offers yet. The market is truly free.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _offers.length,
              itemBuilder: (context, index) {
                final offer = _offers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Display what the user has
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
                        // Display what the user wants
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
                        // Action buttons for the offer
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Wrap(
                            spacing: 8.0, // Space between buttons
                            runSpacing: 8.0, // Space between rows of buttons
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to the OfferDetailPage, passing the selected offer
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
                                onPressed: () {
                                  // TODO: Implement logic to accept offer (would involve smart contract interaction)
                                  print('Accept Offer ID: ${offer.id}');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Attempting to accept offer from ${offer.proposerId}...'),
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
                                  backgroundColor: Colors.green[700], // A slightly different color for 'accept'
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
            ),
    );
  }
}
