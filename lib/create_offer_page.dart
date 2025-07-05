// lib/create_offer_page.dart
import 'package:flutter/material.dart';

class CreateOfferPage extends StatefulWidget {
  const CreateOfferPage({super.key});

  @override
  State<CreateOfferPage> createState() => _CreateOfferPageState();
}

class _CreateOfferPageState extends State<CreateOfferPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _haveController = TextEditingController();
  final TextEditingController _wantController = TextEditingController();

  @override
  void dispose() {
    _haveController.dispose();
    _wantController.dispose();
    super.dispose();
  }

  void _submitOffer() {
    if (_formKey.currentState!.validate()) {
      // In a real app, this data would be sent to a blockchain service
      // For now, we'll just print it.
      print('Offer Submitted:');
      print('  Have: ${_haveController.text}');
      print('  Want: ${_wantController.text}');

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Offer submitted: "${_haveController.text}" for "${_wantController.text}"',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[800],
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
              // Input for what the user has to offer
              TextFormField(
                controller: _haveController,
                decoration: const InputDecoration(
                  labelText: 'I have (e.g., "3 hours of web design", "A vintage record player")',
                  hintText: 'Describe what you are offering...',
                ),
                maxLines: 3, // Allow multiple lines for description
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe what you have.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Input for what the user wants in return
              TextFormField(
                controller: _wantController,
                decoration: const InputDecoration(
                  labelText: 'I want (e.g., "A custom-made ceramic mug", "Help moving furniture")',
                  hintText: 'Describe what you want in return...',
                ),
                maxLines: 3, // Allow multiple lines for description
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe what you want.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              // Button to submit the barter offer
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
