import 'package:flutter/material.dart';
import 'package:focus_app/services/user_provider.dart';
import 'package:provider/provider.dart';
import 'screens/circular_slider.dart';
import 'screens/countdown_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/drawer_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //runApp(const FocusApp());
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: FocusApp(),
    ),
  );
}

class FocusApp extends StatelessWidget {
  const FocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Tree',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      routes: {
        '/home': (context) => const HomePage(),
        '/shop': (context) => const ShopScreen(),
        '/achievements': (context) => const AchievementScreen(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedMinutes = 10;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  //int coins = 2000; // Add a coins variable to track user coins

  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/home';
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF50B36A),
      drawer: AppDrawer(currentRoute: currentRoute, coins: userProvider.coins),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    child: const Icon(Icons.menu, size: 30, color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25863A),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.yellow, size: 18),
                        const SizedBox(width: 4),
                        Text("${userProvider.coins}", style: const TextStyle(color: Colors.white)),
                        const SizedBox(width: 4),
                        const Icon(Icons.add, color: Colors.white, size: 16),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Main content - chiếm toàn bộ phần còn lại
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // "Start planting!" gần sát vòng tròn
                  const Text(
                    "Start planting!",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Vòng tròn + cây
                  CircularTimePicker(
                    onChanged: (value) {
                      setState(() {
                        selectedMinutes = value;
                      });
                    },
                  ),

                  // Phần bên dưới vòng tròn
                  Column(
                    children: [
                      // Tag Study
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 2))
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.fiber_manual_record, color: Colors.red, size: 14),
                            SizedBox(width: 6),
                            Text("Study", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Timer text
                      Text(
                        "${selectedMinutes.toString().padLeft(2, '0')}:00",
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Button Plant
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CountdownScreen(totalMinutes: selectedMinutes),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C853),
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          "Plant",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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