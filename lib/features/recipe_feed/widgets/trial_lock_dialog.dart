import 'package:flutter/material.dart';
import '../../../../services/language_service.dart';
import '../../../../services/trial_service.dart';
import '../../auth/utils/auth_navigation_helper.dart';

class RecipeTrialLockDialog {
  static void show(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    TrialService.showLockedDialog(
      context: context,
      title: isEn ? 'Recipe Locked (Trial Mode)' : 'Resep Terkunci (Mode Trial)',
      message: isEn
          ? 'This recipe is outside the 10 trial recipes limit.\n\nPlease log in or sign up with an Admin-approved account or Coffee Labs Pro to unlock all 500+ champion recipes and enjoy unlimited precision brewing & Barista Toolkit!'
          : 'Resep ini berada di luar batas 10 resep mode trial.\n\nSilakan login dengan akun yang disetujui Admin atau aktifkan Coffee Labs Pro untuk membuka seluruh 500+ koleksi resep, seduh tanpa batas & Toolkit Barista!',
      onLoginTap: () => AuthNavigationHelper.openLoginScreen(context),
    );
  }
}
