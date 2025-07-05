// lib/my_barters_page.dart
import 'package:flutter/material.dart';
import 'package:barterchain/browse_offers_page.dart'; // To use the Offer class

class MyBartersPage extends StatefulWidget {
  const MyBartersPage({super.key});

  @override
  State<MyBartersPage> createState() => _MyBartersPageState();
}

class _MyBartersPageState extends State<MyBartersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for user's offers and history
  final List<Offer> _myOffers = [
    Offer(
      id: 'my_offer_1',
      have: 'My old bicycle (still rides)',
      want: 'A month of guitar lessons',
      proposerId: 'user_current', // Assuming this is the current user
      status: 'open',
    ),
    Offer(
      id: 'my_offer_2',
      have: 'Custom digital portrait',
      want: 'A vintage fountain pen',
      proposerId: 'user_current',
      status: 'open',
    ),
  ];

  final List<Offer> _barterHistory = [
    Offer(
      id: 'history_1',
      have: 'My hand-knitted scarf',
      want: 'A freshly baked pie',
      proposerId: 'user_current',
      status: 'completed',
    ),
    Offer(
      id: 'history_2',
      have: 'Help setting up a home network',
      want: 'A good bottle of wine',
      proposerId: 'user_current',
      status: 'completed',
    ),
    Offer(
      id: 'history_3',
      have: 'My existential dread',
      want: 'A decent cup of coffee',
      proposerId: 'user_current',
      status: 'disputed', // Example of a disputed transaction
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                                      print('Edit Offer ID: ${offer.id}');
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
                                      print('Cancel Offer ID: ${offer.id}');
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
                                    color: transaction.status == 'completed' ? Colors.green : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement logic to view transaction details or dispute resolution
                                  print('View History Item ID: ${transaction.id}');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Viewing history for: ${transaction.id}'),
                                      backgroundColor: Colors.grey[800],
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      margin: const EdgeInsets.all(16.0),
                                    ),
                                  );
                                },
                                child: const Text('View Record'),
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
