import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/family_member_model.dart';
import '../services/firebase_service.dart';

/// Provider for managing family members
class FamilyMemberProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<FamilyMember> _familyMembers = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<FamilyMember>>? _streamSubscription;

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
    _streamSubscription = _firebaseService.getFamilyMembersStream().listen(
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
    return _performOperation(() => _firebaseService.addFamilyMember(member));
  }

  /// Update an existing family member
  Future<bool> updateFamilyMember(String memberId, FamilyMember member) async {
    return _performOperation(() => _firebaseService.updateFamilyMember(memberId, member));
  }

  /// Delete a family member
  Future<bool> deleteFamilyMember(String memberId) async {
    return _performOperation(() => _firebaseService.deleteFamilyMember(memberId));
  }

  /// Helper method to handle operation state and error handling
  Future<bool> _performOperation(Future<dynamic> Function() operation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await operation();

    _isLoading = false;
    if (result == null || result == false) {
      _error = 'Operation failed';
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  /// Clear any error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
