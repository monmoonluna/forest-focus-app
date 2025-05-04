import 'package:flutter/material.dart';
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
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF25863A),
                    ),
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
              context: context
              ,icon: Icons.home,
              text: 'Home',
              route: '/home',
              isSelected: currentRoute == '/home' || currentRoute == '/',
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.shopping_basket,
              text: 'Shop',
              route: '/shop',
              isSelected: currentRoute == '/shop',
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.emoji_events,
              text: 'Achievements',
              route: '/achievements',
              isSelected: currentRoute == '/achievements',
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.add_chart,
              text: 'Statistics',
              route: '/statistics',
              isSelected: currentRoute == '/statistics',
            ),
            const Divider(color: Colors.white70),
            _buildDrawerItem(
              context: context,
              icon: Icons.settings,
              text: 'Settings',
              onTap: () {
                Navigator.pop(context);
                // Add settings navigation if needed
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.logout,
              text: 'Logout',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                );
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