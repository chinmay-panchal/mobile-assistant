import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

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
  final TextEditingController _confirmPasswordController = TextEditingController();

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

  // Step 1 Handler: Request OTP
  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await _authService.forgotPassword(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'OTP code sent to your email.')),
        );
        setState(() => _currentStep = 2);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP code.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await _authService.verifyResetOtp(email: email, otp: otp);
      if (mounted) {
        _resetToken = res['reset_token'] ?? '';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP verified successfully!')),
        );
        setState(() => _currentStep = 3);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters long.')),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(resetToken: _resetToken, newPassword: newPass);
      if (mounted) {
        setState(() => _currentStep = 4);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reset Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (_currentStep > 1 && _currentStep < 4) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              
              // Progress Indicator
              if (_currentStep < 4) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStepDot(1, 'Email'),
                    _buildStepLine(1),
                    _buildStepDot(2, 'OTP'),
                    _buildStepLine(2),
                    _buildStepDot(3, 'Password'),
                  ],
                ),
                const SizedBox(height: 32),
              ],

              // STEP 1: Enter Email
              if (_currentStep == 1) ...[
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_reset, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                const Text('Forgot Password?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text(
                  'Enter your registered email address below. We will send you a 6-digit verification OTP code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _emailController,
                  label: 'EMAIL ADDRESS',
                  hintText: 'teacher@school.edu',
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: _isLoading ? 'Sending OTP...' : 'Send OTP',
                  onPressed: _isLoading ? () {} : _handleSendOtp,
                ),
              ],

              // STEP 2: Enter OTP
              if (_currentStep == 2) ...[
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.warningLight.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_email_read_outlined, size: 40, color: AppColors.warning),
                ),
                const SizedBox(height: 20),
                const Text('Verify OTP Code', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-digit verification code sent to:\n${_emailController.text.trim()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _otpController,
                  label: '6-DIGIT OTP CODE',
                  hintText: '123456',
                  prefixIcon: Icons.pin_outlined,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: _isLoading ? 'Verifying...' : 'Verify OTP',
                  onPressed: _isLoading ? () {} : _handleVerifyOtp,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading ? null : _handleSendOtp,
                  child: const Text('Resend OTP Code', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],

              // STEP 3: Enter New Password
              if (_currentStep == 3) ...[
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.successLight.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.key_outlined, size: 40, color: AppColors.success),
                ),
                const SizedBox(height: 20),
                const Text('Set New Password', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text(
                  'Please enter your new password below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _newPasswordController,
                  label: 'NEW PASSWORD',
                  hintText: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'CONFIRM NEW PASSWORD',
                  hintText: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: _isLoading ? 'Updating Password...' : 'Reset Password',
                  onPressed: _isLoading ? () {} : _handleResetPassword,
                ),
              ],

              // STEP 4: Success
              if (_currentStep == 4) ...[
                const SizedBox(height: 20),
                Container(
                  width: 90, height: 90,
                  decoration: const BoxDecoration(
                    color: AppColors.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, size: 54, color: AppColors.success),
                ),
                const SizedBox(height: 24),
                const Text('Password Reset Complete!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                const Text(
                  'Your password has been reset successfully. You can now log in with your new credentials.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 36),
                PrimaryButton(
                  text: 'Back to Login',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isDone = _currentStep > step;
    final isCurrent = _currentStep == step;

    Color bg = AppColors.divider;
    Color fg = AppColors.textTertiary;
    if (isDone || isCurrent) {
      bg = AppColors.primary;
      fg = Colors.white;
    }

    return Column(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : Text('$step', style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int afterStep) {
    final isPassed = _currentStep > afterStep;
    return Container(
      width: 40, height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      color: isPassed ? AppColors.primary : AppColors.divider,
    );
  }
}
