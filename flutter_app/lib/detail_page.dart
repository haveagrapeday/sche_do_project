import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final Map task;

  const DetailPage({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // extract values with fallbacks
    final subject = task['subject'] ?? 'ไม่มีหัวข้อ';
    final description = task['description'] ?? '';
    final date = task['app_date'] ?? '-';
    final time = task['app_time'] ?? '-';

    return Scaffold(
      appBar: AppBar(title: Text(subject), backgroundColor: Colors.indigo),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 12),
            Text(description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.calendar_month, size: 20, color: Colors.indigo[300]),
                const SizedBox(width: 5),
                Text(date),
                const SizedBox(width: 20),
                Icon(Icons.access_time, size: 20, color: Colors.indigo[300]),
                const SizedBox(width: 5),
                Text(time),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
