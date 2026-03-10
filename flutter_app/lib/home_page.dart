import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'task_page.dart';
import 'setting_page.dart';
import 'create_task_page.dart';
import 'calendar_page.dart';

class HomePage extends StatefulWidget {
  final String? username;
  const HomePage({super.key, this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _displayName = "User";
  List<dynamic> _allTasks = [];
  bool _isLoading = true;
  int _doneCount = 0;
  int _pendingCount = 0;
  int _urgentCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _fetchTasks();
  }

  Future<void> _loadUsername() async {
    if (widget.username != null && widget.username!.isNotEmpty) {
      setState(() => _displayName = widget.username!);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username != null && username.isNotEmpty) {
      setState(() => _displayName = username);
    }
  }

  // --- ฟังก์ชันดึงข้อมูลจาก Database ---
  Future<void> _fetchTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) return;

    final url = Uri.parse(
      'http://10.0.2.2/sche_do_project/backend_api/get_tasks.php?user_id=$userId',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          _allTasks = data;
          // นับจำนวนสถานะต่างๆ
          _doneCount = data.where((t) => t['status'] == 'Completed').length;
          _pendingCount = data.where((t) => t['status'] != 'Completed').length;
          _urgentCount = data
              .where((t) => t['priority']?.toString().toLowerCase() == 'high')
              .length;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // กรองเฉพาะงานที่เป็นของวันนี้ (Today's Tasks)
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final todayTasks = _allTasks
        .where((t) => t['app_date'] == todayStr)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchTasks, // ลากลงเพื่อรีเฟรชข้อมูล
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header Section ---
                  Text(
                    "Hello,",
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  Row(
                    children: [
                      Text(
                        _displayName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text("👋", style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // --- Stat Cards Section (ข้อมูลจริง) ---
                  Row(
                    children: [
                      _buildStatCard(
                        _doneCount.toString(),
                        "Done",
                        Icons.check_circle_outline,
                        const Color(0xFFE0F2F1),
                        Colors.teal,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        _pendingCount.toString(),
                        "Pending",
                        Icons.access_time,
                        const Color(0xFFFFF3E0),
                        Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        _urgentCount.toString(),
                        "Urgent",
                        Icons.warning_amber_rounded,
                        const Color(0xFFFFEBEE),
                        Colors.red[400]!,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- Today's Tasks Section ---
                  const Text(
                    "Today's Tasks",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (todayTasks.isEmpty)
                    _buildEmptyState("No tasks for today")
                  else
                    ...todayTasks
                        .take(3)
                        .map(
                          (task) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildTaskCard(
                              task['subject'],
                              task['category'] ?? 'General',
                              task['priority'],
                            ),
                          ),
                        ),

                  const SizedBox(height: 20),

                  // --- Recent Tasks Section ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Tasks",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TaskPage(),
                          ),
                        ),
                        child: const Text(
                          "See all",
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                    ],
                  ),
                  if (_isLoading)
                    const SizedBox()
                  else if (_allTasks.isEmpty)
                    _buildEmptyState("No recent tasks")
                  else
                    ..._allTasks.reversed
                        .take(3)
                        .map(
                          (task) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildTaskCard(
                              task['subject'],
                              task['app_date'],
                              task['priority'],
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Widget กรณีไม่มีข้อมูล
  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(message, style: TextStyle(color: Colors.grey[400])),
      ),
    );
  }

  // ฟังก์ชันสร้าง Card สถิติ
  Widget _buildStatCard(
    String count,
    String label,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสร้าง Card งาน
  Widget _buildTaskCard(String title, String subtitle, String? priority) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (priority != null && priority.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priority.toLowerCase() == "high"
                        ? Colors.red[50]
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    priority.toLowerCase(),
                    style: TextStyle(
                      color: priority.toLowerCase() == "high"
                          ? Colors.red[300]
                          : Colors.orange[300],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ... _buildBottomNav และ _navItem (เหมือนเดิมจากโค้ดที่คุณมี) ...
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, "Home", Colors.teal, true),
          _navItem(
            Icons.assignment_outlined,
            "Tasks",
            Colors.grey,
            false,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TaskPage()),
            ).then((_) => _fetchTasks()),
          ),
          _navItem(
            Icons.calendar_today_outlined,
            "Calendar",
            Colors.grey,
            false,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalendarPage()),
            ).then((_) => _fetchTasks()),
          ),
          _navItem(
            Icons.person_outline,
            "Profile",
            Colors.grey,
            false,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingPage()),
            ).then((_) => _fetchTasks()),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    Color color,
    bool isActive, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
