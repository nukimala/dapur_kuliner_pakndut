import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/buyer_home_screen.dart';
import 'screens/splash_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dapur Pakndut',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFff7e5f)),
        useMaterial3: true,
      ),
      home: SplashScreen(nextScreen: const AuthWrapper()),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFff7e5f)),
            ),
          );
        }

        if (snapshot.hasError) {
           return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        User? user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        if (!user.emailVerified) {
           return const LoginScreen();
        }

        // We have an authenticated user. Now check their role from Firestore.
        return FutureBuilder<UserModel?>(
          future: AuthService().getCurrentUserData(),
          builder: (context, userSnapshot) {
             if (userSnapshot.connectionState == ConnectionState.waiting) {
               return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFFff7e5f)),
                ),
              );
             }

             if (userSnapshot.hasData && userSnapshot.data != null) {
                final userModel = userSnapshot.data!;
                if (userModel.role == 'admin') {
                  return const AdminDashboard();
                } else {
                  return const BuyerHomeScreen();
                }
             }

             // Fallback if no user data found (shouldn't happen under normal circumstances)
             return const LoginScreen();
          },
        );
      },
    );
  }
}
