// lib/contract_management_page.dart
import 'package:flutter/material.dart';
import 'package:barterchain/models.dart'; // Import the Offer model
import 'package:barterchain/main.dart'; // Import main.dart to access global blockchainService
import 'package:barterchain/review_rating_page.dart'; // Import the review page

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

    // Determine the counterparty ID for review
    // This logic needs to be robust. For now, assuming if current user is proposer,
    // the other party is the accepter (which isn't explicitly in Offer model).
    // If not proposer, then proposer is the counterparty.
    // A proper Contract model would have both proposerId and accepterId.
    final String? counterpartyForReview = blockchainService.userId == contract.proposerId
        ? null // Cannot review self, needs actual accepter ID
        : contract.proposerId;


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

                Center(
                  child: Wrap(
                    spacing: 12.0,
                    runSpacing: 12.0,
                    children: [
                      if (contract.status == 'accepted')
                        ElevatedButton(
                          onPressed: () async {
                            // print('Marking contract ${contract.id} as completed.'); // Avoid print
                            try {
                              await blockchainService.addTransactionAndMine({
                                'type': 'contract_completion',
                                'contract_id': contract.id,
                                'proposer_id': contract.proposerId,
                                'accepter_id': blockchainService.userId, // Assuming current user is accepter
                                'timestamp': DateTime.now().toIso8601String(),
                                'status_update': 'completed',
                              });
                              if (mounted) { // Guard with mounted check
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Contract ${contract.id} marked as completed.'),
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
                              // print('Error completing contract: $e'); // Avoid print
                              if (mounted) { // Guard with mounted check
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to complete contract: $e'),
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
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: const Text('Mark as Completed'),
                        ),
                      if (contract.status == 'accepted' || contract.status == 'disputed')
                        ElevatedButton(
                          onPressed: () async {
                            // print('Initiating dispute for contract ${contract.id}.'); // Avoid print
                            try {
                              await blockchainService.addTransactionAndMine({
                                'type': 'contract_dispute',
                                'contract_id': contract.id,
                                'proposer_id': contract.proposerId,
                                'disputer_id': blockchainService.userId,
                                'timestamp': DateTime.now().toIso8601String(),
                                'status_update': 'disputed',
                              });
                              if (mounted) { // Guard with mounted check
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Contract ${contract.id} marked as disputed.'),
                                    backgroundColor: Colors.red[700],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    margin: const EdgeInsets.all(16.0),
                                  ),
                                );
                              }
                            } catch (e) {
                              // print('Error disputing contract: $e'); // Avoid print
                              if (mounted) { // Guard with mounted check
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to dispute contract: $e'),
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
                            backgroundColor: Colors.red[700],
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: const Text('Dispute Contract'),
                        ),
                      if (contract.status == 'completed' && counterpartyForReview != null && counterpartyForReview != blockchainService.userId)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewRatingPage(
                                  barterId: contract.id,
                                  counterpartyId: counterpartyForReview,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[700], // Distinct color for review
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: const Text('Leave Review'),
                        ),
                      if (contract.status == 'completed' || contract.status == 'disputed')
                        ElevatedButton(
                          onPressed: () {
                            // print('Viewing immutable record for contract ${contract.id}.'); // Avoid print
                            if (mounted) { // Guard with mounted check
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Accessing immutable record for ${contract.id}...'),
                                  backgroundColor: Colors.grey[800],
                                  behavior: SnackBarBehavior.floating,
                                  shape: const RoundedRectangleBorder( // Added const
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  margin: const EdgeInsets.all(16.0),
                                ),
                              );
                            }
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