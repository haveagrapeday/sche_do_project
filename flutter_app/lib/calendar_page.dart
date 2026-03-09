import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Import หน้าอื่นๆ สำหรับ Navigation
import 'home_page.dart';
import 'task_page.dart';
import 'setting_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final Color primaryColor = const Color(0xFF2CB197);

  DateTime _focusedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  
  List<dynamic> _allTasks = []; // เก็บงานทั้งหมดจาก Database
  List<dynamic> _tasksForSelectedDay = []; // เก็บงานเฉพาะวันที่เลือก
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasksFromDatabase();
  }

  // --- ฟังก์ชันดึงข้อมูลจาก Database ---
  Future<void> _fetchTasksFromDatabase() async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    // แก้ไข URL ให้ตรงกับ API ของคุณ
    final url = Uri.parse(
      'http://10.0.2.2/sche_do_project/backend_api/get_tasks.php?user_id=$userId',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _allTasks = data;
          _isLoading = false;
        });
        // อัปเดตรายการงานของวันที่เลือกไว้ (ค่าเริ่มต้นคือวันนี้)
        _updateTasksForDay(_selectedDate);
      }
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- ฟังก์ชันกรองงานตามวันที่เลือก ---
  void _updateTasksForDay(DateTime date) {
    setState(() {
      _selectedDate = date;
      _tasksForSelectedDay = _allTasks.where((task) {
        // ตรวจสอบว่าวันที่ใน Database ตรงกับวันที่เลือกหรือไม่
        // สมมติว่าใน DB วันที่เก็บใน field ชื่อ 'app_date' รูปแบบ YYYY-MM-DD
        DateTime taskDate = DateTime.parse(task['app_date']);
        return taskDate.day == date.day &&
               taskDate.month == date.month &&
               taskDate.year == date.year;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Calendar",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ส่วนควบคุมเดือน
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_getMonthName(_focusedDate.month)} ${_focusedDate.year}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          _buildNavButton(Icons.chevron_left, () {
                            setState(() {
                              _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
                            });
                          }),
                          const SizedBox(width: 8),
                          _buildNavButton(Icons.chevron_right, () {
                            setState(() {
                              _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
                            });
                          }),
                        ],
                      ),
                    ],
                  ),
                ),

                // ตารางปฏิทิน
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                            .map((day) => SizedBox(
                                width: 40,
                                child: Text(day, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold))))
                            .toList(),
                      ),
                      const SizedBox(height: 15),
                      _buildCalendarGrid(),
                    ],
                  ),
                ),

                // รายการงาน
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedDate.day == DateTime.now().day && _selectedDate.month == DateTime.now().month 
                          ? "Today's Tasks" 
                          : "Tasks for ${_selectedDate.day}/${_selectedDate.month}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      _tasksForSelectedDay.isEmpty
                          ? Center(child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Text("No tasks for this day", style: TextStyle(color: Colors.grey[400])),
                            ))
                          : Column(
                              children: _tasksForSelectedDay.map((task) => 
                                _buildTodayTaskCard(
                                  task['subject'] ?? 'No Title', 
                                  task['app_time'] ?? '--:--',
                                  task['priority'] ?? 'normal'
                                )
                              ).toList(),
                            ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- Widget สร้างตารางวันที่ ---
  Widget _buildCalendarGrid() {
    int daysInMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
    int firstDayOffset = DateTime(_focusedDate.year, _focusedDate.month, 1).weekday % 7;
    
    List<Widget> dayWidgets = [];

    for (int i = 0; i < firstDayOffset; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    for (int i = 1; i <= daysInMonth; i++) {
      DateTime currentDay = DateTime(_focusedDate.year, _focusedDate.month, i);
      bool isSelected = (i == _selectedDate.day && _focusedDate.month == _selectedDate.month && _focusedDate.year == _selectedDate.year);
      
      // ตรวจสอบว่าวันนั้นมีงานหรือไม่เพื่อแสดงจุด Marker
      bool hasTask = _allTasks.any((task) {
        DateTime taskDate = DateTime.parse(task['app_date']);
        return taskDate.day == i && taskDate.month == _focusedDate.month && taskDate.year == _focusedDate.year;
      });

      dayWidgets.add(
        GestureDetector(
          onTap: () => _updateTasksForDay(currentDay),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$i",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (hasTask && !isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                    )
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: (MediaQuery.of(context).size.width - 40 - 32 - (40 * 7)) / 6,
      runSpacing: 10,
      children: dayWidgets,
    );
  }

  // --- Widget Card แสดงงาน ---
  Widget _buildTodayTaskCard(String title, String time, String priority) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 4, 
            height: 40, 
            decoration: BoxDecoration(
              color: priority.toLowerCase() == 'high' ? Colors.red : primaryColor, 
              borderRadius: BorderRadius.circular(2)
            )
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Time: $time", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... ส่วนอื่นๆ ( _getMonthName, _buildBottomNav, _navItem) เหมือนเดิม ...
  String _getMonthName(int month) {
    const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    return months[month - 1];
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[200]!)),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, "Home", false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()))),
          _navItem(Icons.assignment_outlined, "Tasks", false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TaskPage()))),
          _navItem(Icons.calendar_month, "Calendar", true),
          _navItem(Icons.person_outline, "Profile", false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingPage()))),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    final color = isActive ? primaryColor : Colors.grey[400]!;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}