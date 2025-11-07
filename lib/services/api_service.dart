// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/team.dart';
import '../models/tournament_status.dart';
import '../models/match.dart';

class ApiService {
  final String _baseUrl = 'http://127.0.0.1:8000'; // Final base URL

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  Future<TournamentStatus> getTournamentStatus() async {
    final response = await http.get(Uri.parse('$_baseUrl/tournament/status'));
    
    if (response.statusCode == 200) {
      return TournamentStatus.fromJson(json.decode(response.body));
    } else {
      final errorBody = json.decode(response.body);
      throw Exception('Server returned status ${response.statusCode}: ${errorBody['detail'] ?? response.reasonPhrase}');
    }
  }

  Future<List<Team>> getTeams() async {
    final response = await http.get(Uri.parse('$_baseUrl/teams'));
    if (response.statusCode == 200) {
      List jsonList = json.decode(response.body);
      return jsonList.map((json) => Team.fromJson(json)).toList();
    } else {
      final errorBody = json.decode(response.body);
      throw Exception('Failed to load teams: ${errorBody['detail'] ?? response.reasonPhrase}');
    }
  }

  Future<Team> registerTeam(Team team) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register_team'),
      headers: _headers,
      body: json.encode(team.toJson()),
    );

    if (response.statusCode == 201) {
      return Team.fromJson(json.decode(response.body));
    } else {
      final errorBody = json.decode(response.body);
      throw Exception('Failed to register team: ${errorBody['detail'] ?? response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>> startTournament() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/start_tournament'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception('Failed to start tournament: ${errorBody['detail'] ?? response.reasonPhrase}');
    }
  }
  
  Future<List<Match>> getMatches() async {
    final response = await http.get(Uri.parse('$_baseUrl/matches'));
    if (response.statusCode == 200) {
      List jsonList = json.decode(response.body);
      return jsonList.map((json) => Match.fromJson(json)).toList();
    } else {
      final errorBody = json.decode(response.body);
      throw Exception('Failed to load matches: ${errorBody['detail'] ?? response.reasonPhrase}');
    }
  }

  Future<Match> simulateMatch(String matchId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/simulate_match/$matchId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return Match.fromJson(json.decode(response.body));
    } else {
      final errorBody = json.decode(response.body);
      throw Exception('Failed to simulate match: ${errorBody['detail'] ?? response.reasonPhrase}');
    }
  }
  
  // Method for tournament reset
  Future<Map<String, dynamic>> resetTournament() async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/tournament/reset'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception('Failed to reset tournament: ${errorBody['detail'] ?? response.reasonPhrase}');
    }
  }
}