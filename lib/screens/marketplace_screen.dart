import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.lock_fill, size: 80, color: AppTheme.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 24),
            Text(
              'Toko Masih Tutup',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24, color: AppTheme.primaryBrown),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kembali lagi nanti saat kami sudah buka!',
              style: TextStyle(color: AppTheme.textMuted),
            )
          ],
        ),
      ),
    );
  }
}
