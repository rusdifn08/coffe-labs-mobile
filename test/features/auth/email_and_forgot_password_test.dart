import 'package:coffee_hub_mobile/features/auth/widgets/auth_login_form.dart';
import 'package:coffee_hub_mobile/features/auth/widgets/auth_signup_form.dart';
import 'package:coffee_hub_mobile/features/auth/widgets/forgot_password_sheet.dart';
import 'package:coffee_hub_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthUser email serialization & validation', () {
    test('parses and serializes email field cleanly', () {
      final user = AuthUser.fromJson({
        'id': 'u-123',
        'username': 'rusdibrew',
        'email': 'rusdi@coffeelabs.id',
        'full_name': 'Rusdi Barista',
        'role': 'user',
        'status': 'approved',
        'tier': 'pro',
        'avatar_url': 'assets/images/characters/avatar_1.png',
      });

      expect(user.email, 'rusdi@coffeelabs.id');
      expect(user.toJson()['email'], 'rusdi@coffeelabs.id');

      final legacy = AuthUser.fromJson({
        'id': 'u-legacy',
        'username': 'oldbarista',
        'full_name': 'Old Barista',
        'role': 'user',
        'status': 'approved',
      });
      expect(legacy.email, isNull);
    });

    test('AuthService.isValidEmail accepts valid and rejects malformed addresses', () {
      expect(AuthService.isValidEmail('rusdi.barista+1@gmail.com'), isTrue);
      expect(AuthService.isValidEmail('owner@kopi-nusantara.co.id'), isTrue);
      expect(AuthService.isValidEmail(''), isFalse);
      expect(AuthService.isValidEmail('tanpa-at.com'), isFalse);
      expect(AuthService.isValidEmail('a..b@gmail.com'), isFalse);
      expect(AuthService.isValidEmail('rusdi@localhost'), isFalse);
    });
  });

  group('Login, SignUp, and ForgotPasswordSheet UI', () {
    testWidgets('AuthLoginForm shows Username atau Email and Lupa Password? button', (tester) async {
      final userCtrl = TextEditingController();
      final passCtrl = TextEditingController();
      var forgotTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AuthLoginForm(
                usernameController: userCtrl,
                passwordController: passCtrl,
                isLoading: false,
                onLogin: () {},
                onSwitchToSignUp: () {},
                onForgotPassword: () => forgotTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Username atau Email'), findsOneWidget);
      expect(find.text('Lupa Password?'), findsOneWidget);

      await tester.tap(find.text('Lupa Password?'));
      await tester.pump();
      expect(forgotTapped, isTrue);

      userCtrl.dispose();
      passCtrl.dispose();
    });

    testWidgets('AuthSignUpForm renders Email Aktif field', (tester) async {
      final fullNameCtrl = TextEditingController();
      final userCtrl = TextEditingController();
      final emailCtrl = TextEditingController();
      final passCtrl = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AuthSignUpForm(
                fullNameController: fullNameCtrl,
                usernameController: userCtrl,
                emailController: emailCtrl,
                passwordController: passCtrl,
                selectedAvatar: null,
                isLoading: false,
                onPickAvatar: () {},
                onRegister: () {},
                onBackToLogin: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Email Aktif'), findsOneWidget);
      expect(find.text('Digunakan untuk reset lupa password & info Coffee Labs'), findsOneWidget);

      fullNameCtrl.dispose();
      userCtrl.dispose();
      emailCtrl.dispose();
      passCtrl.dispose();
    });

    testWidgets('ForgotPasswordSheet completes 2-step reset via email code', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      String? requestedIdentifier;
      String? confirmedCode;
      String? resetSuccessIdentifier;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => ForgotPasswordSheet(
                      initialIdentifier: 'rusdi@gmail.com',
                      onResetSuccess: (id) => resetSuccessIdentifier = id,
                      requestResetFn: ({required String identifier}) async {
                        requestedIdentifier = identifier;
                        return {
                          'success': true,
                          'maskedEmail': 'r***i@gmail.com',
                          'message': 'Kode reset terkirim.',
                        };
                      },
                      confirmResetFn: ({
                        required String identifier,
                        required String code,
                        required String newPassword,
                      }) async {
                        confirmedCode = code;
                        return {
                          'success': true,
                          'message': 'Password berhasil direset!',
                        };
                      },
                    ),
                  );
                },
                child: const Text('Buka Reset'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Reset'));
      await tester.pumpAndSettle();

      expect(find.text('Lupa Password?'), findsOneWidget);
      await tester.tap(find.text('Kirim Kode Reset ke Email'));
      await tester.pumpAndSettle();

      expect(requestedIdentifier, 'rusdi@gmail.com');
      expect(find.textContaining('r***i@gmail.com'), findsOneWidget);

      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(3));
      await tester.enterText(fields.at(0), '482910');
      await tester.enterText(fields.at(1), 'kopibaru123');
      await tester.enterText(fields.at(2), 'kopibaru123');
      await tester.pump();

      await tester.tap(find.text('Simpan Password Baru'));
      await tester.pumpAndSettle();

      expect(confirmedCode, '482910');
      expect(resetSuccessIdentifier, 'rusdi@gmail.com');
      expect(find.text('Password berhasil direset!'), findsOneWidget);
    });
  });
}
