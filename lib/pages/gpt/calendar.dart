import 'dart:math';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: const CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final Map<DateTime, List<CalendarEvent>> _events;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<String> leaveTypes = ['Annual Leave', 'Sick Leave', 'WRA'];
  final List<String> names = [
    'Alice',
    'Bob',
    'Charlie',
    'Diana',
    'Ethan',
    'Fiona',
  ];

  @override
  void initState() {
    super.initState();
    _events = _generateMockEvents();
  }

  Map<DateTime, List<CalendarEvent>> _generateMockEvents() {
    final Map<DateTime, List<CalendarEvent>> data = {};

    final now = DateTime.now();
    final rng = Random();

    // Mock holidays
    data[DateTime(now.year, now.month, now.day + 2)] = [
      CalendarEvent.holiday('National Sports Day'),
    ];
    data[DateTime(now.year, now.month, now.day + 5)] = [
      CalendarEvent.holiday('Mid-Month Celebration'),
    ];

    // Mock random leaves
    for (int i = 1; i <= 28; i++) {
      DateTime date = DateTime(now.year, now.month, i);
      if (rng.nextBool()) {
        data[date] = List.generate(rng.nextInt(3) + 1, (index) {
          return CalendarEvent.leave(
            firstName: names[rng.nextInt(names.length)],
            lastName: 'Lastname',
            leaveType: leaveTypes[rng.nextInt(leaveTypes.length)],
          );
        });
      }
    }

    return data;
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Calendar'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF74EBD5), Color(0xFF9FACE6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildCalendar(),
            const SizedBox(height: 12),
            _buildEventList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TableCalendar<CalendarEvent>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Color(0xFF6C63FF),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(color: Colors.black),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    final events = _getEventsForDay(_selectedDay ?? _focusedDay);
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "No holidays or leave on this day.",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: events.map((event) {
          if (event.isHoliday) {
            return _eventCard(
              Icons.celebration,
              event.title!,
              Colors.pinkAccent,
            );
          } else {
            return _eventCard(
              Icons.person_outline,
              "${event.firstName} ${event.lastName} - ${event.leaveType}",
              _getColorForLeaveType(event.leaveType),
            );
          }
        }).toList(),
      ),
    );
  }

  Widget _eventCard(IconData icon, String text, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Color _getColorForLeaveType(String? type) {
    switch (type) {
      case 'Sick Leave':
        return Colors.redAccent;
      case 'WRA':
        return Colors.orange;
      default:
        return Colors.blueAccent;
    }
  }
}

class CalendarEvent {
  final String? title; // For holiday
  final String? firstName;
  final String? lastName;
  final String? leaveType;
  final bool isHoliday;

  CalendarEvent.holiday(this.title)
    : isHoliday = true,
      firstName = null,
      lastName = null,
      leaveType = null;

  CalendarEvent.leave({
    required this.firstName,
    required this.lastName,
    required this.leaveType,
  }) : title = null,
       isHoliday = false;
}
