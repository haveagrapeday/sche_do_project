import 'package:flutter/material.dart';
import 'task_page.dart'; // import เพื่อไปหน้า Task

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person, size: 100, color: Colors.indigo),
            const SizedBox(height: 20),
            const Text(
              "Welcome Back",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            TextField(
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // เมื่อกด Login ให้ย้ายไปหน้า TaskPage
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const TaskPage()),
                  );
                },
                child: const Text("Login", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}