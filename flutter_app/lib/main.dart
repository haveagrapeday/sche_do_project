import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo, // กำหนดโทนสีของแอป
      ),
      home: const MyHome(),
    ),
  );
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  List tasks = [];
  bool isLoading = true;

  Future<void> getTasks() async {
    setState(() => isLoading = true);
    final url = Uri.parse(
      'http://10.0.2.2/sche_do_project/backend_api/get_tasks.php',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          tasks = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "My Appointments",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: getTasks,
            icon: const Icon(Icons.refresh),
          ), // ปุ่มรีเฟรช
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return _buildTaskCard(tasks[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // ส่วนนี้ไว้ใส่ Navigator ไปหน้าเพิ่มข้อมูลภายหลัง
        },
        label: const Text("เพิ่มนัดหมาย"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // วิดเจ็ตหน้าว่างเปล่า
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "ยังไม่มีการนัดหมาย",
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // หน้า UI
  Widget _buildTaskCard(Map item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item['subject'] ?? 'ไม่มีหัวข้อ',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                const Icon(Icons.more_vert),
              ],
            ),
            const Divider(height: 20),
            Text(
              item['description'] ?? '',
              style: TextStyle(color: Colors.grey[700], fontSize: 15),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildInfoTag(Icons.calendar_month, item['app_date'] ?? '-'),
                const SizedBox(width: 15),
                _buildInfoTag(Icons.access_time, item['app_time'] ?? '-'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // วิดเจ็ตแถบข้อมูลเล็กๆ (Tag)
  Widget _buildInfoTag(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.indigo[300]),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
