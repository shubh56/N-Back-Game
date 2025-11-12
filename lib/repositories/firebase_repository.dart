import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:n_back/models/user_model.dart';

class FirebaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Create a new user profile
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'name': name,
        'highscore': 0,
        'sessionsPlayed': 0,
        'bestPosHits': 0,
        'bestAudioHits': 0,
      });
      print('User profile created for uid=$uid');
    } catch (e, st) {
      print('Error creating user profile: $e\n$st');
      rethrow;
    }
  }

  // Get current user UID
  String? getCurrentUserUid() {
    return _firebaseAuth.currentUser?.uid;
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel.fromMap({...data, 'uid': uid});
      }
      return null;
    } catch (e) {
      print('Error reading user data: $e');
      return null;
    }
  }

  // Get all users for leaderboard
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection("users").get();
      print("Successfully fetched data of all users");
      final List<UserModel> allUsers = [];
      for (var docSnapshot in querySnapshot.docs) {
        final data = docSnapshot.data();
        allUsers.add(UserModel.fromMap({...data, 'uid': docSnapshot.id}));
        print('${docSnapshot.id} => $data');
      }
      return allUsers;
    } catch (e) {
      print("Error fetching all users: $e");
      return [];
    }
  }

  // Save game session
  Future<void> saveGameSession({
    required int posHits,
    required int posMisses,
    required int posFalseAlarms,
    required int audioHits,
    required int audioMisses,
    required int audioFalseAlarms,
    required int numTrials,
    required int nValue,
    required int gridSize,
    required int stimuliValue,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      print('No signed-in user. Skipping Firestore save.');
      return;
    }

    final uid = user.uid;
    final usersRef = _firestore.collection('users').doc(uid);

    try {
      await _firestore.runTransaction((tx) async {
        final snapshot = await tx.get(usersRef);
        final data = snapshot.exists
            ? snapshot.data() as Map<String, dynamic>
            : {};

        final int sessionsPlayed = (data['sessionsPlayed'] ?? 0) as int;
        final int previousBestPos = (data['bestPosHits'] ?? 0) as int;
        final int previousBestAudio = (data['bestAudioHits'] ?? 0) as int;

        tx.set(usersRef, {
          'sessionsPlayed': sessionsPlayed + 1,
          'bestPosHits': posHits > previousBestPos ? posHits : previousBestPos,
          'bestAudioHits': audioHits > previousBestAudio
              ? audioHits
              : previousBestAudio,
        }, SetOptions(merge: true));
      });

      print('Session saved to Firestore for uid=$uid');
    } catch (e, st) {
      print('Error saving session to Firestore: $e\n$st');
    }
  }
}
