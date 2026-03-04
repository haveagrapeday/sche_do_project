import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final Color primaryColor = const Color(0xFF26A69A);
  
  // จำลองข้อมูลวันที่ (ในอนาคตสามารถใช้ DateTime.now() ได้)
  final int selectedDay = 4;
  final List<int> daysWithTasks = [5, 6, 8, 10];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Calendar",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนหัวปฏิทิน (Month Selector)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavButton(Icons.chevron_left),
                  const Text(
                    "March 2026",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildNavButton(Icons.chevron_right),
                ],
              ),
            ),

            // ตารางปฏิทิน
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // ชื่อวันในสัปดาห์
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                        .map((day) => SizedBox(
                              width: 40,
                              child: Text(
                                day,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 15),
                  // วันที่ (จำลองของเดือนมีนาคม 2026 เริ่มวันอาทิตย์ที่ 1)
                  _buildCalendarGrid(),
                ],
              ),
            ),

            const Divider(thickness: 1, height: 1),

            // ส่วนรายการงานของวัน
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Tasks",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _buildTodayTaskCard("Fix login bug", "Dev"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: () {},
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // สร้าง List ของวันที่ 1-31
    List<Widget> dayWidgets = [];
    for (int i = 1; i <= 31; i++) {
      bool isSelected = (i == selectedDay);
      bool hasTask = daysWithTasks.contains(i);

      dayWidgets.add(
        Container(
          width: 45,
          height: 55,
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$i",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              if (hasTask && !isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                )
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: 5,
      children: dayWidgets,
    );
  }

  Widget _buildTodayTaskCard(String title, String category) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(category, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ],
      ),
    );
  }
}