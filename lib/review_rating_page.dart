// lib/review_rating_page.dart
import 'package:flutter/material.dart';

class ReviewRatingPage extends StatefulWidget {
  // In a real application, you might pass a specific completed barter contract
  // to this page, so the user can review the counterparty for that transaction.
  final String? barterId;
  final String? counterpartyId;

  const ReviewRatingPage({super.key, this.barterId, this.counterpartyId});

  @override
  State<ReviewRatingPage> createState() => _ReviewRatingPageState();
}

class _ReviewRatingPageState extends State<ReviewRatingPage> {
  double _rating = 3.0; // Initial rating
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('A review is required, even if it\'s just a single, cutting word.'),
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

    // In a real app, this data would be sent to the blockchain/backend
    print('Submitting review for Barter ID: ${widget.barterId ?? "N/A"}');
    print('  Counterparty: ${widget.counterpartyId ?? "N/A"}');
    print('  Rating: $_rating stars');
    print('  Review: ${_reviewController.text.trim()}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Review submitted for ${widget.counterpartyId ?? "the void"}. Rating: $_rating stars.'),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        margin: const EdgeInsets.all(16.0),
      ),
    );

    // Optionally navigate back or clear fields
    _reviewController.clear();
    setState(() {
      _rating = 3.0; // Reset rating
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave a Review'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Review your recent barter with:',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.counterpartyId ?? 'Unknown Entity', // Display the counterparty ID
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Text(
                  'Rate the exchange:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                // Star Rating Slider
                Slider(
                  value: _rating,
                  min: 1.0,
                  max: 5.0,
                  divisions: 4, // 1, 2, 3, 4, 5 stars
                  label: _rating.toStringAsFixed(0), // Show integer rating
                  onChanged: (double value) {
                    setState(() {
                      _rating = value;
                    });
                  },
                  activeColor: Colors.amber, // Gold color for active rating
                  inactiveColor: Colors.amber.withOpacity(0.3),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < _rating.floor() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 30,
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Your Deconstruction (Review):',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _reviewController,
                  decoration: const InputDecoration(
                    hintText: 'Describe your experience, for posterity and judgment...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  minLines: 3,
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitReview,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                      backgroundColor: Colors.blueGrey[700], // A distinct color for submission
                    ),
                    child: const Text('Submit Review'),
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
