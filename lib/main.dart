import 'view/Home.dart';
import 'view/LoginP.dart';
import 'package:flutter/material.dart';
import 'viewmodels/UserViewModel.dart ';
import 'package:provider/provider.dart';
import 'package:my_app/view/Profile.dart';
import 'package:my_app/view/logout.dart';
import 'package:my_app/view/client/Register.dart';
import 'package:my_app/viewmodels/artisan_view_model.dart';
import 'package:my_app/view/client/planc.dart';
import 'package:my_app/view/artisan/RegisterA.dart';
import 'view/connectapp.dart';
import 'package:my_app/viewmodels/client_view_model.dart';




void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => ArtisanViewModel()),
           ChangeNotifierProvider(create: (_) => ClientViewModel()),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        Widget startWidget;
if (auth.token != null && auth.token!.isNotEmpty) {
  startWidget = const HomePage();   // ✅ logged → home
} else {
  startWidget = const LoginPage();    // ❌ not logged → login
}
        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          navigatorKey: navigatorKey,
          home: const LoginPage(),
          routes: {
            '/login': (_) => const LoginPage(),
            '/home': (_) => SubscriptionPlans(),
            '/logout': (_) => const LogoutPage(),
            '/profile': (_) => const ProfilePage(),
            '/connect' : (_) => const ChooseProfilePage(),
            '/client/register': (_) => const RegisterPage(),
            '/artisan/register': (_) => const ArtisanRegister(),
            
          },
        );
      },
    );
  }
}