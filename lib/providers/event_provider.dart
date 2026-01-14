import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../services/firebase_service.dart';

/// Provider for managing calendar events
class EventProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize the provider and listen to events stream
  void initialize() {
    _firebaseService.getEventsStream().listen(
      (events) {
        _events = events;
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

  /// Get events for a specific date
  List<Event> getEventsForDate(DateTime date) {
    return _events.where((event) => event.occursOnDate(date)).toList();
  }

  /// Get events for a date range
  List<Event> getEventsForDateRange(DateTime start, DateTime end) {
    List<Event> rangeEvents = [];
    DateTime current = start;
    
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      rangeEvents.addAll(getEventsForDate(current));
      current = current.add(Duration(days: 1));
    }
    
    // Remove duplicates
    return rangeEvents.toSet().toList();
  }

  /// Add a new event
  Future<bool> addEvent(Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    String? eventId = await _firebaseService.addEvent(event);
    
    _isLoading = false;
    if (eventId == null) {
      _error = 'Failed to add event';
      notifyListeners();
      return false;
    }
    
    notifyListeners();
    return true;
  }

  /// Update an existing event
  Future<bool> updateEvent(String eventId, Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    bool success = await _firebaseService.updateEvent(eventId, event);
    
    _isLoading = false;
    if (!success) {
      _error = 'Failed to update event';
    }
    
    notifyListeners();
    return success;
  }

  /// Delete an event
  Future<bool> deleteEvent(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    bool success = await _firebaseService.deleteEvent(eventId);
    
    _isLoading = false;
    if (!success) {
      _error = 'Failed to delete event';
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
