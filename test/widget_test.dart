import 'package:flutter_test/flutter_test.dart';
import 'package:family_managment/models/event_model.dart';
import 'package:family_managment/models/shopping_item_model.dart';
import 'package:family_managment/models/family_member_model.dart';

void main() {
  group('Event Model Tests', () {
    test('Event occursOnDate returns true for event date', () {
      final event = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        startTime: DateTime(2024, 1, 15, 10, 0),
        endTime: DateTime(2024, 1, 15, 11, 0),
        assignedTo: 'user1',
        color: '#FFEB3B',
        recurrence: 'none',
        location: 'Home',
        createdBy: 'user1',
        createdAt: DateTime.now(),
      );

      expect(event.occursOnDate(DateTime(2024, 1, 15)), true);
      expect(event.occursOnDate(DateTime(2024, 1, 16)), false);
    });

    test('Recurring daily event occurs every day', () {
      final event = Event(
        id: '1',
        title: 'Daily Event',
        description: 'Daily',
        startTime: DateTime(2024, 1, 15, 10, 0),
        endTime: DateTime(2024, 1, 15, 11, 0),
        assignedTo: 'user1',
        color: '#FFEB3B',
        recurrence: 'daily',
        location: '',
        createdBy: 'user1',
        createdAt: DateTime.now(),
      );

      expect(event.occursOnDate(DateTime(2024, 1, 15)), true);
      expect(event.occursOnDate(DateTime(2024, 1, 16)), true);
      expect(event.occursOnDate(DateTime(2024, 1, 20)), true);
    });

    test('Recurring weekly event occurs on same weekday', () {
      final event = Event(
        id: '1',
        title: 'Weekly Event',
        description: 'Weekly',
        startTime: DateTime(2024, 1, 15, 10, 0), // Monday
        endTime: DateTime(2024, 1, 15, 11, 0),
        assignedTo: 'user1',
        color: '#FFEB3B',
        recurrence: 'weekly',
        location: '',
        createdBy: 'user1',
        createdAt: DateTime.now(),
      );

      expect(event.occursOnDate(DateTime(2024, 1, 15)), true); // Monday
      expect(event.occursOnDate(DateTime(2024, 1, 22)), true); // Next Monday
      expect(event.occursOnDate(DateTime(2024, 1, 16)), false); // Tuesday
    });
  });

  group('Shopping Item Model Tests', () {
    test('Shopping item is created correctly', () {
      final item = ShoppingItem(
        id: '1',
        name: 'Milk',
        isPurchased: false,
        addedBy: 'user1',
        addedAt: DateTime.now(),
      );

      expect(item.name, 'Milk');
      expect(item.isPurchased, false);
    });

    test('Shopping item copyWith works correctly', () {
      final item = ShoppingItem(
        id: '1',
        name: 'Milk',
        isPurchased: false,
        addedBy: 'user1',
        addedAt: DateTime.now(),
      );

      final updatedItem = item.copyWith(isPurchased: true);

      expect(updatedItem.isPurchased, true);
      expect(updatedItem.name, 'Milk');
      expect(updatedItem.id, '1');
    });
  });

  group('Family Member Model Tests', () {
    test('Family member is created correctly', () {
      final member = FamilyMember(
        id: '1',
        name: 'John',
        color: '#FFEB3B',
      );

      expect(member.name, 'John');
      expect(member.color, '#FFEB3B');
    });

    test('Family member copyWith works correctly', () {
      final member = FamilyMember(
        id: '1',
        name: 'John',
        color: '#FFEB3B',
      );

      final updatedMember = member.copyWith(name: 'Jane');

      expect(updatedMember.name, 'Jane');
      expect(updatedMember.color, '#FFEB3B');
      expect(updatedMember.id, '1');
    });
  });
}
