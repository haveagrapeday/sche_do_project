import 'package:flutter/material.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.calendar_today, size: 80, color: Colors.indigo),
            SizedBox(height: 12),
            Text('Calendar view coming soon', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
