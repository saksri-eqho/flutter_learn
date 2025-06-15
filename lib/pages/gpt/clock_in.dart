import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clock In Page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: const ClockInPage(),
    );
  }
}

class ClockInPage extends StatefulWidget {
  const ClockInPage({super.key});

  @override
  State<ClockInPage> createState() => _ClockInPageState();
}

class _ClockInPageState extends State<ClockInPage> {
  bool clockedIn = false;
  bool onLunch = false;

  final List<Map<String, String>> mockEmployees = List.generate(10, (index) {
    return {
      'firstName': 'John',
      'lastName': 'Doe $index',
      'imageUrl': 'https://i.pravatar.cc/150?img=${index + 1}',
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clock In Dashboard'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: "Holiday List",
            onPressed: () {
              // Navigate to holiday list
            },
          ),
          IconButton(
            icon: const Icon(Icons.time_to_leave),
            tooltip: "Apply for Leave",
            onPressed: () {
              // Navigate to apply for leave page
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF74EBD5), Color(0xFF9FACE6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            _buildButtons(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _leaveCard("On Leave Today", mockEmployees),
                  _leaveCard("On Leave Tomorrow", mockEmployees),
                  _leaveCard("On Leave Day After Tomorrow", mockEmployees),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    List<Widget> buttons = [];

    if (!clockedIn) {
      buttons.add(
        _customButton("Clock In", Colors.green, () {
          setState(() {
            clockedIn = true;
            onLunch = false;
          });
        }),
      );
    } else {
      buttons.add(
        _customButton("Clock Out", Colors.redAccent, () {
          setState(() {
            clockedIn = false;
            onLunch = false;
          });
        }),
      );

      if (!onLunch) {
        buttons.add(
          _customButton("Lunch In", Colors.orange, () {
            setState(() {
              onLunch = true;
            });
          }),
        );
      } else {
        buttons.add(
          _customButton("Lunch Out", Colors.deepOrangeAccent, () {
            setState(() {
              onLunch = false;
            });
          }),
        );
      }
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: buttons,
    );
  }

  Widget _customButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _leaveCard(String title, List<Map<String, String>> employees) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...employees.map((e) => _employeeTile(e)),
          ],
        ),
      ),
    );
  }

  Widget _employeeTile(Map<String, String> employee) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(employee['imageUrl']!),
          ),
          const SizedBox(width: 12),
          Text(
            "${employee['firstName']} ${employee['lastName']}",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
