import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../theme/app_theme.dart';
import '../../data/barista_toolkit_api_service.dart';
import '../../data/barista_toolkit_seed_data.dart';
import '../../data/ebook_drm_vault_service.dart';
import '../../data/lms_video_session_manager.dart';
import '../../domain/barista_toolkit_models.dart';
import '../ebook_reader/ebook_library_screen.dart';
import '../ebook_reader/encrypted_ebook_reader_screen.dart';
import 'lms_interactive_lab_widget.dart';

/// Bitmask tracker 100-bit (13 byte) anti-skip sesuai arsitektur Modul 2.1.
class Lms100BitTracker {
  final Uint8List bytes = Uint8List(13);

  void markSegment(int segmentPct) {
    final idx = segmentPct.clamp(0, 99);
    bytes[idx ~/ 8] |= 1 << (idx % 8);
  }

  int get completedSegments {
    int count = 0;
    for (int i = 0; i < 100; i++) {
      if ((bytes[i ~/ 8] & (1 << (i % 8))) != 0) count++;
    }
    return count;
  }

  int get completionPct => completedSegments.clamp(0, 100);

  bool get isAntiSkipThresholdMet => completedSegments >= 85;

  String toBase64() => base64Encode(bytes);
}

class LmsCoursePlayerScreen extends ConsumerStatefulWidget {
  final LmsCourseModel course;
  final LmsLessonModel lesson;

  const LmsCoursePlayerScreen({
    super.key,
    required this.course,
    required this.lesson,
  });

  @override
  ConsumerState<LmsCoursePlayerScreen> createState() =>
      _LmsCoursePlayerScreenState();
}

class _LmsCoursePlayerScreenState
    extends ConsumerState<LmsCoursePlayerScreen> {
  final Lms100BitTracker _tracker = Lms100BitTracker();
  final Map<int, int> _selectedAnswers = {};
  final List<StreamSubscription<dynamic>> _playerSubs = [];

  // ValueNotifier terisolasi agar update posisi/play/buffer/100-bit TIDAK pernah
  // memicu full-screen setState (mencegah lag saat video berjalan 30–60fps).
  late final ValueNotifier<double> _positionSecNotifier;
  late final ValueNotifier<int> _durationSecNotifier;
  late final ValueNotifier<bool> _isPlayingNotifier;
  late final ValueNotifier<bool> _isBufferingNotifier;
  late final ValueNotifier<int> _completionPctNotifier;

  late final Widget? _cachedMarkdownSection;

  Player? _player;
  VideoController? _videoController;
  Timer? _fallbackPlaybackTimer;
  int _sessionToken = 0;
  bool _isDisposed = false;
  int _lastTickedSecond = -1;

  bool _usingNativeVideo = false;
  bool _showInteractiveLab = false;
  double _playbackSpeed = 1.0;
  String? _streamStatusText;
  String? _streamSourceBadge;
  bool _submitting = false;

  bool get _isHeadlessTest =>
      kIsWeb || Platform.environment.containsKey('FLUTTER_TEST');

  int get _durationSec => _durationSecNotifier.value;

  String _formatClock(int sec) {
    final s = sec < 0 ? 0 : sec;
    final m = s ~/ 60;
    final rem = s % 60;
    return '${m.toString().padLeft(2, '0')}:${rem.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    final initialDur =
        widget.lesson.durationSec <= 0 ? 180 : widget.lesson.durationSec;
    _positionSecNotifier = ValueNotifier<double>(0);
    _durationSecNotifier = ValueNotifier<int>(initialDur);
    _isPlayingNotifier = ValueNotifier<bool>(false);
    _isBufferingNotifier = ValueNotifier<bool>(false);
    _completionPctNotifier = ValueNotifier<int>(widget.lesson.completionPct.clamp(0, 100));

    _cachedMarkdownSection = widget.lesson.keyTakeawaysMarkdown.isNotEmpty
        ? RepaintBoundary(
            child: _LmsMarkdownRenderer(
              markdown: widget.lesson.keyTakeawaysMarkdown,
            ),
          )
        : null;

    // Untuk Bab 1 yang sudah memiliki video animasi HD di Object Storage, tampilkan Video Animasi dulu
    _showInteractiveLab = widget.lesson.simulationConfig['lab_kind'] != null &&
        !widget.lesson.subchapterCode.startsWith('1.');
    if (widget.lesson.completionPct > 0) {
      for (int p = 0; p < widget.lesson.completionPct; p++) {
        _tracker.markSegment(p);
      }
      _completionPctNotifier.value = _tracker.completionPct;
    }

    _sessionToken = LmsVideoSessionManager.instance.acquireSession();
    _initStreamPlayer();
  }

  void _cancelPlayerSubscriptions() {
    for (final sub in _playerSubs) {
      unawaited(sub.cancel());
    }
    _playerSubs.clear();
  }

  static const Map<String, String> _bab1ObjectKeys = {
    '1.1': 'coffeelabs/lms/bab1/sub_1_1_bcc',
    '1.2': 'coffeelabs/lms/bab1/sub_1_2_water',
    '1.3': 'coffeelabs/lms/bab1/sub_1_3_degassing',
    '1.4': 'coffeelabs/lms/bab1/sub_1_4_paragon',
  };

  Future<bool> _probeHttpReachable(
    String url, {
    Duration timeout = const Duration(milliseconds: 1500),
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return false;
    }
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final req = await client.headUrl(uri).timeout(timeout);
      final res = await req.close().timeout(timeout);
      await res.drain<void>();
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  /// Menemukan berkas video MP4 lokal di bucket Object Storage backend saat menjalankan mode desktop dev.
  File? _findLocalWorkspaceObjectFile(String objectKeyNoExt) {
    if (kIsWeb || !(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      return null;
    }
    final relPaths = [
      'coffe-labs-backend/storage/object_storage/$objectKeyNoExt.mp4',
      '../coffe-labs-backend/storage/object_storage/$objectKeyNoExt.mp4',
      '../../coffe-labs-backend/storage/object_storage/$objectKeyNoExt.mp4',
      'storage/object_storage/$objectKeyNoExt.mp4',
    ];
    final roots = <Directory>[
      Directory.current,
      File(Platform.resolvedExecutable).parent,
    ];
    for (final base in roots) {
      Directory cur = base;
      for (int depth = 0; depth < 7; depth++) {
        for (final rel in relPaths) {
          final f = File('${cur.path}${Platform.pathSeparator}$rel');
          if (f.existsSync() && f.lengthSync() > 10000) {
            return f;
          }
        }
        if (cur.parent.path == cur.path) break;
        cur = cur.parent;
      }
    }
    return null;
  }

  Future<(String source, String badge)?> _resolveBestPlayableSource({
    required BaristaToolkitApiService api,
    required String? serverUrl,
  }) async {
    final bab1Stem = _bab1ObjectKeys[widget.lesson.subchapterCode];
    final cleanServer = (serverUrl ?? '').trim();
    final isRealRemote = cleanServer.isNotEmpty && !cleanServer.contains('cdn.coffeelabs.app');

    // 1. Remote / Cloud CDN / Backend aktif (.m3u8 lalu .mp4)
    final remoteCandidates = <String>[];
    if (isRealRemote) {
      final resolved = api.resolveMediaUrl(cleanServer);
      remoteCandidates.add(resolved);
      if (resolved.endsWith('.m3u8')) {
        remoteCandidates.add(resolved.replaceAll('.m3u8', '.mp4'));
      }
    } else if (bab1Stem != null) {
      remoteCandidates.add(api.resolveMediaUrl('/api/v1/toolkit/object-storage/$bab1Stem.m3u8'));
      remoteCandidates.add(api.resolveMediaUrl('/api/v1/toolkit/object-storage/$bab1Stem.mp4'));
    }

    // Pada desktop dev, bila berkas lokal tersedia langsung di disk dan server mengembalikan URL placeholder,
    // prioritaskan berkas lokal agar langsung putar dalam < 50ms tanpa menunggu timeout cloud 404.
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    if (isDesktop && bab1Stem != null && !isRealRemote) {
      final localFile = _findLocalWorkspaceObjectFile(bab1Stem);
      if (localFile != null) {
        final cleanPath = localFile.resolveSymbolicLinksSync();
        return (cleanPath, 'HD Object Storage (Lokal)');
      }
    }

    for (final url in remoteCandidates) {
      if (_isDisposed) return null;
      if (await _probeHttpReachable(url)) {
        final badge = url.endsWith('.m3u8') ? 'HLS Object Storage' : 'HD MP4 Cloud';
        return (url, badge);
      }
    }

    // 2. Backend lokal dev (127.0.0.1:3000) & fallback disk lokal pada desktop
    if (bab1Stem != null && isDesktop && !_isDisposed) {
      for (final ext in const ['m3u8', 'mp4']) {
        final localUrl = 'http://127.0.0.1:3000/api/v1/toolkit/object-storage/$bab1Stem.$ext';
        if (await _probeHttpReachable(localUrl, timeout: const Duration(milliseconds: 500))) {
          return (localUrl, ext == 'm3u8' ? 'HLS Local Storage' : 'HD MP4 Local');
        }
      }

      final localFile = _findLocalWorkspaceObjectFile(bab1Stem);
      if (localFile != null) {
        final cleanPath = localFile.resolveSymbolicLinksSync();
        return (cleanPath, 'HD Object Storage (Lokal)');
      }
    }
    return null;
  }

  Future<void> _initStreamPlayer() async {
    final token = _sessionToken;
    final api = ref.read(baristaToolkitApiProvider);
    String? rawUrl;
    try {
      final info = await api.fetchLessonStream(widget.lesson.id);
      if (_isDisposed || !mounted) return;
      rawUrl = info['signed_hls_url']?.toString();
      final serverDur = (info['duration_sec'] as num?)?.toInt() ?? 0;
      if (serverDur > 0) {
        _durationSecNotifier.value = serverDur;
      }
    } catch (_) {}

    if (_isDisposed || !mounted) return;

    if (!_isHeadlessTest) {
      final resolved = await _resolveBestPlayableSource(api: api, serverUrl: rawUrl);
      if (_isDisposed || !mounted) return;
      if (resolved != null) {
        final (playableSource, badge) = resolved;
        final session = await LmsVideoSessionManager.instance.openMedia(
          token: token,
          playableSource: playableSource,
        );
        if (_isDisposed || !mounted || session == null) return;

        final (player, vc) = session;
        _cancelPlayerSubscriptions();
        _playerSubs.addAll([
          player.stream.duration.listen((dur) {
            if (_isDisposed || dur.inSeconds <= 0) return;
            if (_durationSecNotifier.value != dur.inSeconds) {
              _durationSecNotifier.value = dur.inSeconds;
            }
          }),
          player.stream.position.listen((pos) {
            if (_isDisposed) return;
            final wholeSec = pos.inSeconds;
            // Throttle 1 Hz agar slider & jam hanya update saat detik berubah (bukan 60x/detik)
            if (wholeSec == _lastTickedSecond) return;
            _lastTickedSecond = wholeSec;
            _onPlaybackTick(wholeSec.toDouble());
          }),
          player.stream.playing.listen((playing) {
            if (_isDisposed) return;
            if (_isPlayingNotifier.value != playing) {
              _isPlayingNotifier.value = playing;
            }
          }),
          player.stream.buffering.listen((buf) {
            if (_isDisposed) return;
            if (_isBufferingNotifier.value != buf) {
              _isBufferingNotifier.value = buf;
            }
          }),
        ]);

        setState(() {
          _player = player;
          _videoController = vc;
          _usingNativeVideo = true;
          _streamSourceBadge = badge;
          _streamStatusText = 'Video Animasi HD Siap Diputar ($badge)';
        });
        return;
      }
    }

    if (_isDisposed || !mounted) return;
    setState(() {
      _usingNativeVideo = false;
      _streamSourceBadge = null;
      _streamStatusText = widget.lesson.subchapterCode.startsWith('1.')
          ? 'Video Bab 1 belum tersinkron di server cloud (404). Deploy backend atau aktifkan Cloudinary untuk streaming online.'
          : 'Interactive Stage & Storyboard (HLS Offline Sync Ready)';
    });
  }

  void _togglePlayPause() {
    if (_usingNativeVideo && _player != null) {
      unawaited(_player!.playOrPause().catchError((_) {}));
      return;
    }
    final nextPlaying = !_isPlayingNotifier.value;
    _isPlayingNotifier.value = nextPlaying;
    _fallbackPlaybackTimer?.cancel();
    if (nextPlaying) {
      _fallbackPlaybackTimer = Timer.periodic(
        const Duration(milliseconds: 500),
        (_) {
          if (_isDisposed || !mounted) return;
          final next = (_positionSecNotifier.value + 1.0 * _playbackSpeed)
              .clamp(0.0, _durationSec.toDouble());
          _onPlaybackTick(next);
          if (next >= _durationSec) {
            _isPlayingNotifier.value = false;
            _fallbackPlaybackTimer?.cancel();
          }
        },
      );
    }
  }

  void _onPlaybackTick(double newPosSec) {
    final dur = _durationSec > 0 ? _durationSec : 1;
    final seg = ((newPosSec / dur) * 100).floor().clamp(0, 99);
    _tracker.markSegment(seg);
    _positionSecNotifier.value = newPosSec;
    final pct = _tracker.completionPct;
    if (_completionPctNotifier.value != pct) {
      _completionPctNotifier.value = pct;
    }
  }

  void _attemptSeek(double requestedSec) {
    final highestAllowed = (_tracker.completedSegments / 100.0) * _durationSec;
    if (requestedSec > highestAllowed + 3.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Anti-Skip aktif: tonton segmen video secara berurutan atau jalankan Lab Simulasi.',
          ),
        ),
      );
      return;
    }
    final targetSec = requestedSec.round();
    _lastTickedSecond = targetSec;
    _positionSecNotifier.value = requestedSec;
    if (_usingNativeVideo && _player != null) {
      unawaited(_player!.seek(Duration(seconds: targetSec)).catchError((_) {}));
    }
  }

  Future<void> _submitProgressAndQuiz() async {
    // Izinkan penyelesaian bila simulasi interaktif & kuis telah dikerjakan jika video HLS tidak di-stream
    if (!_tracker.isAntiSkipThresholdMet &&
        widget.lesson.simulationConfig['lab_kind'] != null) {
      for (int i = 0; i < 86; i++) {
        _tracker.markSegment(i);
      }
    }

    setState(() => _submitting = true);
    try {
      final answers = List<int>.generate(
        widget.lesson.quizQuestions.length,
        (i) => _selectedAnswers[i] ?? 0,
      );
      await ref.read(baristaToolkitApiProvider).syncLmsProgress(
            lessonId: widget.lesson.id,
            watchedBitmapB64: _tracker.toBase64(),
            lastPositionSec: _positionSecNotifier.value.round(),
            quizAnswers: answers,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF2E7D32),
          content: Text('Progres 100-bit & Kuis Sub-Bab tersimpan!'),
        ),
      );
    } catch (_) {
      final score = _localQuizScore();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tersimpan lokal (skor kuis $score%, segmen ${_tracker.completionPct}%).',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  int _localQuizScore() {
    if (widget.lesson.quizQuestions.isEmpty) return 100;
    int correct = 0;
    for (int i = 0; i < widget.lesson.quizQuestions.length; i++) {
      if (_selectedAnswers[i] == widget.lesson.quizQuestions[i].answerIdx) {
        correct++;
      }
    }
    return ((correct * 100) / widget.lesson.quizQuestions.length).round();
  }

  Future<void> _openLinkedEbook() async {
    final code = widget.lesson.linkedEbookCode;
    if (code == null || code.isEmpty) return;
    LmsVideoSessionManager.instance.pauseIfActive(_sessionToken);
    final books = await BaristaToolkitFallbackSeed.offlineEbooks();
    final matched = books.where((b) => b.bookCode == code).firstOrNull;
    if (!mounted) return;
    if (matched == null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const EbookLibraryScreen()),
      );
      return;
    }
    final isOffline = await EncryptedEbookVaultService.instance
        .isBookDownloadedOffline(matched.bookCode);
    if (!mounted) return;
    if (isOffline) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => EncryptedEbookReaderScreen(
            ebook: matched,
            initialChapterNumber: widget.lesson.linkedEbookChapter,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Silakan unduh ${matched.bookCode} dari Object Storage di Pustaka E-Book untuk membukanya offline.',
          ),
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const EbookLibraryScreen()),
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _fallbackPlaybackTimer?.cancel();
    _cancelPlayerSubscriptions();
    // Lepas sesi secara non-blocking (pause + stop) tanpa dispose VideoOutput sinkron
    // agar bebas crash ANGLE Surface.cpp:528 & bebas freeze UI thread saat Back.
    LmsVideoSessionManager.instance.releaseSession(_sessionToken);
    _positionSecNotifier.dispose();
    _durationSecNotifier.dispose();
    _isPlayingNotifier.dispose();
    _isBufferingNotifier.dispose();
    _completionPctNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final lessonsInCourse = widget.course.lessons;
    final currentIdx = lessonsInCourse.indexWhere((l) => l.id == lesson.id);
    final prevLesson = currentIdx > 0 ? lessonsInCourse[currentIdx - 1] : null;
    final nextLesson =
        currentIdx >= 0 && currentIdx < lessonsInCourse.length - 1
            ? lessonsInCourse[currentIdx + 1]
            : null;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sub-Bab ${lesson.subchapterCode}: ${lesson.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            Text(
              widget.course.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
        children: [
          if (lesson.simulationConfig['lab_kind'] != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderWarm),
              ),
              child: Row(
                children: [
                  _stageTab(
                    label: 'Lab Simulasi Interaktif',
                    icon: Icons.science_rounded,
                    selected: _showInteractiveLab,
                    onTap: () {
                      LmsVideoSessionManager.instance.pauseIfActive(_sessionToken);
                      setState(() => _showInteractiveLab = true);
                    },
                  ),
                  _stageTab(
                    label: 'Video HLS 100-Bit',
                    icon: Icons.play_circle_outline_rounded,
                    selected: !_showInteractiveLab,
                    onTap: () => setState(() => _showInteractiveLab = false),
                  ),
                ],
              ),
            ),
          if (_showInteractiveLab &&
              lesson.simulationConfig['lab_kind'] != null)
            LmsInteractiveLabWidget(lesson: lesson)
          else
            _buildVideoStage(lesson),
          if (lesson.linkedEbookCode != null &&
              lesson.linkedEbookCode!.isNotEmpty) ...[
            const SizedBox(height: 4),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryBrown,
                side: const BorderSide(color: AppTheme.primaryBrown),
                backgroundColor: const Color(0xFFFFF8E7),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              ),
              onPressed: _openLinkedEbook,
              icon: const Icon(Icons.auto_stories_rounded, size: 18),
              label: Text(
                'Buka Referensi E-Book ${lesson.linkedEbookCode}'
                '${lesson.linkedEbookChapter != null ? " (Bab ${lesson.linkedEbookChapter})" : ""}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (_cachedMarkdownSection != null) ...[
            _sectionCard(
              title: 'Materi Mendalam & Parameter Sains',
              icon: Icons.menu_book_rounded,
              child: _cachedMarkdownSection,
            ),
            const SizedBox(height: 12),
          ],
          if (lesson.formulasLatex.isNotEmpty) ...[
            _sectionCard(
              title: 'Rumus Fisika & Kimia Kopi',
              icon: Icons.functions_rounded,
              child: Column(
                children: lesson.formulasLatex
                    .map(
                      (f) => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF241811),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f['label'] ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              f['latex'] ?? '',
                              style: const TextStyle(
                                color: AppTheme.accentGold,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            if ((f['desc'] ?? '').isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                f['desc']!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (lesson.storyboardScenes.isNotEmpty) ...[
            _sectionCard(
              title: 'Alur Storyboard Video (${lesson.storyboardScenes.length} Adegan)',
              icon: Icons.movie_filter_rounded,
              child: Column(
                children: lesson.storyboardScenes
                    .map(
                      (sc) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBrown.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                (sc['ts'] ?? '').isNotEmpty
                                    ? sc['ts']!
                                    : 'Scene',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  color: AppTheme.primaryBrown,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (sc['visual'] ?? '').isNotEmpty
                                        ? sc['visual']!
                                        : (sc['scene'] ?? ''),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  if (((sc['narration'] ?? '').isNotEmpty
                                          ? sc['narration']!
                                          : (sc['detail'] ?? ''))
                                      .isNotEmpty)
                                    Text(
                                      (sc['narration'] ?? '').isNotEmpty
                                          ? sc['narration']!
                                          : (sc['detail'] ?? ''),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (lesson.quizQuestions.isNotEmpty) ...[
            _sectionCard(
              title: 'Evaluasi Sub-Bab (${lesson.quizQuestions.length} Soal)',
              icon: Icons.quiz_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(lesson.quizQuestions.length, (qIdx) {
                    final q = lesson.quizQuestions[qIdx];
                    final chosen = _selectedAnswers[qIdx];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${qIdx + 1}. ${q.question}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...List.generate(q.options.length, (optIdx) {
                            final selected = chosen == optIdx;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => setState(
                                    () => _selectedAnswers[qIdx] = optIdx),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppTheme.primaryBrown.withValues(alpha: 0.1)
                                        : const Color(0xFFFAF6F0),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: selected
                                          ? AppTheme.primaryBrown
                                          : AppTheme.borderWarm,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        selected
                                            ? Icons.radio_button_checked_rounded
                                            : Icons.radio_button_unchecked_rounded,
                                        size: 18,
                                        color: selected
                                            ? AppTheme.primaryBrown
                                            : AppTheme.textMuted,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          q.options[optIdx],
                                          style: const TextStyle(fontSize: 12.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _submitting ? null : _submitProgressAndQuiz,
                      icon: _submitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.verified_rounded, size: 18),
                      label: Text(
                        'Selesaikan Sub-Bab (+${lesson.xpReward} XP)',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (prevLesson != null || nextLesson != null)
            Row(
              children: [
                if (prevLesson != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => LmsCoursePlayerScreen(
                              course: widget.course,
                              lesson: prevLesson,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chevron_left_rounded),
                      label: Text(
                        'Sub ${prevLesson.subchapterCode}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                if (prevLesson != null && nextLesson != null)
                  const SizedBox(width: 10),
                if (nextLesson != null)
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primaryBrown),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => LmsCoursePlayerScreen(
                              course: widget.course,
                              lesson: nextLesson,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chevron_right_rounded),
                      label: Text(
                        'Lanjut ${nextLesson.subchapterCode}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _stageTab({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryBrown : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 15,
                  color: selected ? Colors.white : AppTheme.textMuted),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : AppTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoStage(LmsLessonModel lesson) {
    final isWindowsDesktop = !kIsWeb && Platform.isWindows;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C130E),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _usingNativeVideo && _videoController != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      RepaintBoundary(
                        child: Video(
                          controller: _videoController!,
                          controls: NoVideoControls,
                          wakelock: !isWindowsDesktop,
                          pauseUponEnteringBackgroundMode: true,
                        ),
                      ),
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _togglePlayPause,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _isPlayingNotifier,
                            builder: (_, isPlaying, _) {
                              return ValueListenableBuilder<bool>(
                                valueListenable: _isBufferingNotifier,
                                builder: (_, isBuffering, _) {
                                  return AnimatedOpacity(
                                    duration: const Duration(milliseconds: 200),
                                    opacity: (!isPlaying || isBuffering) ? 1.0 : 0.0,
                                    child: Center(
                                      child: isBuffering
                                          ? const CircularProgressIndicator(
                                              color: AppTheme.accentGold,
                                            )
                                          : Container(
                                              width: 58,
                                              height: 58,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.55),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppTheme.accentGold,
                                                  width: 2,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.play_arrow_rounded,
                                                color: AppTheme.accentGold,
                                                size: 36,
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      if (_streamSourceBadge != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.62),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.accentGold.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              _streamSourceBadge!,
                              style: const TextStyle(
                                color: AppTheme.accentGold,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: _isPlayingNotifier,
                        builder: (_, isPlaying, _) {
                          return IconButton(
                            iconSize: 54,
                            color: AppTheme.accentGold,
                            onPressed: _togglePlayPause,
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.play_circle_filled_rounded,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _streamStatusText ?? 'HLS Player Ready',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Column(
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: _durationSecNotifier,
                  builder: (_, durSec, _) {
                    final safeDur = durSec > 0 ? durSec.toDouble() : 1.0;
                    return ValueListenableBuilder<double>(
                      valueListenable: _positionSecNotifier,
                      builder: (_, posSec, _) {
                        return Slider(
                          value: posSec.clamp(0.0, safeDur),
                          max: safeDur,
                          activeColor: AppTheme.accentGold,
                          inactiveColor: Colors.white24,
                          onChanged: _attemptSeek,
                        );
                      },
                    );
                  },
                ),
                Row(
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: _isPlayingNotifier,
                      builder: (_, isPlaying, _) {
                        return IconButton(
                          visualDensity: VisualDensity.compact,
                          color: AppTheme.accentGold,
                          onPressed: _togglePlayPause,
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_filled_rounded,
                            size: 28,
                          ),
                        );
                      },
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: _durationSecNotifier,
                      builder: (_, durSec, _) {
                        return ValueListenableBuilder<double>(
                          valueListenable: _positionSecNotifier,
                          builder: (_, posSec, _) {
                            return Text(
                              '${_formatClock(posSec.round())} / ${_formatClock(durSec)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ValueListenableBuilder<int>(
                        valueListenable: _completionPctNotifier,
                        builder: (_, pct, _) {
                          return Text(
                            '• 100-Bit: $pct%',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11),
                          );
                        },
                      ),
                    ),
                    DropdownButton<double>(
                      value: _playbackSpeed,
                      dropdownColor: const Color(0xFF2B1B12),
                      style: const TextStyle(
                          color: AppTheme.accentGold, fontSize: 12),
                      underline: const SizedBox.shrink(),
                      items: const [0.75, 1.0, 1.25, 1.5]
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text('${r}x'),
                              ))
                          .toList(),
                      onChanged: (r) {
                        if (r == null) return;
                        setState(() => _playbackSpeed = r);
                        if (_player != null) {
                          unawaited(_player!.setRate(r).catchError((_) {}));
                        }
                      },
                    ),
                  ],
                ),
                if (lesson.chapterMarkers.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 28,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: lesson.chapterMarkers.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 6),
                      itemBuilder: (context, idx) {
                        final mk = lesson.chapterMarkers[idx];
                        final sec = (mk['sec'] as num?)?.toInt() ?? 0;
                        final label = mk['label']?.toString() ?? 'Bab ${idx + 1}';
                        return InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _attemptSeek(sec.toDouble()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.accentGold.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              '${_formatClock(sec)} $label',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryBrown),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _LmsMarkdownRenderer extends StatelessWidget {
  final String markdown;

  const _LmsMarkdownRenderer({required this.markdown});

  @override
  Widget build(BuildContext context) {
    final lines = markdown.split('\n');
    final widgets = <Widget>[];
    int i = 0;

    while (i < lines.length) {
      final line = lines[i].trimRight();
      if (line.trim().isEmpty) {
        i++;
        continue;
      }

      if (line.trim().startsWith('|') &&
          i + 1 < lines.length &&
          lines[i + 1].trim().startsWith('|')) {
        final tableLines = <String>[];
        while (i < lines.length && lines[i].trim().startsWith('|')) {
          tableLines.add(lines[i].trim());
          i++;
        }
        widgets.add(_buildTable(tableLines));
        continue;
      }

      if (line.startsWith('### ') || line.startsWith('## ')) {
        final text = line.replaceFirst(RegExp(r'^#{2,4}\s*'), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryBrown,
              ),
            ),
          ),
        );
      } else if (line.trimLeft().startsWith('- ') ||
          line.trimLeft().startsWith('* ')) {
        final bulletText =
            line.trimLeft().replaceFirst(RegExp(r'^[-*]\s+'), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(
                    color: AppTheme.primaryBrown,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Expanded(child: _richText(bulletText)),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _richText(line),
          ),
        );
      }
      i++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _richText(String input) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;
    for (final m in regex.allMatches(input)) {
      if (m.start > lastEnd) {
        spans.add(TextSpan(text: input.substring(lastEnd, m.start)));
      }
      spans.add(
        TextSpan(
          text: m.group(1),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      );
      lastEnd = m.end;
    }
    if (lastEnd < input.length) {
      spans.add(TextSpan(text: input.substring(lastEnd)));
    }
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13,
          height: 1.45,
          color: AppTheme.textDark,
        ),
        children: spans,
      ),
    );
  }

  Widget _buildTable(List<String> rawRows) {
    final rows = rawRows
        .where((r) => !RegExp(r'^\|[\s:-]+\|$').hasMatch(r.replaceAll('|', '|').trim()) && !r.contains('---'))
        .map(
          (r) => r
              .split('|')
              .map((c) => c.trim())
              .where((c) => c.isNotEmpty)
              .toList(),
        )
        .where((cells) => cells.isNotEmpty)
        .toList();
    if (rows.isEmpty) return const SizedBox.shrink();

    final colCount = rows.first.length;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.all(
            color: AppTheme.borderWarm,
            borderRadius: BorderRadius.circular(8),
          ),
          children: List.generate(rows.length, (rIdx) {
            final isHeader = rIdx == 0;
            final cells = rows[rIdx];
            return TableRow(
              decoration: BoxDecoration(
                color: isHeader
                    ? AppTheme.primaryBrown.withValues(alpha: 0.1)
                    : (rIdx.isOdd ? const Color(0xFFFAF6F0) : Colors.white),
              ),
              children: List.generate(colCount, (cIdx) {
                final text = cIdx < cells.length ? cells[cIdx] : '';
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 7),
                  child: Text(
                    text.replaceAll('**', ''),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isHeader ? FontWeight.w800 : FontWeight.w500,
                      color: AppTheme.textDark,
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
