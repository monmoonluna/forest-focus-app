import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  int _coins = 2000; // Default starting coins
  List<String> _purchasedItems = []; // Items bought in shop
  List<bool> _achievementsStatus = List<bool>.filled(6, false); // Achievement unlocked status
  List<int> _currentProgress = List<int>.filled(6, 0); // Current progress for each achievement
  List<int> _requiredProgress = [4, 10, 50, 5, 100, 7]; // Initial required progress for each achievement

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getters
  int get coins => _coins;
  List<String> get purchasedItems => List.unmodifiable(_purchasedItems);
  List<bool> get achievementsStatus => List.unmodifiable(_achievementsStatus);
  List<int> get currentProgress => List.unmodifiable(_currentProgress);
  List<int> get requiredProgress => List.unmodifiable(_requiredProgress);

  UserProvider() {
    _loadUserData();
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print("Không có người dùng đăng nhập");
        return;
      }
      await user.reload(); // Đảm bảo xác thực
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _coins = doc.get('coins') ?? 2000;
        _purchasedItems = List<String>.from(doc.get('purchasedItems') ?? []);
        _achievementsStatus = List<bool>.from(doc.get('achievementsStatus') ?? List.filled(6, false));
        _currentProgress = List<int>.from(doc.get('currentProgress') ?? [2, 0, 0, 0, 0, 0]);
        _requiredProgress = List<int>.from(doc.get('requiredProgress') ?? [4, 10, 50, 5, 100, 7]);
      } else {
        print("Tài liệu người dùng không tồn tại, tạo mới...");
        await _firestore.collection('users').doc(user.uid).set({
          'user_id': user.uid,
          'email': user.email,
          'display_name': user.displayName ?? 'Anonymous',
          'coins': 2000,
          'purchasedItems': [],
          'achievementsStatus': List.filled(6, false),
          'currentProgress': [2, 0, 0, 0, 0, 0],
          'requiredProgress': [4, 10, 50, 5, 100, 7],
          'created_at': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      notifyListeners();
    } catch (e) {
      print("Lỗi tải dữ liệu người dùng: $e");
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print("Không có người dùng đăng nhập, không thể lưu dữ liệu");
        return;
      }

      await _firestore.collection('users').doc(user.uid).set({
        'coins': _coins,
        'purchasedItems': _purchasedItems,
        'achievementsStatus': _achievementsStatus,
        'currentProgress': _currentProgress,
        'requiredProgress': _requiredProgress,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Lỗi lưu dữ liệu người dùng: $e");
      // Có thể thêm callback để thông báo lỗi cho UI
    }
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
    _currentProgress = [2, 0, 0, 0, 0, 0]; // Reset with initial progress for Novice Planter
    _requiredProgress = [4, 10, 50, 5, 100, 7]; // Reset to initial requirements
    await _saveUserData();
    notifyListeners();
  }
}