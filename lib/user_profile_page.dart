// lib/user_profile_page.dart
import 'package:flutter/material.dart';
import 'package:barterchain/main.dart'; // To access blockchainService and localBlockchain, and Firestore instances
import 'package:barterchain/block_blockchain.dart'; // For Blockchain type in StreamBuilder
import 'package:barterchain/models.dart'; // To use the Offer model
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore operations
import 'package:barterchain/my_barters_page.dart'; // Import MyBartersPage

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String _userId = 'Loading...';
  double _trustScore = 0.0;
  int _completedBarters = 0;
  int _pendingBarters = 0;
  String _userBio = 'No bio yet. The void awaits your words.'; // Default bio
  List<Map<String, dynamic>> _receivedReviews = [];
  bool _isEditingBio = false;
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userId = blockchainService.userId; // Get initial user ID
    _bioController.text = _userBio; // Initialize controller with default bio

    // Fetch user bio from Firestore
    _fetchUserBio();

    // Listen to blockchain updates to refresh profile stats and reviews
    blockchainService.blockchainUpdates.listen((blockchain) {
      _updateProfileStatsAndReviews(blockchain);
    });
    // Initialize stats and reviews from the current blockchain state
    _updateProfileStatsAndReviews(localBlockchain);
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  // Firestore collection path for user profiles
  // /artifacts/{appId}/users/{userId}/profile/data
  DocumentReference _getUserProfileDoc(String userId) {
    return db.collection('artifacts')
             .doc(_appId) // Access the global _appId from main.dart
             .collection('users')
             .doc(userId)
             .collection('profile')
             .doc('data');
  }

  Future<void> _fetchUserBio() async {
    try {
      final docSnapshot = await _getUserProfileDoc(_userId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        if (mounted) { // Guard with mounted check
          setState(() {
            _userBio = data['bio'] ?? _userBio;
            _bioController.text = _userBio; // Update controller with fetched bio
          });
        }
      }
    } catch (e) {
      // print('Error fetching user bio: $e'); // Avoid print
    }
  }

  Future<void> _saveUserBio() async {
    setState(() {
      _isEditingBio = false;
    });
    final newBio = _bioController.text.trim();
    if (newBio.isEmpty) {
      if (mounted) { // Guard with mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Your bio cannot be an empty existential vacuum.'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: const EdgeInsets.all(16.0),
          ),
        );
        // Revert to previous bio if empty
        setState(() {
          _bioController.text = _userBio;
        });
      }
      return;
    }

    try {
      await _getUserProfileDoc(_userId).set({
        'bio': newBio,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Use merge to only update specified fields
      if (mounted) { // Guard with mounted check
        setState(() {
          _userBio = newBio;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bio updated. Your narrative is now immutable (on this platform).'),
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
      // print('Error saving user bio: $e'); // Avoid print
      if (mounted) { // Guard with mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update bio: $e'),
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

  void _updateProfileStatsAndReviews(Blockchain blockchain) {
    int completed = 0;
    int pending = 0;
    double totalRating = 0.0;
    int reviewCount = 0;
    List<Map<String, dynamic>> tempReviews = [];

    Set<String> processedContracts = {}; // To avoid double counting contracts

    for (var block in blockchain.chain) {
      for (var transaction in block.transactions) {
        if (transaction['type'] == 'contract_completion') {
          final String contractId = transaction['contract_id'];
          final String proposerId = transaction['proposer_id'];
          final String accepterId = transaction['accepter_id'];

          if ((proposerId == _userId || accepterId == _userId) && !processedContracts.contains(contractId)) {
            completed++;
            processedContracts.add(contractId);
          }
        } else if (transaction['type'] == 'offer_acceptance') {
          final String offerId = transaction['offer_id'];
          final String proposerId = transaction['proposer_id'];
          final String accepterId = transaction['accepter_id'];

          // Check if this accepted offer has been completed or disputed later in the chain
          bool isStillPending = true;
          for (var futureBlock in blockchain.chain.where((b) => b.index > block.index)) {
            for (var futureTx in futureBlock.transactions) {
              if ((futureTx['type'] == 'contract_completion' || futureTx['type'] == 'contract_dispute') &&
                  futureTx['contract_id'] == offerId) {
                isStillPending = false;
                break;
              }
            }
            if (!isStillPending) break;
          }

          if (isStillPending && (proposerId == _userId || accepterId == _userId) && !processedContracts.contains(offerId)) {
            pending++;
            processedContracts.add(offerId);
          }
        } else if (transaction['type'] == 'review_submission') {
          final String reviewedUserId = transaction['reviewed_user_id'];
          if (reviewedUserId == _userId) {
            totalRating += (transaction['rating'] as num).toDouble();
            reviewCount++;
            tempReviews.add({
              'reviewer_id': transaction['reviewer_id'],
              'rating': transaction['rating'],
              'review_text': transaction['review_text'],
              'timestamp': transaction['timestamp'],
            });
          }
        }
      }
    }

    if (mounted) { // Guard with mounted check
      setState(() {
        _completedBarters = completed;
        _pendingBarters = pending;
        _trustScore = reviewCount > 0 ? (totalRating / reviewCount) : 0.0;
        _receivedReviews = tempReviews.reversed.toList(); // Show latest reviews first
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[800],
              child: Icon(
                Icons.person,
                size: 80,
                color: Colors.white.withAlpha((255 * 0.7).round()), // Corrected deprecated withOpacity
              ),
            ),
            const SizedBox(height: 20),
            // Display User ID prominently
            Text(
              'User ID: $_userId',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Trust Score:',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _trustScore.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Based on completed barters and peer reviews.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildStatCard(context, 'Completed Barters', _completedBarters.toString()),
                _buildStatCard(context, 'Pending Barters', _pendingBarters.toString()),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'About Me:',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white70),
                        ),
                        IconButton(
                          icon: Icon(_isEditingBio ? Icons.check : Icons.edit, color: Colors.white70),
                          onPressed: () {
                            setState(() {
                              if (_isEditingBio) {
                                _saveUserBio(); // Save when done editing
                              } else {
                                _isEditingBio = true; // Start editing
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _isEditingBio
                        ? TextField(
                            controller: _bioController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your bio here...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 5,
                            minLines: 3,
                          )
                        : Text(
                            _userBio,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyBartersPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('View My Barters'),
            ),
            const SizedBox(height: 30),
            Text(
              'Reviews Received:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            _receivedReviews.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'No reviews yet. The judgment awaits.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _receivedReviews.length,
                    itemBuilder: (context, index) {
                      final review = _receivedReviews[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'From: ${review['reviewer_id']}',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Row(
                                    children: List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < (review['rating'] as num).floor() ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                        size: 18,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                review['review_text'],
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  DateTime.parse(review['timestamp']).toLocal().toString().split('.')[0],
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
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
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}