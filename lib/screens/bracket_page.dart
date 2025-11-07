// lib/screens/bracket_page.dart
import 'package:flutter/material.dart';
import '../models/match.dart';
import '../services/api_service.dart';

class BracketPage extends StatefulWidget {
  const BracketPage({super.key});

  @override
  State<BracketPage> createState() => _BracketPageState();
}

class _BracketPageState extends State<BracketPage> {
  final ApiService _apiService = ApiService();
  List<Match> _allMatches = [];
  bool _isLoading = true;

  static const Color afconGreen = Color(0xFF00A300);

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  void _fetchMatches() async {
    setState(() { _isLoading = true; });
    try {
      final matches = await _apiService.getMatches();
      setState(() {
        _allMatches = matches;
        // Sort matches to display in order (Final, SF, QF is reversed in build)
        _allMatches.sort((a, b) => _getStageOrder(a.stage).compareTo(_getStageOrder(b.stage)));
      });
    } catch (e) {
      // Handle error (Snackbars are better in production)
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  int _getStageOrder(String stage) {
    switch (stage) {
      case 'Quarter-Final': return 1;
      case 'Semi-Final': return 2;
      case 'Final': return 3;
      default: return 0;
    }
  }

  List<Match> _getMatchesByStage(String stage) {
    return _allMatches.where((m) => m.stage == stage).toList();
  }

  Widget _buildMatchCard(BuildContext context, Match match) {
    final bool isCompleted = match.status == 'completed';
    
    Color homeTextColor = isCompleted && match.winnerTeamId == match.homeTeamId ? afconGreen : Colors.black87;
    Color awayTextColor = isCompleted && match.winnerTeamId == match.awayTeamId ? afconGreen : Colors.black87;
    
    Widget statusBadge;
    if (isCompleted) {
      statusBadge = const Icon(Icons.check_circle, size: 16, color: afconGreen);
    } else {
      statusBadge = const Icon(Icons.timer, size: 16, color: Colors.blueGrey);
    }
    
    return InkWell(
      onTap: isCompleted ? () {
        Navigator.pushNamed(
          context,
          '/match-summary',
          arguments: {'matchId': match.id!, 'stage': match.stage}
        ).then((_) => _fetchMatches());
      } : null,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(match.stage.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  statusBadge,
                ],
              ),
              const Divider(height: 10),
              
              _buildTeamScoreRow(match.homeTeamName, match.homeGoals, homeTextColor, isCompleted),
              _buildTeamScoreRow(match.awayTeamName, match.awayGoals, awayTextColor, isCompleted),
              
              if (isCompleted && match.penaltyShootout != null)
                Text('Penalties: ${match.penaltyShootout!['home']} - ${match.penaltyShootout!['away']}', 
                  style: const TextStyle(fontSize: 10, color: Colors.red)),
              
              if (isCompleted)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('WINNER: ${match.winnerTeamId == match.homeTeamId ? match.homeTeamName : match.awayTeamName}', 
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: afconGreen)),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamScoreRow(String name, int? score, Color color, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name, 
              style: TextStyle(
                fontSize: 14, 
                fontWeight: isCompleted && color == afconGreen ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            isCompleted ? (score ?? 0).toString() : '-',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isCompleted && color == afconGreen ? FontWeight.w900 : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBracketStage(String title, List<Match> matches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: afconGreen),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 2.5, 
          ),
          itemCount: matches.length,
          itemBuilder: (context, index) => _buildMatchCard(context, matches[index]),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final qfMatches = _getMatchesByStage('Quarter-Final');
    final sfMatches = _getMatchesByStage('Semi-Final');
    final finalMatches = _getMatchesByStage('Final');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Bracket', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: afconGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildBracketStage('Final', finalMatches),
                  _buildBracketStage('Semi-Final', sfMatches),
                  _buildBracketStage('Quarter-Final', qfMatches),
                  
                  if (_allMatches.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text('No matches created. Please start the tournament from the Admin Panel.', style: TextStyle(fontSize: 16, color: Colors.black54)),
                    ),
                ],
              ),
            ),
    );
  }
}