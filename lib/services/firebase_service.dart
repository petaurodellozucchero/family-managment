import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../models/shopping_item_model.dart';
import '../models/family_member_model.dart';

/// Service for handling Firebase Firestore operations
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get eventsCollection => _firestore.collection('events');
  CollectionReference get shoppingListCollection =>
      _firestore.collection('shoppingList');
  CollectionReference get familyMembersCollection =>
      _firestore.collection('familyMembers');

  // ==================== EVENTS ====================

  /// Stream of all events
  Stream<List<Event>> getEventsStream() {
    return eventsCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  /// Get a single event by ID
  Future<Event?> getEvent(String eventId) async {
    try {
      DocumentSnapshot doc = await eventsCollection.doc(eventId).get();
      if (doc.exists) {
        return Event.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting event: $e');
      return null;
    }
  }

  /// Add a new event
  Future<String?> addEvent(Event event) async {
    try {
      DocumentReference docRef =
          await eventsCollection.add(event.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding event: $e');
      return null;
    }
  }

  /// Update an existing event
  Future<bool> updateEvent(String eventId, Event event) async {
    try {
      await eventsCollection.doc(eventId).update(event.toFirestore());
      return true;
    } catch (e) {
      print('Error updating event: $e');
      return false;
    }
  }

  /// Delete an event
  Future<bool> deleteEvent(String eventId) async {
    try {
      await eventsCollection.doc(eventId).delete();
      return true;
    } catch (e) {
      print('Error deleting event: $e');
      return false;
    }
  }

  // ==================== SHOPPING LIST ====================

  /// Stream of all shopping items
  Stream<List<ShoppingItem>> getShoppingListStream() {
    return shoppingListCollection
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShoppingItem.fromFirestore(doc))
            .toList());
  }

  /// Add a new shopping item
  Future<String?> addShoppingItem(ShoppingItem item) async {
    try {
      DocumentReference docRef =
          await shoppingListCollection.add(item.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding shopping item: $e');
      return null;
    }
  }

  /// Update a shopping item
  Future<bool> updateShoppingItem(String itemId, ShoppingItem item) async {
    try {
      await shoppingListCollection.doc(itemId).update(item.toFirestore());
      return true;
    } catch (e) {
      print('Error updating shopping item: $e');
      return false;
    }
  }

  /// Toggle purchase status of a shopping item
  Future<bool> toggleShoppingItemStatus(String itemId, bool isPurchased) async {
    try {
      await shoppingListCollection.doc(itemId).update({
        'isPurchased': isPurchased,
      });
      return true;
    } catch (e) {
      print('Error toggling shopping item status: $e');
      return false;
    }
  }

  /// Delete a shopping item
  Future<bool> deleteShoppingItem(String itemId) async {
    try {
      await shoppingListCollection.doc(itemId).delete();
      return true;
    } catch (e) {
      print('Error deleting shopping item: $e');
      return false;
    }
  }

  /// Delete all purchased shopping items
  Future<bool> clearPurchasedItems() async {
    try {
      QuerySnapshot snapshot = await shoppingListCollection
          .where('isPurchased', isEqualTo: true)
          .get();
      
      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      print('Error clearing purchased items: $e');
      return false;
    }
  }

  // ==================== FAMILY MEMBERS ====================

  /// Stream of all family members
  Stream<List<FamilyMember>> getFamilyMembersStream() {
    return familyMembersCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => FamilyMember.fromFirestore(doc))
        .toList());
  }

  /// Add a new family member
  Future<String?> addFamilyMember(FamilyMember member) async {
    try {
      DocumentReference docRef =
          await familyMembersCollection.add(member.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding family member: $e');
      return null;
    }
  }

  /// Update an existing family member
  Future<bool> updateFamilyMember(String memberId, FamilyMember member) async {
    try {
      await familyMembersCollection.doc(memberId).update(member.toFirestore());
      return true;
    } catch (e) {
      print('Error updating family member: $e');
      return false;
    }
  }

  /// Delete a family member
  Future<bool> deleteFamilyMember(String memberId) async {
    try {
      await familyMembersCollection.doc(memberId).delete();
      return true;
    } catch (e) {
      print('Error deleting family member: $e');
      return false;
    }
  }

  /// Initialize default family members if none exist
  Future<void> initializeDefaultFamilyMembers() async {
    try {
      QuerySnapshot snapshot = await familyMembersCollection.limit(1).get();
      
      if (snapshot.docs.isEmpty) {
        // Add default family members
        List<Map<String, String>> defaultMembers = [
          {'name': 'You', 'color': '#FFEB3B'}, // Yellow
          {'name': 'Sister', 'color': '#E91E63'}, // Pink
          {'name': 'Mom', 'color': '#F44336'}, // Red
          {'name': 'Dad', 'color': '#2196F3'}, // Blue
          {'name': 'Brother', 'color': '#4CAF50'}, // Green
        ];

        for (var member in defaultMembers) {
          await familyMembersCollection.add(member);
        }
      }
    } catch (e) {
      print('Error initializing family members: $e');
    }
  }
}
