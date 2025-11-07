// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/registration_page.dart';
import 'screens/admin_page.dart';
import 'screens/bracket_page.dart';
import 'screens/match_summary_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // New UCL/FPL Dark Theme Colors
  static const Color primaryNavy = Color(0xFF000122);
  static const Color accentPurple = Color(0xFFC639FF);
  static const Color accentGreen = Color(0xFF00D283);
  static const Color silverText = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'African Nations League Simulator',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: primaryNavy,
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: accentGreen,
          brightness: Brightness.dark,
          primary: accentGreen,
          onPrimary: Colors.black,
          secondary: accentPurple,
          surface: const Color(0xFF1A1A3A),
          onSurface: silverText,
        ),
        
        // --- FINAL FIX: Use CardTheme.copyWith to generate the CardThemeData ---
        cardTheme: CardThemeData( 
          color: const Color(0xFF1A1A3A),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        // --- END FINAL FIX ---

        appBarTheme: AppBarTheme(
          backgroundColor: primaryNavy,
          foregroundColor: silverText,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 22, 
            fontWeight: FontWeight.w900, 
            color: silverText,
          ),
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white10,
          labelStyle: TextStyle(color: silverText.withOpacity(0.8)),
          hintStyle: TextStyle(color: silverText.withOpacity(0.5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: accentPurple, width: 2),
          ),
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/register': (context) => const RegistrationPage(),
        '/admin': (context) => const AdminPage(),
        '/bracket': (context) => const BracketPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/match-summary') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => MatchSummaryPage(
              matchId: args['matchId'] as String,
              stage: args['stage'] as String,
            ),
          );
        }
        return null;
      },
    );
  }
}

void main() {
  runApp(const MyApp());
}