// lib/help_support_page.dart
import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Barterchain Support',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Here you can find answers to common questions and get assistance with using the Barterchain app. Remember, the system is designed for direct, trust-based exchange, secured by the immutable ledger.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          // FAQ Section
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ExpansionTile(
              title: Text(
                'Frequently Asked Questions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              children: <Widget>[
                ListTile(
                  title: Text(
                    'What is a "Trust Score"?',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  subtitle: Text(
                    'Your Trust Score is a cumulative measure of your reliability within the Barterchain network, based on successfully completed barters and peer reviews. A higher score indicates a more dependable exchange partner.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ListTile(
                  title: Text(
                    'How are disputes resolved?',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  subtitle: Text(
                    'In the event of a dispute, a decentralized arbitration process involving a randomly selected, reputation-weighted panel of users will review the contract and evidence to reach a consensus, which is then recorded on the blockchain.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ListTile(
                  title: Text(
                    'Is my data private?',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  subtitle: Text(
                    'While barter contracts are publicly verifiable on the blockchain, personal identifying information is kept private. Only your user ID and transaction history (without direct links to your real-world identity) are visible.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          // Contact Support
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Support',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'If you cannot find an answer to your question, please reach out to our support team.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement email or in-app support chat
                      print('Contact Support button pressed');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Opening support channel... (Feature not fully implemented)'),
                          backgroundColor: Colors.grey[800],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: const EdgeInsets.all(16.0),
                        ),
                      );
                    },
                    icon: const Icon(Icons.email, color: Colors.white),
                    label: const Text('Email Support'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
