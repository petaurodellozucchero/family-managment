import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a shopping list item
class ShoppingItem {
  final String id;
  final String name;
  final bool isPurchased;
  final String addedBy;
  final DateTime addedAt;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.isPurchased,
    required this.addedBy,
    required this.addedAt,
  });

  /// Create ShoppingItem from Firestore document
  factory ShoppingItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ShoppingItem(
      id: doc.id,
      name: data['name'] ?? '',
      isPurchased: data['isPurchased'] ?? false,
      addedBy: data['addedBy'] ?? '',
      addedAt: data['addedAt'] != null
          ? (data['addedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert ShoppingItem to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'isPurchased': isPurchased,
      'addedBy': addedBy,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  /// Create a copy with updated fields
  ShoppingItem copyWith({
    String? id,
    String? name,
    bool? isPurchased,
    String? addedBy,
    DateTime? addedAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isPurchased: isPurchased ?? this.isPurchased,
      addedBy: addedBy ?? this.addedBy,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
