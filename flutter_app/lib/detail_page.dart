import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_task_page.dart';

class DetailPage extends StatefulWidget {
  final Map task;
  const DetailPage({super.key, required this.task});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isUpdating = false;
  final Color primaryColor = const Color(0xFF2CB197);

  // ฟังก์ชันลบข้อมูล
  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Task?"),
        content: const Text("Are you sure you want to remove this task?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), 
            child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isUpdating = true);

    try {
      final url = Uri.parse('http://10.0.2.2/sche_do_project/backend_api/delete_task.php');
      final response = await http.post(url, body: {
        'task_id': widget.task['id'].toString(),
      });

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true); // ส่งค่า true กลับไปให้หน้า TaskPage รีเฟรช
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String priority = (widget.task['priority'] ?? 'Low').toString();
    Color pColor = priority.toLowerCase() == 'high' ? Colors.red : (priority.toLowerCase() == 'medium' ? Colors.orange : Colors.green);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF2CB197)),
            onPressed: () async {
              final result = await Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => EditTaskPage(task: widget.task))
              );
              if (result == true) Navigator.pop(context, true);
            },
          ),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: _deleteTask),
        ],
      ),
      body: _isUpdating 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: pColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text("${priority.toUpperCase()} PRIORITY", style: TextStyle(color: pColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(height: 15),
                Text(widget.task['subject'] ?? 'No Title', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Text(widget.task['description'] ?? '', style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
                const SizedBox(height: 30),
                _buildDetailRow(Icons.calendar_today_outlined, "Due Date", widget.task['app_date'] ?? '-'),
                _buildDetailRow(Icons.access_time_outlined, "Time", widget.task['app_time'] ?? '-'),
                _buildDetailRow(Icons.label_outline, "Category", widget.task['category'] ?? 'General'),
                _buildDetailRow(Icons.flag_outlined, "Status", widget.task['status'] ?? "Pending"),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.grey[600])),
          const SizedBox(width: 15),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
        ],
      ),
    );
  }
}