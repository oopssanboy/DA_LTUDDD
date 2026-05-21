import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: NeonBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('MoveTime', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 241, 109, 21), letterSpacing: 2)),
                  const SizedBox(height: 30),
                  GlassContainer(
                    borderRadius: 30,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'ĐĂNG KÝ', 
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tạo tài khoản để nhận nhiều ưu đãi', 
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.white54)
                        ),
                        const SizedBox(height: 30),
                        
                        TextFormField(
                          controller: _emailCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Email đăng ký', 'Nhập email của bạn', Icons.email_outlined),
                          validator: (v) => v!.contains('@') ? null : 'Email không hợp lệ',
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Mật khẩu', 'Tạo mật khẩu', Icons.lock_outline),
                          validator: (v) => v!.length >= 6 ? null : 'Tối thiểu 6 ký tự',
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _confirmPassCtrl,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Xác nhận mật khẩu', 'Nhập lại mật khẩu', Icons.lock_outline),
                          validator: (v) {
                            if (v!.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                            if (v != _passCtrl.text) return 'Mật khẩu không khớp';
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        
                        if (auth.loading)
                          const Center(child: CircularProgressIndicator(color: AppTheme.neonPink))
                        else
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.neonPink, 
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  bool success = await auth.signUp(_emailCtrl.text.trim(), _passCtrl.text.trim());
                                  if (success) {
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thành công', style: TextStyle(color: Colors.white))));
                                    Navigator.pop(context);
                                  }
                                }
                              },
                              child: const Text('ĐĂNG KÝ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Bạn đã có tài khoản? ", style: TextStyle(color: Colors.white70)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text('Đăng nhập ngay', style: TextStyle(color: AppTheme.neonBlue, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white54),
      hintStyle: const TextStyle(color: Colors.white30),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.neonBlue)),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}