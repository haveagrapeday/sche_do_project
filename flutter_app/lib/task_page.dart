import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  String selectedFilter = "All";
  
  // 1. เพิ่ม Controller สำหรับช่องค้นหา
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = ""; 

  @override
  void initState() {
    super.initState();
    getTasks();
    
    // 2. ดักจับการพิมพ์ในช่องค้นหา
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.toLowerCase();
      });
    });
  }

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

    final url = Uri.parse('http://10.0.2.2/sche_do_project/backend_api/get_tasks.php?user_id=$userId');
    
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

  // 3. ปรับปรุง Logic การกรองข้อมูล (รวมทั้ง Filter และ Search)
  List get filteredTasks {
    List tempTasks = tasks;

    // กรองตามสถานะ (All, Active, Completed)
    if (selectedFilter == "Completed") {
      tempTasks = tempTasks.where((task) => task['status'] == 'Completed').toList();
    } else if (selectedFilter == "Active") {
      tempTasks = tempTasks.where((task) => task['status'] != 'Completed').toList();
    }

    // กรองตามคำค้นหา (Subject)
    if (_searchQuery.isNotEmpty) {
      tempTasks = tempTasks.where((task) {
        String subject = (task['subject'] ?? "").toString().toLowerCase();
        return subject.contains(_searchQuery);
      }).toList();
    }

    return tempTasks;
  }

  @override
  void dispose() {
    _searchCtrl.dispose(); // คืนคืนหน่วยความจำ
    super.dispose();
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
                  const Text("Tasks", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateTaskPage()),
                      );
                      if (result == true) getTasks();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFF2CB197), shape: BoxShape.circle),
                      child: const Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                  )
                ],
              ),
            ),

            // --- Search Bar (ผูกกับ Controller) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _searchCtrl, // เชื่อมต่อ Controller
                decoration: InputDecoration(
                  hintText: "Search tasks...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  // เพิ่มปุ่มล้างคำค้นหา
                  suffixIcon: _searchQuery.isNotEmpty 
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchCtrl.clear()) 
                    : null,
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

  Widget _buildFilterTab(String label) {
    bool isActive = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2CB197) : Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTaskCard(Map item) {
    bool isDone = item['status'] == 'Completed';
    String priorityValue = (item['priority'] ?? 'Low').toString().toLowerCase();
    Color priorityBg = priorityValue == 'high' ? const Color(0xFFFFEBEE) : (priorityValue == 'medium' ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9));
    Color priorityText = priorityValue == 'high' ? const Color(0xFFE57373) : (priorityValue == 'medium' ? const Color(0xFFFFB74D) : const Color(0xFF81C784));

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(task: item)),
        );
        if (result == true) getTasks();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked, color: isDone ? const Color(0xFF2CB197) : Colors.grey[300], size: 26),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['subject'] ?? 'No Title', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, decoration: isDone ? TextDecoration.lineThrough : null, color: isDone ? Colors.grey : Colors.black87)),
                  const SizedBox(height: 4),
                  Text("${item['app_date']} • ${item['category'] ?? 'General'}", style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: priorityBg, borderRadius: BorderRadius.circular(8)),
              child: Text(priorityValue.toUpperCase(), style: TextStyle(color: priorityText, fontSize: 10, fontWeight: FontWeight.bold)),
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
          Icon(Icons.search_off, size: 70, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(_searchQuery.isEmpty ? "No $selectedFilter tasks" : "No results for '$_searchQuery'", style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, "Home", false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()))),
          _navItem(Icons.assignment_turned_in, "Tasks", true),
          _navItem(Icons.calendar_month_outlined, "Calendar", false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CalendarPage()))),
          _navItem(Icons.person_outline, "Profile", false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingPage()))),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    final color = isActive ? const Color(0xFF2CB197) : Colors.grey[400]!;
    return InkWell(onTap: onTap, child: SizedBox(width: 70, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 26), const SizedBox(height: 4), Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal))])));
  }
}