import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SmartScaleScreen extends StatelessWidget {
  const SmartScaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.textDark, // Dark theme for smart device
      appBar: AppBar(
        backgroundColor: AppTheme.textDark,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Smart Scale', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.bluetooth, color: Colors.blue, size: 40),
            const SizedBox(height: 16),
            const Text('Connected to Acaia Pearl', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 60),
            const Text('150.5', style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'monospace')),
            const Text('grams', style: TextStyle(color: AppTheme.accentAmber, fontSize: 20)),
            const SizedBox(height: 80),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white12,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(30),
              ),
              onPressed: () {},
              child: const Text('TARE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
