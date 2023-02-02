import 'package:dispute/model/profile.dart';
import 'package:dispute/screen/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:nostr/nostr.dart';
import 'package:provider/provider.dart';

final logger = Logger();

String generateSubscription() {
  return '["REQ","${generate64RandomHexChars()}",{"kinds":[1],"since":${currentUnixTimestampSeconds() - 86400}}]';
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Profile(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'dispute',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
      ),
      home: const HomeScreen(),
    );
  }
}
