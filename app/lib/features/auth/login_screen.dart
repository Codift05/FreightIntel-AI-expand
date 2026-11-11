import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/illustrations.dart';
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  child: Image.asset(Illus.loginHero, fit: BoxFit.cover),
                ),
                const SizedBox(height: 22),
                const Center(child: Wordmark(fontSize: 28)),
                const SizedBox(height: 6),
                Center(
                    child: Text('Manajemen keuangan & pengiriman kargo',
                        style: labelStyle())),
                const SizedBox(height: 36),
                _field('Email', Icons.mail_outline_rounded),
                const SizedBox(height: 14),
                _field('Password', Icons.lock_outline_rounded, obscure: true),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.lime,
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadii.pill)),
                  ),
                  onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeShell())),
                  child: const Text('Masuk',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                const SizedBox(height: 14),
                Center(
                    child: Text('Demo. Tekan Masuk untuk melihat aplikasi.',
                        style: labelStyle().copyWith(
                            letterSpacing: 0, fontWeight: FontWeight.w500))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, IconData icon, {bool obscure = false}) =>
      TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.muted),
          filled: true,
          fillColor: AppColors.surfaceAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.input),
            borderSide: BorderSide.none,
          ),
        ),
      );
}
