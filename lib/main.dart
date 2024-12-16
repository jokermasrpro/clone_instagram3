import 'package:clone_instagram/screens/auth_page/login_screen.dart';
import 'package:clone_instagram/screens/provider.dart';
import 'package:clone_instagram/shard/widgets/button_nav.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            return UserProvider();
          },
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                color: Colors.white,
              );
            } else if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    children: [
                      Text("${snapshot.error}"),
                      ElevatedButton(
                          onPressed: () {}, child: const Text("restart")),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              return const ButtonNav();
            } else if (snapshot.data == null) {
              return const LoginScreen();
            } else {
              return const Scaffold();
            }
          },
        ),
      ),
    );
  }
}
