import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';

/// Week view widget showing events for a week
class WeekView extends StatelessWidget {
  final DateTime selectedDate;
  final List<Event> events;

  const WeekView({
    Key? key,
    required this.selectedDate,
    required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the start of the week (Monday)
    DateTime weekStart = selectedDate.subtract(
      Duration(days: (selectedDate.weekday - 1) % 7),
    );
    
    return Column(
      children: [
        // Week header
        Container(
          padding: EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_view_week, size: 20),
              SizedBox(width: 8),
              Text(
                'Week of ${DateFormat('MMM d').format(weekStart)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Days of week
        Expanded(
          child: ListView.builder(
            itemCount: 7,
            itemBuilder: (context, index) {
              DateTime day = weekStart.add(Duration(days: index));
              List<Event> dayEvents =
                  events.where((event) => event.occursOnDate(day)).toList();
              dayEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

              bool isToday = DateTime.now().year == day.year &&
                  DateTime.now().month == day.month &&
                  DateTime.now().day == day.day;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: isToday
                        ? Theme.of(context).primaryColor.withOpacity(0.2)
                        : Colors.grey[100],
                    child: Row(
                      children: [
                        Text(
                          DateFormat('EEE').format(day),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isToday
                                ? Theme.of(context).primaryColor
                                : Colors.black87,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          DateFormat('MMM d').format(day),
                          style: TextStyle(
                            fontSize: 16,
                            color: isToday
                                ? Theme.of(context).primaryColor
                                : Colors.black54,
                          ),
                        ),
                        if (isToday) ...[
                          SizedBox(width: 8),
                          Container(
                            padding:
                                EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (dayEvents.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No events',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  else
                    ...dayEvents.map((event) => EventCard(event: event)).toList(),
                  Divider(height: 1),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
