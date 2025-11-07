// lib/screens/registration_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../services/api_service.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  static const Color accentPurple = Color(0xFFC639FF);
  static const Color accentGreen = Color(0xFF00D283);
  static const Color silverText = Color(0xFFE0E0E0);
  static const Color pitchColor = Color(0xFF006400);

  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _managerNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _captainNameController = TextEditingController();

  List<Player> _players = List.generate(
    23,
    (index) => Player(name: '', position: index < 2 ? 'GK' : (index < 9 ? 'DF' : (index < 16 ? 'MD' : 'AT'))),
  );

  final List<String> _positions = ['GK', 'DF', 'MD', 'AT'];
  bool _isLoading = false;

  @override
  void dispose() {
    _countryController.dispose();
    _managerNameController.dispose();
    _emailController.dispose();
    _captainNameController.dispose();
    super.dispose();
  }

  List<Player> _getPlayersByPosition(String position) {
    return _players.where((p) => p.position == position).toList();
  }
  
  void _showPlayerEditDialog(int index) {
    String playerPosition = _players[index].position;
    final nameController = TextEditingController(text: _players[index].name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          title: Text('Edit Player ${index + 1}', style: GoogleFonts.montserrat(color: accentPurple, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Player Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),
                StatefulBuilder(
                  builder: (context, setStateSB) {
                    return DropdownButtonFormField<String>(
                      value: playerPosition,
                      decoration: const InputDecoration(labelText: 'Position', border: OutlineInputBorder()),
                      items: _positions.map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value, style: TextStyle(color: silverText)));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setStateSB(() { playerPosition = newValue!; });
                      },
                    );
                  }
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: accentPurple, foregroundColor: Colors.white),
              child: const Text('SAVE'),
              onPressed: () {
                setState(() {
                  _players[index].name = nameController.text.trim();
                  _players[index].position = playerPosition;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((_) {
      nameController.dispose();
      setState(() {});
    });
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) { return; }
    if (_players.any((p) => p.name.trim().isEmpty)) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All 23 player slots must be filled.')));
      return;
    }
    final captainName = _captainNameController.text.trim();
    if (_players.indexWhere((p) => p.name.trim() == captainName) == -1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Captain must be one of the 23 registered players!')));
      return;
    }
    
    final newTeam = Team(
      country: _countryController.text.trim(),
      managerName: _managerNameController.text.trim(),
      representativeEmail: _emailController.text.trim(),
      players: _players,
      captainName: captainName,
    );

    setState(() { _isLoading = true; });

    try {
      await _apiService.registerTeam(newTeam);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Team ${newTeam.country} Registered Successfully!'), backgroundColor: accentGreen));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration Failed: ${e.toString().split(':').last.trim()}')),);
      }
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  Widget _buildPlayerCard(Player player, int originalIndex) {
    bool isFilled = player.name.isNotEmpty;
    bool isCaptain = player.name == _captainNameController.text.trim() && isFilled;
    
    return InkWell(
      onTap: () => _showPlayerEditDialog(originalIndex),
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: accentGreen.withOpacity(isFilled ? 1.0 : 0.6),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 4)],
              ),
              child: Center(
                child: Text(
                  player.position,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: isFilled ? Colors.white : Colors.white10,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isFilled ? player.name.split(' ').last : 'SLOT ${originalIndex + 1}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isFilled ? Colors.black87 : silverText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isCaptain)
                    Text('C', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: accentPurple)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFplRosterView() {
    final gkPlayers = _getPlayersByPosition('GK');
    final dfPlayers = _getPlayersByPosition('DF');
    final mdPlayers = _getPlayersByPosition('MD');
    final atPlayers = _getPlayersByPosition('AT');

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: pitchColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              '23-MAN ROSTER BUILD', 
              style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: silverText),
            ),
          ),
          
          ..._buildPlayerRow(gkPlayers, 'GK'),
          ..._buildPlayerRow(dfPlayers, 'DF'),
          ..._buildPlayerRow(mdPlayers, 'MD'),
          ..._buildPlayerRow(atPlayers, 'AT'),
        ],
      ),
    );
  }
  
  List<Widget> _buildPlayerRow(List<Player> players, String position) {
    return [
      const SizedBox(height: 15),
      const Divider(color: Colors.white30, thickness: 1),
      const SizedBox(height: 15),
      Text(position, style: GoogleFonts.montserrat(color: accentGreen, fontSize: 12, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        alignment: WrapAlignment.center,
        children: List.generate(players.length, (i) {
          final player = players[i];
          final originalIndex = _players.indexOf(player);
          return _buildPlayerCard(player, originalIndex);
        }),
      ),
    ];
  }

  Widget _buildTeamDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FEDERATION DETAILS',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: accentPurple),
            ),
            const Divider(color: Colors.white12, height: 20),
            _buildCustomTextFormField(_countryController, 'Country Name (e.g., Ghana)', Icons.flag),
            _buildCustomTextFormField(_managerNameController, 'Manager Name', Icons.person),
            _buildCustomTextFormField(_emailController, 'Federation Email', Icons.email, keyboard: TextInputType.emailAddress, isEmail: true),
            _buildCustomTextFormField(_captainNameController, 'Captain Name (Must be in Roster)', Icons.star, iconColor: accentPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTextFormField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboard, Color iconColor = Colors.white70, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        style: GoogleFonts.inter(color: silverText),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: iconColor),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          if (isEmail && !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
            return 'Enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Build Your Roster', style: Theme.of(context).appBarTheme.titleTextStyle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTeamDetailsCard(),
              const SizedBox(height: 30),
              _buildFplRosterView(),
              const SizedBox(height: 40),

              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: accentPurple))
                  : ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text('REGISTER TEAM', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}