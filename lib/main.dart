import 'package:flutter/material.dart';
import 'package:focus_app/screens/overlay.dart';
import 'package:focus_app/screens/statistics_screen.dart';
import 'package:focus_app/services/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/circular_slider.dart';
import 'screens/countdown_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/drawer_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const FocusApp(),
    ),
  );
}

@pragma('vm:entry-point')
void overlayMain() {
  runApp(OverlayApp());
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
        '/statistics': (context) => const StatisticsScreen(),
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
  String selectedTag = "Study";
  bool isDeepFocus = false;
  bool isPlantTogether = false;
  bool isCountExceeded = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedTreeAsset = 'assets/images/tree_stage_4.png';
  bool isDefaultTree = true;

  final List<String> availableTags = [
    "Study", "Work", "Social", "Rest", "Entertainment", "Sport", "Other", "Unset",
  ];

  final Map<String, Color> tagColors = {
    "Study": Colors.blue,
    "Work": Colors.orange,
    "Social": Colors.purple,
    "Rest": Colors.green,
    "Entertainment": Colors.pink,
    "Sport": Colors.greenAccent,
    "Other": Colors.brown,
    "Unset": Colors.grey,
  };

  void _showTagSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: availableTags.map((tag) {
              return ChoiceChip(
                label: Text(tag),
                selected: selectedTag == tag,
                selectedColor: tagColors[tag]?.withOpacity(0.2),
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(
                  color: selectedTag == tag ? tagColors[tag] : Colors.black,
                ),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: tagColors[tag] ?? Colors.black,
                    width: selectedTag == tag ? 2 : 1,
                  ),
                ),
                onSelected: (_) {
                  setState(() {
                    selectedTag = tag;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showDeepFocusDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // Đóng cửa sổ khi nhấn ra ngoài
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer, color: Colors.purple),
                          SizedBox(width: 8),
                          Text(
                            "Timer Mode",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Colors.grey, thickness: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.orange),
                            const SizedBox(width: 8),
                            const Text(
                              "Deep focus",
                              style: TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                        Switch(
                          value: isDeepFocus,
                          onChanged: (value) {
                            setState(() {
                              isDeepFocus = value;
                            });
                            // Cập nhật trạng thái của widget cha
                            (context as Element).markNeedsBuild();
                          },
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildCoinDisplay() {
    final userProvider = Provider.of<UserProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Image.asset('assets/images/coin.png', width: 28, height: 28),
          const SizedBox(width: 6),
          Text(
            "${userProvider.coins}",
            style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.greenAccent,
            ),
            child: const Icon(Icons.add, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/home';
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF46AE71),
      drawer: AppDrawer(currentRoute: currentRoute, coins: Provider.of<UserProvider>(context).coins),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    child: const Icon(Icons.menu, size: 40, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: _showDeepFocusDialog,
                    child: Container(
                      width: 100,
                      height: 40,
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image.asset(
                        'assets/images/hourglass_icon2.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  buildCoinDisplay(),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    "Start planting!",
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  CircularTimePicker(
                    onChanged: (value) {
                      setState(() {
                        selectedMinutes = value;
                      });
                    },
                    onTreeChanged: (treeAsset, isDefault) {
                      setState(() {
                        selectedTreeAsset = treeAsset;
                        isDefaultTree = isDefault;
                      });
                    },
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _showTagSelector,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: tagColors[selectedTag]?.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 2)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.fiber_manual_record, color: tagColors[selectedTag], size: 14),
                              const SizedBox(width: 6),
                              Text(selectedTag, style: const TextStyle(color: Colors.white)),
                              const SizedBox(width: 6),
                              const Icon(Icons.edit, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "${selectedMinutes.toString().padLeft(2, '0')}:00",
                        style: const TextStyle(fontSize: 60, fontWeight: FontWeight.normal, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CountdownScreen(
                                //totalMinutes: selectedMinutes,
                                totalMinutes: 1,
                                tag: selectedTag,
                                tagColor: tagColors[selectedTag] ?? Colors.white,
                                isDeepFocus: isDeepFocus,
                                selectedTreeAsset: selectedTreeAsset,
                                isDefaultTree: isDefaultTree,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C853),
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          "Plant",
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.normal),
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