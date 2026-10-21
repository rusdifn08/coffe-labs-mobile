import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SmartScaleScreen extends StatefulWidget {
  const SmartScaleScreen({super.key});

  @override
  State<SmartScaleScreen> createState() => _SmartScaleScreenState();
}

class _SmartScaleScreenState extends State<SmartScaleScreen> {
  double _weight = 0.0;
  bool _isPouring = false;
  Timer? _pourTimer;

  @override
  void dispose() {
    _pourTimer?.cancel();
    super.dispose();
  }

  void _tare() {
    _pourTimer?.cancel();
    setState(() {
      _isPouring = false;
      _weight = 0.0;
    });
  }

  void _togglePourSimulation() {
    if (_isPouring) {
      _pourTimer?.cancel();
      setState(() => _isPouring = false);
    } else {
      setState(() => _isPouring = true);
      _pourTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        setState(() {
          _weight = (_weight + 0.6).clamp(0.0, 999.9);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.textDark,
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
            const Text('Simulasi Timbangan Barista', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 60),
            Text(
              _weight.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'monospace',
              ),
            ),
            const Text('grams', style: TextStyle(color: AppTheme.accentAmber, fontSize: 20)),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white12,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(28),
                  ),
                  onPressed: _tare,
                  child: const Text('TARE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPouring ? Colors.redAccent : AppTheme.primaryBrown,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _togglePourSimulation,
                  icon: Icon(_isPouring ? CupertinoIcons.stop_fill : CupertinoIcons.drop_fill, color: Colors.white),
                  label: Text(
                    _isPouring ? 'Stop Pour' : 'Simulate Pour',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
