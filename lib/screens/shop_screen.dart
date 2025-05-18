import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';
import 'drawer_menu.dart';

class ShopItem {
  final String name;
  final int price;
  final String imagePath;

  ShopItem({required this.name, required this.price, required this.imagePath});
}

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<ShopItem> shopItems = [
    ShopItem(name: 'Golden Tree', price: 2000, imagePath: 'assets/images/golden_tree.png'),
    ShopItem(name: 'Tangerine Tree', price: 1000, imagePath: 'assets/images/tangerine_tree.png'),
    ShopItem(name: 'Crystal Tree', price: 3000, imagePath: 'assets/images/crystal_tree.png'),
    ShopItem(name: 'Celestial Tree', price: 1500, imagePath: 'assets/images/celestial_tree.png'),
    ShopItem(name: 'Balloon Flower', price: 5000, imagePath: 'assets/images/balloon_flower.png'),
    ShopItem(name: 'Geraniums Flower', price: 800, imagePath: 'assets/images/geraniums_flower.png'),
  ];

  void _purchaseItem(BuildContext context, ShopItem item) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.coins >= item.price) {
      // Check if the item is already purchased to avoid double-counting
      if (!userProvider.purchasedItems.contains(item.name)) {
        userProvider.spendCoins(item.price, item.name);
        // Update progress for "Eco Warrior" achievement (index 3)
        userProvider.updateProgress(3, 1);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} purchased successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} is already purchased!'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough coins to purchase ${item.name}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/shop';
    final userProvider = Provider.of<UserProvider>(context);
    final int availableCoins = userProvider.coins;

    return Scaffold(
      backgroundColor: const Color(0xFF50B36A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF25863A),
        title: const Text(
          'Shop',
          style: TextStyle(color: Colors.white),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
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
                  '$availableCoins',
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
      drawer: AppDrawer(currentRoute: currentRoute, coins: availableCoins),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: shopItems.length,
        itemBuilder: (context, index) {
          final item = shopItems[index];
          return _buildShopItem(context, item);
        },
      ),
    );
  }

  Widget _buildShopItem(BuildContext context, ShopItem item) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isPurchased = userProvider.purchasedItems.contains(item.name);

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
                color: const Color(0xFFFFF9C4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.amber[100],
                    child: Center(
                      child: Icon(
                        Icons.nature,
                        size: 60,
                        color: item.name.contains('Golden') ? Colors.amber : Colors.green,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Text(
            item.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${item.price}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: isPurchased ? null : () => _purchaseItem(context, item),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPurchased ? Colors.grey : const Color(0xFF00C853),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(isPurchased ? 'Purchased' : 'Buy'),
            ),
          ),
        ],
      ),
    );
  }
}