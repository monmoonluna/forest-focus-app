import 'package:flutter/material.dart';
import '../main.dart';
import 'signup_screen.dart'; // Import màn hình đăng ký

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập đầy đủ email và mật khẩu!")),
      );
      return;
    }

    // Xử lý đăng nhập tại đây (ví dụ gọi AuthService)

    // Nếu đăng nhập thành công, chuyển đến trang chủ (HomePage)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(  // Bọc trong SingleChildScrollView
        child: Column(
          children: [
            Container(
              width: screenWidth,  // Sử dụng chiều rộng toàn màn hình
              height: screenHeight,  // Sử dụng chiều cao toàn màn hình
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: const Color(0xFFE6F4EA)),
              child: Stack(
                children: [
                  Positioned(
                    left: 35,
                    top: 184,
                    child: Text(
                      'Chào mừng bạn đã quay lại!',
                      style: TextStyle(
                        color: const Color(0xFF2E7D32),
                        fontSize: 29,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 37,
                    top: 302,
                    child: Text(
                      'Email',
                      style: TextStyle(
                        color: const Color(0xFF666666),
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
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFFDDDDDD),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 37,
                    top: 468,
                    child: Text(
                      'Password',
                      style: TextStyle(
                        color: const Color(0xFF666666),
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
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFFDDDDDD),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
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
                      decoration: ShapeDecoration(
                        image: DecorationImage(
                          // image: NetworkImage("https://placehold.co/80x80"),
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
                        child: Center(
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
                  Positioned(
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
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text(
                        'Đăng ký',
                        style: TextStyle(
                          color: const Color(0xFF4CAF50),
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
