import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; // THÊM THƯ VIỆN HTTP
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _newPassCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final String _cloudName = 'dpywl6fkb'; // Ví dụ: 'dxyz123ab'
  final String _uploadPreset = 'ml_default';
  
  final FirestoreService _firestoreService = FirestoreService();
  String _avatarUrl = 'https://via.placeholder.com/150';
  bool _isLoading = false;

  // HƯỚNG DẪN: Truy cập https://api.imgbb.com/ để tạo tài khoản miễn phí và lấy API Key của riêng bạn
  final String _imgBbApiKey = 'aff26afe769ba47d6c81bd0fdd1fc0c2'; 

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profile = await _firestoreService.getUserProfile(user.uid);
      if (profile != null) {
        setState(() {
          _nameCtrl.text = profile['displayName'] ?? '';
          _bioCtrl.text = profile['bio'] ?? '';
          _avatarUrl = profile['avatarUrl'] ?? 'https://via.placeholder.com/150';
        });
      }
    }
  }

  // ========================================================
  // LOGIC UP ẢNH MỚI: SỬ DỤNG HTTP MULTIPART ĐẨY LÊN IMGBB
  // ========================================================
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    if (pickedFile == null) return;

    setState(() => _isLoading = true);
    try {
      if (_cloudName == 'YOUR_CLOUD_NAME') {
        throw Exception('Vui lòng nhập Cloud Name và Upload Preset của Cloudinary!');
      }

      // 1. Tạo request gửi tới API của Cloudinary
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      var request = http.MultipartRequest('POST', uri);

      // 2. Truyền Upload Preset (Bắt buộc phải là dạng Unsigned)
      request.fields['upload_preset'] = _uploadPreset;

      // 3. Đính kèm file ảnh
      request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));

      // 4. Gửi request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Lấy URL bảo mật (HTTPS) trả về từ Cloudinary
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String uploadedUrl = responseData['secure_url']; 

        setState(() {
          _avatarUrl = uploadedUrl;
        });

        // Lưu URL vào Firestore
        await _saveProfile();
      } else {
        debugPrint("LỖI CLOUDINARY: ${response.body}");
        final Map<String, dynamic> errorData = json.decode(response.body);
        final String errorMsg = errorData['error']['message'] ?? 'Lỗi không xác định';
        throw Exception(errorMsg);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Không thể tải ảnh: $e'),
        backgroundColor: Colors.redAccent,
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestoreService.updateUserProfile(
        user.uid, 
        _nameCtrl.text.trim(), 
        _bioCtrl.text.trim(), 
        _avatarUrl
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật hồ sơ thành công!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: NeonBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 0),
              Center(
                child: GestureDetector(
                  onTap: _isLoading ? null : _pickAndUploadImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white24,
                        backgroundImage: NetworkImage(_avatarUrl),
                        child: _isLoading ? const CircularProgressIndicator(color: AppTheme.neonPink) : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppTheme.neonPink, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.email ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 32),
              
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Thông tin cá nhân', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Tên hiển thị'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bioCtrl,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: _inputDecoration('Giới thiệu bản thân (Bio)'),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonBlue, 
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _saveProfile,
                        child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              GlassContainer(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Đổi mật khẩu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newPassCtrl,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Mật khẩu mới'),
                        validator: (v) => v!.length >= 6 ? null : 'Tối thiểu 6 ký tự',
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, 
                            side: const BorderSide(color: AppTheme.neonPink),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                await user?.updatePassword(_newPassCtrl.text.trim());
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công')));
                                _newPassCtrl.clear();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                              }
                            }
                          },
                          child: const Text('Cập nhật mật khẩu', style: TextStyle(color: AppTheme.neonPink, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, 
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async => await auth.signOut(),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Đăng xuất', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.neonBlue)),
    );
  }
}