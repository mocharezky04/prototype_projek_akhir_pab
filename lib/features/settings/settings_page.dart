import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/clay_card.dart';
import '../../widgets/clay_fade_slide.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (auth.error != null) {
      return Center(child: Text('Gagal memuat user: ${auth.error}'));
    }

    return auth.users.isEmpty
        ? const Center(child: Text('Belum ada user.'))
        : ListView.builder(
            itemCount: auth.users.length,
            itemBuilder: (context, index) {
              final user = auth.users[index];
              return ClayFadeSlide(
                index: index,
                child: ClayCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email),
                            const SizedBox(height: 4),
                            Text('Role: ${user.role}'),
                          ],
                        ),
                      ),
                      DropdownButton<String>(
                        value: user.role,
                        items: const [
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          DropdownMenuItem(value: 'kasir', child: Text('Kasir')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          auth.updateRole(user.id, value);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
