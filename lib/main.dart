import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/auth_service.dart';
import 'stores/favorite_store.dart';
import 'theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<bool> _restoreSession() async {
    if (!await AuthService.isLoggedIn()) {
      return false;
    }

    final userId = await AuthService.getUserId();
    if (userId == null) {
      return false;
    }

    await FavoriteStore.instance.init(userId);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Explorer',
      theme: appTheme,
      home: FutureBuilder<bool>(
        future: _restoreSession(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Gagal memuat sesi: ${snapshot.error}')),
            );
          }

          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return snapshot.data == true
              ? const MainShell()
              : const LoginScreen();
        },
      ),
    );
  }
}
