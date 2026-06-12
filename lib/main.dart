// Copyright (c) 2026 evenTra. All rights reserved.
// Christ University Venue Booking Platform.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'utils/constants.dart';
import 'providers/auth_provider.dart';
import 'providers/auditorium_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/help_provider.dart';
import 'providers/lost_found_provider.dart';
import 'providers/incharge_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/auditorium/auditorium_detail_screen.dart';
import 'screens/booking/booking_form_screen.dart';
import 'screens/booking/booking_detail_screen.dart';
import 'screens/admin/booking_requests_screen.dart';
import 'screens/help/help_request_screen.dart';
import 'screens/lost_found/lost_found_screen.dart';
import 'screens/lost_found/add_item_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase will initialize successfully after the app is connected
    // with platform config such as google-services.json.
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AuditoriumProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => HelpProvider()),
        ChangeNotifierProvider(create: (_) => LostFoundProvider()),
        ChangeNotifierProvider(create: (_) => InchargeProvider()),
      ],
      child: const VenueXApp(),
    ),
  );
}

class VenueXApp extends StatelessWidget {
  const VenueXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: Constants.splashRoute,
      routes: {
        Constants.splashRoute: (context) => const SplashScreen(),
        Constants.loginRoute: (context) => const LoginScreen(),
        Constants.roleSelectionRoute: (context) => const RoleSelectionScreen(),
        Constants.homeRoute: (context) => const HomeScreen(),
        Constants.bookingRequestsRoute: (context) => const BookingRequestsScreen(),
        '/support': (context) => const HelpRequestScreen(),
        '/lost_found': (context) => const LostFoundScreen(),
        '/add_lost_found': (context) => const AddLostFoundScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == Constants.auditoriumDetailRoute) {
          final id = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => AuditoriumDetailScreen(auditoriumId: id),
          );
        }
        if (settings.name == Constants.bookingFormRoute) {
          final id = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => BookingFormScreen(auditoriumId: id),
          );
        }
        if (settings.name == Constants.bookingDetailRoute) {
          final id = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => BookingDetailScreen(bookingId: id),
          );
        }
        return null;
      },
    );
  }
}
