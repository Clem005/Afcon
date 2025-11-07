// lib/screens/match_summary_page.dart
import 'package:flutter/material.dart';
import '../models/match.dart';
import '../services/api_service.dart';

class MatchSummaryPage extends StatefulWidget {
  final String matchId;
  final String stage;

  const MatchSummaryPage({super.key, required this.matchId, required this.stage});

  @override
  State<MatchSummaryPage> createState() => _MatchSummaryPageState();
}

class _MatchSummaryPageState extends State<MatchSummaryPage> {
  final ApiService _apiService = ApiService();
  Match? _match;
  bool _isLoading = true;

  static const Color afconGreen = Color(0xFF00A300);
  static const Color afconGold = Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _fetchMatchDetails();
  }

  Future<void> _fetchMatchDetails() async {
    setState(() { _isLoading = true; });
    try {
      final allMatches = await _apiService.getMatches();
      final match = allMatches.firstWhere(
        (m) => m.id == widget.matchId,
        orElse: () => throw Exception("Match not found")
      );
      setState(() {
        _match = match;
      });
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading match: ${e.toString()}')));
      }
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // FPL-Style Player Row (Goal Scorers)
  Widget _buildScorerRow(Map<String, dynamic> scorer) {
    final teamName = scorer['team_name'] as String? ?? 'Team';
    final minute = scorer['minute'] as int? ?? 0;
    final name = scorer['name'] as String? ?? 'Unknown Player';

    bool isHomeTeam = _match!.homeTeamName == teamName;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text('$minute\'', style: const TextStyle(fontWeight: FontWeight.bold, color: afconGold)),
          ),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Icon(Icons.sports_soccer, size: 16, color: isHomeTeam ? afconGreen : Colors.red),
        ],
      ),
    );
  }
  
  // FPL-Style Commentary Feed
  Widget _buildCommentaryFeed() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('LIVE COMMENTARY FEED', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: afconGreen)),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _match!.commentary!.length,
              itemBuilder: (context, index) {
                final text = _match!.commentary![index];
                final bool isGoal = text.contains('GOAL') || text.contains('Clinical finish');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isGoal ? Colors.black : Colors.black87,
                      fontWeight: isGoal ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.stage)),
        body: const Center(child: CircularProgressIndicator(color: afconGreen)),
      );
    }

    if (_match == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.stage)),
        body: const Center(child: Text('Match data could not be loaded.')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${_match!.homeTeamName} vs ${_match!.awayTeamName}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: const Color(0xFF006400),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                const Text('FULL TIME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(child: Text(_match!.homeTeamName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
                                    Text('${_match!.homeGoals} - ${_match!.awayGoals}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: afconGold)),
                                    Expanded(child: Text(_match!.awayTeamName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
                                  ],
                                ),
                                if (_match!.penaltyShootout != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('(${_match!.penaltyShootout!['home']} - ${_match!.penaltyShootout!['away']} Penalties)', style: const TextStyle(fontSize: 14, color: afconGold)),
                                  ),
                                const SizedBox(height: 10),
                                Text('Winner: ${_match!.winnerTeamId == _match!.homeTeamId ? _match!.homeTeamName : _match!.awayTeamName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: afconGold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('GOAL SCORERS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: afconGreen)),
                                const Divider(),
                                if (_match!.scorers == null || _match!.scorers!.isEmpty)
                                  const Text('No goals scored in regulation time.')
                                else
                                  ...(_match!.scorers as List<dynamic>).map((scorer) => _buildScorerRow(scorer as Map<String, dynamic>)).toList(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildCommentaryFeed(),
                        const SizedBox(height: 50),
                      ],
                    ),
            ),
    );
  }
}