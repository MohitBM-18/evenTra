// Copyright (c) 2026 evenTra. All rights reserved.
// Christ University Venue Booking Platform.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Logo animation
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  // Tagline animation
  late AnimationController _taglineController;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;

  // Subtitle animation
  late AnimationController _subtitleController;
  late Animation<double> _subtitleOpacity;

  // Progress bar animation
  late AnimationController _progressController;
  late Animation<double> _progressValue;

  // Orb glow animation
  late AnimationController _glowController;
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();

    // --- Orb glow ---
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowOpacity = CurvedAnimation(parent: _glowController, curve: Curves.easeIn);

    // --- Logo: scale + fade ---
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // --- Tagline: slide up + fade ---
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOutCubic),
    );

    // --- Subtitle: fade ---
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeIn),
    );

    // --- Progress bar ---
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Step 1: Glow orbs appear
    _glowController.forward();
    await Future.delayed(const Duration(milliseconds: 300));

    // Step 2: Logo pops in
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 700));

    // Step 3: Tagline slides up
    _taglineController.forward();
    await Future.delayed(const Duration(milliseconds: 400));

    // Step 4: Subtitle fades in
    _subtitleController.forward();
    await Future.delayed(const Duration(milliseconds: 300));

    // Step 5: Progress bar sweeps
    _progressController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));

    // Navigate
    if (mounted) {
      Navigator.pushReplacementNamed(context, Constants.loginRoute);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    _subtitleController.dispose();
    _progressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // --- Background glow orbs ---
          FadeTransition(
            opacity: _glowOpacity,
            child: Stack(
              children: [
                Positioned(
                  top: -80,
                  left: -80,
                  child: _buildOrb(280, AppTheme.primaryPurple, 0.25),
                ),
                Positioned(
                  bottom: -60,
                  right: -60,
                  child: _buildOrb(240, AppTheme.primaryCyan, 0.18),
                ),
                Positioned(
                  top: size.height * 0.4,
                  left: size.width * 0.6,
                  child: _buildOrb(160, AppTheme.accentPink, 0.15),
                ),
              ],
            ),
          ),

          // --- Main content ---
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo card with scale + fade
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 184,
                    height: 184,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(42),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withOpacity(0.38),
                          blurRadius: 50,
                          spreadRadius: 8,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: AppTheme.accentPink.withOpacity(0.22),
                          blurRadius: 30,
                          spreadRadius: 2,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/eventra_app_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Tagline: "Events with exTra efforts"
                SlideTransition(
                  position: _taglineSlide,
                  child: FadeTransition(
                    opacity: _taglineOpacity,
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          const LinearGradient(
                            colors: [
                              Color(0xFF7C3AED),
                              Color(0xFFEC4899),
                              Color(0xFFF59E0B),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds),
                      child: Text(
                        'Events with exTra efforts',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                FadeTransition(
                  opacity: _subtitleOpacity,
                  child: Text(
                    'Smart Venue Booking · Christ University',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: LinearProgressIndicator(
                              value: _progressValue.value,
                              minHeight: 3,
                              backgroundColor: Colors.white.withOpacity(0.08),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryCyan,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      FadeTransition(
                        opacity: _subtitleOpacity,
                        child: Text(
                          'Loading...',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.textSecondary.withOpacity(0.6),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrb(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(opacity),
            color.withOpacity(0.0),
          ],
        ),
      ),
    );
  }
}
