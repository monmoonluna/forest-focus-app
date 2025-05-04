import 'package:flutter/material.dart';
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
  bool _isLoading = false; // Thêm trạng thái loading

  Future<void> _signUp() async {
    if (_isLoading) return; // Ngăn gọi lại khi đang xử lý

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

    final user = await _authService.signUp(
      email: email,
      password: password,
      name: name,
    );

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      _showSnackBar("Đăng ký thành công!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      _showSnackBar("Đăng ký thất bại! Vui lòng kiểm tra thông tin và thử lại.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
                    fit: BoxFit.cover,
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
              _buildInputField(controller: _nameController),
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
              _buildInputField(controller: _emailController),
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
              _buildInputField(controller: _passwordController, isPassword: true),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _isLoading ? null : _signUp, // Vô hiệu hóa khi đang loading
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: ShapeDecoration(
                    color: _isLoading
                        ? Colors.grey
                        : const Color(0xFF4CAF50), // Đổi màu khi loading
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

  Widget _buildInputField({required TextEditingController controller, bool isPassword = false}) {
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
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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