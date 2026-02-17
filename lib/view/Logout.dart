import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/viewmodels/UserViewModel.dart';

class LogoutPage extends StatefulWidget {
  const LogoutPage({super.key});

  @override
  State<LogoutPage> createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadUser();
    });
    logout();
  }

void logout() {

      context.read<AuthProvider>().logout();
    }
  @override
  Widget build(BuildContext context) {

    return const Placeholder();
  }
}
