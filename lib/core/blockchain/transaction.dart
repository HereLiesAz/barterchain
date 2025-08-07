import 'package:uuid/uuid.dart';

enum TransactionType {
  createOffer,
  acceptContract,
  fulfillContract,
  submitReview,
  initiateDispute
}

// Base class for all transaction payloads. Enforces serialization.
abstract class TransactionPayload {
  Map<String, dynamic> toJson();
}

// Payload for creating a new barter offer.
class CreateOfferPayload implements TransactionPayload {
  final String offerId;
  final String proposerId;
  final String have;
  final String want;

  CreateOfferPayload({
    required this.proposerId,
    required this.have,
    required this.want,
  }) : offerId = const Uuid().v4();

  CreateOfferPayload._({
    required this.offerId,
    required this.proposerId,
    required this.have,
    required this.want,
  });

  @override
  Map<String, dynamic> toJson() => {
        'offerId': offerId,
        'proposerId': proposerId,
        'have': have,
        'want': want,
      };

  factory CreateOfferPayload.fromJson(Map<String, dynamic> json) =>
      CreateOfferPayload._(
        offerId: json['offerId'],
        proposerId: json['proposerId'],
        have: json['have'],
        want: json['want'],
      );
}

// Payload for accepting an offer and forming a contract.
class AcceptContractPayload implements TransactionPayload {
  final String contractId;
  final String offerId;
  final String accepterId;

  AcceptContractPayload({
    required this.offerId,
    required this.accepterId,
  }) : contractId = const Uuid().v4();

  AcceptContractPayload._({
    required this.contractId,
    required this.offerId,
    required this.accepterId,
  });

  @override
  Map<String, dynamic> toJson() => {
        'contractId': contractId,
        'offerId': offerId,
        'accepterId': accepterId,
      };

  factory AcceptContractPayload.fromJson(Map<String, dynamic> json) =>
      AcceptContractPayload._(
        contractId: json['contractId'],
        offerId: json['offerId'],
        accepterId: json['accepterId'],
      );
}

// ... other payload classes would go here (Fulfill, Review, Dispute)
// For now, these are sufficient to prove the model.

// The main Transaction class, now holding a strongly-typed payload.
class Transaction {
  final String id;
  final TransactionType type;
  final TransactionPayload payload;
  final DateTime timestamp;

  Transaction({
    required this.type,
    required this.payload,
    DateTime? timestamp,
  })  : id = const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Transaction._({
    required this.id,
    required this.type,
    required this.payload,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'payload': payload.toJson(),
        'timestamp': timestamp.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final type = TransactionType.values.byName(json['type']);
    final payloadJson = json['payload'] as Map<String, dynamic>;
    TransactionPayload payload;

    switch (type) {
      case TransactionType.createOffer:
        payload = CreateOfferPayload.fromJson(payloadJson);
        break;
      case TransactionType.acceptContract:
        payload = AcceptContractPayload.fromJson(payloadJson);
        break;
      // Add cases for other types as they are implemented
      default:
        throw ArgumentError('Unknown transaction type: $type');
    }

    return Transaction._(
      id: json['id'],
      type: type,
      payload: payload,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
