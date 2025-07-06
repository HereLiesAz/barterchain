// lib/review_rating_page.dart
import 'package:flutter/material.dart';
import 'package:barterchain/main.dart'; // To access global blockchainService

class ReviewRatingPage extends StatefulWidget {
  final String? barterId; // The ID of the barter contract being reviewed
  final String? counterpartyId; // The ID of the user being reviewed

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

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      if (mounted) { // Guard with mounted check
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
      }
      return;
    }

    // Ensure we have a counterparty ID to review
    if (widget.counterpartyId == null || widget.counterpartyId!.isEmpty) {
      if (mounted) { // Guard with mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cannot submit review: Counterparty ID is missing.'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: const EdgeInsets.all(16.0),
          ),
        );
      }
      return;
    }

    // Prevent self-review
    if (widget.counterpartyId == blockchainService.userId) {
      if (mounted) { // Guard with mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('You cannot review yourself. The irony would be too much.'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: const EdgeInsets.all(16.0),
          ),
        );
      }
      return;
    }

    // Add the review as a transaction to the local blockchain and broadcast it
    try {
      await blockchainService.addTransactionAndMine({
        'type': 'review_submission',
        'barter_id': widget.barterId, // Optional: link to specific barter
        'reviewer_id': blockchainService.userId, // The user submitting the review
        'reviewed_user_id': widget.counterpartyId, // The user being reviewed
        'rating': _rating,
        'review_text': _reviewController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (mounted) { // Guard with mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Review submitted for ${widget.counterpartyId}. Rating: ${_rating.toStringAsFixed(1)} stars.'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: const EdgeInsets.all(16.0),
          ),
        );

        // Optionally navigate back after successful submission
        Navigator.pop(context);
      }
    } catch (e) {
      // print('Error submitting review to blockchain: $e'); // Avoid print
      if (mounted) { // Guard with mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $e'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: const EdgeInsets.all(16.0),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
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
                  widget.counterpartyId ?? 'Unknown Entity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Text(
                  'Rate the exchange:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Slider(
                  value: _rating,
                  min: 1.0,
                  max: 5.0,
                  divisions: 4,
                  label: _rating.toStringAsFixed(0),
                  onChanged: (double value) {
                    setState(() {
                      _rating = value;
                    });
                  },
                  activeColor: Colors.amber,
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
                      backgroundColor: Colors.blueGrey[700],
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