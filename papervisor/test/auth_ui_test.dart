import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papervisor/features/auth/screens/forgot_password_screen.dart';
import 'package:papervisor/features/auth/screens/login_screen.dart';
import 'package:papervisor/features/auth/screens/signup_screen.dart';
import 'package:papervisor/features/auth/widgets/auth_otp_field.dart';
import 'package:papervisor/features/auth/widgets/auth_primary_button.dart';
import 'package:papervisor/features/auth/widgets/auth_text_field.dart';

void main() {
  group('Auth UI & Component Tests', () {
    testWidgets('LoginScreen renders form, illustration and CTAs', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();

      expect(find.text('Welcome back 👋'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
    });

    testWidgets('SignupScreen renders all inputs and buttons', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupScreen()));
      await tester.pump();

      expect(find.text('Create your account ✨'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('ForgotPasswordScreen renders Step 1 with email and send CTA', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));
      await tester.pump();

      expect(find.text('Forgot your password?'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Send Verification Code'), findsOneWidget);
      expect(find.text('Step 1 of 3'), findsOneWidget);
    });

    testWidgets('AuthPrimaryButton responds to tap and displays loading state', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthPrimaryButton(
              text: 'Continue',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      expect(pressed, isTrue);

      // Loading state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthPrimaryButton(
              text: 'Continue',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AuthTextField toggles password visibility', (WidgetTester tester) async {
      final controller = TextEditingController(text: 'secret123');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              label: 'Password',
              hintText: 'Enter password',
              controller: controller,
              isPassword: true,
            ),
          ),
        ),
      );

      final visibilityToggle = find.byIcon(Icons.visibility_outlined);
      expect(visibilityToggle, findsOneWidget);

      await tester.tap(visibilityToggle);
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('AuthOtpField renders 6 digit boxes and syncs input', (WidgetTester tester) async {
      final controller = TextEditingController();
      String lastCompleted = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthOtpField(
              length: 6,
              controller: controller,
              onCompleted: (val) => lastCompleted = val,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsNWidgets(6));
      controller.text = '123456';
      await tester.pump();
      expect(lastCompleted, equals('123456'));
    });
  });
}
