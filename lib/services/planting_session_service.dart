import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlantingSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> createPlantingSession({
    required int duration,
    required String status,
    required String date,
    required int pointsEarned,
  }) async {
    try {
      if (_auth.currentUser == null) {
        print("Error: User is not authenticated. Cannot create session.");
        return "Người dùng chưa đăng nhập! Không thể tạo phiên.";
      }
      String userId = _auth.currentUser!.uid;
      print("Creating session for user: $userId, duration: $duration, status: $status, date: $date, points: $pointsEarned");
      await _firestore.collection('planting_sessions').add({
        'user_id': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'duration': duration,
        'status': status,
        'date': date,
        'points_earned': pointsEarned,
      });
      print("Session created successfully.");
      return null;
    } catch (e) {
      print("Failed to create session: $e");
      return 'Lỗi khi tạo phiên: $e';
    }
  }

  Future<List<Map<String, dynamic>>> getPlantingHistory() async {
    try {
      if (_auth.currentUser == null) {
        print("Error: User is not authenticated. Cannot fetch history.");
        throw Exception("Người dùng chưa đăng nhập! Không thể tải lịch sử.");
      }
      String userId = _auth.currentUser!.uid;
      print("Fetching history for user: $userId");
      QuerySnapshot snapshot = await _firestore
          .collection('planting_sessions')
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      var result = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
      print("Fetched ${result.length} sessions.");
      return result;
    } catch (e) {
      print("Failed to fetch history: $e");
      throw Exception('Lỗi khi tải lịch sử: $e');
    }
  }
}