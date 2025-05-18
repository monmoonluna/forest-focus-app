import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  int _coins = 2000; // Default starting coins
  String _displayName = 'Anonymous'; // Default display name
  List<String> _purchasedItems = []; // Items bought in shop
  List<int> _currentProgress = List<int>.filled(6, 0); // Current progress for each achievement
  List<int> _requiredProgress = [4, 10, 50, 5, 100, 7]; // Initial required progress for each achievement

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getters
  int get coins => _coins;
  String get displayName => _displayName;
  List<String> get purchasedItems => List.unmodifiable(_purchasedItems);
  List<int> get currentProgress => List.unmodifiable(_currentProgress);
  List<int> get requiredProgress => List.unmodifiable(_requiredProgress);

  UserProvider() {
    _loadUserData();
  }
  Future<void> loadUserData() async {
    await _loadUserData();
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
        _displayName = doc.get('name') ?? 'Anonymous';
        _purchasedItems = List<String>.from(doc.get('purchasedItems') ?? []);
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
        'name': _displayName,
        'purchasedItems': _purchasedItems,
        'currentProgress': _currentProgress,
        'requiredProgress': _requiredProgress,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Lỗi lưu dữ liệu người dùng: $e");
    }
  }

  // Increase coin balance and persist
  void addCoins(int amount) {
    _coins += amount;
    _saveUserData();
    notifyListeners();
  }

  // Spend coins and record purchased item
  void spendCoins(int amount, String itemName) {
    if (_coins >= amount && !_purchasedItems.contains(itemName)) {
      _coins -= amount;
      _purchasedItems.add(itemName);
      _saveUserData();
      notifyListeners();
    }
  }

  // Update progress for an achievement
  void updateProgress(int index, int amount) {
    if (index >= 0 && index < _currentProgress.length) {
      _currentProgress[index] += amount;
      _saveUserData();
      notifyListeners();
    }
  }

  // Unlock an achievement by index and persist
  void unlockAchievement(int index) {
    if (index >= 0 && index < _requiredProgress.length &&
        _currentProgress[index] >= _requiredProgress[index]) {
      _requiredProgress[index] *= 2; // Nhân đôi yêu cầu cho lần tiếp theo
      addCoins(100); // Thưởng 100 coins
      _saveUserData();
      notifyListeners();
    }
  }

  // Reset user data (for logout)
  Future<void> resetUserData() async {
    _coins = 2000;
    _displayName = 'Anonymous';
    _purchasedItems.clear();
    _currentProgress = List<int>.filled(6, 0);
    _requiredProgress = [4, 10, 50, 5, 100, 7]; // Reset to initial requirements
    notifyListeners();
  }
}