import 'package:flutter/material.dart';
import '../../../../services/language_service.dart';
import '../../../../services/trial_service.dart';
import '../../../../screens/onboarding_screen.dart';

class RecipeTrialLockDialog {
  static void show(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    TrialService.showLockedDialog(
      context: context,
      title: isEn ? 'Recipe Locked (Trial Mode)' : 'Resep Terkunci (Mode Trial)',
      message: isEn
          ? 'This recipe is outside the 10 trial recipes limit.\n\nPlease log in or sign up with an Admin-approved account to unlock all 96+ champion recipes and enjoy unlimited precision brewing!'
          : 'Resep ini berada di luar batas 10 resep mode trial.\n\nSilakan login atau daftar akun resmi yang disetujui Admin untuk membuka seluruh koleksi resep dan menikmati pengalaman seduh tanpa batas!',
      onLoginTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
      },
    );
  }
}
