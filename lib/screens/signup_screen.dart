import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _createUserDocument(User user, String displayName) async {
    try {
      await user.reload();
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      DocumentSnapshot doc = await userDocRef.get();
      if (!doc.exists) {
        await userDocRef.set({
          'user_id': user.uid,
          'email': user.email,
          'display_name': displayName,
          'coins': 2000,
          'purchasedItems': [],
          'achievementsStatus': List.filled(6, false),
          'currentProgress': [2, 0, 0, 0, 0, 0],
          'requiredProgress': [4, 10, 50, 5, 100, 7],
          'created_at': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('Tài liệu người dùng đã được tạo cho ${user.email}');
      }
    } catch (e) {
      print('Lỗi khi tạo tài liệu người dùng: $e');
      _showSnackBar('Lỗi tạo dữ liệu người dùng: $e');
    }
  }

  Future<void> _signUp() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Vui lòng nhập đầy đủ thông tin!");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(email)) {
      _showSnackBar("Email không hợp lệ!");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (password.length < 6) {
      _showSnackBar("Mật khẩu phải có ít nhất 6 ký tự!");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );

      if (user != null) {
        await _createUserDocument(user, name);
        _showSnackBar("Đăng ký thành công!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        _showSnackBar("Đăng ký thất bại! Vui lòng kiểm tra thông tin và thử lại.");
      }
    } catch (e) {
      _showSnackBar("Lỗi đăng ký: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildInputField({required TextEditingController controller, bool isPassword = false, String? hintText}) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFDDDDDD),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          hintText: hintText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F4EA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 80,
                height: 80,
                decoration: const ShapeDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/tree.png"),
                    fit: BoxFit.fill,
                  ),
                  shape: OvalBorder(),
                  shadows: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Tạo tài khoản',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 32,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tên',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildInputField(controller: _nameController, hintText: 'Nhập tên'),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildInputField(controller: _emailController, hintText: 'Nhập email'),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mật khẩu',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildInputField(controller: _passwordController, isPassword: true, hintText: 'Nhập mật khẩu'),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _isLoading ? null : _signUp,
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: ShapeDecoration(
                    color: _isLoading ? Colors.grey : const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                        : const Text(
                      'Đăng ký',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Đã có tài khoản?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}