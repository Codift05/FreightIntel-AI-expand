import 'package:flutter/material.dart';
import '../../core/illustrations.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/logo_mark.dart';
import '../home/home_shell.dart';
import '../settings/settings_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl =
      TextEditingController(text: 'owner@nusantara.co.id');
  final _passCtrl = TextEditingController(text: 'demo1234');
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _loading = true);
    await ApiClient.instance.login(_emailCtrl.text, _passCtrl.text);
    await SettingsRepository.instance.syncFromBackend();
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

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
                _field('Email', Icons.mail_outline_rounded, _emailCtrl),
                const SizedBox(height: 14),
                _field('Password', Icons.lock_outline_rounded, _passCtrl,
                    obscure: true),
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
                  onPressed: _loading ? null : _submit,
                  child: Text(_loading ? 'Memuat sesi...' : 'Masuk',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                const SizedBox(height: 14),
                Center(
                  child: GestureDetector(
                    onTap: _showServerSheet,
                    child: Text(
                      'Akun bawaan siap pakai · Ketuk untuk atur server',
                      style: labelStyle().copyWith(
                          letterSpacing: 0, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showServerSheet() {
    final ctrl = TextEditingController(
      text: ApiClient.instance.currentBaseUrl,
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Alamat server API', style: numStyle(size: 16)),
                const SizedBox(height: 4),
                const Text(
                  'Kosongkan untuk otomatis mencoba server lokal atau jalan mandiri (offline).',
                  style: TextStyle(
                      color: AppColors.muted, fontSize: 12.5, height: 1.4),
                ),
                const SizedBox(height: 14),
                _field('URL Server (opsional)', Icons.dns_outlined, ctrl),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.lime,
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.pill)),
                  ),
                  onPressed: () {
                    ApiClient.instance.setCustomBaseUrl(ctrl.text);
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Server diatur ke: ${ApiClient.instance.currentBaseUrl}'),
                      ),
                    );
                  },
                  child: const Text('Simpan alamat server',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(ctrl.dispose);
  }

  Widget _field(String label, IconData icon, TextEditingController ctrl,
          {bool obscure = false}) =>
      TextField(
        controller: ctrl,
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
