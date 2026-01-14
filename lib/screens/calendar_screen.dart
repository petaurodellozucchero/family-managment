import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/family_member_provider.dart';
import '../widgets/day_view.dart';
import '../widgets/week_view.dart';
import '../widgets/month_view.dart';
import 'event_detail_screen.dart';

/// Main calendar screen with day, week, and month views
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  void _selectToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Calendar', style: TextStyle(fontSize: 22)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Day'),
            Tab(text: 'Week'),
            Tab(text: 'Month'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Today',
            onPressed: _selectToday,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Pick Date',
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isLoading && eventProvider.events.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Navigation controls
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.grey[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 32),
                      onPressed: () => _changeDate(_getNavigationDays() * -1),
                    ),
                    TextButton(
                      onPressed: _selectToday,
                      child: const Text(
                        'Today',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 32),
                      onPressed: () => _changeDate(_getNavigationDays()),
                    ),
                  ],
                ),
              ),
              // Calendar views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Day View
                    DayView(
                      selectedDate: _selectedDate,
                      events: eventProvider.getEventsForDate(_selectedDate),
                    ),
                    // Week View
                    WeekView(
                      selectedDate: _selectedDate,
                      events: eventProvider.getEventsForDateRange(
                        _selectedDate.subtract(
                          Duration(days: _selectedDate.weekday - 1),
                        ),
                        _selectedDate.add(
                          Duration(days: 7 - _selectedDate.weekday),
                        ),
                      ),
                    ),
                    // Month View
                    MonthView(
                      selectedDate: _selectedDate,
                      events: eventProvider.events,
                      onDaySelected: (day) {
                        setState(() {
                          _selectedDate = day;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final familyMemberProvider = Provider.of<FamilyMemberProvider>(context, listen: false);
          if (familyMemberProvider.familyMembers.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No family members found. Please set up family members first.')),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(
                initialDate: _selectedDate,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Event', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  int _getNavigationDays() {
    switch (_tabController.index) {
      case 0: // Day
        return 1;
      case 1: // Week
        return 7;
      case 2: // Month
        return 30;
      default:
        return 1;
    }
  }
}
