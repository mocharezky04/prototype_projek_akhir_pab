import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/emoji_filter.dart';
import '../../core/utils/input_validators.dart';
import '../../widgets/clay_background.dart';
import '../../widgets/clay_button.dart';
import '../../widgets/clay_card.dart';
import '../../widgets/clay_input.dart';
import '../../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onLoginTap;
  const RegisterPage({super.key, required this.onLoginTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    await auth.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (auth.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi gagal: ${auth.error}')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil, silakan login.')),
      );
      widget.onLoginTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: ClayBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ClayCard(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Daftar Akun',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ClayInput(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: [EmojiFilter.denyEmoji],
                      validator: InputValidators.email,
                    ),
                    const SizedBox(height: 12),
                    ClayInput(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: true,
                      inputFormatters: [EmojiFilter.denyEmoji],
                      validator: InputValidators.password,
                    ),
                    const SizedBox(height: 20),
                    ClayButton(
                      label: auth.isLoading ? 'Memproses...' : 'Daftar',
                      onPressed: auth.isLoading ? null : () => _handleRegister(auth),
                      fullWidth: true,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: widget.onLoginTap,
                      child: const Text('Sudah punya akun? Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
