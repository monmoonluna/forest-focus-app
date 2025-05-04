import 'package:flutter/material.dart';
import '../main.dart';
import 'signup_screen.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ email và mật khẩu!")),
      );
      return;
    }

    final user = await _authService.signIn(email: email, password: password);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng nhập thất bại! Vui lòng kiểm tra email hoặc mật khẩu.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(color: Color(0xFFE6F4EA)),
              child: Stack(
                children: [
                  const Positioned(
                    left: 35,
                    top: 184,
                    child: Text(
                      'Chào mừng bạn đã quay lại!',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 29,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 37,
                    top: 302,
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
                  Positioned(
                    left: 37,
                    top: 335,
                    child: Container(
                      width: 320,
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
                        controller: _emailController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 37,
                    top: 468,
                    child: Text(
                      'Password',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 37,
                    top: 501,
                    child: Container(
                      width: 320,
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
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 157,
                    top: 56,
                    child: Container(
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
                  ),
                  Positioned(
                    left: 43,
                    top: 634,
                    child: GestureDetector(
                      onTap: () => _signIn(context),
                      child: Container(
                        width: 320,
                        height: 48,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 104,
                    top: 767,
                    child: Text(
                      'Chưa có tài khoản?',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 246,
                    top: 767,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        'Đăng ký',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}