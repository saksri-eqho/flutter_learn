import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// --- DATA MODELS ---

// A simple class to model an employee
class Employee {
  final String firstName;
  final String lastName;
  final String imageUrl;

  Employee({
    required this.firstName,
    required this.lastName,
    required this.imageUrl,
  });
}

// A class for holiday events
class Holiday {
  final String name;
  Holiday(this.name);

  @override
  String toString() => name;
}

// A class for leave events
class LeaveEvent {
  final Employee employee;
  final String leaveType;
  LeaveEvent({required this.employee, required this.leaveType});

  @override
  String toString() =>
      '${employee.firstName} ${employee.lastName} ($leaveType)';
}

// --- CALENDAR PAGE WIDGET ---

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<List<dynamic>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Using a Map to store events. The key is the date, value is a list of events.
  final Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _generateMockEvents();
  }

  // Method to generate mock data for the calendar
  void _generateMockEvents() {
    final random = Random();
    final leaveTypes = [
      'Annual Leave',
      'Sick Leave',
      'Work From Home',
      'Personal Day',
    ];
    final employees = [
      Employee(
        firstName: 'Zoe',
        lastName: 'Bell',
        imageUrl: 'https://placehold.co/64x64/E9ECEF/495057?text=ZB',
      ),
      Employee(
        firstName: 'Yara',
        lastName: 'Shah',
        imageUrl: 'https://placehold.co/64x64/E9ECEF/495057?text=YS',
      ),
      Employee(
        firstName: 'Xavier',
        lastName: 'King',
        imageUrl: 'https://placehold.co/64x64/E9ECEF/495057?text=XK',
      ),
      Employee(
        firstName: 'Liam',
        lastName: 'Patel',
        imageUrl: 'https://placehold.co/64x64/E9ECEF/495057?text=LP',
      ),
      Employee(
        firstName: 'Noah',
        lastName: 'Kim',
        imageUrl: 'https://placehold.co/64x64/E9ECEF/495057?text=NK',
      ),
      Employee(
        firstName: 'Ava',
        lastName: 'Brown',
        imageUrl: 'https://placehold.co/64x64/E9ECEF/495057?text=AB',
      ),
    ];

    // Add a mock holiday
    final today = DateTime.now();
    _events[DateTime.utc(today.year, today.month, 10)] = [
      Holiday('National Day'),
    ];
    _events[DateTime.utc(today.year, today.month, 25)] = [
      Holiday('Founders Day'),
    ];

    // Add random leave events for the current month on weekdays
    for (int i = 0; i < 15; i++) {
      final day = random.nextInt(28) + 1;
      final date = DateTime.utc(today.year, today.month, day);

      // Ensure it's a weekday
      if (date.weekday != DateTime.saturday &&
          date.weekday != DateTime.sunday) {
        final employee = employees[random.nextInt(employees.length)];
        final leaveType = leaveTypes[random.nextInt(leaveTypes.length)];
        final event = LeaveEvent(employee: employee, leaveType: leaveType);

        if (_events[date] == null) _events[date] = [];
        _events[date]!.add(event);
      }
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    // Return list of events from map. Corrected day.day from day.
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF495057)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: Color(0xFF212529),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 8.0),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: _onDaySelected,
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        eventLoader: _getEventsForDay,
        calendarStyle: _calendarStyle(),
        headerStyle: _headerStyle(),
        calendarBuilders: _calendarBuilders(),
      ),
    );
  }

  Widget _buildEventList() {
    return ValueListenableBuilder<List<dynamic>>(
      valueListenable: _selectedEvents,
      builder: (context, value, _) {
        if (value.isEmpty) {
          return const Center(
            child: Text(
              'No events for this day.',
              style: TextStyle(color: Color(0xFF6C757D), fontSize: 16),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: value.length,
          itemBuilder: (context, index) {
            final event = value[index];
            if (event is Holiday) {
              return _buildHolidayTile(event);
            } else if (event is LeaveEvent) {
              return _buildLeaveTile(event);
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildHolidayTile(Holiday holiday) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: const Color(0xFFE3F2FD),
      child: ListTile(
        leading: const Icon(Icons.celebration, color: Color(0xFF4A90E2)),
        title: Text(
          holiday.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF212529),
          ),
        ),
        subtitle: const Text('Public Holiday'),
      ),
    );
  }

  Widget _buildLeaveTile(LeaveEvent event) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(event.employee.imageUrl),
          backgroundColor: const Color(0xFFE9ECEF),
        ),
        title: Text(
          '${event.employee.firstName} ${event.employee.lastName}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          event.leaveType,
          style: TextStyle(
            color: _getLeaveTypeColor(event.leaveType),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // --- STYLING HELPERS ---

  CalendarStyle _calendarStyle() {
    return CalendarStyle(
      todayDecoration: BoxDecoration(
        color: const Color(0xFFADB5BD).withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      selectedDecoration: const BoxDecoration(
        color: Color(0xFF4A90E2),
        shape: BoxShape.circle,
      ),
      markerDecoration: const BoxDecoration(
        color: Color(0xFFFFA500),
        shape: BoxShape.circle,
      ),
      outsideDaysVisible: false,
    );
  }

  HeaderStyle _headerStyle() {
    return HeaderStyle(
      titleCentered: true,
      formatButtonVisible: false,
      titleTextStyle: const TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: Color(0xFF212529),
      ),
      leftChevronIcon: const Icon(Icons.chevron_left, color: Color(0xFF495057)),
      rightChevronIcon: const Icon(
        Icons.chevron_right,
        color: Color(0xFF495057),
      ),
    );
  }

  CalendarBuilders _calendarBuilders() {
    return CalendarBuilders(
      markerBuilder: (context, date, events) {
        if (events.isNotEmpty) {
          // Creating a list of unique colors for the markers
          final markerColors = events
              .map((event) {
                return event is Holiday
                    ? const Color(0xFF4A90E2)
                    : const Color(0xFFFFA500);
              })
              .toSet()
              .toList();

          return Positioned(
            right: 4,
            bottom: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: markerColors
                  .map(
                    (color) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        }
        return null;
      },
    );
  }

  Color _getLeaveTypeColor(String leaveType) {
    switch (leaveType) {
      case 'Annual Leave':
        return const Color(0xFF28A745);
      case 'Sick Leave':
        return const Color(0xFFDC3545);
      case 'Work From Home':
        return const Color(0xFF17A2B8);
      case 'Personal Day':
        return const Color(0xFF6f42c1);
      default:
        return const Color(0xFF6C757D);
    }
  }
}
