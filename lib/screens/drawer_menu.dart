import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focus_app/services/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class AppDrawer extends StatelessWidget {
  final int coins;
  final String currentRoute;

  const AppDrawer({
    Key? key,
    required this.currentRoute,
    this.coins = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final String displayName = userProvider.displayName ?? 'Phonn Phamm';

    return Drawer(
      child: Container(
        color: const Color(0xFF3C8F52),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF25863A),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Color(0xFF25863A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Focus Tree',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.home,
              text: 'Trang chủ',
              route: '/home',
              isSelected: currentRoute == '/home' || currentRoute == '/',
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.shopping_basket,
              text: 'Cửa hàng',
              route: '/shop',
              isSelected: currentRoute == '/shop',
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.emoji_events,
              text: 'Thành tựu',
              route: '/achievements',
              isSelected: currentRoute == '/achievements',
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.add_chart,
              text: 'Thống kê',
              route: '/statistics',
              isSelected: currentRoute == '/statistics',
            ),
            const Divider(color: Colors.white70),
            _buildDrawerItem(
              context: context,
              icon: Icons.settings,
              text: 'Cài đặt',
              onTap: () {
                Navigator.pop(context);
                // Thêm điều hướng tới màn hình cài đặt nếu cần
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.logout,
              text: 'Đăng xuất',
              onTap: () async {
                try {
                  // Đặt lại dữ liệu người dùng trước khi đăng xuất (nếu cần lưu trạng thái hiện tại)
                  await userProvider.resetUserData();
                  // Đăng xuất khỏi Firebase
                  await FirebaseAuth.instance.signOut();

                  // Chuyển đến màn hình đăng nhập và xóa toàn bộ lịch sử điều hướng
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false,
                  );
                } catch (e) {
                  print("Lỗi khi đăng xuất: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đăng xuất thất bại. Vui lòng thử lại.')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    String? route,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.white70,
        size: 28,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? Colors.black12 : null,
      onTap: onTap ?? () {
        Navigator.pop(context);
        if (route != null && ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}