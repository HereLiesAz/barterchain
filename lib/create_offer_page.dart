// lib/create_offer_page.dart
import 'package:flutter/material.dart';
import 'package:barterchain/main.dart'; // Import main.dart to access global blockchainService
import 'package:barterchain/models.dart'; // Import the Offer model
import 'package:uuid/uuid.dart'; // For generating unique IDs

class CreateOfferPage extends StatefulWidget {
  const CreateOfferPage({super.key});

  @override
  State<CreateOfferPage> createState() => _CreateOfferPageState();
}

class _CreateOfferPageState extends State<CreateOfferPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _haveController = TextEditingController();
  final TextEditingController _wantController = TextEditingController();
  final Uuid _uuid = const Uuid(); // Initialize UUID generator

  @override
  void dispose() {
    _haveController.dispose();
    _wantController.dispose();
    super.dispose();
  }

  Future<void> _submitOffer() async {
    if (_formKey.currentState!.validate()) {
      final String offerId = _uuid.v4(); // Generate a unique ID for the offer
      final String proposerId = blockchainService.userId; // Get current user's ID from blockchainService

      // Create an Offer object
      final Offer newOffer = Offer(
        id: offerId,
        have: _haveController.text.trim(),
        want: _wantController.text.trim(),
        proposerId: proposerId,
        status: 'open', // Initial status for a new offer
      );

      // Add the offer as a transaction to the local blockchain and broadcast it
      try {
        await blockchainService.addTransactionAndMine({
          'type': 'offer_creation',
          'offer': newOffer.toJson(), // Convert Offer object to JSON map
          'timestamp': DateTime.now().toIso8601String(),
        });

        if (mounted) { // Guard with mounted check
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Offer proposed and broadcast: "${newOffer.have}" for "${newOffer.want}"',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              margin: const EdgeInsets.all(16.0),
            ),
          );

          // Optionally clear fields or navigate back
          _haveController.clear();
          _wantController.clear();
        }
      } catch (e) {
        // print('Error submitting offer to blockchain: $e'); // Avoid print
        if (mounted) { // Guard with mounted check
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to propose offer: $e'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Barter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _haveController,
                decoration: const InputDecoration(
                  labelText: 'I have (e.g., "3 hours of web design", "A vintage record player")',
                  hintText: 'Describe what you are offering...',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe what you have.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _wantController,
                decoration: const InputDecoration(
                  labelText: 'I want (e.g., "A custom-made ceramic mug", "Help moving furniture")',
                  hintText: 'Describe what you want in return...',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe what you want.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _submitOffer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Propose Barter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}