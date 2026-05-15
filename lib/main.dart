import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stradia_ace/providers/auth_provider.dart';
import 'package:stradia_ace/providers/student_provider.dart';
import 'package:stradia_ace/providers/tournament_provider.dart';
import 'package:stradia_ace/screens/splash_screen.dart';
import 'package:stradia_ace/utils/app_fonts.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => TournamentProvider()),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        title: 'Stradia Ace',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0B0E14),
          primaryColor: const Color(0xFF6B4CFF),
          textTheme: GoogleFonts.getTextTheme(
            AppFonts.secondaryFont,
            ThemeData.dark().textTheme,
          ),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6B4CFF),
            secondary: Color(0xFF9D8CFF),
          ),
        ),
        home: SplashScreen(isLoggedIn: isLoggedIn),
      ),
    );
  }
}
