import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clock In & Login App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
      ),
      home: const ClockInPage(),
    );
  }
}

// Enum to manage the user's current status
enum ClockStatus { clockedOut, clockedIn, onLunch }

class ClockInPage extends StatefulWidget {
  const ClockInPage({super.key});

  @override
  State<ClockInPage> createState() => _ClockInPageState();
}

class _ClockInPageState extends State<ClockInPage> {
  ClockStatus _status = ClockStatus.clockedOut;
  DateTime? _clockInTime;
  DateTime? _lunchInTime;
  DateTime? _lunchOutTime;
  DateTime? _clockOutTime;

  // Mock data using the Employee class
  final List<Employee> _leaveToday = List.generate(
    6,
    (index) => Employee(
      firstName: ['Olivia', 'Liam', 'Emma', 'Noah', 'Amelia', 'Oliver'][index],
      lastName: ['Chen', 'Patel', 'Garcia', 'Kim', 'Wong', 'Lee'][index],
      imageUrl:
          'https://placehold.co/64x64/E9ECEF/495057?text=${['OC', 'LP', 'EG', 'NK', 'AW', 'OL'][index]}',
    ),
  );
  final List<Employee> _leaveTomorrow = List.generate(
    5,
    (index) => Employee(
      firstName: ['Sophia', 'James', 'Isabella', 'William', 'Ava'][index],
      lastName: ['Rodriguez', 'Smith', 'Martinez', 'Johnson', 'Brown'][index],
      imageUrl:
          'https://placehold.co/64x64/E9ECEF/495057?text=${['SR', 'JS', 'IM', 'WJ', 'AB'][index]}',
    ),
  );
  final List<Employee> _leaveDayAfter = List.generate(
    4,
    (index) => Employee(
      firstName: ['Mia', 'Benjamin', 'Charlotte', 'Elijah'][index],
      lastName: ['Davis', 'Miller', 'Wilson', 'Taylor'][index],
      imageUrl:
          'https://placehold.co/64x64/E9ECEF/495057?text=${['MD', 'BM', 'CW', 'ET'][index]}',
    ),
  );

  void _handleClockIn() => setState(() {
    _status = ClockStatus.clockedIn;
    _clockInTime = DateTime.now();
  });
  void _handleClockOut() => setState(() {
    _status = ClockStatus.clockedOut;
    _clockOutTime = DateTime.now();
  });
  void _handleLunchIn() => setState(() {
    _status = ClockStatus.onLunch;
    _lunchInTime = DateTime.now();
  });
  void _handleLunchOut() => setState(() {
    _status = ClockStatus.clockedIn;
    _lunchOutTime = DateTime.now();
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The main container with the gradient background
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        // A clean, transparent AppBar that blends with the background
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Time & Attendance',
          style: TextStyle(
            color: Color(0xFF212529),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add_outlined, color: Color(0xFF495057)),
            onPressed: () {
              /* TODO: Navigate to apply leave page */
            },
            tooltip: 'Apply for Leave',
          ),
          IconButton(
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF495057),
            ),
            onPressed: () {
              /* TODO: Navigate to holiday list page */
            },
            tooltip: 'Holiday List',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF), Color(0xFFDEE2E6)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6C757D),
                  ),
                ),
                const SizedBox(height: 32),
                _buildActionButtons(), // Action Buttons based on status
                const SizedBox(height: 40),
                const Divider(color: Color(0xFFADB5BD)),
                const SizedBox(height: 24),
                const Text(
                  "Who's On Leave",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF343A40),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLeaveCard('Today', _leaveToday),
                const SizedBox(height: 16),
                _buildLeaveCard('Tomorrow', _leaveTomorrow),
                const SizedBox(height: 16),
                _buildLeaveCard('Day After Tomorrow', _leaveDayAfter),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget to build action buttons based on the user's current status
  Widget _buildActionButtons() {
    switch (_status) {
      case ClockStatus.clockedOut:
        return _buildButton(
          'CLOCK IN',
          Icons.timer_outlined,
          const Color(0xFF28A745),
          _handleClockIn,
        );
      case ClockStatus.clockedIn:
        return Column(
          children: [
            _buildButton(
              'LUNCH IN',
              Icons.free_breakfast_outlined,
              const Color(0xFFFFA500),
              _handleLunchIn,
            ),
            const SizedBox(height: 16),
            _buildButton(
              'CLOCK OUT',
              Icons.timer_off_outlined,
              const Color(0xFFDC3545),
              _handleClockOut,
            ),
          ],
        );
      case ClockStatus.onLunch:
        // Now includes Clock Out button even during lunch
        return Column(
          children: [
            _buildButton(
              'LUNCH OUT',
              Icons.restaurant_menu_outlined,
              const Color(0xFF17A2B8),
              _handleLunchOut,
            ),
            const SizedBox(height: 16),
            _buildButton(
              'CLOCK OUT',
              Icons.timer_off_outlined,
              const Color(0xFFDC3545),
              _handleClockOut,
            ),
          ],
        );
    }
  }

  // Helper for creating the styled action buttons
  Widget _buildButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
    );
  }

  // Helper widget for the leave information cards
  Widget _buildLeaveCard(String title, List<Employee> employees) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF495057),
              ),
            ),
            const Divider(height: 20),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: employees
                  .map((employee) => _buildEmployeeInfo(employee))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // A new helper widget to display employee info with a profile picture
  Widget _buildEmployeeInfo(Employee employee) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(employee.imageUrl),
          // Provides a fallback for image loading errors
          onBackgroundImageError: (_, __) {},
          backgroundColor: const Color(0xFFE9ECEF),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              employee.firstName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF343A40),
              ),
            ),
            Text(
              employee.lastName,
              style: const TextStyle(color: Color(0xFF6C757D)),
            ),
          ],
        ),
      ],
    );
  }
}
