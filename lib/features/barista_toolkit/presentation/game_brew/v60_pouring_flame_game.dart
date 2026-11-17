import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class V60SimulationSnapshot {
  final double elapsedSec;
  final double pouredMl;
  final double serverMl;
  final double coneVolumeMl;
  final double flowRateMlS;
  final double tempC;
  final double estimatedEyPct;
  final double acidPct;
  final double sweetPct;
  final double bitterPct;
  final double pourAccuracyPct;
  final double thermalStabilityPct;
  final double channelingRiskPct;
  final bool isCompleted;
  final String liveTip;

  const V60SimulationSnapshot({
    this.elapsedSec = 0,
    this.pouredMl = 0,
    this.serverMl = 0,
    this.coneVolumeMl = 0,
    this.flowRateMlS = 0,
    this.tempC = 92,
    this.estimatedEyPct = 0,
    this.acidPct = 0,
    this.sweetPct = 0,
    this.bitterPct = 0,
    this.pourAccuracyPct = 100,
    this.thermalStabilityPct = 100,
    this.channelingRiskPct = 0,
    this.isCompleted = false,
    this.liveTip = 'Tahan dan geser di area V60 atau naikkan tuas ketel untuk memulai blooming.',
  });
}

class _BloomBubble {
  double x;
  double y;
  double radius;
  double life;
  _BloomBubble(this.x, this.y, this.radius, this.life);
}

class _DripDrop {
  double y;
  double speed;
  _DripDrop(this.y, this.speed);
}

/// Mesin Simulasi V60 60fps berbasis FlameGame (Rumus Modul 2.1):
/// - Q(t) = Q_max * theta^1.4
/// - Drawdown Hukum Darcy dV_cone/dt = Q(t) - k_perm * V_cone / (1 + phi_choke)
/// - Kinetika ekstraksi berurutan: Asam -> Manis -> Pahit + Channeling / Thermal Drop 70C.
class V60PouringFlameGame extends FlameGame {
  final double doseG;
  final double targetWaterMl;
  final double bloomMl;
  final double bloomSec;
  final double initialTempC;
  final double? dropTempC;
  final double? dropAtMl;
  final double targetTimeSec;
  final double idealFlowMlS;

  final ValueNotifier<V60SimulationSnapshot> snapshotNotifier = ValueNotifier(
    const V60SimulationSnapshot(),
  );

  V60PouringFlameGame({
    required this.doseG,
    required this.targetWaterMl,
    required this.bloomMl,
    required this.bloomSec,
    required this.initialTempC,
    this.dropTempC,
    this.dropAtMl,
    required this.targetTimeSec,
    required this.idealFlowMlS,
  }) : _currentTempC = initialTempC;

  static const double _qMaxMlS = 12.0;

  bool _isRunning = true;
  bool _hasStartedPour = false;
  bool _completed = false;

  double _pourTiltTheta = 0.0;
  Offset _aimOffset = Offset.zero;
  Offset _prevAimOffset = Offset.zero;

  double _elapsedSec = 0.0;
  double _pouredMl = 0.0;
  double _serverMl = 0.0;
  double _coneVolumeMl = 0.0;
  double _currentFlowMlS = 0.0;
  double _currentTempC;

  double _acidExtracted = 0.0;
  double _sweetExtracted = 0.0;
  double _bitterExtracted = 0.0;

  double _spiralQualityAccum = 0.0;
  double _spiralSamples = 0.0;
  double _chokePenalty = 0.0;
  double _bypassPenalty = 0.0;
  double _thermalScore = 100.0;
  bool _thermalDropTriggered = false;
  double _swirlAngle = 0.0;
  double _raoSpinBoost = 0.0;
  double _uiEmitTimer = 0.0;

  final math.Random _rng = math.Random(42);
  final List<_BloomBubble> _bubbles = [];
  final List<_DripDrop> _drops = [];

  void setPourControls({double? tiltTheta, Offset? aimNormalized}) {
    if (tiltTheta != null) {
      _pourTiltTheta = tiltTheta.clamp(0.0, 1.0);
    }
    if (aimNormalized != null) {
      _aimOffset = Offset(
        aimNormalized.dx.clamp(-1.0, 1.0),
        aimNormalized.dy.clamp(-1.0, 1.0),
      );
    }
  }

  void triggerRaoSpin() {
    if (_completed) return;
    _raoSpinBoost = 1.0;
    _chokePenalty = (_chokePenalty - 0.35).clamp(0.0, 2.5);
  }

  void activateThermalDrop(double targetColdTempC) {
    if (_completed) return;
    _currentTempC = targetColdTempC.clamp(60.0, 95.0);
    _thermalDropTriggered = true;
    final atMl = dropAtMl ?? targetWaterMl * 0.6;
    final deltaMl = (_pouredMl - atMl).abs();
    if (deltaMl <= 35) {
      _thermalScore = (_thermalScore + 12).clamp(0.0, 100.0);
    } else {
      _thermalScore = (_thermalScore - 15).clamp(40.0, 100.0);
    }
  }

  void resetSimulation() {
    _isRunning = true;
    _hasStartedPour = false;
    _completed = false;
    _pourTiltTheta = 0.0;
    _aimOffset = Offset.zero;
    _prevAimOffset = Offset.zero;
    _elapsedSec = 0.0;
    _pouredMl = 0.0;
    _serverMl = 0.0;
    _coneVolumeMl = 0.0;
    _currentFlowMlS = 0.0;
    _currentTempC = initialTempC;
    _acidExtracted = 0.0;
    _sweetExtracted = 0.0;
    _bitterExtracted = 0.0;
    _spiralQualityAccum = 0.0;
    _spiralSamples = 0.0;
    _chokePenalty = 0.0;
    _bypassPenalty = 0.0;
    _thermalScore = 100.0;
    _thermalDropTriggered = false;
    _bubbles.clear();
    _drops.clear();
    _emitSnapshot();
  }

  @override
  void onRemove() {
    snapshotNotifier.dispose();
    super.onRemove();
  }

  @override
  Color backgroundColor() => const Color(0xFF1F1611);

  @override
  void update(double dt) {
    super.update(dt);
    if (!_isRunning || _completed) return;
    final clampedDt = dt.clamp(0.0, 0.05);

    if (_raoSpinBoost > 0) {
      _raoSpinBoost = (_raoSpinBoost - clampedDt * 1.4).clamp(0.0, 1.0);
      _swirlAngle += clampedDt * 8.0;
    }

    // Laju tuangan Q(t) = Q_max * theta^1.4
    final remainingAllowed = (targetWaterMl - _pouredMl).clamp(0.0, targetWaterMl);
    if (_pourTiltTheta > 0.03 && remainingAllowed > 0.01) {
      _hasStartedPour = true;
      _currentFlowMlS = _qMaxMlS * math.pow(_pourTiltTheta, 1.4).toDouble();
      final pouredDelta = math.min(_currentFlowMlS * clampedDt, remainingAllowed);
      _pouredMl += pouredDelta;
      _coneVolumeMl += pouredDelta;

      final radius = _aimOffset.distance;
      final movedDelta = (_aimOffset - _prevAimOffset).distance;

      // Penilaian pola tuang melingkar
      if (radius > 0.85) {
        _bypassPenalty = (_bypassPenalty + clampedDt * 0.65).clamp(0.0, 2.0);
        _spiralQualityAccum += 0.32 * clampedDt;
      } else if (_currentFlowMlS > idealFlowMlS * 1.65) {
        _chokePenalty = (_chokePenalty + clampedDt * 0.4).clamp(0.0, 2.5);
        _spiralQualityAccum += 0.55 * clampedDt;
      } else if (radius >= 0.18 && radius <= 0.72 && movedDelta > 0.004) {
        _spiralQualityAccum += 1.0 * clampedDt;
      } else {
        _spiralQualityAccum += 0.78 * clampedDt;
      }
      _spiralSamples += clampedDt;
      _swirlAngle += clampedDt * (1.2 + _pourTiltTheta * 3.0);

      // CO2 bloom degassing bubbles
      if (_pouredMl <= bloomMl * 1.65 && _bubbles.length < 36) {
        _bubbles.add(_BloomBubble(
          (_rng.nextDouble() - 0.5) * 1.1,
          (_rng.nextDouble() - 0.5) * 1.1,
          2.0 + _rng.nextDouble() * 4.5,
          1.0,
        ));
      }
    } else {
      _currentFlowMlS = 0.0;
    }

    _prevAimOffset = _aimOffset;

    if (_hasStartedPour) {
      _elapsedSec += clampedDt;
      // Pendinginan alami perlahan jika tidak memicu Dual Temp
      _currentTempC = (_currentTempC - clampedDt * 0.045).clamp(64.0, 96.0);
    }

    // Hukum Darcy: drawdown tergantung tinggi kolom air di cone & oklusi fines (phi_choke)
    if (_coneVolumeMl > 0.02) {
      final kPermeability = 0.135;
      final drawdownMlS = (kPermeability * _coneVolumeMl / (1.0 + 0.35 * _chokePenalty))
          .clamp(0.15, _coneVolumeMl / math.max(clampedDt, 0.01));
      final drained = math.min(_coneVolumeMl, drawdownMlS * clampedDt);
      _coneVolumeMl -= drained;
      _serverMl += drained;

      // Kinetika Ekstraksi Sekuensial: Asam -> Manis -> Pahit
      final tempFactor = ((_currentTempC - 65.0) / 30.0).clamp(0.35, 1.15);
      final progressRatio = (_pouredMl / targetWaterMl).clamp(0.0, 1.0);
      if (progressRatio < 0.32) {
        _acidExtracted += drained * 0.52 * tempFactor;
      } else if (progressRatio < 0.76) {
        _sweetExtracted += drained * 0.62 * tempFactor;
        _acidExtracted += drained * 0.12 * tempFactor;
      } else {
        // Chapter 4 Thermal Drop mengurangi ekstraksi tanin pahit akhir
        final bitterShield = _thermalDropTriggered && _currentTempC <= 75 ? 0.25 : 1.0;
        _bitterExtracted += drained * 0.45 * tempFactor * bitterShield;
        _sweetExtracted += drained * 0.32 * tempFactor;
      }

      if (_drops.length < 8 && _rng.nextDouble() < 0.28) {
        _drops.add(_DripDrop(0.0, 80.0 + _rng.nextDouble() * 45.0));
      }
    }

    // Animasi partikel gelembung CO2 & tetesan ke server
    for (var i = _bubbles.length - 1; i >= 0; i--) {
      _bubbles[i].life -= clampedDt * 0.85;
      _bubbles[i].radius += clampedDt * 1.4;
      if (_bubbles[i].life <= 0) _bubbles.removeAt(i);
    }
    for (var i = _drops.length - 1; i >= 0; i--) {
      _drops[i].y += _drops[i].speed * clampedDt;
      if (_drops[i].y > 54.0) _drops.removeAt(i);
    }

    // Cek kondisi selesai seduh
    if (_hasStartedPour &&
        _pouredMl >= targetWaterMl - 0.5 &&
        _coneVolumeMl < 1.5 &&
        (_serverMl >= targetWaterMl - 4.0)) {
      _completed = true;
      _currentFlowMlS = 0.0;
      if (dropTempC != null && !_thermalDropTriggered) {
        _thermalScore = (_thermalScore - 28.0).clamp(45.0, 100.0);
      }
      _emitSnapshot();
      return;
    }

    _uiEmitTimer += clampedDt;
    if (_uiEmitTimer >= 0.066) {
      _uiEmitTimer = 0.0;
      _emitSnapshot();
    }
  }

  void _emitSnapshot() {
    final accuracy = _spiralSamples > 0.1
        ? ((_spiralQualityAccum / _spiralSamples) * 100.0 - _chokePenalty * 8 - _bypassPenalty * 9)
            .clamp(35.0, 100.0)
        : 100.0;

    final rawTotal = _acidExtracted + _sweetExtracted + _bitterExtracted;
    final acidPct = rawTotal > 0 ? (_acidExtracted / rawTotal * 100).clamp(0.0, 100.0) : 30.0;
    final sweetPct = rawTotal > 0 ? (_sweetExtracted / rawTotal * 100).clamp(0.0, 100.0) : 45.0;
    final bitterPct = rawTotal > 0 ? (_bitterExtracted / rawTotal * 100).clamp(0.0, 100.0) : 25.0;

    final baseEy = 18.0 +
        (sweetPct - 35.0) * 0.075 +
        (accuracy - 75.0) * 0.055 -
        _bypassPenalty * 0.9;
    final ey = _pouredMl < 5 ? 0.0 : baseEy.clamp(15.2, 23.8);

    String tip;
    if (!_hasStartedPour) {
      tip = 'Mulai tuang ${bloomMl.toInt()}ml di tengah V60 untuk fase Blooming CO2.';
    } else if (_pouredMl <= bloomMl + 8 && _elapsedSec < bloomSec) {
      tip = 'Tahan dulu sejenak! Biarkan CO2 terlepas (${bloomSec.toInt()}s) atau tekan Rao Spin.';
    } else if (dropTempC != null &&
        !_thermalDropTriggered &&
        _pouredMl >= (dropAtMl ?? targetWaterMl * 0.6) - 10) {
      tip = 'Momen Kritis! Tekan tombol Campur Air ${dropTempC!.toInt()}°C sekarang!';
    } else if (_bypassPenalty > 0.6) {
      tip = 'Tuangan terlalu dekat bibir filter! Arahkan spiral ke bagian dalam.';
    } else if (_currentFlowMlS > idealFlowMlS * 1.45) {
      tip = 'Aliran terlalu deras! Kurangi kemiringan ketel agar tidak channeling.';
    } else if (_completed) {
      tip = 'Seduhan V60 selesai! Cangkir siap dinilai oleh Master Kaito.';
    } else {
      tip = 'Ritme tuang stabil! Pertahankan gerakan spiral memusat hingga ${targetWaterMl.toInt()}ml.';
    }

    snapshotNotifier.value = V60SimulationSnapshot(
      elapsedSec: _elapsedSec,
      pouredMl: _pouredMl,
      serverMl: _serverMl,
      coneVolumeMl: _coneVolumeMl,
      flowRateMlS: _currentFlowMlS,
      tempC: _currentTempC,
      estimatedEyPct: double.parse(ey.toStringAsFixed(1)),
      acidPct: acidPct,
      sweetPct: sweetPct,
      bitterPct: bitterPct,
      pourAccuracyPct: double.parse(accuracy.toStringAsFixed(1)),
      thermalStabilityPct: double.parse(_thermalScore.toStringAsFixed(1)),
      channelingRiskPct: ((_chokePenalty + _bypassPenalty) * 24).clamp(0.0, 100.0),
      isCompleted: _completed,
      liveTip: tip,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (size.x <= 10 || size.y <= 10) return;

    final w = size.x;
    final h = size.y;

    // Latar kayu Kedai Senja hangat
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2B1C14), Color(0xFF19100B)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // 1. Top-Down V60 Cone Arena (kiri/tengah)
    final coneCenter = Offset(w * 0.42, h * 0.48);
    final coneRadius = math.min(w * 0.30, h * 0.37);

    // Piringan luar V60 keramik
    canvas.drawCircle(
      coneCenter,
      coneRadius + 10,
      Paint()..color = const Color(0xFFF3ECE4).withValues(alpha: 0.94),
    );
    canvas.drawCircle(
      coneCenter,
      coneRadius,
      Paint()..color = const Color(0xFFDFC7AF),
    );

    // Kertas filter & bed bubuk kopi basah
    final bedFill = (_pouredMl / bloomMl).clamp(0.25, 1.0);
    canvas.drawCircle(
      coneCenter,
      coneRadius * 0.88,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(const Color(0xFF6B3E23), const Color(0xFF3E2212), bedFill)!,
            const Color(0xFF4A2A18),
          ],
        ).createShader(Rect.fromCircle(center: coneCenter, radius: coneRadius * 0.88)),
    );

    // Spiral ribs halus V60
    final ribPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 10; i++) {
      final a = _swirlAngle * 0.25 + (i * math.pi * 2 / 10);
      final p1 = coneCenter + Offset(math.cos(a), math.sin(a)) * (coneRadius * 0.22);
      final p2 = coneCenter + Offset(math.cos(a + 0.35), math.sin(a + 0.35)) * (coneRadius * 0.94);
      canvas.drawLine(p1, p2, ribPaint);
    }

    // Lingkaran panduan zona ideal tuang (target zone)
    canvas.drawCircle(
      coneCenter,
      coneRadius * 0.55,
      Paint()
        ..color = const Color(0xFFD4AF37).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Ketinggian slurry di dalam cone (glow air menggenang)
    final waterFraction = (_coneVolumeMl / 95.0).clamp(0.0, 1.0);
    if (waterFraction > 0.02) {
      canvas.drawCircle(
        coneCenter,
        coneRadius * (0.38 + waterFraction * 0.45),
        Paint()..color = const Color(0xFFA06438).withValues(alpha: 0.35 + waterFraction * 0.25),
      );
    }

    // Gelembung CO2 Bloom
    for (final b in _bubbles) {
      final bx = coneCenter.dx + b.x * coneRadius * 0.55;
      final by = coneCenter.dy + b.y * coneRadius * 0.55;
      canvas.drawCircle(
        Offset(bx, by),
        b.radius,
        Paint()
          ..color = const Color(0xFFEBD2B4).withValues(alpha: (b.life * 0.72).clamp(0.0, 0.8))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Target titik jatuh air dari ketel gooseneck
    final aimWorld = coneCenter + Offset(_aimOffset.dx * coneRadius * 0.85, _aimOffset.dy * coneRadius * 0.85);
    if (_pourTiltTheta > 0.03 && _pouredMl < targetWaterMl) {
      // Aliran air dari sudut kanan atas ke posisi tuang
      final spoutStart = Offset(w * 0.82, h * 0.06);
      final jetPaint = Paint()
        ..color = _thermalDropTriggered && _currentTempC <= 75
            ? const Color(0xFF7DD3FC).withValues(alpha: 0.88)
            : const Color(0xFFE0F2FE).withValues(alpha: 0.90)
        ..strokeWidth = 2.0 + _pourTiltTheta * 4.2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(spoutStart.dx, spoutStart.dy)
        ..quadraticBezierTo(aimWorld.dx + 12, spoutStart.dy + 35, aimWorld.dx, aimWorld.dy);
      canvas.drawPath(path, jetPaint);
      canvas.drawCircle(
        aimWorld,
        6.0 + _pourTiltTheta * 5.0,
        Paint()..color = const Color(0xFFBAE6FD).withValues(alpha: 0.65),
      );
    } else {
      canvas.drawCircle(
        aimWorld,
        6,
        Paint()
          ..color = const Color(0xFFD4AF37).withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }

    // 2. Cutaway Glass Server & Tetesan (sebelah kanan)
    final serverRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.77, h * 0.44, w * 0.16, h * 0.42),
      const Radius.circular(14),
    );
    canvas.drawRRect(
      serverRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      serverRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final fillRatio = (_serverMl / targetWaterMl).clamp(0.0, 1.0);
    if (fillRatio > 0.01) {
      final fillHeight = serverRect.height * fillRatio;
      final coffeeRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          serverRect.left + 2,
          serverRect.bottom - fillHeight,
          serverRect.width - 4,
          fillHeight - 2,
        ),
        bottomLeft: const Radius.circular(12),
        bottomRight: const Radius.circular(12),
      );
      canvas.drawRRect(
        coffeeRect,
        Paint()..color = const Color(0xFF6B3219).withValues(alpha: 0.92),
      );
    }

    // Animasi tetesan jatuh ke server
    final dropX = serverRect.center.dx;
    for (final d in _drops) {
      canvas.drawCircle(
        Offset(dropX, serverRect.top - 10 + d.y * 0.75),
        2.6,
        Paint()..color = const Color(0xFFD48B4B),
      );
    }
  }
}
