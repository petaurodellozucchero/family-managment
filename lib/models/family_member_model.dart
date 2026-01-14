import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a family member with their unique color
class FamilyMember {
  final String id;
  final String name;
  final String color; // Hex color code

  FamilyMember({
    required this.id,
    required this.name,
    required this.color,
  });

  /// Create FamilyMember from Firestore document
  factory FamilyMember.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FamilyMember(
      id: doc.id,
      name: data['name'] ?? '',
      color: data['color'] ?? '#FFEB3B',
    );
  }

  /// Convert FamilyMember to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'color': color,
    };
  }

  /// Create a copy with updated fields
  FamilyMember copyWith({
    String? id,
    String? name,
    String? color,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
}
