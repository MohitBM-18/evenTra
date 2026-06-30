import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        setState(() {
          _selectedRole = authProvider.currentUser!.role;
        });
      }
    });
  }

  void _handleContinue() {
    if (_selectedRole != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.selectRole(_selectedRole!);
      Navigator.pushReplacementNamed(context, Constants.homeRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableRoles = [
      UserRole.studentCoordinator,
      UserRole.facultyCoordinator,
      UserRole.hod,
      UserRole.venueIncharge,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'How are you using evenTra?',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor(context),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your role determines what actions you can perform in the app.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppTheme.secondaryTextColor(context),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: availableRoles.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final role = availableRoles[index];
                    final isSelected = _selectedRole == role;

                    return AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      backgroundColor: isSelected
                          ? AppTheme.primaryColor(context).withOpacity(0.1)
                          : AppTheme.cardColor(context),
                      onTap: () {
                        setState(() {
                          _selectedRole = role;
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            role.icon,
                            size: 28,
                            color: isSelected
                                ? AppTheme.primaryColor(context)
                                : AppTheme.secondaryTextColor(context),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              role.displayName,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected
                                    ? AppTheme.primaryColor(context)
                                    : AppTheme.textColor(context),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor(context)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Continue',
                onPressed: _selectedRole != null ? _handleContinue : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
