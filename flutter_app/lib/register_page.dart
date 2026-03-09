import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';
import 'login_page.dart'; // เพื่อให้ Navigator.pop หรือ push กลับไปหน้า Login ได้

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  
  bool _isLoading = false;
  final Color primaryColor = const Color(0xFF2CB197); // สี Teal ตามหน้าอื่นๆ

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    // 1. ตรวจสอบค่าว่าง
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('กรุณากรอกข้อมูลให้ครบทุกช่อง');
      return;
    }

    // 2. ตรวจสอบรหัสผ่านตรงกัน
    if (password != confirm) {
      _showSnackBar('รหัสผ่านไม่ตรงกัน');
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse('http://10.0.2.2/sche_do_project/backend_api/register_user.php');

    try {
      final response = await http.post(
        url,
        body: {
          'username': username,
          'password': password,
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          
          // บันทึกข้อมูลลงเครื่องเพื่อให้คงสถานะ Login
          await prefs.setString('username', username);
          await prefs.setString('email', email);
          if (data['user_id'] != null) {
            await prefs.setString('user_id', data['user_id'].toString());
          }
          // ใส่ Token สมมติเพื่อให้ระบบ Auto Login ทำงานได้
          await prefs.setString('auth_token', 'registered_user_token');

          if (!mounted) return;
          
          _showSnackBar('ลงทะเบียนสำเร็จ!');
          
          // ไปที่หน้า Home ทันที
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage(username: username)),
            (route) => false,
          );
          return;
        } else {
          _showSnackBar(data['message'] ?? 'ลงทะเบียนไม่สำเร็จ');
        }
      } else {
        _showSnackBar('เกิดข้อผิดพลาดจากเซิร์ฟเวอร์: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('การเชื่อมต่อล้มเหลว: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              // Icon ประจำหน้า
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_add_rounded, size: 80, color: primaryColor),
              ),
              const SizedBox(height: 20),
              const Text(
                "Create Account",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Sign up to get started!",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 40),

              // ช่องกรอกข้อมูล
              _buildTextField(_usernameController, "Username", Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField(_emailController, "Email", Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField(_passwordController, "Password", Icons.lock_outline, isPassword: true),
              const SizedBox(height: 16),
              _buildTextField(_confirmController, "Confirm Password", Icons.lock_reset_outlined, isPassword: true),
              
              const SizedBox(height: 30),

              // ปุ่ม Register
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Register", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 20),

              // ปุ่มย้อนกลับไปหน้า Sign In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Sign In",
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Widget ช่วยสร้าง TextField ให้สวยงาม
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: const Color(0xFFF1F4F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}