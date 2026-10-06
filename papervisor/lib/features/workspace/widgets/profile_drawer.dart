import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../services/auth_service.dart';
import '../constants/workspace_theme.dart';

/// Premium sliding side drawer displaying Educator Profile details,
/// appearance/theme mode configuration (Light / Dark / System),
/// app information, and account actions (Logout & Delete Profile).
class ProfileDrawer extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onDeleteProfile;

  const ProfileDrawer({
    super.key,
    required this.onLogout,
    required this.onDeleteProfile,
  });

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  final AuthService _authService = AuthService();
  String _userName = 'Educator';
  String _userEmail = 'educator@papervisor.com';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _authService.getUserProfile();
      if (mounted) {
        setState(() {
          _userName = profile['name'] ?? 'Educator';
          _userEmail = profile['email'] ?? 'educator@papervisor.com';
        });
      }
    } catch (_) {}
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'E';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed
        .substring(0, trimmed.length > 2 ? 2 : trimmed.length)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentMode = themeProvider.themeMode;
    final isDark = themeProvider.isDarkMode(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final drawerWidth = screenWidth < 500 ? screenWidth * 0.86 : 380.0;

    return Drawer(
      width: drawerWidth,
      backgroundColor: WorkspaceTheme.surfaceWhite,
      surfaceTintColor: Colors.transparent,
      elevation: 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Top Navigation Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: WorkspaceTheme.accentCobalt.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_pin_rounded,
                            size: 20,
                            color: WorkspaceTheme.accentCobalt,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'Educator Profile',
                            style: TextStyle(
                              fontFamily: WorkspaceTheme.fontFamily,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: WorkspaceTheme.textPrimary,
                              letterSpacing: -0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: WorkspaceTheme.textSecondary,
                    ),
                    splashRadius: 18,
                    tooltip: 'Close Drawer',
                  ),
                ],
              ),
            ),
            Divider(color: WorkspaceTheme.borderSubtle, height: 1),

            // Scrollable Content
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                children: [
                  // Educator Identity Card
                  _buildIdentityCard(isDark),

                  const SizedBox(height: 24),

                  // Appearance / Theme Section
                  _buildSectionLabel('APPEARANCE'),
                  const SizedBox(height: 10),
                  _buildThemeSelector(context, themeProvider, currentMode),

                  const SizedBox(height: 24),

                  // Privacy & Integrity Section
                  _buildSectionLabel('PRIVACY & INTEGRITY'),
                  const SizedBox(height: 10),
                  _buildPrivacyTile(context),

                  const SizedBox(height: 24),

                  // Account Actions Section
                  _buildSectionLabel('ACCOUNT ACTIONS'),
                  const SizedBox(height: 10),
                  _buildAccountActions(context),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Subtle Footer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'Papervisor v1.0.0 • AI Exam Architect',
                style: TextStyle(
                  fontFamily: WorkspaceTheme.fontFamily,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: WorkspaceTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: WorkspaceTheme.fontFamily,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: WorkspaceTheme.textTertiary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildIdentityCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WorkspaceTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
        border: Border.all(color: WorkspaceTheme.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Initials Avatar
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF2563EB), const Color(0xFF0284C7)]
                    : [const Color(0xFF0F172A), const Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getInitials(_userName),
                style: const TextStyle(
                  fontFamily: WorkspaceTheme.fontFamily,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _userName,
                        style: TextStyle(
                          fontFamily: WorkspaceTheme.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: WorkspaceTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.verified_rounded,
                      size: 15,
                      color: Color(0xFF10B981),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _userEmail,
                  style: TextStyle(
                    fontFamily: WorkspaceTheme.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: WorkspaceTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeMode currentMode,
  ) {
    final isDark = currentMode == ThemeMode.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WorkspaceTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
        border: Border.all(color: WorkspaceTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Theme Mode',
                style: TextStyle(
                  fontFamily: WorkspaceTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: WorkspaceTheme.textPrimary,
                ),
              ),
              Text(
                isDark ? 'Dark' : 'Light',
                style: TextStyle(
                  fontFamily: WorkspaceTheme.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: WorkspaceTheme.accentCobalt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2 Segment Buttons: Light / Dark
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  icon: Icons.light_mode_rounded,
                  label: 'Light',
                  isSelected: !isDark,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildThemeOption(
                  icon: Icons.dark_mode_rounded,
                  label: 'Dark',
                  isSelected: isDark,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(WorkspaceTheme.radiusElement),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? WorkspaceTheme.surfaceWhite
                : Colors.transparent,
            borderRadius: BorderRadius.circular(WorkspaceTheme.radiusElement),
            border: Border.all(
              color: isSelected
                  ? WorkspaceTheme.accentCobalt
                  : WorkspaceTheme.borderSubtle.withValues(alpha: 0.5),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: WorkspaceTheme.accentCobalt.withValues(
                        alpha: 0.12,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 19,
                color: isSelected
                    ? WorkspaceTheme.accentCobalt
                    : WorkspaceTheme.textSecondary,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontFamily: WorkspaceTheme.fontFamily,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? WorkspaceTheme.accentCobalt
                      : WorkspaceTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyTile(BuildContext context) {
    return Material(
      color: WorkspaceTheme.surfaceMuted,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
        side: BorderSide(color: WorkspaceTheme.borderSubtle),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: WorkspaceTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: WorkspaceTheme.borderSubtle),
          ),
          child: const Icon(
            Icons.shield_outlined,
            size: 19,
            color: WorkspaceTheme.accentCobalt,
          ),
        ),
        title: Text(
          'Privacy & Academic Integrity',
          style: TextStyle(
            fontFamily: WorkspaceTheme.fontFamily,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: WorkspaceTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          'Educator ownership & confidential exam generation',
          style: TextStyle(
            fontFamily: WorkspaceTheme.fontFamily,
            fontSize: 11.5,
            color: WorkspaceTheme.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: 19,
          color: WorkspaceTheme.textTertiary,
        ),
        onTap: () => _showPrivacyDialog(context),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: WorkspaceTheme.surfaceWhite,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: WorkspaceTheme.accentCobalt.withValues(
                          alpha: 0.1,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: WorkspaceTheme.accentCobalt.withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: WorkspaceTheme.accentCobalt,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Privacy & Academic Integrity',
                        style: TextStyle(
                          fontFamily: WorkspaceTheme.fontFamily,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: WorkspaceTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPrivacyBullet(
                  title: 'Strictly Isolated Educator Storage',
                  description:
                      'All uploaded textbooks, syllabus chapters, and question papers are tied strictly to your authenticated account and are never shared across institutions.',
                ),
                const SizedBox(height: 10),
                _buildPrivacyBullet(
                  title: 'Private AI Exam Grounding',
                  description:
                      'Exam questions and blueprints are grounded purely in your selected textbooks to uphold strict syllabus accuracy and prevent external paper leaks.',
                ),
                const SizedBox(height: 10),
                _buildPrivacyBullet(
                  title: 'Zero Ads & Zero Tracking',
                  description:
                      'Papervisor contains no third-party ad networks, tracking SDKs, or data brokers. Your educator and student test data is never sold or monetized.',
                ),
                const SizedBox(height: 10),
                _buildPrivacyBullet(
                  title: 'Complete Data Erasure Rights',
                  description:
                      'Educators retain 100% data ownership. Deleting your profile permanently erases all workspaces, textbooks, and generated papers from our servers.',
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      backgroundColor: WorkspaceTheme.accentCobalt.withValues(
                        alpha: 0.1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Understand & Close',
                      style: TextStyle(
                        fontFamily: WorkspaceTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: WorkspaceTheme.accentCobalt,
                      ),
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

  Widget _buildPrivacyBullet({
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: WorkspaceTheme.accentCobalt,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: WorkspaceTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: WorkspaceTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontFamily: WorkspaceTheme.fontFamily,
                  fontSize: 12,
                  height: 1.4,
                  color: WorkspaceTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountActions(BuildContext context) {
    return Column(
      children: [
        // Logout Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              widget.onLogout();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: WorkspaceTheme.surfaceMuted,
                borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
                border: Border.all(color: WorkspaceTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: WorkspaceTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: WorkspaceTheme.borderSubtle),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: WorkspaceTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Log Out',
                          style: TextStyle(
                            fontFamily: WorkspaceTheme.fontFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: WorkspaceTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'End current educator session',
                          style: TextStyle(
                            fontFamily: WorkspaceTheme.fontFamily,
                            fontSize: 11.5,
                            color: WorkspaceTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 19,
                    color: WorkspaceTheme.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Delete Profile Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              widget.onDeleteProfile();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: WorkspaceTheme.errorLight,
                borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
                border: Border.all(color: WorkspaceTheme.errorBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: WorkspaceTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: WorkspaceTheme.errorBorder),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: WorkspaceTheme.error,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delete Profile',
                          style: TextStyle(
                            fontFamily: WorkspaceTheme.fontFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: WorkspaceTheme.error,
                          ),
                        ),
                        Text(
                          'Permanently delete account and all data',
                          style: TextStyle(
                            fontFamily: WorkspaceTheme.fontFamily,
                            fontSize: 11.5,
                            color: WorkspaceTheme.error.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 19,
                    color: WorkspaceTheme.error,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
