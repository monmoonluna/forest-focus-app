import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';
import 'drawer_menu.dart';

class Achievement {
  final String title;
  final String description;

  Achievement({
    required this.title,
    required this.description,
  });
}

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({Key? key}) : super(key: key);

  @override
  _AchievementScreenState createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Danh sách thành tựu
  final List<Achievement> achievements = [
    Achievement(title: 'Novice Planter', description: 'Total focused time reaches 4 hours'),
    Achievement(title: 'Green Thumb', description: 'Plant 10 trees in the app'),
    Achievement(title: 'Forest Keeper', description: 'Reach 50 hours of focused time'),
    Achievement(title: 'Eco Warrior', description: 'Unlock 5 different tree types'),
    Achievement(title: 'Master Gardener', description: 'Complete 100 tasks'),
    Achievement(title: 'Nature Lover', description: 'Spend 7 days in a row planting'),
  ];

  void _claimAchievement(int index, Achievement achievement) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.achievementsStatus[index] &&
        userProvider.currentProgress[index] >= userProvider.requiredProgress[index]) {
      userProvider.unlockAchievement(index); // Gọi hàm unlock từ UserProvider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${achievement.title} claimed! +100 coins'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (userProvider.achievementsStatus[index]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${achievement.title} already claimed'),
          backgroundColor: Colors.grey,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough progress to claim ${achievement.title}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/achievements';
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF4CAF50),
      appBar: AppBar(
        backgroundColor: const Color(0xFF388E3C),
        title: const Text(
          'Achievements',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.yellow, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${userProvider.coins}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.add, color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
      drawer: AppDrawer(currentRoute: currentRoute, coins: userProvider.coins),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          final isUnlocked = userProvider.achievementsStatus[index];
          final currentProgress = userProvider.currentProgress[index];
          final requiredProgress = userProvider.requiredProgress[index];
          return _buildAchievementCard(
              achievement, index, isUnlocked, currentProgress, requiredProgress);
        },
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, int index, bool isUnlocked,
      int currentProgress, int requiredProgress) {
    // Cập nhật description để hiển thị tiến trình động
    final displayDescription = achievement.description.contains('(0/')
        ? achievement.description.replaceFirst(
        RegExp(r'\(0/\d+\)'), '($currentProgress/$requiredProgress)')
        : '${achievement.description} ($currentProgress/$requiredProgress)';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUnlocked ? const Color(0xFFFFF9C4) : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  isUnlocked ? Icons.star : Icons.lock,
                  size: 60,
                  color: isUnlocked ? Colors.amber : Colors.grey,
                ),
              ),
            ),
          ),
          Text(
            achievement.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              displayDescription,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () => _claimAchievement(index, achievement),
              style: ElevatedButton.styleFrom(
                backgroundColor: isUnlocked ? Colors.grey : const Color(0xFF00C853),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(isUnlocked ? 'Claimed' : 'Claim'),
            ),
          ),
        ],
      ),
    );
  }
}