import 'package:flutter/foundation.dart';
import '../models/family_member_model.dart';
import '../services/firebase_service.dart';

/// Provider for managing family members
class FamilyMemberProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<FamilyMember> _familyMembers = [];
  bool _isLoading = false;
  String? _error;

  List<FamilyMember> get familyMembers => _familyMembers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize the provider and listen to family members stream
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // First ensure default members are initialized
    await _firebaseService.initializeDefaultFamilyMembers();

    // Then listen to the stream
    _firebaseService.getFamilyMembersStream().listen(
      (members) {
        _familyMembers = members;
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

  /// Add a new family member
  Future<bool> addFamilyMember(FamilyMember member) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    String? memberId = await _firebaseService.addFamilyMember(member);

    _isLoading = false;
    if (memberId == null) {
      _error = 'Failed to add family member';
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  /// Update an existing family member
  Future<bool> updateFamilyMember(String memberId, FamilyMember member) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    bool success = await _firebaseService.updateFamilyMember(memberId, member);

    _isLoading = false;
    if (!success) {
      _error = 'Failed to update family member';
    }

    notifyListeners();
    return success;
  }

  /// Delete a family member
  Future<bool> deleteFamilyMember(String memberId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    bool success = await _firebaseService.deleteFamilyMember(memberId);

    _isLoading = false;
    if (!success) {
      _error = 'Failed to delete family member';
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
