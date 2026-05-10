import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Đăng ký MoveTime', style: TextStyle(fontSize: 28, color: Colors.red, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red.shade200)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                  ),
                  validator: (v) => v!.contains('@') ? null : 'Email không hợp lệ',
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red.shade200)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                  ),
                  validator: (v) => v!.length >= 6 ? null : 'Tối thiểu 6 ký tự',
                ),
                const SizedBox(height: 20),
                if (auth.loading)
                  const CircularProgressIndicator()
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          bool success = await auth.signUp(_emailCtrl.text.trim(), _passCtrl.text.trim());
                          if (success) {
                            Navigator.pop(context); // về login
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thất bại')));
                          }
                        }
                      },
                      child: const Text('Đăng ký', style: TextStyle(fontSize: 16)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}