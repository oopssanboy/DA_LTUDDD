import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFd97706),
                child: Text(
                  (user?.email ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.email ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 32),
            const Text(
              'Đổi mật khẩu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _newPassCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu mới',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (v) => v!.length >= 6 ? null : 'Tối thiểu 6 ký tự',
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          await user?.updatePassword(_newPassCtrl.text.trim());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đổi mật khẩu thành công')),
                          );
                          _newPassCtrl.clear();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Cập nhật mật khẩu'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await auth.signOut();
              },
              child: const Text('Đăng xuất'),
            ),
          ],
        ),
      ),
    );
  }
}