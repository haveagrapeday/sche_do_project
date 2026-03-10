import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditTaskPage extends StatefulWidget {
  final Map task;
  const EditTaskPage({super.key, required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _catCtrl;
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _priority = "Medium";
  String _status = "Pending";
  bool _isSaving = false;

  final Color primaryColor = const Color(0xFF2CB197);

  @override
  void initState() {
    super.initState();
    // ดึงข้อมูลเดิมมาใส่ในช่องกรอก
    _titleCtrl = TextEditingController(text: widget.task['subject']);
    _descCtrl = TextEditingController(text: widget.task['description']);
    _catCtrl = TextEditingController(text: widget.task['category']);
    _priority = widget.task['priority'] ?? "Medium";
    _status = widget.task['status'] ?? "Pending";

    // จัดการเรื่องวันที่เดิม
    if (widget.task['app_date'] != null && widget.task['app_date'] != "0000-00-00") {
      _selectedDate = DateTime.parse(widget.task['app_date']);
    } else {
      _selectedDate = DateTime.now();
    }

    // จัดการเรื่องเวลาเดิม
    if (widget.task['app_time'] != null && widget.task['app_time'] != "00:00:00") {
      final parts = widget.task['app_time'].toString().split(':');
      _selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } else {
      _selectedTime = TimeOfDay.now();
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _updateTask() async {
    setState(() => _isSaving = true);
    try {
      final url = Uri.parse('http://10.0.2.2/sche_do_project/backend_api/update_task.php');
      
      // ฟอร์แมตวันที่และเวลาส่งไป Database
      final dateStr = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
      final timeStr = "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00";

      final response = await http.post(url, body: {
        'task_id': widget.task['id'].toString(),
        'subject': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'category': _catCtrl.text.trim(),
        'priority': _priority,
        'status': _status,
        'app_date': dateStr,
        'app_time': timeStr,
      });

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true); 
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Task", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Subject"),
            _buildTextField(_titleCtrl, "Task title"),

            const SizedBox(height: 20),
            _buildLabel("Description"),
            _buildTextField(_descCtrl, "Task details...", maxLines: 3),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildPickerCard("Date", _selectedDate!.toIso8601String().split('T')[0], Icons.calendar_today, _pickDate)),
                const SizedBox(width: 15),
                Expanded(child: _buildPickerCard("Time", _selectedTime!.format(context), Icons.access_time, _pickTime)),
              ],
            ),

            const SizedBox(height: 20),
            _buildLabel("Priority"),
            Row(
              children: ["Low", "Medium", "High"].map((p) => _buildChoiceChip(p, isPriority: true)).toList(),
            ),

            const SizedBox(height: 20),
            _buildLabel("Status"),
            Row(
              children: ["Pending", "In Progress", "Completed"].map((s) => _buildChoiceChip(s, isPriority: false)).toList(),
            ),

            const SizedBox(height: 20),
            _buildLabel("Category"),
            _buildTextField(_catCtrl, "Work, Personal, etc."),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _updateTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- Helpers Widgets ---
  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));

  Widget _buildTextField(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF1F4F7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPickerCard(String label, String value, IconData icon, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: const Color(0xFFF1F4F7), borderRadius: BorderRadius.circular(15)),
            child: Row(children: [Icon(icon, size: 18, color: primaryColor), const SizedBox(width: 10), Text(value)]),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceChip(String label, {required bool isPriority}) {
    bool isSelected = isPriority ? _priority == label : _status == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) => setState(() => isPriority ? _priority = label : _status = label),
        selectedColor: primaryColor,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }
}