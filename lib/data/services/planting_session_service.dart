import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlantingSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createPlantingSession({
    required int duration,
    required String status,
    required String date,
    required int pointsEarned,
  }) async {
    try {
      String userId = _auth.currentUser!.uid;
      await _firestore.collection('planting_sessions').add({
        'user_id': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'duration': duration,
        'status': status,
        'date': date,
        'points_earned': pointsEarned,
      });
    } catch (e) {
      print('Error creating session: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPlantingHistory() async {
    try {
      String userId = _auth.currentUser!.uid;
      QuerySnapshot snapshot = await _firestore
          .collection('planting_sessions')
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      print('Error fetching history: $e');
      return [];
    }
  }
}