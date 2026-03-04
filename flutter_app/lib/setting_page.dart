import 'package:flutter/material.dart';
import 'login_page.dart'; // อย่าลืม import ไฟล์ login_page ของคุณด้วยนะครับ

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    Color primaryColor = const Color(0xFF26A69A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        // เพิ่มปุ่มย้อนกลับให้กดได้ในกรณีที่ไม่ได้กด Sign Out
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFE0F2F1),
              child: Text("A",
                  style: TextStyle(
                      fontSize: 40,
                      color: Color(0xFF26A69A),
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            const Text("angoon",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("angoon@gmail.com", style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 30),

            // Statistics Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Statistics",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 20),
                  _buildStatRow(Icons.list_alt, "Total Tasks", "5"),
                  _buildStatRow(Icons.check_circle_outline, "Completed", "1",
                      iconColor: Colors.teal),
                  _buildStatRow(Icons.access_time, "Pending", "4",
                      iconColor: Colors.orange),
                  const SizedBox(height: 15),
                  const Text("Completion rate",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.2,
                    backgroundColor: Colors.grey[200],
                    color: primaryColor,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                // แก้ไขส่วนนี้ครับ
                onPressed: () {
                  // Logout และกลับไปหน้า Login โดยไม่สามารถกด Back กลับมาได้
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text("Sign Out",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEBEE),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String title, String value,
      {Color iconColor = Colors.grey}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 15)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}