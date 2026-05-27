import 'package:flutter/material.dart';
import 'package:captain/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tmwdwthwrozqbzvomxio.supabase.co',

    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtd2R3dGh3cm96cWJ6dm9teGlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxNzE5OTQsImV4cCI6MjA5Mzc0Nzk5NH0.OeSh0r6GandmIKCZthv8i2_lx7pUN9e-vU5DdG6s4Hg',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginPage(),
      // theme: ThemeData(
      //   listTileTheme: ListTileThemeData(
      //     tileColor: Colors.grey.shade100,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(12),
      //     ),
      //     iconColor: Colors.blue,
      //     textColor: Colors.black,
      //   ),
      // ),
      debugShowCheckedModeBanner: false,

      title: 'Captains App',
    );
  }
}
