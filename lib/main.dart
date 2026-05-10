import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/movie_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

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
        ChangeNotifierProvider(create: (_) => MovieProvider()),
      ],
      child: MaterialApp(
        title: 'MoveTime',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
          ),
          scaffoldBackgroundColor: Colors.black,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            // Nếu chưa đăng nhập, hiển thị Login; ngược lại vào Home
            if (auth.user == null) {
              return LoginScreen();
            } else {
              // Cập nhật userId cho MovieProvider
              Future.microtask(() {
                Provider.of<MovieProvider>(context, listen: false)
                    .setUserId(auth.user!.uid);
              });
              return HomeScreen();
            }
          },
        ),
      ),
    );
  }
}