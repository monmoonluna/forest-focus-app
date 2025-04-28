import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  int _coins = 2000; // Default starting coins
  List<String> _purchasedItems = []; // Items bought in shop
  List<bool> _achievementsStatus = List<bool>.filled(6, false); // Achievement unlocked status
  List<int> _currentProgress = List<int>.filled(6, 0); // Current progress for each achievement
  List<int> _requiredProgress = [4, 10, 50, 5, 100, 7]; // Initial required progress for each achievement

  // Getters
  int get coins => _coins;
  List<String> get purchasedItems => List.unmodifiable(_purchasedItems);
  List<bool> get achievementsStatus => List.unmodifiable(_achievementsStatus);
  List<int> get currentProgress => List.unmodifiable(_currentProgress);
  List<int> get requiredProgress => List.unmodifiable(_requiredProgress);

  UserProvider() {
    _loadUserData();
  }

  // Load user data (coins, purchases, achievements, progress) from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt('coins') ?? 2000;
    //_coins = 2000; // Forced to 2000 as per your code
    _purchasedItems = prefs.getStringList('purchasedItems') ?? [];

    final savedAchiev = prefs.getStringList('achievementsStatus');
    if (savedAchiev != null && savedAchiev.length == _achievementsStatus.length) {
      _achievementsStatus = savedAchiev.map((e) => e == 'true').toList();
    }

    final savedProgress = prefs.getStringList('currentProgress');
    if (savedProgress != null && savedProgress.length == _currentProgress.length) {
      _currentProgress = savedProgress.map((e) => int.parse(e)).toList();
      _currentProgress[0] = 4;
    } else {
      // Set initial progress for Novice Planter (index 0) to 2
      _currentProgress[0] = 2; // Novice Planter starts with 2/4 progress
    }

    final savedRequired = prefs.getStringList('requiredProgress');
    if (savedRequired != null && savedRequired.length == _requiredProgress.length) {
      _requiredProgress = savedRequired.map((e) => int.parse(e)).toList();
    } else {
      _requiredProgress = [4, 10, 50, 5, 100, 7]; // Default requirements
    }

    notifyListeners();
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', _coins);
    await prefs.setStringList('purchasedItems', _purchasedItems);
    await prefs.setStringList('achievementsStatus', _achievementsStatus.map((e) => e ? 'true' : 'false').toList());
    await prefs.setStringList('currentProgress', _currentProgress.map((e) => e.toString()).toList());
    await prefs.setStringList('requiredProgress', _requiredProgress.map((e) => e.toString()).toList());
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

  /// Update progress for an achievement
  void updateProgress(int index, int amount) {
    if (index >= 0 && index < _currentProgress.length) {
      _currentProgress[index] += amount;
      _saveUserData();
      notifyListeners();
    }
  }

  /// Unlock an achievement by index and persist
  void unlockAchievement(int index) {
    if (index >= 0 &&
        index < _achievementsStatus.length &&
        !_achievementsStatus[index] &&
        _currentProgress[index] >= _requiredProgress[index]) {
      _achievementsStatus[index] = true;
      _currentProgress[index] = _currentProgress[index]; // Reset progress after unlock
      _requiredProgress[index] *= 2; // Double the requirement for next unlock
      addCoins(100); // Reward coins on unlock
      _saveUserData();
      notifyListeners();
    }
  }

  /// Reset user data (for testing or logout)
  Future<void> resetUserData() async {
    _coins = 2000;
    _purchasedItems.clear();
    _achievementsStatus = List<bool>.filled(_achievementsStatus.length, false);
    _currentProgress = List<int>.filled(_currentProgress.length, 0);
    _currentProgress[0] = 2; // Reset with initial progress for Novice Planter
    _requiredProgress = [4, 10, 50, 5, 100, 7]; // Reset to initial requirements
    await _saveUserData();
    notifyListeners();
  }
}