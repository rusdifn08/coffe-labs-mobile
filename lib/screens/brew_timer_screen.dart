import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';
import '../services/api_service.dart';
import 'brew_journal_screen.dart';

class BrewTimerScreen extends StatefulWidget {
  final dynamic recipeData;

  const BrewTimerScreen({super.key, required this.recipeData});

  @override
  State<BrewTimerScreen> createState() => _BrewTimerScreenState();
}

class _BrewTimerScreenState extends State<BrewTimerScreen> {
  Timer? _timer;
  Timer? _prepTimer;
  
  int _elapsedSeconds = 0;
  int _prepSeconds = 5;
  
  bool _isRunning = false;
  bool _isPreparing = false;
  
  late String title;
  late int totalSeconds;
  late List<dynamic> steps;

  @override
  void initState() {
    super.initState();
    title = widget.recipeData['title'] ?? 'Brew Timer';
    totalSeconds = widget.recipeData['totalTimeSeconds'] ?? 0;
    steps = widget.recipeData['steps'] ?? [];
  }

  @override
  void dispose() {
    _timer?.cancel();
    _prepTimer?.cancel();
    AudioService.stopBgm();
    super.dispose();
  }

  void _startMainTimer() {
    setState(() {
      _isPreparing = false;
      _isRunning = true;
    });
    
    AudioService.startBgm();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_elapsedSeconds < totalSeconds) {
        setState(() => _elapsedSeconds++);
        
        // Check if a step is ending soon or just finished
        int accumulated = 0;
        for (var step in steps) {
          accumulated += (step['durationSeconds'] as int? ?? 0);
          if (accumulated > _elapsedSeconds) {
            int left = accumulated - _elapsedSeconds;
            if (left <= 5 && left > 0) {
              AudioService.playTick();
            }
            break;
          } else if (accumulated == _elapsedSeconds && _elapsedSeconds != totalSeconds) {
            AudioService.playTransition();
          }
        }
        
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        AudioService.stopBgm();
        AudioService.playEnjoy();
        _promptJournal();
      }
    });
  }

  bool _isEndingSoon() {
    if (_isPreparing) return false;
    int accumulated = 0;
    for (var step in steps) {
      accumulated += (step['durationSeconds'] as int? ?? 0);
      if (accumulated > _elapsedSeconds) {
        int left = accumulated - _elapsedSeconds;
        return left <= 5 && left > 0;
      }
    }
    return false;
  }

  void _toggleTimer() {
    if (_isRunning || _isPreparing) {
      // Pause
      _timer?.cancel();
      _prepTimer?.cancel();
      AudioService.stopBgm();
      setState(() {
        _isRunning = false;
        _isPreparing = false;
      });
    } else {
      // Start or Resume
      if (_elapsedSeconds == 0 && _prepSeconds > 0) {
        // Start Prep
        setState(() => _isPreparing = true);
        _prepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_prepSeconds > 1) {
            AudioService.playTick();
            setState(() => _prepSeconds--);
          } else {
            _prepTimer?.cancel();
            AudioService.playTransition();
            _startMainTimer();
          }
        });
      } else {
        // Resume directly
        _startMainTimer();
      }
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _prepTimer?.cancel();
    setState(() {
      _elapsedSeconds = 0;
      _prepSeconds = 5;
      _isRunning = false;
      _isPreparing = false;
    });
  }

  void _promptJournal() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Brew selesai!'),
        content: const Text('Mau catat hasil rasa di Jurnal Brew?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Nanti')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final rating = 4.0;
              await ApiService.addJournalEntry({
                'recipeId': widget.recipeData['id'],
                'recipeTitle': widget.recipeData['title'],
                'author': widget.recipeData['author'],
                'authorAvatarUrl': widget.recipeData['authorAvatarUrl'] ?? widget.recipeData['authorImageUrl'],
                'authorImageUrl': widget.recipeData['coverImageUrl'] ?? widget.recipeData['authorImageUrl'],
                'grindNote': widget.recipeData['grindSize']?.toString() ?? '',
                'rating': rating,
                'notes': 'Brew selesai via timer.',
              });
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Tersimpan di Jurnal. Edit detail kapan saja.'),
                  action: SnackBarAction(
                    label: 'Buka',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BrewJournalScreen()),
                      );
                    },
                  ),
                ),
              );
            },
            child: const Text('Catat'),
          ),
        ],
      ),
    );
  }

  
  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int _getActiveStepIndex() {
    int accumulated = 0;
    for (int i = 0; i < steps.length; i++) {
      accumulated += (steps[i]['durationSeconds'] as int? ?? 0);
      if (_elapsedSeconds < accumulated || (_elapsedSeconds == accumulated && _elapsedSeconds == totalSeconds)) {
        return i;
      }
    }
    return steps.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    int activeIndex = _elapsedSeconds > 0 ? _getActiveStepIndex() : -1;
    if (_elapsedSeconds == totalSeconds) activeIndex = steps.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // TIMER DISPLAY (FIXED)
          Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: SegmentedTimerPainter(
                  steps: steps,
                  totalSeconds: totalSeconds,
                  elapsedSeconds: _elapsedSeconds,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isPreparing)
                        const Text(
                          "Prep",
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      if (_elapsedSeconds > 0 && _elapsedSeconds >= totalSeconds) ...[
                        const Text(
                          "Enjoy your",
                          style: TextStyle(color: AppTheme.primaryBrown, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "coffee!",
                          style: TextStyle(color: AppTheme.primaryBrown, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ] else ...[
                        Text(
                          _isPreparing ? '$_prepSeconds' : _formatTime(_elapsedSeconds),
                          style: TextStyle(
                            fontSize: _isPreparing ? 80 : 64, 
                            fontWeight: FontWeight.bold, 
                            color: _isPreparing ? AppTheme.accentAmber : (_isEndingSoon() ? Colors.red : AppTheme.primaryBrown)
                          ),
                        ),
                        if (!_isPreparing)
                          Text(
                            "of ${_formatTime(totalSeconds)}",
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 16),
                          )
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // SCROLLABLE STEPS LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                var step = steps[index];
                bool isActive = index == activeIndex && !_isPreparing;
                bool isDone = _elapsedSeconds > 0 && index < activeIndex;
                
                Color stepColor = _getColorForStep(index);
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isActive ? stepColor.withValues(alpha: 0.1) : AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? stepColor : AppTheme.primaryBrown.withValues(alpha: 0.1),
                      width: isActive ? 2 : 1
                    ),
                    boxShadow: isActive ? [
                      BoxShadow(color: stepColor.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))
                    ] : [],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDone ? stepColor : (isActive ? stepColor : stepColor.withValues(alpha: 0.2)),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isDone 
                            ? const Icon(CupertinoIcons.check_mark, color: Colors.white, size: 20)
                            : Text("${index + 1}", style: TextStyle(color: isActive ? Colors.white : stepColor, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['title'] ?? 'Step', 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: isActive ? 16 : 14, color: isActive ? AppTheme.textDark : AppTheme.textMuted)
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(CupertinoIcons.drop_fill, size: 12, color: Colors.blueAccent),
                                const SizedBox(width: 4),
                                Text("${step['waterAddedGrams']}g Water", style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatTime(step['durationSeconds'] ?? 0), 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isActive ? AppTheme.textDark : AppTheme.textMuted)
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // BOTTOM CONTROL PANEL
          Container(
            padding: const EdgeInsets.only(top: 16, bottom: 32, left: 24, right: 24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -10))
              ],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'reset',
                  backgroundColor: AppTheme.bgCream,
                  elevation: 0,
                  onPressed: _resetTimer,
                  child: const Icon(CupertinoIcons.refresh, color: AppTheme.primaryBrown),
                ),
                const SizedBox(width: 32),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: FloatingActionButton(
                    heroTag: 'playpause',
                    backgroundColor: AppTheme.primaryBrown,
                    elevation: 5,
                    onPressed: _toggleTimer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Icon(_isRunning || _isPreparing ? CupertinoIcons.pause_solid : CupertinoIcons.play_arrow_solid, color: Colors.white, size: 40),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

Color _getColorForStep(int index) {
  List<Color> colors = [
    Colors.blueAccent,
    Colors.green,
    Colors.orangeAccent,
    Colors.pinkAccent,
    Colors.purpleAccent,
    Colors.amber,
    Colors.redAccent,
  ];
  return colors[index % colors.length];
}

class SegmentedTimerPainter extends CustomPainter {
  final List<dynamic> steps;
  final num totalSeconds;
  final num elapsedSeconds;

  SegmentedTimerPainter({required this.steps, required this.totalSeconds, required this.elapsedSeconds});

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 20.0;
    Rect rect = Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2 - strokeWidth / 2);
    
    // Draw background track
    Paint trackPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2 - strokeWidth / 2, trackPaint);

    if (totalSeconds <= 0) return;

    // Draw static colored segments and active filled segments
    double startAngle = -pi / 2; // start from top
    double currentElapsed = elapsedSeconds.toDouble();

    for (int i = 0; i < steps.length; i++) {
      double stepSecs = (steps[i]['durationSeconds'] ?? 0).toDouble();
      double sweepAngle = (stepSecs / totalSeconds) * 2 * pi;
      
      Color stepColor = _getColorForStep(i);
      
      // Draw background (faint) segment
      Paint segmentPaint = Paint()
        ..color = stepColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt
        ..strokeWidth = strokeWidth;
      
      // Leave a tiny gap between segments
      canvas.drawArc(rect, startAngle, sweepAngle - 0.05, false, segmentPaint);
      
      // Draw filled (bright) segment if elapsed reaches into this step
      if (currentElapsed > 0) {
        double filledSecs = min(currentElapsed, stepSecs);
        double filledSweepAngle = (filledSecs / totalSeconds) * 2 * pi;
        
        Paint filledPaint = Paint()
          ..color = stepColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth + 2; // slightly thicker for pop effect
          
        canvas.drawArc(rect, startAngle, filledSweepAngle, false, filledPaint);
        currentElapsed -= filledSecs;
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant SegmentedTimerPainter oldDelegate) {
    return oldDelegate.elapsedSeconds != elapsedSeconds || oldDelegate.totalSeconds != totalSeconds;
  }
}
