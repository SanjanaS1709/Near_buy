import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nearbuy_app/screens/login_screen.dart';

void main() {
  runApp(const NearBuyApp());
}

class NearBuyApp extends StatelessWidget {
  const NearBuyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NearBuy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA50000)),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const LoginScreen(),
    );
  }
}
