/// Centralized asset management for authentication illustrations and graphics.
/// This isolates asset locations so any asset can be updated or replaced in a single place.
class AuthAssets {
  static const String basePath = 'assets/auth/illustrations';

  // Illustrations
  static const String loginIllustration = '$basePath/login_illustration.svg';
  static const String signupIllustration = '$basePath/signup_illustration.svg';
  static const String forgotPasswordIllustration = '$basePath/forgot_password_illustration.svg';
  static const String otpIllustration = '$basePath/otp_illustration.svg';
  static const String resetSuccessIllustration = '$basePath/reset_success_illustration.svg';
}
