import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFf0f2f5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF333333), letterSpacing: 1.2)),
                const SizedBox(height: 8),
                const Text('Chào mừng bạn quay trở lại với MoveTime', style: TextStyle(fontSize: 14, color: Color(0xFF777777))),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Email đăng nhập', hintText: 'Nhập email của bạn',
                          labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFd97706))),
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                        ),
                        validator: (v) => v!.contains('@') ? null : 'Email không hợp lệ',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: true,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu', hintText: 'Nhập mật khẩu',
                          labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFd97706))),
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                        ),
                        validator: (v) => v!.length >= 6 ? null : 'Tối thiểu 6 ký tự',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Checkbox(value: _rememberMe, onChanged: (val) => setState(() => _rememberMe = val ?? false), activeColor: const Color(0xFFd97706)),
                            const Text('Ghi nhớ tôi', style: TextStyle(fontSize: 13, color: Color(0xFF555555))),
                          ]),
                          TextButton(onPressed: () {}, child: const Text('Quên mật khẩu?', style: TextStyle(fontSize: 13, color: Color(0xFFd97706), fontWeight: FontWeight.w600))),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFd97706), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              bool success = await auth.signIn(_emailCtrl.text.trim(), _passCtrl.text.trim());
                              if (!success && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng nhập thất bại')));
                            }
                          },
                          child: const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Bạn chưa có tài khoản? "),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen())),
                      child: const Text('Đăng ký ngay', style: TextStyle(color: Color(0xFFd97706), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}