// lib/models/team.dart
import 'player.dart';

class Team {
  String? id;
  String country;
  String managerName;
  String representativeEmail;
  List<Player> players;
  String captainName;
  double? teamRating;
  String? registeredAt;

  Team({
    this.id,
    required this.country,
    required this.managerName,
    required this.representativeEmail,
    required this.players,
    required this.captainName,
    this.teamRating,
    this.registeredAt,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as String?,
      country: json['country'] as String,
      managerName: json['manager_name'] as String,
      representativeEmail: json['representative_email'] as String,
      players: (json['players'] as List)
          .map((i) => Player.fromJson(i as Map<String, dynamic>))
          .toList(),
      captainName: json['captain_name'] as String,
      teamRating: (json['team_rating'] as num?)?.toDouble(),
      registeredAt: json['registered_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'manager_name': managerName,
      'representative_email': representativeEmail,
      'players': players.map((p) => p.toJson()).toList(),
      'captain_name': captainName,
    };
  }
}