import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Import หน้าที่เกี่ยวข้อง
import 'home_page.dart';
import 'detail_page.dart';
import 'create_task_page.dart';
import 'calendar_page.dart';
import 'setting_page.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List tasks = [];
  bool isLoading = true;
  String selectedFilter = "All"; // สถานะตัวกรอง: All, Active, Completed

  @override
  void initState() {
    super.initState();
    getTasks();
  }

  // --- Logic ดึงข้อมูลจาก Database ---
  Future<void> getTasks() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null || userId.isEmpty) {
      setState(() {
        tasks = [];
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
      'http://10.0.2.2/sche_do_project/backend_api/get_tasks.php?user_id=$userId',
    );
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          tasks = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  // --- Logic การกรองข้อมูลตาม Filter ที่เลือก ---
  List get filteredTasks {
    if (selectedFilter == "All") return tasks;
    if (selectedFilter == "Completed") {
      return tasks.where((task) => task['status'] == 'Completed').toList();
    }
    if (selectedFilter == "Active") {
      return tasks.where((task) => task['status'] != 'Completed').toList();
    }
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            // --- Header Section ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tasks",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateTaskPage()),
                      );
                      if (result == true) getTasks(); // รีเฟรชข้อมูลเมื่อกลับมา
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2CB197),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                  )
                ],
              ),
            ),

            // --- Search Bar ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search tasks...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFF1F4F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // --- Filter Tabs ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterTab("All"),
                  _buildFilterTab("Active"),
                  _buildFilterTab("Completed"),
                ],
              ),
            ),

            // --- Task List ---
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF2CB197)))
                  : filteredTasks.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            return _buildTaskCard(filteredTasks[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- Widget สำหรับปุ่มตัวกรอง ---
  Widget _buildFilterTab(String label) {
    bool isActive = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2CB197) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isActive ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- Widget สำหรับ Card งานพร้อมการแบ่งสี Priority ---
  Widget _buildTaskCard(Map item) {
    bool isDone = item['status'] == 'Completed';
    
    // Logic การเลือกสีตามความสำคัญ (Priority)
    String priorityValue = (item['priority'] ?? 'Low').toString().toLowerCase();
    Color priorityBg;
    Color priorityText;

    switch (priorityValue) {
      case 'high':
        priorityBg = const Color(0xFFFFEBEE); // แดงระเรื่อ
        priorityText = const Color(0xFFE57373); // แดง
        break;
      case 'medium':
        priorityBg = const Color(0xFFFFF3E0); // ส้มระเรื่อ
        priorityText = const Color(0xFFFFB74D); // ส้ม
        break;
      default: // low หรืออื่นๆ
        priorityBg = const Color(0xFFE8F5E9); // เขียวระเรื่อ
        priorityText = const Color(0xFF81C784); // เขียว
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(task: item)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? const Color(0xFF2CB197) : Colors.grey[300],
              size: 26,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['subject'] ?? 'No Title',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? Colors.grey : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${item['app_date']} • ${item['category'] ?? 'General'}",
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            ),
            // Badge แสดง Priority
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: priorityBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                priorityValue.toUpperCase(),
                style: TextStyle(
                  color: priorityText,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 70, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text("No $selectedFilter tasks", style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }

  // --- Navigation Bar ---
  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, "Home", false, onTap: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
          }),
          _navItem(Icons.assignment_turned_in, "Tasks", true),
          _navItem(Icons.calendar_month_outlined, "Calendar", false, onTap: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CalendarPage()));
          }),
          _navItem(Icons.person_outline, "Profile", false, onTap: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingPage()));
          }),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    final color = isActive ? const Color(0xFF2CB197) : Colors.grey[400]!;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}