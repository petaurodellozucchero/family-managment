import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/family_member_model.dart';

/// Provider for managing the current user identity
class CurrentUserProvider with ChangeNotifier {
  FamilyMember? _currentUser;
  bool _isInitialized = false;

  static const String _userIdKey = 'current_user_id';

  FamilyMember? get currentUser => _currentUser;
  bool get isInitialized => _isInitialized;
  bool get hasUser => _currentUser != null;

  /// Load saved user ID from SharedPreferences
  Future<String?> loadSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Save user ID to SharedPreferences
  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  /// Clear saved user ID from SharedPreferences
  Future<void> _clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  /// Set the current user identity
  Future<void> setCurrentUser(FamilyMember member) async {
    _currentUser = member;
    _isInitialized = true;
    await _saveUserId(member.id);
    notifyListeners();
  }

  /// Initialize with a family member (called when matching saved ID)
  void initializeWithMember(FamilyMember member) {
    _currentUser = member;
    _isInitialized = true;
    notifyListeners();
  }

  /// Mark as initialized without a user (user needs to select)
  void markInitialized() {
    _isInitialized = true;
    notifyListeners();
  }

  /// Clear the current user (logout)
  Future<void> clearCurrentUser() async {
    _currentUser = null;
    _isInitialized = true;
    await _clearUserId();
    notifyListeners();
  }
}
