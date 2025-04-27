import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  int _coins = 2000; // Default starting coins
  List<String> _purchasedItems = []; // Items bought in shop
  List<bool> _achievementsStatus = List<bool>.filled(6, false); // Achievement unlocked status

  // Getters
  int get coins => _coins;
  List<String> get purchasedItems => List.unmodifiable(_purchasedItems);
  List<bool> get achievementsStatus => List.unmodifiable(_achievementsStatus);

  UserProvider() {
    _loadUserData();
  }

  // Load user data (coins, purchases, achievements) from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt('coins') ?? 2000;
    _purchasedItems = prefs.getStringList('purchasedItems') ?? [];
    final savedAchiev = prefs.getStringList('achievementsStatus');
    if (savedAchiev != null && savedAchiev.length == _achievementsStatus.length) {
      _achievementsStatus = savedAchiev.map((e) => e == 'true').toList();
    }
    notifyListeners();
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', _coins);
    await prefs.setStringList('purchasedItems', _purchasedItems);
    await prefs.setStringList('achievementsStatus', _achievementsStatus.map((e) => e ? 'true' : 'false').toList());
  }

  /// Increase coin balance and persist
  void addCoins(int amount) {
    _coins += amount;
    _saveUserData();
    notifyListeners();
  }

  /// Spend coins and record purchased item
  void spendCoins(int amount, String itemName) {
    if (_coins >= amount && !_purchasedItems.contains(itemName)) {
      _coins -= amount;
      _purchasedItems.add(itemName);
      _saveUserData();
      notifyListeners();
    }
  }

  /// Unlock an achievement by index and persist
  void unlockAchievement(int index) {
    if (index >= 0 && index < _achievementsStatus.length && !_achievementsStatus[index]) {
      _achievementsStatus[index] = true;
      addCoins(100); // reward coins on unlock
      _saveUserData();
      notifyListeners();
    }
  }

  /// Reset user data (for testing or logout)
  Future<void> resetUserData() async {
    _coins = 2000;
    _purchasedItems.clear();
    _achievementsStatus = List<bool>.filled(_achievementsStatus.length, false);
    await _saveUserData();
    notifyListeners();
  }
}
