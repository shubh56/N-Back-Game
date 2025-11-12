import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
FirebaseAuth userCred = FirebaseAuth.instance;
String? userUID = '';
Object? userData;
Object? allUserData;
final docRef = db.collection('users').doc(userUID);

String currentUserUid() {
  userUID = userCred.currentUser?.uid;
  return userUID!;
}

void readUserData() {
  docRef.get().then((DocumentSnapshot doc) {
    userData = doc.data();
    print('User data for $userUID with ${userCred.currentUser?.email} fetched');
    return userData;
  });
}

Future<List<Map<String, dynamic>>> readAllUserData() async {
  try {
    final querySnapshot = await db.collection("users").get();
    print("Successfully fetched data of all users");
    final List<Map<String, dynamic>> allUserData = [];
    for (var docSnapshot in querySnapshot.docs) {
      allUserData.add(docSnapshot.data());
      print('${docSnapshot.id} => ${docSnapshot.data()}');
    }
    return allUserData;
  } catch (e) {
    print("Error completing: $e");
    return []; // return empty list on error
  }
}

Future<void> userSignOut() async {
  await userCred.signOut();
}

Future<void> saveSessionToFirestore({
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
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    // user not signed in — you can either skip saving or save locally
    print('No signed-in user. Skipping Firestore save.');
    return;
  }

  final uid = user.uid;
  final usersRef = FirebaseFirestore.instance.collection('users').doc(uid);

  // final now = FieldValue.serverTimestamp();

  try {
    // // 1) Update last session fields (merge so we don't clobber other fields)
    // await usersRef.set({
    //   'lastSession': now,
    //   'lastPosHits': posHits,
    //   'lastPosMisses': posMisses,
    //   'lastPosFalseAlarms': posFalseAlarms,
    //   'lastAudioHits': audioHits,
    //   'lastAudioMisses': audioMisses,
    //   'lastAudioFalseAlarms': audioFalseAlarms,
    //   'lastNumTrials': numTrials,
    //   'lastN': nValue,
    //   'lastGridSize': gridSize,
    //   'lastStimuliValue': stimuliValue,
    // }, SetOptions(merge: true));

    // 2) Optionally: update aggregates (sessionsPlayed, bestPosHits)
    // Use a transaction to be safe for concurrent writes
    await FirebaseFirestore.instance.runTransaction((tx) async {
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
