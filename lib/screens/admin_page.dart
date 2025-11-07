// lib/screens/admin_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tournament_status.dart';
import '../models/match.dart';
import '../services/api_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final ApiService _apiService = ApiService();
  TournamentStatus? _status;
  List<Match> _pendingMatches = [];
  bool _isLoading = true;
  String? _errorMessage;

  static const Color accentPurple = Color(0xFFC639FF);
  static const Color accentGreen = Color(0xFF00D283);
  static const Color silverText = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _pendingMatches = [];
    });
    try {
      final status = await _apiService.getTournamentStatus();
      List<Match> allMatches = [];
      if (status.isActive) {
        allMatches = await _apiService.getMatches(); 
        _pendingMatches = allMatches.where((m) => m.status == 'pending').toList();
      }
      
      setState(() {
        _status = status;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: ${e.toString().split(':').last.trim()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startTournament() async {
    setState(() { _isLoading = true; });
    try {
      await _apiService.startTournament();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tournament Started! Quarter-Finals created.'), backgroundColor: accentGreen));
      }
      _fetchData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString().split(':').last.trim()}'), backgroundColor: Colors.red));
      }
      _fetchData();
    } finally {
      setState(() { _isLoading = false; });
    }
  }
  
  Future<void> _simulateMatch(String matchId) async {
    setState(() { _isLoading = true; });
    try {
      final Match result = await _apiService.simulateMatch(matchId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.homeTeamName} ${result.homeGoals} - ${result.awayGoals} ${result.awayTeamName} (${result.stage})'),
            backgroundColor: accentGreen,
          ),
        );
      }
      _fetchData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Simulation Error: ${e.toString().split(':').last.trim()}'), backgroundColor: Colors.red));
      }
      _fetchData();
    } finally {
      setState(() { _isLoading = false; });
    }
  }
  
  Future<void> _resetTournament() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text('CONFIRM TOURNAMENT RESET', style: GoogleFonts.montserrat(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete ALL tournament data (teams, matches, status)? This action cannot be undone.', style: GoogleFonts.inter(color: silverText)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text('RESET ALL DATA', style: GoogleFonts.montserrat(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() { _isLoading = true; });
      try {
        await _apiService.resetTournament();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tournament DATA Wiped! Starting Registration Phase.'), backgroundColor: accentGreen));
        }
        _fetchData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reset Error: ${e.toString().split(':').last.trim()}'), backgroundColor: Colors.red));
        }
      } finally {
        setState(() { _isLoading = false; });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: accentPurple)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: accentPurple,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: accentPurple));
    }
    
    final status = _status!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAdminStatusHeader(status),
          const SizedBox(height: 20),

          if (!status.isActive && status.teamsRegistered == status.maxTeams)
            _buildStartTournamentButton()
          else if (!status.isActive)
            _buildInfoCard(
              'Awaiting Teams',
              'Need ${status.maxTeams - status.teamsRegistered} more teams to start the Quarter-Finals.',
              Icons.people_outline,
              Colors.blueGrey.shade400,
            ),
          
          if (status.isActive && _pendingMatches.isNotEmpty)
            _buildMatchSimulationList(context)
          else if (status.currentStage == 'completed')
             _buildInfoCard(
              'Tournament Complete!',
              'The African Nations League Champion has been crowned.',
              Icons.military_tech,
              accentPurple,
            )
          else if (status.isActive && _pendingMatches.isEmpty && status.currentStage != 'completed')
             _buildInfoCard(
              'Awaiting Progression',
              'All ${status.currentStage.toUpperCase().replaceAll('_', ' ')} matches are complete. Check the Bracket.',
              Icons.check_circle_outline,
              accentGreen,
            ),
          
          const SizedBox(height: 40),
          _buildResetButton(),
        ],
      ),
    );
  }

  Widget _buildAdminStatusHeader(TournamentStatus status) {
    String stageText = status.currentStage.toUpperCase().replaceAll('_', ' ');
    Color stageColor = status.isActive ? accentGreen : Colors.blueGrey.shade400;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TOURNAMENT CONTROL', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
            const SizedBox(height: 4),
            Text(
              stageText,
              style: GoogleFonts.montserrat(
                fontSize: 28, 
                fontWeight: FontWeight.w900, 
                color: stageColor,
              ),
            ),
            const Divider(color: Colors.white12, height: 20),
            _buildStatusRow('Teams Registered', '${status.teamsRegistered}/${status.maxTeams}'),
            _buildStatusRow('Tournament Active', status.isActive ? 'YES' : 'NO'),
            if (status.currentStage != 'registration')
              _buildStatusRow('Current Stage', status.currentStage),
            if (status.winnerTeamId != null)
              _buildStatusRow('WINNER', status.winnerTeamId!, isHighlight: true),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 16, color: silverText)),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? accentPurple : silverText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartTournamentButton() {
    return ElevatedButton.icon(
      onPressed: _startTournament,
      icon: const Icon(Icons.play_arrow),
      label: Text('START TOURNAMENT: QUARTER-FINALS', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: accentGreen,
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMatchSimulationList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
          child: Text(
            'PENDING MATCHES',
            style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: accentGreen),
          ),
        ),
        const Divider(color: Colors.white12),
        ..._pendingMatches.map((match) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${match.homeTeamName} vs ${match.awayTeamName}',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: silverText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stage: ${match.stage}',
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _simulateMatch(match.id!),
                      child: const Text('Simulate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
  
  Widget _buildResetButton() {
    return ElevatedButton.icon(
      onPressed: _resetTournament,
      icon: const Icon(Icons.delete_forever),
      label: Text('DANGER: RESET ALL TOURNAMENT DATA', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}