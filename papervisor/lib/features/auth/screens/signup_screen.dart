import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../workspace/screens/home_screen.dart';
import '../constants/auth_assets.dart';
import '../theme/auth_theme.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_illustration.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import 'login_screen.dart';
import 'privacy_policy_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _agreedToPrivacy = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    
    if (!_agreedToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AuthTheme.error,
          content: const Text(
            'Please agree to the Privacy Policy to continue.',
            style: TextStyle(
              fontFamily: AuthTheme.fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
      return;
    }

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AuthTheme.error,
          content: const Text(
            'Please fill out all fields.',
            style: TextStyle(
              fontFamily: AuthTheme.fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(name: name, email: email, password: password);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: AuthTheme.error,
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          // Papervisor Brand Title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(AuthAssets.appLogo, fit: BoxFit.cover),
              ),
              const SizedBox(width: 8),
              Text(
                'Papervisor',
                style: TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? const Color(0xFFF8FAFC)
                      : AuthTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Illustration
          const AuthIllustration(
            assetPath: AuthAssets.signupIllustration,
            height: 130,
          ),
          const SizedBox(height: 16),

          // Header Text
          const AuthHeader(
            title: 'Create your account ✨',
            subtitle: 'Start your journey with AI exam preparation.',
          ),
          const SizedBox(height: 24),

          // Input Form Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: ShapeDecoration(
              color: AuthTheme.surfaceWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AuthTheme.radiusCard),
                side: BorderSide(
                  color: AuthTheme.inputBorder.withValues(alpha: 0.6),
                  width: 1.0,
                ),
              ),
              shadows: AuthTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hintText: 'e.g. Dr. Jane Smith',
                  prefixIcon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _emailController,
                  label: 'Email address',
                  hintText: 'teacher@school.edu',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Create a secure password',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleSignup(),
                ),
                const SizedBox(height: 16),

                // Explicit Consent Checkbox inside Card
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _agreedToPrivacy,
                        onChanged: (val) {
                          setState(() {
                            _agreedToPrivacy = val ?? false;
                          });
                        },
                        activeColor: AuthTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: const BorderSide(color: Color(0xFF94A3B8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreedToPrivacy = !_agreedToPrivacy;
                              });
                            },
                            child: const Text(
                              'I agree to the ',
                              style: TextStyle(
                                fontFamily: AuthTheme.fontFamily,
                                fontSize: 12.5,
                                color: AuthTheme.textSecondary,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PrivacyPolicyScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontFamily: AuthTheme.fontFamily,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AuthTheme.accentSky,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                AuthPrimaryButton(
                  text: 'Create Account',
                  isLoading: _isLoading,
                  onPressed: _handleSignup,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Toggle to Log In
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: AuthTheme.subtitle,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AuthTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
