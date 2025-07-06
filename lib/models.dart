// lib/models.dart
// This file will hold common data models used across the application.

class Offer {
  final String id;
  final String have;
  final String want;
  final String proposerId;
  final String status; // e.g., 'open', 'accepted', 'completed', 'disputed'

  Offer({
    required this.id,
    required this.have,
    required this.want,
    required this.proposerId,
    this.status = 'open',
  });

  // Factory constructor to create an Offer from a JSON map (e.g., from blockchain transaction)
  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as String,
      have: json['have'] as String,
      want: json['want'] as String,
      proposerId: json['proposerId'] as String,
      status: json['status'] as String,
    );
  }

  // Convert an Offer object to a JSON map for storage (e.g., in blockchain transaction)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'have': have,
      'want': want,
      'proposerId': proposerId,
      'status': status,
    };
  }
}
