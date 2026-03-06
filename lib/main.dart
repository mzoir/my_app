import 'view/LoginP.dart';
import 'package:flutter/material.dart';
import 'viewmodels/UserViewModel.dart ';
import 'package:provider/provider.dart';
import 'package:my_app/view/logout.dart';
import 'package:my_app/view/client/register_client.dart';
import 'package:my_app/view/artisan/Home/navbottom.dart';
import 'package:my_app/view/client/Home/navbottom.dart';
import 'package:my_app/viewmodels/artisan_view_model.dart';
import 'package:my_app/utils/responsive.dart';
import 'package:my_app/utils/responsive.dart';
import 'package:my_app/view/client/planc.dart';
import 'package:my_app/view/artisan/register_Artisan.dart';
import 'package:my_app/viewmodels/handle.dart';
import 'view/connect_app.dart';
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
          startWidget = const LoginPage(); // ✅ logged → home
        } else {
          startWidget = const LoginPage(); // ❌ not logged → login
        }
        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            Responsive.init(context); // ← one line, covers every screen
            return child!;
          },
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          navigatorKey: navigatorKey,
          home: const LoginPage(),
          routes: {
            '/login': (_) => const LoginPage(),
            '/home': (_) => SubscriptionPlans(),
            '/home/client': (_) => HomeShellC(),
            '/logout': (_) => const LogoutPage(),
            '/connect': (_) => const ChooseProfilePage(),
            '/client/register': (_) => const RegisterPage(),
            '/artisan/register': (_) => const ArtisanRegister(),
            '/connectgoogle': (_) => GoogleLoginDemo(),
            '/home/artisan': (_) => HomeShell(),
          },
        );
      },
    );
  }
}
