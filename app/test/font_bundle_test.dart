import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:freightintel/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets(
    'Seluruh 5 bobot font Onest (w400-w800) termuat dari bundel aset lokal tanpa internet',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: Column(
              children: [
                Text('Regular 400', style: GoogleFonts.onest(fontWeight: FontWeight.w400)),
                Text('Medium 500', style: GoogleFonts.onest(fontWeight: FontWeight.w500)),
                Text('SemiBold 600', style: labelStyle()),
                Text('Bold 700', style: numStyle(size: 30, weight: FontWeight.w700)),
                Text('ExtraBold 800', style: GoogleFonts.onest(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      );

      await GoogleFonts.pendingFonts();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Regular 400'), findsOneWidget);
      expect(find.text('Bold 700'), findsOneWidget);
    },
  );
}
