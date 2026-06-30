// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:eventra/main.dart';
import 'package:eventra/providers/auth_provider.dart';
import 'package:eventra/providers/auditorium_provider.dart';
import 'package:eventra/providers/booking_provider.dart';
import 'package:eventra/providers/help_provider.dart';
import 'package:eventra/providers/lost_found_provider.dart';

void main() {
  testWidgets('App startup smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => AuditoriumProvider()),
          ChangeNotifierProvider(create: (_) => BookingProvider()),
          ChangeNotifierProvider(create: (_) => HelpProvider()),
          ChangeNotifierProvider(create: (_) => LostFoundProvider()),
        ],
        child: const EvenTraApp(),
      ),
    );

    // Verify that the splash screen or login screen is rendered (shows app title or loading indicator)
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Pump and settle with duration to allow splash screen timer to finish
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
