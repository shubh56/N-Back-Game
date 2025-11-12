class UserModel {
  final String uid;
  final String email;
  final String name;
  final int highScore;
  final int sessionsPlayed;
  final int bestPosHits;
  final int bestAudioHits;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.highScore = 0,
    this.sessionsPlayed = 0,
    this.bestPosHits = 0,
    this.bestAudioHits = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? 'No Name',
      highScore: (map['highscore'] as int?) ?? 0,
      sessionsPlayed: (map['sessionsPlayed'] as int?) ?? 0,
      bestPosHits: (map['bestPosHits'] as int?) ?? 0,
      bestAudioHits: (map['bestAudioHits'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'highscore': highScore,
      'sessionsPlayed': sessionsPlayed,
      'bestPosHits': bestPosHits,
      'bestAudioHits': bestAudioHits,
    };
  }
}
