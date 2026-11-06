import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/logo_mark.dart';
import '../home/home_shell.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: LogoMark(size: 76)),
                const SizedBox(height: 18),
                const Center(child: Wordmark(fontSize: 28)),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'FREIGHT INTELLIGENCE',
                    style: TextStyle(
                      color: AppColors.muted,
                      letterSpacing: 3,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                TextField(decoration: _dec('Email', Icons.mail_outline)),
                const SizedBox(height: 14),
                TextField(
                  obscureText: true,
                  decoration: _dec('Password', Icons.lock_outline),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeShell()),
                  ),
                  child: const Text(
                    'Masuk',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 14),
                const Center(
                  child: Text(
                    'Demo — tekan Masuk untuk melihat aplikasi.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );
}
