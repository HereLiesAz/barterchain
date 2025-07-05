// lib/contract_management_page.dart
import 'package:flutter/material.dart';
import 'package:barterchain/browse_offers_page.dart'; // To use the Offer class

class ContractManagementPage extends StatelessWidget {
  final Offer contract; // The offer that has become a contract

  const ContractManagementPage({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    // Determine the color for the status text
    Color statusColor;
    switch (contract.status) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contract Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Contract ID:',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white54),
                ),
                const SizedBox(height: 4),
                Text(
                  contract.id,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Divider(height: 30, thickness: 1, color: Colors.white12),

                Text(
                  'Your Obligation:',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  contract.have,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(height: 30, thickness: 1, color: Colors.white12),

                Text(
                  'Your Entitlement:',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  contract.want,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(height: 30, thickness: 1, color: Colors.white12),

                Text(
                  'Counterparty:',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white54),
                ),
                const SizedBox(height: 4),
                Text(
                  contract.proposerId, // In a real scenario, this would be the other party's ID
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),

                Text(
                  'Current Status:',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white54),
                ),
                const SizedBox(height: 4),
                Text(
                  contract.status.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 30),

                // Action buttons based on contract status
                Center(
                  child: Wrap(
                    spacing: 12.0,
                    runSpacing: 12.0,
                    children: [
                      if (contract.status == 'accepted')
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implement logic to mark contract as completed
                            print('Marking contract ${contract.id} as completed.');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Attempting to complete contract ${contract.id}...'),
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
                            backgroundColor: Colors.green[700],
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: const Text('Mark as Completed'),
                        ),
                      if (contract.status == 'accepted' || contract.status == 'disputed')
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implement dispute resolution logic
                            print('Initiating dispute for contract ${contract.id}.');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Initiating dispute for contract ${contract.id}...'),
                                backgroundColor: Colors.red[700],
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                margin: const EdgeInsets.all(16.0),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: const Text('Dispute Contract'),
                        ),
                      if (contract.status == 'completed' || contract.status == 'disputed')
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implement logic to view immutable transaction record
                            print('Viewing immutable record for contract ${contract.id}.');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Accessing immutable record for ${contract.id}...'),
                                backgroundColor: Colors.grey[800],
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                margin: const EdgeInsets.all(16.0),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: const Text('View Immutable Record'),
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
