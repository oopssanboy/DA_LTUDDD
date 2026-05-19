import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/media_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MediaProvider()..fetchGenres()),
      ],
      child: MaterialApp(
        title: 'MoveTime',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFFd97706),
          scaffoldBackgroundColor: const Color(0xFFf0f2f5),
          textTheme: GoogleFonts.robotoTextTheme().apply(
            bodyColor: const Color(0xFF333333),
            displayColor: const Color(0xFF333333),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF333333),
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF333333)),
            titleTextStyle: TextStyle(
              color: Color(0xFF333333),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFd97706),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.user == null) {
              return LoginScreen();
            } else {
              Future.microtask(() {
                Provider.of<MediaProvider>(context, listen: false)
                    .setUserId(auth.user!.uid);
              });
              return MainScreen();
            }
          },
        ),
      ),
    );
  }
}