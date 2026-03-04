import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'task_page.dart';
import 'login_page.dart';
import 'setting_page.dart';
import 'create_task_page.dart';
import 'calendar_page.dart';

class HomePage extends StatefulWidget {
  final String? username; // รับค่า username เบื้องต้นมาจากหน้า Login
  const HomePage({super.key, this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _displayName = "Loading..."; // ชื่อที่จะแสดงบนหน้าจอ

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // ดึงข้อมูลจาก Database ทันทีที่เปิดหน้า
  }

  // ฟังก์ชันดึงชื่อจาก Database (อ้างอิงจาก username ของ account)
  Future<void> _fetchUserData() async {
    // แก้ไข URL ให้ตรงกับ API ที่คุณใช้ดึงข้อมูล Profile
    final url = Uri.parse(
      'http://10.0.2.2/sche_do_project/backend_api/get_user_profile.php?username=${widget.username}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // สมมติว่า API คืนค่าชื่อจริงใน key ที่ชื่อ 'full_name' หรือ 'username'
          _displayName = data['full_name'] ?? data['username'] ?? widget.username;
        });
      } else {
        setState(() => _displayName = widget.username ?? "User");
      }
    } catch (e) {
      setState(() => _displayName = widget.username ?? "User");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = const Color(0xFF26A69A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text("Hello,", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              Row(
                children: [
                  Text(
                    _displayName, // ใช้ชื่อที่ดึงมาจาก Database
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  const Text("👋", style: TextStyle(fontSize: 24)),
                ],
              ),
              const SizedBox(height: 25),
              
              // ส่วนที่เหลือของโค้ดคุณ...
              Row(
                children: [
                  _buildStatBox("Done", "1", const Color(0xFFE0F2F1), primaryColor, Icons.check_circle_outline),
                  const SizedBox(width: 15),
                  _buildStatBox("Pending", "4", const Color(0xFFFFF3E0), Colors.orange, Icons.access_time),
                  const SizedBox(width: 15),
                  _buildStatBox("Urgent", "2", const Color(0xFFFFEBEE), Colors.red, Icons.report_problem_outlined),
                ],
              ),
              const SizedBox(height: 30),
              const Text("Today's Tasks", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildTaskTile("Fix login bug", "Dev", null),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Recent Tasks", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: Text("See all", style: TextStyle(color: primaryColor))),
                ],
              ),
              _buildTaskTile("Design wireframes", "2026-03-06", "high"),
              _buildTaskTile("Weekly team meeting", "2026-03-05", "medium"),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // Widget ตัวช่วยอื่นๆ ยังคงเดิม...
  Widget _buildStatBox(String label, String count, Color bg, Color textCol, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Icon(icon, color: textCol, size: 24),
            const SizedBox(height: 8),
            Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textCol)),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTile(String title, String subtitle, String? priority) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            ],
          ),
          if (priority != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: priority == "high" ? Colors.red[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                priority,
                style: TextStyle(color: priority == "high" ? Colors.red : Colors.orange, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, "Home", true, () {}),
          _navItem(Icons.assignment_turned_in_outlined, "Tasks", false, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TaskPage()));
          }),
          _navItem(Icons.calendar_month_outlined, "Calendar", false, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarPage()));
          }),
          _navItem(Icons.person_outline, "Profile", false, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingPage()));
          }),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    Color primaryColor = const Color(0xFF26A69A);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? primaryColor : Colors.grey),
          Text(label, style: TextStyle(color: isActive ? primaryColor : Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}