// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tournament_status.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  TournamentStatus? _status;
  String? _errorMessage;
  bool _isLoading = true;

  static const Color accentPurple = Color(0xFFC639FF);
  static const Color accentGreen = Color(0xFF00D283);
  static const Color silverText = Color(0xFFE0E0E0);
  static const Color primaryNavy = Color(0xFF000122);

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  void _fetchStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final status = await _apiService.getTournamentStatus();
      setState(() {
        _status = status;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching status: ${e.toString().split(':').last.trim()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('African Nations League', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: accentGreen)),
        backgroundColor: primaryNavy,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: accentGreen),
            onPressed: _fetchStatus,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: accentPurple));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade400)),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusCard(context),
          const SizedBox(height: 30),

          _buildActionButton(
            context,
            icon: Icons.app_registration,
            text: 'Register Your Nation',
            subtitle: 'Sign up to compete (${_status!.teamsRegistered}/${_status!.maxTeams} spots filled)',
            onPressed: _status!.isActive || _status!.teamsRegistered == _status!.maxTeams ? null : () => Navigator.pushNamed(context, '/register').then((_) => _fetchStatus()),
            isDisabled: _status!.isActive || _status!.teamsRegistered == _status!.maxTeams,
            accentColor: accentGreen,
          ),
          const SizedBox(height: 20),
          
          _buildActionButton(
            context,
            icon: Icons.emoji_events,
            text: 'View Tournament Bracket',
            subtitle: 'See all matches, results, and progress',
            onPressed: _status!.teamsRegistered < 2 ? null : () => Navigator.pushNamed(context, '/bracket').then((_) => _fetchStatus()),
            isDisabled: _status!.teamsRegistered < 2,
            accentColor: accentGreen,
          ),
          const SizedBox(height: 20),
          
          _buildActionButton(
            context,
            icon: Icons.admin_panel_settings,
            text: 'Administrator Panel',
            subtitle: 'Start and simulate matches',
            onPressed: () => Navigator.pushNamed(context, '/admin').then((_) => _fetchStatus()),
            isAccent: true,
            accentColor: accentPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final status = _status!;
    String stageText = status.currentStage.toUpperCase().replaceAll('_', ' ');
    Color stageColor = status.isActive ? accentGreen : Colors.blueGrey.shade400;
    String statusDetail = status.isActive 
        ? 'ACTIVE: ${stageText} Stage'
        : 'REGISTRATION PHASE';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOURNAMENT STATUS',
              style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade400),
            ),
            const Divider(color: Colors.white12, height: 10),
            _buildStatusRow('Current Stage', statusDetail, color: stageColor),
            _buildStatusRow('Teams Registered', '${status.teamsRegistered} / ${status.maxTeams}', isHighlight: status.teamsRegistered == status.maxTeams),
            if (status.winnerTeamId != null)
              _buildStatusRow('UCL CHAMPION', status.winnerTeamId!, isHighlight: true),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, {bool isHighlight = false, Color? color}) {
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
              color: isHighlight ? accentPurple : color ?? silverText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String text,
        required String subtitle,
        required VoidCallback? onPressed,
        bool isDisabled = false,
        bool isAccent = false,
        required Color accentColor,
      }) {
    Color cardColor = isAccent ? accentColor : Theme.of(context).cardTheme.color!;
    Color iconTextColor = isAccent ? Colors.black : accentColor;
    
    if (isDisabled) {
      cardColor = Colors.grey.shade800;
      iconTextColor = Colors.grey.shade600;
    }

    return Card(
      color: cardColor,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: iconTextColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: GoogleFonts.montserrat(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: isAccent ? Colors.black : silverText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 14, 
                        color: isDisabled ? Colors.grey.shade600 : silverText.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: iconTextColor),
            ],
          ),
        ),
      ),
    );
  }
}