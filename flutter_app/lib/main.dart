import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: MyApp(), // ลบ const ออกแล้ว
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List tasks = [];

  Future<void> getTasks() async {
    
    final url = Uri.parse('http://10.0.2.2/sche_do_project/backend_api/get_tasks.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          tasks = json.decode(response.body);
        });
      }
    } catch (e) {
      print("Error: $e");
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
      appBar: AppBar(title: Text("My Appointment")),
      body: tasks.isEmpty 
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text(tasks[index]['subject'] ?? ''),
                  subtitle: Text("รายละเอียด: ${tasks[index]['description']}\nวันที่: ${tasks[index]['app_date']} เวลา: ${tasks[index]['app_time']}"),
                  isThreeLine: true, // เพื่อให้แสดง subtitle ได้หลายบรรทัด
                );
              },
            ),
    );
  }
}