import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';

/// Day view widget showing events for a single day
class DayView extends StatelessWidget {
  final DateTime selectedDate;
  final List<Event> events;

  const DayView({
    super.key,
    required this.selectedDate,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    // Sort events by start time
    List<Event> sortedEvents = List.from(events)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Column(
      children: [
        // Date header
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, size: 20),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEEE d MMMM y', 'it').format(selectedDate),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Events list
        Expanded(
          child: sortedEvents.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nessun evento per questo giorno',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: sortedEvents.length,
                  itemBuilder: (context, index) {
                    return EventCard(event: sortedEvents[index]);
                  },
                ),
        ),
      ],
    );
  }
}
