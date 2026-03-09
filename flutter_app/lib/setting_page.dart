import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'home_page.dart';
import 'task_page.dart';
import 'calendar_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late TextEditingController _usernameCtrl;
  late TextEditingController _emailCtrl;
  String? _profileImageUrl;
  bool _isUploadingImage = false;
  
  // สีหลักที่เราใช้ในหน้าอื่นๆ
  final Color primaryColor = const Color(0xFF2CB197);

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final email = prefs.getString('email') ?? '';
    final profileImage = prefs.getString('profile_image');

    if (!mounted) return;
    setState(() {
      _usernameCtrl.text = username;
      _emailCtrl.text = email;
      _profileImageUrl = profileImage;
    });
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // --- Logic การทำงานเดิม (คงไว้ตามที่คุณส่งมา) ---

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final email = _emailCtrl.text.trim();

    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot find user ID.')));
      return;
    }

    try {
      final url = Uri.parse('http://10.0.2.2/sche_do_project/backend_api/update_user.php');
      final response = await http.post(url, body: {'user_id': userId, 'email': email});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await prefs.setString('email', email);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved successfully!')));
          return;
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _pickAndUploadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 80);
    if (picked == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final uri = Uri.parse('http://10.0.2.2/sche_do_project/backend_api/upload_profile_image.php');
      final request = http.MultipartRequest('POST', uri)
        ..fields['user_id'] = userId
        ..files.add(await http.MultipartFile.fromPath('profile_image', picked.path));

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (responseBody.statusCode == 200) {
        final data = json.decode(responseBody.body);
        if (data['success'] == true) {
          final profileImage = data['profile_image'] as String?;
          if (profileImage != null) {
            await prefs.setString('profile_image', profileImage);
            setState(() => _profileImageUrl = profileImage);
          }
        }
      }
    } catch (e) {
       debugPrint("Upload Error: $e");
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (shouldLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // ล้างข้อมูลทั้งหมดเพื่อให้ต้อง Login ใหม่
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        automaticallyImplyLeading: false, // เอาปุ่มย้อนกลับออกเพราะมี Task bar แล้ว
        title: const Text('Profile Settings', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            // --- ส่วนรูปโปรไฟล์ ---
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
                      child: _profileImageUrl == null
                          ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                          : null,
                    ),
                  ),
                  GestureDetector(
                    onTap: _isUploadingImage ? null : _pickAndUploadProfileImage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                      child: _isUploadingImage
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // --- ช่องกรอกข้อมูล ---
            _buildInputField(_usernameCtrl, "Username", Icons.person_outline, readOnly: true),
            const SizedBox(height: 16),
            _buildInputField(_emailCtrl, "Email Address", Icons.email_outlined),
            
            const SizedBox(height: 30),
            
            // --- ปุ่มบันทึก ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: const Text('Save Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // --- ปุ่ม Logout ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildInputField(TextEditingController ctrl, String label, IconData icon, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          readOnly: readOnly,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: primaryColor),
            filled: true,
            fillColor: readOnly ? Colors.grey[100] : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            hintText: label,
          ),
        ),
      ],
    );
  }

  // --- ส่วน Task Bar (Navigation) ---
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
          _navItem(Icons.home_outlined, "Home", false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()))),
          _navItem(Icons.assignment_outlined, "Tasks", false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TaskPage()))),
          _navItem(Icons.calendar_month_outlined, "Calendar", false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CalendarPage()))),
          _navItem(Icons.person, "Profile", true), // หน้านี้คือ Active
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