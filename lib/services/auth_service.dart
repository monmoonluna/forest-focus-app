import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Đăng nhập bằng email và mật khẩu
  Future<User?> signIn({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Lỗi đăng nhập: $e");
      return null;
    }
  }

  // Đăng ký
  Future<User?> signUp({required String email, required String password, required String name}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user == null) {
        print("User is null after registration.");
        return null;
      }

      print("User created with UID: ${user.uid}");

      // Lưu thông tin người dùng vào Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'name': name,
        'user_id': user.uid,
        'coins': 2000,
        'purchasedItems': [],
        'achievementsStatus': List.filled(6, false),
        'currentProgress': [2, 0, 0, 0, 0, 0], // Novice Planter starts with 2/4 progress
        'requiredProgress': [4, 10, 50, 5, 100, 7],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Tạo lịch sử người dùng
      await _firestore.collection('users').doc(user.uid).collection('history').add({
        'action': 'sign_up',
        'time': FieldValue.serverTimestamp(),
      });

      return user;
    } catch (e) {
      print("Lỗi đăng ký: $e");
      return null;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Lỗi đăng xuất: $e");
    }
  }

  // Lấy người dùng hiện tại
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}