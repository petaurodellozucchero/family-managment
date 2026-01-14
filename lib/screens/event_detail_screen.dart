import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../models/family_member_model.dart';
import '../providers/event_provider.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';

/// Screen for viewing and editing event details
class EventDetailScreen extends StatefulWidget {
  final Event? event;
  final DateTime? initialDate;

  const EventDetailScreen({
    Key? key,
    this.event,
    this.initialDate,
  }) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  
  String? _selectedMemberId;
  String _selectedRecurrence = 'none';
  
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  
  List<FamilyMember> _familyMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadFamilyMembers();
  }

  void _initializeForm() {
    if (widget.event != null) {
      // Edit mode
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _locationController.text = widget.event!.location;
      _startDate = widget.event!.startTime;
      _startTime = TimeOfDay.fromDateTime(widget.event!.startTime);
      _endDate = widget.event!.endTime;
      _endTime = TimeOfDay.fromDateTime(widget.event!.endTime);
      _selectedMemberId = widget.event!.assignedTo;
      _selectedRecurrence = widget.event!.recurrence;
    } else {
      // Create mode
      DateTime initial = widget.initialDate ?? DateTime.now();
      _startDate = initial;
      _startTime = TimeOfDay(hour: 9, minute: 0);
      _endDate = initial;
      _endTime = TimeOfDay(hour: 10, minute: 0);
    }
  }

  Future<void> _loadFamilyMembers() async {
    try {
      List<FamilyMember> members =
          await _firebaseService.getFamilyMembersStream().first;
      setState(() {
        _familyMembers = members;
        if (_selectedMemberId == null && members.isNotEmpty) {
          _selectedMemberId = members.first.id;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading family members')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Ensure end date is not before start date
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a family member')),
      );
      return;
    }

    // Create DateTime objects
    DateTime startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    DateTime endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    FamilyMember selectedMember =
        _familyMembers.firstWhere((m) => m.id == _selectedMemberId);

    Event event = Event(
      id: widget.event?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
      assignedTo: _selectedMemberId!,
      color: selectedMember.color,
      recurrence: _selectedRecurrence,
      location: _locationController.text.trim(),
      createdBy: _authService.currentUserId ?? 'anonymous',
      createdAt: widget.event?.createdAt ?? DateTime.now(),
    );

    final provider = Provider.of<EventProvider>(context, listen: false);
    bool success;

    if (widget.event != null) {
      // Update existing event
      success = await provider.updateEvent(widget.event!.id, event);
    } else {
      // Create new event
      success = await provider.addEvent(event);
    }

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.event != null
                ? 'Event updated successfully'
                : 'Event created successfully',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save event')),
      );
    }
  }

  Future<void> _deleteEvent() async {
    if (widget.event == null) return;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Event'),
          content: Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final provider = Provider.of<EventProvider>(context, listen: false);
      bool success = await provider.deleteEvent(widget.event!.id);

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete event')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event != null ? 'Edit Event' : 'New Event',
          style: TextStyle(fontSize: 22),
        ),
        actions: [
          if (widget.event != null)
            IconButton(
              icon: Icon(Icons.delete),
              tooltip: 'Delete Event',
              onPressed: _deleteEvent,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(fontSize: 18),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      style: TextStyle(fontSize: 18),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(fontSize: 18),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      style: TextStyle(fontSize: 18),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    
                    // Start Date and Time
                    Text(
                      'Start',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.calendar_today),
                            label: Text(
                              DateFormat('MMM d, y').format(_startDate),
                              style: TextStyle(fontSize: 16),
                            ),
                            onPressed: _selectStartDate,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.access_time),
                            label: Text(
                              _startTime.format(context),
                              style: TextStyle(fontSize: 16),
                            ),
                            onPressed: _selectStartTime,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // End Date and Time
                    Text(
                      'End',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.calendar_today),
                            label: Text(
                              DateFormat('MMM d, y').format(_endDate),
                              style: TextStyle(fontSize: 16),
                            ),
                            onPressed: _selectEndDate,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.access_time),
                            label: Text(
                              _endTime.format(context),
                              style: TextStyle(fontSize: 16),
                            ),
                            onPressed: _selectEndTime,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Family Member
                    DropdownButtonFormField<String>(
                      value: _selectedMemberId,
                      decoration: InputDecoration(
                        labelText: 'Assign to',
                        labelStyle: TextStyle(fontSize: 18),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                      items: _familyMembers.map((member) {
                        return DropdownMenuItem(
                          value: member.id,
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _hexToColor(member.color),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(member.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMemberId = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Recurrence
                    DropdownButtonFormField<String>(
                      value: _selectedRecurrence,
                      decoration: InputDecoration(
                        labelText: 'Recurrence',
                        labelStyle: TextStyle(fontSize: 18),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.repeat),
                      ),
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                      items: [
                        DropdownMenuItem(value: 'none', child: Text('None')),
                        DropdownMenuItem(value: 'daily', child: Text('Daily')),
                        DropdownMenuItem(
                            value: 'weekly', child: Text('Weekly')),
                        DropdownMenuItem(
                            value: 'monthly', child: Text('Monthly')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRecurrence = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location (optional)',
                        labelStyle: TextStyle(fontSize: 18),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 24),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveEvent,
                        child: Text(
                          widget.event != null ? 'Update Event' : 'Create Event',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
