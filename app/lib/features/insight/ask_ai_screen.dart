import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/pressable.dart';

typedef _Msg = ({String text, bool me});

/// Jawaban contoh. Kunci = kata yang dicari di pertanyaan (huruf kecil).
/// Belum ada backend: ini bukan model AI, hanya pencocokan kata.
const _canned = <({List<String> keys, String answer})>[
  (
    keys: ['margin', 'turun', 'tokyo'],
    answer:
        'Margin rute Jakarta → Tokyo turun 6 poin (dari 22% ke 16%) dalam 2 bulan.\n\n'
        'Penyebabnya biaya trucking naik 18% sementara tarif jual ke customer belum disesuaikan. '
        'Kalau tarif dinaikkan 5%, margin balik ke sekitar 20%.',
  ),
  (
    keys: ['rute', 'untung', 'paling'],
    answer:
        'Tiga rute dengan laba terbesar bulan ini:\n\n'
        '1. Surabaya → Singapura · Rp 96 jt (margin 24%)\n'
        '2. Jakarta → Shanghai · Rp 71 jt (margin 19%)\n'
        '3. Belawan → Port Klang · Rp 54 jt (margin 18%)\n\n'
        'Jakarta → Tokyo volumenya paling besar, tapi marginnya paling tipis.',
  ),
  (
    keys: ['piutang', 'tagih', 'invoice', 'jatuh tempo'],
    answer:
        'Ada 2 invoice lewat jatuh tempo, total Rp 130 jt:\n\n'
        '• INV/2610/009 · PT Sinar Abadi · telat 12 hari · Rp 78 jt\n'
        '• INV/2609/008 · CV Harum Jaya · telat 21 hari · Rp 52 jt\n\n'
        'Total piutang berjalan Rp 412 jt, 68% di antaranya belum jatuh tempo.',
  ),
  (
    keys: ['biaya', 'trucking', 'naik', 'vendor'],
    answer:
        'Biaya terbesar bulan ini: trucking Rp 92 jt (naik 18%), handling Rp 61 jt, '
        'dokumen & bea Rp 38 jt.\n\n'
        'Kenaikan trucking datang dari CV Mitra Laut yang tarifnya 12% di atas rata-rata vendor sejenis.',
  ),
  (
    keys: ['prediksi', 'bulan depan', 'forecast', 'proyeksi'],
    answer:
        'Prediksi laba bulan depan Rp 820 jt (naik 4%), dengan rentang Rp 760–880 jt.\n\n'
        'Dihitung dari tren 6 bulan terakhir dan 34 shipment yang sudah terjadwal.',
  ),
  (
    keys: ['profit', 'laba', 'bulan ini', 'performa'],
    answer:
        'Laba bulan ini Rp 790 jt dari 128 shipment, naik 12% dibanding bulan lalu.\n\n'
        'Pendapatan Rp 3,4 M, biaya Rp 2,6 M. Margin rata-rata 23%.',
  ),
];

const _suggestions = [
  'Kenapa margin turun?',
  'Rute mana paling untung?',
  'Piutang yang lewat jatuh tempo?',
  'Prediksi bulan depan',
];

String _answerFor(String q) {
  final t = q.toLowerCase();
  for (final c in _canned) {
    if (c.keys.any(t.contains)) return c.answer;
  }
  return 'Pertanyaan itu belum bisa dijawab dari data demo.\n\n'
      'Coba tanya soal margin, rute, piutang, biaya, atau prediksi bulan depan.';
}

/// Chat Tanya AI (FR-AI-04). Jawaban masih contoh dari data demo.
class AskAiScreen extends StatefulWidget {
  const AskAiScreen({super.key});

  @override
  State<AskAiScreen> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends State<AskAiScreen> {
  final _msgs = <_Msg>[];
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();
  bool _typing = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: kEaseOut,
      );
    });
  }

  Future<void> _send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _typing) return;
    HapticFeedback.selectionClick();
    setState(() {
      _msgs.add((text: text, me: true));
      _ctrl.clear();
      _typing = true;
    });
    _toBottom();

    await Future.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;
    setState(() {
      _msgs.add((text: _answerFor(text), me: false));
      _typing = false;
    });
    _toBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: _msgs.isEmpty
                  ? _intro()
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      itemCount: _msgs.length + (_typing ? 1 : 0),
                      itemBuilder: (_, i) => i >= _msgs.length
                          ? const _Typing()
                          : _Bubble(_msgs[i]),
                    ),
            ),
            _composer(),
          ],
        ),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 20, 10),
        child: Row(
          children: [
            Pressable(
              semanticLabel: 'Kembali',
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(IconsaxPlusLinear.arrow_left,
                    size: 22, color: AppColors.ink),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tanya AI', style: numStyle(size: 18)),
                  const Text('Jawaban dari data demo',
                      style:
                          TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
            if (_msgs.isNotEmpty)
              Pressable(
                semanticLabel: 'Mulai ulang percakapan',
                onTap: () => setState(_msgs.clear),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(IconsaxPlusLinear.refresh_2,
                      size: 20, color: AppColors.muted),
                ),
              ),
          ],
        ),
      );

  /// Keadaan awal: ajakan + pertanyaan siap pakai (bukan layar kosong).
  Widget _intro() => ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.inkDeep,
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tanya apa saja soal keuangan perusahaanmu.',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.35),
                ),
                SizedBox(height: 8),
                Text(
                  'Margin per rute, piutang yang menunggak, biaya yang naik, sampai prediksi bulan depan.',
                  style: TextStyle(
                      color: AppColors.onDark, fontSize: 13, height: 1.45),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 380.ms).slideY(
              begin: 0.06, end: 0, curve: kEaseOut),
          const SizedBox(height: 24),
          Text('Coba tanyakan', style: numStyle(size: 15)),
          const SizedBox(height: 10),
          for (final s in _suggestions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Pressable(
                onTap: () => _send(s),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    boxShadow: AppShadows.soft,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(s,
                            style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600)),
                      ),
                      const Icon(IconsaxPlusLinear.arrow_right_3,
                          size: 16, color: AppColors.muted),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 14),
          const Text(
            'Jawaban masih contoh dari data demo, belum terhubung ke data perusahaan.',
            style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
          ),
        ],
      );

  Widget _composer() => Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: const BoxDecoration(
          color: AppColors.bg,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  boxShadow: AppShadows.soft,
                ),
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _send,
                  style: const TextStyle(
                      color: AppColors.ink, fontSize: 14, height: 1.4),
                  decoration: const InputDecoration(
                    hintText: 'Tulis pertanyaan',
                    hintStyle:
                        TextStyle(color: AppColors.muted, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Pressable(
              semanticLabel: 'Kirim',
              onTap: () => _send(_ctrl.text),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                    color: AppColors.lime, shape: BoxShape.circle),
                child: const Icon(IconsaxPlusBold.send_1,
                    size: 20, color: AppColors.ink),
              ),
            ),
          ],
        ),
      );
}

class _Bubble extends StatelessWidget {
  final _Msg m;
  const _Bubble(this.m);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Align(
      alignment: m.me ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: w * 0.78),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: m.me ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(m.me ? 20 : 6),
            bottomRight: Radius.circular(m.me ? 6 : 20),
          ),
          boxShadow: m.me ? null : AppShadows.soft,
        ),
        child: Text(
          m.text,
          style: TextStyle(
            color: m.me ? Colors.white : AppColors.ink,
            fontSize: 13.5,
            height: 1.5,
            fontWeight: m.me ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ).animate().fadeIn(duration: 220.ms).slideY(
          begin: 0.12, end: 0, duration: 260.ms, curve: kEaseOut),
    );
  }
}

/// Tiga titik saat jawaban sedang disusun.
class _Typing extends StatelessWidget {
  const _Typing();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: EdgeInsets.only(right: i == 2 ? 0 : 5),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: AppColors.muted, shape: BoxShape.circle),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(
                        delay: (i * 140).ms,
                        duration: 420.ms,
                        begin: 0.25,
                        curve: Curves.easeInOut),
              ),
          ],
        ),
      ),
    );
  }
}
