import 'package:coffee_hub_mobile/features/barista_toolkit/domain/barista_toolkit_models.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/presentation/lms_academy/lms_course_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleLesson = LmsLessonModel(
    id: 'lesson-1-1',
    courseId: 'course-1',
    moduleNumber: 1,
    lessonNumber: 1,
    subchapterCode: '1.1',
    title: 'Fisika & Matematika Ekstraksi',
    description: 'Uji coba seek bebas & markdown',
    kind: 'HLS_VIDEO',
    durationSec: 310,
    xpReward: 120,
    keyTakeawaysMarkdown:
        '### Standar Golden Cup\n'
        '- **Rentang TDS:** `1,15% - 1,35% TDS` terasa seimbang, di bawah terasa tipis (*watery*).\n',
    chapterMarkers: [
      {'sec': 0, 'label': '30% Solubles'},
      {'sec': 95, 'label': 'Matematika EY%'},
    ],
    storyboardScenes: [
      {'ts': '01:35', 'visual': 'Rumus Extraction Yield', 'narration': 'Detail EY'},
    ],
    quizQuestions: [
      LmsQuizQuestion(
        question: 'Rentang TDS Golden Cup Filter?',
        options: ['0,5%', '1,15% - 1,35%', '5,0%'],
        answerIdx: 1,
      ),
    ],
  );

  const sampleCourse = LmsCourseModel(
    id: 'course-1',
    slug: 'bab-1',
    title: 'Bab 1: Sains Fundamental',
    subtitle: 'Sub',
    instructorName: 'Dr. Nadia',
    difficulty: 'NOVICE',
    requiredTier: 'Trial',
    isUnlocked: true,
    totalDurationSec: 310,
    xpRewardOnComplete: 300,
    lessons: [sampleLesson],
  );

  testWidgets('LMS player allows free forward skip without Anti-Skip SnackBar and renders clean markdown',
      (tester) async {
    tester.view.physicalSize = const Size(600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LmsCoursePlayerScreen(
            course: sampleCourse,
            lesson: sampleLesson,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Tap forward chapter chip at 01:35 -> must seek immediately with ZERO Anti-Skip SnackBar
    await tester.tap(find.text('01:35 Matematika EY%'));
    await tester.pumpAndSettle();

    expect(find.textContaining('01:35 / 05:10'), findsOneWidget);
    expect(find.textContaining('Anti-Skip'), findsNothing);
    expect(find.byType(SnackBar), findsNothing);

    // 2. Tap +10s button -> must advance to 01:45 with ZERO Anti-Skip SnackBar
    await tester.tap(find.byTooltip('Maju 10 detik'));
    await tester.pumpAndSettle();

    expect(find.textContaining('01:45 / 05:10'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    // 3. Inline code & italic markdown rendered cleanly (no raw backticks or asterisks)
    expect(find.text('1,15% - 1,35% TDS'), findsOneWidget);
    expect(find.textContaining('`'), findsNothing);
    expect(find.textContaining('*watery*'), findsNothing);
  });
}
