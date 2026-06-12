import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              ShaderMask(
                shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                child: Text(
                  'Choose Your Role',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select how you\'ll use VenueX',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: UserRole.values
                      .where((role) {
                        if (role == UserRole.superAdmin) {
                          final email = Provider.of<AuthProvider>(context, listen: false)
                                  .currentUser
                                  ?.email
                                  .toLowerCase() ??
                              '';
                          return email == 'mohitbm28@gmail.com';
                        }
                        return true;
                      })
                      .map((role) => _buildRoleCard(role))
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: _selectedRole != null ? AppTheme.gradientDecoration() : null,
                child: ElevatedButton(
                  onPressed: _selectedRole != null
                      ? () {
                          Provider.of<AuthProvider>(context, listen: false).selectRole(_selectedRole!);
                          Navigator.pushReplacementNamed(context, Constants.homeRoute);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedRole != null ? Colors.transparent : Colors.grey[800],
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(UserRole role) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        decoration: AppTheme.glassDecoration().copyWith(
          border: Border.all(
            color: isSelected ? AppTheme.primaryCyan : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              role.icon,
              size: 32,
              color: isSelected ? AppTheme.primaryCyan : AppTheme.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              role.displayName,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryCyan : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
