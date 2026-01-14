import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';

/// Month view widget using table_calendar
class MonthView extends StatefulWidget {
  final DateTime selectedDate;
  final List<Event> events;
  final Function(DateTime) onDaySelected;

  const MonthView({
    Key? key,
    required this.selectedDate,
    required this.events,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate;
    _selectedDay = widget.selectedDate;
  }

  @override
  void didUpdateWidget(MonthView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      setState(() {
        _focusedDay = widget.selectedDate;
        _selectedDay = widget.selectedDate;
      });
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return widget.events.where((event) => event.occursOnDate(day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Event> selectedDayEvents = _getEventsForDay(_selectedDay);
    selectedDayEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Column(
      children: [
        // Calendar
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          eventLoader: _getEventsForDay,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            widget.onDaySelected(selectedDay);
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
        ),
        Divider(height: 1),
        // Selected day events
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  DateFormat('EEEE, MMMM d').format(_selectedDay),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: selectedDayEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'No events for this day',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 8),
                        itemCount: selectedDayEvents.length,
                        itemBuilder: (context, index) {
                          return EventCard(event: selectedDayEvents[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
