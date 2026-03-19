import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_page.dart';
import 'login_page.dart';
import '../../widgets/clay_button.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Future<void>? _profileFuture;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return StreamBuilder(
      stream: auth.authChanges,
      builder: (context, snapshot) {
        if (!auth.isLoggedIn) {
          _profileFuture = null;
          return const LoginPage();
        }

        _profileFuture ??= auth.loadProfile();
        return FutureBuilder(
          future: _profileFuture,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (auth.profile == null || auth.error != null) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(auth.error ?? 'Gagal memuat profil'),
                      const SizedBox(height: 12),
                      ClayButton(
                        onPressed: () {
                          setState(() {
                            _profileFuture = auth.loadProfile();
                          });
                        },
                        label: 'Coba lagi',
                      ),
                    ],
                  ),
                ),
              );
            }
            return HomePage(profile: auth.profile!);
          },
        );
      },
    );
  }
}
