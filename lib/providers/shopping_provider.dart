import 'package:flutter/foundation.dart';
import '../models/shopping_item_model.dart';
import '../services/firebase_service.dart';

/// Provider for managing shopping list
class ShoppingProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<ShoppingItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<ShoppingItem> get items => _items;
  List<ShoppingItem> get activeItems =>
      _items.where((item) => !item.isPurchased).toList();
  List<ShoppingItem> get purchasedItems =>
      _items.where((item) => item.isPurchased).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize the provider and listen to shopping list stream
  void initialize() {
    _firebaseService.getShoppingListStream().listen(
      (items) {
        _items = items;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Add a new shopping item
  Future<bool> addItem(ShoppingItem item) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    String? itemId = await _firebaseService.addShoppingItem(item);
    
    _isLoading = false;
    if (itemId == null) {
      _error = 'Failed to add item';
      notifyListeners();
      return false;
    }
    
    notifyListeners();
    return true;
  }

  /// Toggle the purchase status of an item
  Future<bool> toggleItemStatus(String itemId, bool isPurchased) async {
    bool success =
        await _firebaseService.toggleShoppingItemStatus(itemId, isPurchased);
    
    if (!success) {
      _error = 'Failed to update item';
      notifyListeners();
    }
    
    return success;
  }

  /// Delete a shopping item
  Future<bool> deleteItem(String itemId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    bool success = await _firebaseService.deleteShoppingItem(itemId);
    
    _isLoading = false;
    if (!success) {
      _error = 'Failed to delete item';
    }
    
    notifyListeners();
    return success;
  }

  /// Clear all purchased items
  Future<bool> clearPurchasedItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    bool success = await _firebaseService.clearPurchasedItems();
    
    _isLoading = false;
    if (!success) {
      _error = 'Failed to clear purchased items';
    }
    
    notifyListeners();
    return success;
  }

  /// Clear any error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
