import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../constants/auth_assets.dart';
import '../theme/auth_theme.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_illustration.dart';
import '../widgets/auth_otp_field.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthService _authService = AuthService();

  // Step 1: Email
  final TextEditingController _emailController = TextEditingController();

  // Step 2: OTP
  final TextEditingController _otpController = TextEditingController();

  // Step 3: Password
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  int _currentStep = 1; // 1: Email, 2: OTP, 3: New Password, 4: Success
  bool _isLoading = false;
  String _resetToken = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isError ? AuthTheme.error : AuthTheme.success,
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: AuthTheme.fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Step 1 Handler: Request OTP
  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar('Please enter a valid email address.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await _authService.forgotPassword(email: email);
      if (mounted) {
        _showSnackBar(
          res['message'] ?? 'OTP code sent to your email.',
          isError: false,
        );
        setState(() => _currentStep = 2);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Step 2 Handler: Verify OTP
  Future<void> _handleVerifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      _showSnackBar('Please enter the 6-digit OTP code.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await _authService.verifyResetOtp(email: email, otp: otp);
      if (mounted) {
        _resetToken = res['reset_token'] ?? '';
        _showSnackBar('OTP verified successfully!', isError: false);
        setState(() => _currentStep = 3);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Step 3 Handler: Reset Password
  Future<void> _handleResetPassword() async {
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (newPass.length < 6) {
      _showSnackBar('Password must be at least 6 characters long.');
      return;
    }

    if (newPass != confirmPass) {
      _showSnackBar('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(
        resetToken: _resetToken,
        newPassword: newPass,
      );
      if (mounted) {
        setState(() => _currentStep = 4);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onBackNavigation() {
    if (_currentStep > 1 && _currentStep < 4) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      topBar: _buildTopBar(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _buildCurrentStepView(),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            splashRadius: 24,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AuthTheme.inputBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AuthTheme.textPrimary,
              ),
            ),
            onPressed: _onBackNavigation,
          ),
          if (_currentStep < 4)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
                border: Border.all(color: AuthTheme.inputBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 14,
                    color: AuthTheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Step $_currentStep of 3',
                    style: const TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AuthTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 48), // Balancing width
        ],
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Email();
      case 2:
        return _buildStep2Otp();
      case 3:
        return _buildStep3NewPassword();
      case 4:
        return _buildStep4Success();
      default:
        return _buildStep1Email();
    }
  }

  // STEP 1: Enter Email
  Widget _buildStep1Email() {
    return Column(
      key: const ValueKey('step_1'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        const AuthIllustration(
          assetPath: AuthAssets.forgotPasswordIllustration,
          height: 135,
        ),
        const SizedBox(height: 20),
        const AuthHeader(
          badgeText: 'Password Recovery',
          badgeIcon: Icons.lock_reset_rounded,
          title: 'Forgot your password?',
          subtitle:
              "No worries! Enter your registered email and we'll send a 6-digit verification code.",
        ),
        const SizedBox(height: 28),
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
                controller: _emailController,
                label: 'Email address',
                hintText: 'teacher@school.edu',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleSendOtp(),
              ),
              const SizedBox(height: 24),
              AuthPrimaryButton(
                text: 'Send Verification Code',
                isLoading: _isLoading,
                onPressed: _handleSendOtp,
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Sign In', style: AuthTheme.link),
        ),
      ],
    );
  }

  // STEP 2: Enter 6-digit OTP
  Widget _buildStep2Otp() {
    final email = _emailController.text.trim();

    return Column(
      key: const ValueKey('step_2'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        const AuthIllustration(
          assetPath: AuthAssets.otpIllustration,
          height: 135,
        ),
        const SizedBox(height: 20),
        AuthHeader(
          badgeText: 'Check Your Inbox',
          badgeIcon: Icons.mark_email_read_outlined,
          title: 'Enter verification code',
          subtitle: 'We sent a 6-digit security code to:\n$email',
        ),
        const SizedBox(height: 28),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AuthOtpField(
                length: 6,
                controller: _otpController,
                onCompleted: (_) => _handleVerifyOtp(),
              ),
              const SizedBox(height: 24),
              AuthPrimaryButton(
                text: 'Verify Code',
                isLoading: _isLoading,
                onPressed: _handleVerifyOtp,
                icon: const Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive the code? ",
                    style: AuthTheme.subtitle,
                  ),
                  GestureDetector(
                    onTap: _isLoading ? null : _handleSendOtp,
                    child: Text(
                      'Resend Code',
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _isLoading
                            ? AuthTheme.textTertiary
                            : AuthTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 3: Set New Password
  Widget _buildStep3NewPassword() {
    return Column(
      key: const ValueKey('step_3'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        const AuthIllustration(
          assetPath: AuthAssets.forgotPasswordIllustration,
          height: 135,
        ),
        const SizedBox(height: 20),
        const AuthHeader(
          badgeText: 'Account Security',
          badgeIcon: Icons.lock_outline_rounded,
          title: 'Create new password 🔒',
          subtitle: 'Choose a strong password with at least 6 characters.',
        ),
        const SizedBox(height: 28),
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
                controller: _newPasswordController,
                label: 'New Password',
                hintText: 'Enter new password',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                hintText: 'Confirm new password',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleResetPassword(),
              ),
              const SizedBox(height: 24),
              AuthPrimaryButton(
                text: 'Reset Password',
                isLoading: _isLoading,
                onPressed: _handleResetPassword,
                icon: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 4: Success View
  Widget _buildStep4Success() {
    return Column(
      key: const ValueKey('step_4'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const AuthIllustration(
          assetPath: AuthAssets.resetSuccessIllustration,
          height: 150,
        ),
        const SizedBox(height: 24),
        const AuthHeader(
          badgeText: 'All Done 🎉',
          badgeIcon: Icons.task_alt_rounded,
          title: 'Password Reset Complete!',
          subtitle:
              'Your password has been reset successfully. You can now sign in with your new credentials.',
        ),
        const SizedBox(height: 36),
        AuthPrimaryButton(
          text: 'Back to Sign In',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.login_rounded, size: 18, color: Colors.white),
        ),
      ],
    );
  }
}
