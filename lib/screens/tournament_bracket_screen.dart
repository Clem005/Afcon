// screens/tournament_bracket_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TournamentBracketScreen extends StatefulWidget {
  @override
  _TournamentBracketScreenState createState() => _TournamentBracketScreenState();
}

class _TournamentBracketScreenState extends State<TournamentBracketScreen> {
  // Placeholder for fetched match data
  // You'll need to define Match and Team models in models/ folder
  List<dynamic> _matches = []; // Store fetched match data

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    try {
      final response = await http.get(Uri.parse('YOUR_BACKEND_URL/matches')); // Replace
      if (response.statusCode == 200) {
        setState(() {
          _matches = jsonDecode(response.body);
          // Sort matches by stage and match number if necessary for display
        });
      } else {
        // Handle error
        print('Failed to load matches: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching matches: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tournament Bracket')),
      body: _matches.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                // This is a simplified representation. A true bracket UI is complex.
                // You might use a package like 'flutter_bracket_view' or custom drawing.
                child: Column(
                  children: [
                    Text('CAF AFRICA CUP NATIONS 2023', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    // Display Quarter-Finals
                    _buildStageHeader('Quarter-Finals'),
                    ..._matches.where((m) => m['stage'] == 'Quarter-Final').map((match) => _buildMatchCard(match)).toList(),
                    SizedBox(height: 40),
                    // Display Semi-Finals (will be populated after QF completes)
                    _buildStageHeader('Semi-Finals'),
                    // Display Final
                    _buildStageHeader('Final'),
                    // Display Winner
                    _buildStageHeader('Winner'),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStageHeader(String stage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(stage, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMatchCard(dynamic match) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${match['home_team_name']} vs ${match['away_team_name']}'),
            Text('Stage: ${match['stage']}'),
            Text('Status: ${match['status']}'),
            if (match['status'] == 'completed')
              Text('Result: ${match['home_goals']} - ${match['away_goals']}'),
            // Add a button to view match details
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(context, MaterialPageRoute(builder: (context) => MatchDetailsScreen(matchId: match['id'])));
            //   },
            //   child: Text('Details'),
            // ),
          ],
        ),
      ),
    );
  }
}