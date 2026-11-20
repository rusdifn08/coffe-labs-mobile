import '../../../models/subscription_plan.dart';
import '../../../services/auth_service.dart';
import '../../../services/trial_service.dart';

/// Evaluator akses tier terpusat (1:1 dengan backend `tier_access_resolver.rs`)
/// untuk Pustaka E-Book DRM dan Akademi Barista LMS.
class ToolkitTierAccess {
  const ToolkitTierAccess._();

  static int requiredTierLevel(String rawTier) {
    switch (rawTier.trim().toLowerCase()) {
      case 'business':
        return 3;
      case 'pro':
        return 2;
      default:
        return 1;
    }
  }

  static int resolveUserTierLevel({
    required AuthUser? user,
    SubscriptionPlan? localPlan,
    bool? hasFullNonBusinessTrial,
  }) {
    final fullTrial = hasFullNonBusinessTrial ??
        TrialService.isFullNonBusinessTrialActiveSync(user: user);
    if (user != null) {
      if (user.isAdmin || user.isBusiness) return 3;
      if (user.isPro) return 2;
      if (user.hasActiveFullTrialOverride || fullTrial) return 2;
      return 1;
    }
    if (localPlan != null) {
      if (localPlan.tier == SubscriptionTier.business) return 3;
      if (localPlan.tier == SubscriptionTier.pro) return 2;
    }
    if (fullTrial) return 2;
    return 1;
  }

  static bool isUnlockedFor({
    required String requiredTier,
    required AuthUser? user,
    SubscriptionPlan? localPlan,
    bool? hasFullNonBusinessTrial,
  }) {
    final reqLevel = requiredTierLevel(requiredTier);
    if (reqLevel <= 1) return true;
    final userLevel = resolveUserTierLevel(
      user: user,
      localPlan: localPlan,
      hasFullNonBusinessTrial: hasFullNonBusinessTrial,
    );
    return userLevel >= reqLevel;
  }
}

class LmsQuizQuestion {
  final String question;
  final List<String> options;
  final int answerIdx;

  const LmsQuizQuestion({
    required this.question,
    required this.options,
    required this.answerIdx,
  });

  factory LmsQuizQuestion.fromJson(Map<String, dynamic> j) => LmsQuizQuestion(
        question: j['q']?.toString() ?? '',
        options: (j['options'] as List? ?? []).map((e) => e.toString()).toList(),
        answerIdx: (j['answer_idx'] as num?)?.toInt() ?? 0,
      );
}

class LmsLessonModel {
  final String id;
  final String courseId;
  final int moduleNumber;
  final int lessonNumber;
  final String subchapterCode;
  final String title;
  final String description;
  final String kind;
  final int durationSec;
  final int completionPct;
  final int? quizScorePct;
  final bool isCompleted;
  final int xpReward;
  final String? signedHlsUrl;
  final String keyTakeawaysMarkdown;
  final List<Map<String, String>> formulasLatex;
  final List<Map<String, String>> storyboardScenes;
  final Map<String, dynamic> simulationConfig;
  final List<Map<String, dynamic>> chapterMarkers;
  final List<LmsQuizQuestion> quizQuestions;
  final String? linkedEbookCode;
  final int? linkedEbookChapter;

  const LmsLessonModel({
    required this.id,
    required this.courseId,
    required this.moduleNumber,
    required this.lessonNumber,
    this.subchapterCode = '',
    required this.title,
    required this.description,
    required this.kind,
    required this.durationSec,
    this.completionPct = 0,
    this.quizScorePct,
    this.isCompleted = false,
    required this.xpReward,
    this.signedHlsUrl,
    this.keyTakeawaysMarkdown = '',
    this.formulasLatex = const [],
    this.storyboardScenes = const [],
    this.simulationConfig = const {},
    this.chapterMarkers = const [],
    this.quizQuestions = const [],
    this.linkedEbookCode,
    this.linkedEbookChapter,
  });

  factory LmsLessonModel.fromJson(Map<String, dynamic> j) => LmsLessonModel(
        id: j['id']?.toString() ?? '',
        courseId: j['course_id']?.toString() ?? '',
        moduleNumber: (j['module_number'] as num?)?.toInt() ?? 1,
        lessonNumber: (j['lesson_number'] as num?)?.toInt() ?? 1,
        subchapterCode: j['subchapter_code']?.toString() ?? '',
        title: j['title']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        kind: j['kind']?.toString() ?? 'HLS_VIDEO',
        durationSec: (j['duration_sec'] as num?)?.toInt() ?? 300,
        completionPct: (j['completion_pct'] as num?)?.toInt() ?? 0,
        quizScorePct: (j['quiz_score_pct'] as num?)?.toInt(),
        isCompleted: j['is_completed'] == true,
        xpReward: (j['xp_reward'] as num?)?.toInt() ?? 80,
        keyTakeawaysMarkdown: j['key_takeaways_markdown']?.toString() ?? '',
        formulasLatex: ((j['formulas_latex'] ?? j['formulas_latex_json']) as List? ?? [])
            .map((e) => Map<String, String>.from(
                  (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
                ))
            .toList(),
        storyboardScenes: ((j['storyboard_scenes'] ?? j['storyboard_scenes_json']) as List? ?? [])
            .map((e) => Map<String, String>.from(
                  (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
                ))
            .toList(),
        simulationConfig: ((j['simulation_config'] ?? j['simulation_config_json']) as Map?)
                ?.cast<String, dynamic>() ??
            const {},
        chapterMarkers: ((j['chapter_markers'] ?? j['chapter_markers_json']) as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        quizQuestions: ((j['quiz_questions'] ?? j['quiz_questions_json']) as List? ?? [])
            .map((e) => LmsQuizQuestion.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        linkedEbookCode: j['linked_ebook_code']?.toString(),
        linkedEbookChapter: (j['linked_ebook_chapter'] as num?)?.toInt(),
      );
}

class LmsCourseModel {
  final String id;
  final String slug;
  final String title;
  final String subtitle;
  final String instructorName;
  final String difficulty;
  final String requiredTier;
  final bool isUnlocked;
  final String competencyLevel;
  final String focusSummary;
  final String interactiveEngineType;
  final String? linkedEbookId;
  final int totalDurationSec;
  final int xpRewardOnComplete;
  final List<LmsLessonModel> lessons;

  const LmsCourseModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.instructorName,
    required this.difficulty,
    required this.requiredTier,
    required this.isUnlocked,
    this.competencyLevel = '',
    this.focusSummary = '',
    this.interactiveEngineType = '',
    this.linkedEbookId,
    required this.totalDurationSec,
    required this.xpRewardOnComplete,
    required this.lessons,
  });

  factory LmsCourseModel.fromJson(Map<String, dynamic> j) => LmsCourseModel(
        id: j['id']?.toString() ?? '',
        slug: j['slug']?.toString() ?? '',
        title: j['title']?.toString() ?? '',
        subtitle: j['subtitle']?.toString() ?? '',
        instructorName: j['instructor_name']?.toString() ?? 'Coffee Labs Faculty',
        difficulty: j['difficulty']?.toString() ?? 'NOVICE',
        requiredTier: j['required_tier']?.toString() ?? 'Trial',
        isUnlocked: j['is_unlocked'] != false,
        competencyLevel: j['competency_level']?.toString() ?? '',
        focusSummary: j['focus_summary']?.toString() ?? '',
        interactiveEngineType: j['interactive_engine_type']?.toString() ?? '',
        linkedEbookId: j['linked_ebook_id']?.toString(),
        totalDurationSec: (j['total_duration_sec'] as num?)?.toInt() ?? 420,
        xpRewardOnComplete: (j['xp_reward_on_complete'] as num?)?.toInt() ?? 300,
        lessons: (j['lessons'] as List? ?? [])
            .map((e) => LmsLessonModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  LmsCourseModel copyWith({bool? isUnlocked}) => LmsCourseModel(
        id: id,
        slug: slug,
        title: title,
        subtitle: subtitle,
        instructorName: instructorName,
        difficulty: difficulty,
        requiredTier: requiredTier,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        competencyLevel: competencyLevel,
        focusSummary: focusSummary,
        interactiveEngineType: interactiveEngineType,
        linkedEbookId: linkedEbookId,
        totalDurationSec: totalDurationSec,
        xpRewardOnComplete: xpRewardOnComplete,
        lessons: lessons,
      );
}

class EbookTocChapter {
  final String title;
  final String? titleEn;
  final int chapterNumber;
  final int startPage;

  const EbookTocChapter({
    required this.title,
    this.titleEn,
    this.chapterNumber = 1,
    required this.startPage,
  });

  factory EbookTocChapter.fromJson(Map<String, dynamic> j) => EbookTocChapter(
        title: j['title']?.toString() ?? '',
        titleEn: j['title_en']?.toString(),
        chapterNumber: (j['chapter_number'] as num?)?.toInt() ?? 1,
        startPage: (j['start_page'] as num?)?.toInt() ?? 1,
      );
}

class EbookDocBlock {
  final String blockId;
  final String blockType;
  final String textId;
  final String textEnOriginal;
  final String latexExpression;
  final String widgetKind;
  final String? figureSecureUrl;
  final String? figureCaptionId;

  const EbookDocBlock({
    required this.blockId,
    required this.blockType,
    this.textId = '',
    this.textEnOriginal = '',
    this.latexExpression = '',
    this.widgetKind = '',
    this.figureSecureUrl,
    this.figureCaptionId,
  });

  factory EbookDocBlock.fromJson(Map<String, dynamic> j) => EbookDocBlock(
        blockId: j['block_id']?.toString() ?? '',
        blockType: j['block_type']?.toString() ?? 'paragraph',
        textId: j['text_id']?.toString() ?? '',
        textEnOriginal: j['text_en_original']?.toString() ?? '',
        latexExpression: j['latex_expression']?.toString() ?? '',
        widgetKind: j['widget_kind']?.toString() ?? '',
        figureSecureUrl: j['figure_secure_url']?.toString(),
        figureCaptionId: j['figure_caption_id']?.toString(),
      );
}

class EbookChapterAstModel {
  final String id;
  final int chapterNumber;
  final String titleId;
  final String? titleEn;
  final int estimatedReadTimeMin;
  final int startPdfPage;
  final int endPdfPage;
  final List<EbookDocBlock> blocks;
  final List<String> keySummaryPoints;
  final List<LmsQuizQuestion> chapterQuiz;

  const EbookChapterAstModel({
    required this.id,
    required this.chapterNumber,
    required this.titleId,
    this.titleEn,
    this.estimatedReadTimeMin = 12,
    this.startPdfPage = 1,
    this.endPdfPage = 2,
    this.blocks = const [],
    this.keySummaryPoints = const [],
    this.chapterQuiz = const [],
  });

  factory EbookChapterAstModel.fromJson(Map<String, dynamic> j) => EbookChapterAstModel(
        id: j['id']?.toString() ?? '',
        chapterNumber: (j['chapter_number'] as num?)?.toInt() ?? 1,
        titleId: j['title_id']?.toString() ?? '',
        titleEn: j['title_en']?.toString(),
        estimatedReadTimeMin: (j['estimated_read_time_min'] as num?)?.toInt() ?? 12,
        startPdfPage: (j['start_pdf_page'] as num?)?.toInt() ?? 1,
        endPdfPage: (j['end_pdf_page'] as num?)?.toInt() ?? 2,
        blocks: (j['mobile_blocks_ast'] as List? ?? [])
            .map((e) => EbookDocBlock.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        keySummaryPoints:
            (j['key_summary_points'] as List? ?? []).map((e) => e.toString()).toList(),
        chapterQuiz: (j['chapter_quiz_json'] as List? ?? [])
            .map((e) => LmsQuizQuestion.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class CoffeeDictionaryEntryModel {
  final String id;
  final String termSlug;
  final String alphabetLetter;
  final String termTitle;
  final String category;
  final String shortDefinitionId;
  final String deepExplanationId;
  final String? relatedFormulaLatex;
  final String relatedBookCode;
  final int relatedChapterNum;

  const CoffeeDictionaryEntryModel({
    required this.id,
    required this.termSlug,
    required this.alphabetLetter,
    required this.termTitle,
    required this.category,
    required this.shortDefinitionId,
    required this.deepExplanationId,
    this.relatedFormulaLatex,
    this.relatedBookCode = 'CL-BOOK-08',
    this.relatedChapterNum = 1,
  });

  factory CoffeeDictionaryEntryModel.fromJson(Map<String, dynamic> j) =>
      CoffeeDictionaryEntryModel(
        id: j['id']?.toString() ?? '',
        termSlug: j['term_slug']?.toString() ?? '',
        alphabetLetter: j['alphabet_letter']?.toString() ?? 'A',
        termTitle: j['term_title']?.toString() ?? '',
        category: j['category']?.toString() ?? 'PHYSICS',
        shortDefinitionId: j['short_definition_id']?.toString() ?? '',
        deepExplanationId: j['deep_explanation_id']?.toString() ?? '',
        relatedFormulaLatex: j['related_formula_latex']?.toString(),
        relatedBookCode: j['related_book_code']?.toString() ?? 'CL-BOOK-08',
        relatedChapterNum: (j['related_chapter_num'] as num?)?.toInt() ?? 1,
      );
}

class EbookCatalogItem {
  final String id;
  final String bookCode;
  final String title;
  final String? originalTitle;
  final String author;
  final String synopsis;
  final String category;
  final String requiredTier;
  final bool isUnlocked;
  final String coverImageUrl;
  final int totalPages;
  final int totalChaptersCount;
  final int totalFiguresCount;
  final bool supportsBilingualToggle;
  final String objectStorageProvider;
  final int fileSizeBytes;
  final int pdfFileSizeBytes;
  final int epubFileSizeBytes;
  final String sha256CiphertextHash;
  final String bundledAssetPath;
  final List<EbookTocChapter> tocChapters;
  final int currentPage;
  final int currentChapterNumber;
  final int completionPct;

  const EbookCatalogItem({
    required this.id,
    required this.bookCode,
    required this.title,
    this.originalTitle,
    required this.author,
    required this.synopsis,
    required this.category,
    required this.requiredTier,
    required this.isUnlocked,
    this.coverImageUrl = '',
    required this.totalPages,
    this.totalChaptersCount = 1,
    this.totalFiguresCount = 1,
    this.supportsBilingualToggle = true,
    this.objectStorageProvider = 'OBJECT_STORAGE',
    required this.fileSizeBytes,
    this.pdfFileSizeBytes = 0,
    this.epubFileSizeBytes = 0,
    required this.sha256CiphertextHash,
    this.bundledAssetPath = '',
    required this.tocChapters,
    this.currentPage = 1,
    this.currentChapterNumber = 1,
    this.completionPct = 0,
  });

  factory EbookCatalogItem.fromJson(Map<String, dynamic> j) => EbookCatalogItem(
        id: j['id']?.toString() ?? '',
        bookCode: j['book_code']?.toString() ?? 'CL-BOOK-01',
        title: j['title']?.toString() ?? '',
        originalTitle: j['original_title']?.toString(),
        author: j['author']?.toString() ?? '',
        synopsis: j['synopsis']?.toString() ?? '',
        category: j['category']?.toString() ?? 'SCIENCE',
        requiredTier: j['required_tier']?.toString() ?? 'Trial',
        isUnlocked: j['is_unlocked'] != false,
        coverImageUrl: j['cover_image_url']?.toString() ?? '',
        totalPages: (j['total_pages'] as num?)?.toInt() ?? 5,
        totalChaptersCount: (j['total_chapters_count'] as num?)?.toInt() ?? 1,
        totalFiguresCount: (j['total_figures_count'] as num?)?.toInt() ?? 1,
        supportsBilingualToggle: j['supports_bilingual_toggle'] != false,
        objectStorageProvider:
            j['object_storage_provider']?.toString() ?? 'OBJECT_STORAGE',
        fileSizeBytes: (j['file_size_bytes'] as num?)?.toInt() ?? 0,
        pdfFileSizeBytes: (j['pdf_file_size_bytes'] as num?)?.toInt() ?? 0,
        epubFileSizeBytes: (j['epub_file_size_bytes'] as num?)?.toInt() ?? 0,
        sha256CiphertextHash: j['sha256_ciphertext_hash']?.toString() ?? '',
        bundledAssetPath: j['bundled_asset_path']?.toString() ?? '',
        tocChapters: ((j['toc_chapters'] ?? j['toc_chapters_json']) as List? ?? [])
            .map((e) => EbookTocChapter.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        currentPage: (j['current_page'] as num?)?.toInt() ?? 1,
        currentChapterNumber: (j['current_chapter_number'] as num?)?.toInt() ?? 1,
        completionPct: (j['completion_pct'] as num?)?.toInt() ?? 0,
      );

  int get totalEstimatedDownloadBytes {
    final sum = (fileSizeBytes > 0 ? fileSizeBytes : pdfFileSizeBytes) + epubFileSizeBytes;
    return sum > 0 ? sum : 950000;
  }

  EbookCatalogItem copyWith({bool? isUnlocked}) => EbookCatalogItem(
        id: id,
        bookCode: bookCode,
        title: title,
        originalTitle: originalTitle,
        author: author,
        synopsis: synopsis,
        category: category,
        requiredTier: requiredTier,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        coverImageUrl: coverImageUrl,
        totalPages: totalPages,
        totalChaptersCount: totalChaptersCount,
        totalFiguresCount: totalFiguresCount,
        supportsBilingualToggle: supportsBilingualToggle,
        objectStorageProvider: objectStorageProvider,
        fileSizeBytes: fileSizeBytes,
        pdfFileSizeBytes: pdfFileSizeBytes,
        epubFileSizeBytes: epubFileSizeBytes,
        sha256CiphertextHash: sha256CiphertextHash,
        bundledAssetPath: bundledAssetPath,
        tocChapters: tocChapters,
        currentPage: currentPage,
        currentChapterNumber: currentChapterNumber,
        completionPct: completionPct,
      );
}

class GameBrewChapterModel {
  final int chapterNumber;
  final String slug;
  final String title;
  final String storyLocation;
  final String npcMentorName;
  final String targetRecipeSlug;
  final Map<String, dynamic> physicsConfig;
  final List<Map<String, String>> storyDialogue;
  final int xpReward3Stars;
  final int starsEarned;
  final double highScoreAccuracyPct;
  final bool isUnlocked;

  const GameBrewChapterModel({
    required this.chapterNumber,
    required this.slug,
    required this.title,
    required this.storyLocation,
    required this.npcMentorName,
    required this.targetRecipeSlug,
    required this.physicsConfig,
    required this.storyDialogue,
    required this.xpReward3Stars,
    this.starsEarned = 0,
    this.highScoreAccuracyPct = 0.0,
    this.isUnlocked = false,
  });

  factory GameBrewChapterModel.fromJson(Map<String, dynamic> j) => GameBrewChapterModel(
        chapterNumber: (j['chapter_number'] as num?)?.toInt() ?? 1,
        slug: j['slug']?.toString() ?? '',
        title: j['title']?.toString() ?? '',
        storyLocation: j['story_location']?.toString() ?? 'Kedai Senja Malabar',
        npcMentorName: j['npc_mentor_name']?.toString() ?? 'Master Kaito',
        targetRecipeSlug: j['target_recipe_slug']?.toString() ?? '',
        physicsConfig:
            (j['physics_config'] as Map?)?.cast<String, dynamic>() ?? const {},
        storyDialogue: (j['story_dialogue'] as List? ?? [])
            .map((e) => Map<String, String>.from(
                  (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
                ))
            .toList(),
        xpReward3Stars: (j['xp_reward_3_stars'] as num?)?.toInt() ?? 200,
        starsEarned: (j['stars_earned'] as num?)?.toInt() ?? 0,
        highScoreAccuracyPct:
            (j['high_score_accuracy_pct'] as num?)?.toDouble() ?? 0.0,
        isUnlocked: j['is_unlocked'] == true || ((j['chapter_number'] as num?)?.toInt() ?? 1) == 1,
      );
}

class BrewDoctorDiagnosisModel {
  final String diagnosisCode;
  final String diagnosisTitle;
  final double xExtraction;
  final double yStrength;
  final double estimatedEyPct;
  final double estimatedTdsPct;
  final int grindClicksDelta;
  final int tempCDelta;
  final String recommendedRatio;
  final String explanation;
  final String pourTechniqueAdvice;

  const BrewDoctorDiagnosisModel({
    required this.diagnosisCode,
    required this.diagnosisTitle,
    required this.xExtraction,
    required this.yStrength,
    required this.estimatedEyPct,
    required this.estimatedTdsPct,
    required this.grindClicksDelta,
    required this.tempCDelta,
    required this.recommendedRatio,
    required this.explanation,
    required this.pourTechniqueAdvice,
  });

  factory BrewDoctorDiagnosisModel.fromJson(Map<String, dynamic> j) =>
      BrewDoctorDiagnosisModel(
        diagnosisCode: j['diagnosis_code']?.toString() ?? 'BALANCED_GOLDEN_CUP',
        diagnosisTitle: j['diagnosis_title']?.toString() ?? '',
        xExtraction: (j['x_extraction'] as num?)?.toDouble() ?? 0.0,
        yStrength: (j['y_strength'] as num?)?.toDouble() ?? 0.0,
        estimatedEyPct: (j['estimated_ey_pct'] as num?)?.toDouble() ?? 20.0,
        estimatedTdsPct: (j['estimated_tds_pct'] as num?)?.toDouble() ?? 1.38,
        grindClicksDelta: (j['grind_clicks_delta'] as num?)?.toInt() ?? 0,
        tempCDelta: (j['temp_c_delta'] as num?)?.toInt() ?? 0,
        recommendedRatio: j['recommended_ratio']?.toString() ?? '1:15',
        explanation: j['explanation']?.toString() ?? '',
        pourTechniqueAdvice: j['pour_technique_advice']?.toString() ?? '',
      );
}
