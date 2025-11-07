// lib/models/tournament_status.dart

class TournamentStatus {
  String? id;
  String currentStage;
  int teamsRegistered;
  int maxTeams;
  bool isActive;
  String? startTime;
  String? winnerTeamId;

  TournamentStatus({
    this.id,
    required this.currentStage,
    required this.teamsRegistered,
    required this.maxTeams,
    required this.isActive,
    this.startTime,
    this.winnerTeamId,
  });

  factory TournamentStatus.fromJson(Map<String, dynamic> json) {
    return TournamentStatus(
      id: json['id'] as String?,
      currentStage: json['current_stage'] as String,
      teamsRegistered: json['teams_registered'] as int,
      maxTeams: json['max_teams'] as int,
      isActive: json['is_active'] as bool,
      startTime: json['start_time'] as String?,
      winnerTeamId: json['winner_team_id'] as String?,
    );
  }
}