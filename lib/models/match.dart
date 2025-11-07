// lib/models/match.dart

class Match {
  String? id;
  String homeTeamId;
  String awayTeamId;
  String homeTeamName;
  String awayTeamName;
  String stage;
  int matchNumber;
  int? homeGoals;
  int? awayGoals;
  List<dynamic>? scorers; 
  List<String>? commentary;
  String? winnerTeamId;
  String? loserTeamId;
  String? nextMatchId;
  String status;
  String? matchDate;
  Map<String, dynamic>? penaltyShootout;

  Match({
    this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.stage,
    required this.matchNumber,
    this.homeGoals,
    this.awayGoals,
    this.scorers,
    this.commentary,
    this.winnerTeamId,
    this.loserTeamId,
    this.nextMatchId,
    required this.status,
    this.matchDate,
    this.penaltyShootout,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String?,
      homeTeamId: json['home_team_id'] as String,
      awayTeamId: json['away_team_id'] as String,
      homeTeamName: json['home_team_name'] as String,
      awayTeamName: json['away_team_name'] as String,
      stage: json['stage'] as String,
      matchNumber: json['match_number'] as int,
      homeGoals: json['home_goals'] as int?,
      awayGoals: json['away_goals'] as int?,
      scorers: json['scorers'] as List?,
      commentary: (json['commentary'] as List?)?.map((i) => i.toString()).toList(),
      winnerTeamId: json['winner_team_id'] as String?,
      loserTeamId: json['loser_team_id'] as String?,
      nextMatchId: json['next_match_id'] as String?,
      status: json['status'] as String,
      matchDate: json['match_date'] as String?,
      penaltyShootout: json['penalty_shootout'] as Map<String, dynamic>?,
    );
  }
}