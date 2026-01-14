import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a calendar event with all its properties
class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String assignedTo; // Family member ID
  final String color; // Hex color code
  final String recurrence; // none, daily, weekly, monthly
  final String location;
  final String createdBy;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.assignedTo,
    required this.color,
    required this.recurrence,
    required this.location,
    required this.createdBy,
    required this.createdAt,
  });

  /// Create Event from Firestore document
  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      assignedTo: data['assignedTo'] ?? '',
      color: data['color'] ?? '#FFEB3B',
      recurrence: data['recurrence'] ?? 'none',
      location: data['location'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert Event to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'assignedTo': assignedTo,
      'color': color,
      'recurrence': recurrence,
      'location': location,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with updated fields
  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? assignedTo,
    String? color,
    String? recurrence,
    String? location,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      assignedTo: assignedTo ?? this.assignedTo,
      color: color ?? this.color,
      recurrence: recurrence ?? this.recurrence,
      location: location ?? this.location,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if event occurs on a specific date (considering recurrence)
  bool occursOnDate(DateTime date) {
    DateTime checkDate = DateTime(date.year, date.month, date.day);
    DateTime eventStart = DateTime(startTime.year, startTime.month, startTime.day);
    DateTime eventEnd = DateTime(endTime.year, endTime.month, endTime.day);

    // Non-recurring event
    if (recurrence == 'none') {
      return checkDate.isAtSameMomentAs(eventStart) ||
          (checkDate.isAfter(eventStart) && checkDate.isBefore(eventEnd)) ||
          checkDate.isAtSameMomentAs(eventEnd);
    }

    // Recurring events
    if (checkDate.isBefore(eventStart)) {
      return false;
    }

    switch (recurrence) {
      case 'daily':
        return true;
      case 'weekly':
        return checkDate.weekday == eventStart.weekday;
      case 'monthly':
        return checkDate.day == eventStart.day;
      default:
        return false;
    }
  }
}
