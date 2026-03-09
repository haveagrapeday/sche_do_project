import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditTaskPage extends StatefulWidget {
  final Map task; // รับข้อมูลเดิมมา
  const EditTaskPage({super.key, required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _catCtrl;
  String _priority = "Medium";
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // --- ตั้งค่าข้อมูล Default จากของเดิม ---
    _titleCtrl = TextEditingController(text: widget.task['subject']);
    _descCtrl = TextEditingController(text: widget.task['description']);
    _catCtrl = TextEditingController(text: widget.task['category']);
    _priority = widget.task['priority'] ?? "Medium";
  }

  Future<void> _updateTask() async {
    setState(() => _isSaving = true);
    try {
      final url = Uri.parse('http://10.0.2.2/sche_do_project/backend_api/update_task.php');
      final response = await http.post(url, body: {
        'task_id': widget.task['id'].toString(),
        'subject': _titleCtrl.text,
        'description': _descCtrl.text,
        'category': _catCtrl.text,
        'priority': _priority,
      });

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true); // ส่งค่ากลับว่าอัปเดตสำเร็จ
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Task"), backgroundColor: const Color(0xFF2CB197)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: "Subject")),
            const SizedBox(height: 15),
            TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: "Description"), maxLines: 3),
            const SizedBox(height: 15),
            TextField(controller: _catCtrl, decoration: const InputDecoration(labelText: "Category")),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _updateTask,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2CB197)),
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Changes", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}