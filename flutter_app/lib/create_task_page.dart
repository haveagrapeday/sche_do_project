import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _catCtrl = TextEditingController(); // เพิ่ม Category
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _priority = "Medium"; // ค่าเริ่มต้น
  String? _userId;
  bool _isSaving = false;

  final Color primaryColor = const Color(0xFF2CB197);

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('user_id');
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _showSnack('Please enter a title');
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      _showSnack('Please select date and time');
      return;
    }

    setState(() => _isSaving = true);

    if (_userId == null || _userId!.isEmpty) {
      _showSnack('Cannot find user ID (please log in again)');
      setState(() => _isSaving = false);
      return;
    }

    try {
      final url = Uri.parse('http://10.0.2.2/sche_do_project/backend_api/add_task.php');
      final appDate = _selectedDate!.toLocal().toIso8601String().split('T')[0];
      final appTime = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

      final response = await http.post(
        url,
        body: {
          'user_id': _userId!,
          'subject': title,
          'description': _descCtrl.text.trim(),
          'app_date': appDate,
          'app_time': appTime,
          'priority': _priority, // ส่ง priority ไปด้วย
          'category': _catCtrl.text.trim(), // ส่ง category ไปด้วย
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          _showSnack('Task added successfully');
          Navigator.pop(context, true);
        } else {
          _showSnack(result['message'] ?? 'Error');
        }
      }
    } catch (e) {
      _showSnack('Network error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _catCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFF1F4F7),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text("New Task", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Title"),
            _buildTextField(_titleCtrl, "What needs to be done?"),
            
            const SizedBox(height: 20),
            _buildLabel("Description"),
            _buildTextField(_descCtrl, "Add details...", maxLines: 3),

            const SizedBox(height: 20),
            _buildLabel("Priority"),
            Row(
              children: [
                _buildPriorityBtn("Low", Colors.green),
                const SizedBox(width: 10),
                _buildPriorityBtn("Medium", Colors.orange),
                const SizedBox(width: 10),
                _buildPriorityBtn("High", Colors.red),
              ],
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Due Date"),
                      InkWell(
                        onTap: _pickDate,
                        child: _buildPickerBox(
                          _selectedDate == null ? "Select Date" : "${_selectedDate!.toLocal()}".split(' ')[0],
                          Icons.calendar_today,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Time"),
                      InkWell(
                        onTap: _pickTime,
                        child: _buildPickerBox(
                          _selectedTime == null ? "Select Time" : _selectedTime!.format(context),
                          Icons.access_time,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            _buildLabel("Category"),
            _buildTextField(_catCtrl, "e.g. Work, Personal, Dev"),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Task", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF1F4F7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(18),
      ),
    );
  }

  Widget _buildPickerBox(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: TextStyle(color: _selectedDate == null && icon == Icons.calendar_today || _selectedTime == null && icon == Icons.access_time ? Colors.grey : Colors.black87)),
          Icon(icon, size: 20, color: primaryColor),
        ],
      ),
    );
  }

  Widget _buildPriorityBtn(String label, Color color) {
    bool isSelected = _priority == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : const Color(0xFFF1F4F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}