// lib/models/player.dart

class Player {
  String name;
  String position;
  String? teamId;
  Map<String, int>? ratings;

  Player({
    required this.name,
    required this.position,
    this.teamId,
    this.ratings,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'] as String,
      position: json['position'] as String,
      teamId: json['team_id'] as String?,
      ratings: json['ratings'] != null ? Map<String, int>.from(json['ratings']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
    };
  }
}