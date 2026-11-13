import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_thread_models.freezed.dart';
part 'social_thread_models.g.dart';

enum ProfileFeedTab {
  allThreads('ALL_THREADS', 'Threads'),
  brewLogs('BREW_LOGS', 'Brew Logs'),
  createdRecipes('CREATED_RECIPES', 'Created Recipes'),
  media('MEDIA', 'Media');

  final String wireValue;
  final String label;
  const ProfileFeedTab(this.wireValue, this.label);
}

@freezed
abstract class RecipeStepMiniDto with _$RecipeStepMiniDto {
  const factory RecipeStepMiniDto({
    @JsonKey(name: 'step_number') required int stepNumber,
    required String title,
    @JsonKey(name: 'duration_sec') required int durationSec,
    @JsonKey(name: 'water_added_ml') required double waterAddedMl,
    @JsonKey(name: 'target_temp_c') int? targetTempC,
    String? instruction,
  }) = _RecipeStepMiniDto;

  factory RecipeStepMiniDto.fromJson(Map<String, dynamic> json) =>
      _$RecipeStepMiniDtoFromJson(json);
}

@freezed
abstract class PourCurvePoint with _$PourCurvePoint {
  const factory PourCurvePoint({
    @JsonKey(name: 't_sec') required int tSec,
    @JsonKey(name: 'actual_ml') required double actualMl,
    @JsonKey(name: 'target_ml') required double targetMl,
    @JsonKey(name: 'temp_c') required double tempC,
  }) = _PourCurvePoint;

  factory PourCurvePoint.fromJson(Map<String, dynamic> json) =>
      _$PourCurvePointFromJson(json);
}

@freezed
abstract class MediaAttachmentItem with _$MediaAttachmentItem {
  const factory MediaAttachmentItem({
    required String url,
    int? width,
    int? height,
    String? blurhash,
  }) = _MediaAttachmentItem;

  factory MediaAttachmentItem.fromJson(Map<String, dynamic> json) =>
      _$MediaAttachmentItemFromJson(json);
}

@freezed
sealed class ThreadAttachment with _$ThreadAttachment {
  const ThreadAttachment._();

  const factory ThreadAttachment.interactiveRecipeCard({
    @JsonKey(name: 'recipe_id') required String recipeId,
    required String title,
    @JsonKey(name: 'brewer_name') required String brewerName,
    required String method,
    @JsonKey(name: 'coffee_dose_g') required double coffeeDoseG,
    @JsonKey(name: 'total_water_ml') required double totalWaterMl,
    @JsonKey(name: 'primary_temp_c') required int primaryTempC,
    @JsonKey(name: 'secondary_temp_c') int? secondaryTempC,
    @JsonKey(name: 'target_duration_sec') required int targetDurationSec,
    @JsonKey(name: 'steps_preview')
    @Default([])
    List<RecipeStepMiniDto> stepsPreview,
  }) = InteractiveRecipeCardAttachment;

  const factory ThreadAttachment.pouringTelemetryCurve({
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'recipe_title') required String recipeTitle,
    @JsonKey(name: 'bean_name') required String beanName,
    @JsonKey(name: 'accuracy_score_pct') required double accuracyScorePct,
    @JsonKey(name: 'total_duration_sec') required int totalDurationSec,
    @JsonKey(name: 'curve_points')
    @Default([])
    List<PourCurvePoint> curvePoints,
  }) = PouringTelemetryCurveAttachment;

  const factory ThreadAttachment.scannedCoffeeBagTag({
    @JsonKey(name: 'class_slug') required String classSlug,
    required String roastery,
    @JsonKey(name: 'bean_name') required String beanName,
    required String origin,
    required String process,
    @JsonKey(name: 'altitude_masl') required String altitudeMasl,
    @JsonKey(name: 'tasting_notes') @Default([]) List<String> tastingNotes,
    @JsonKey(name: 'confidence_pct') required double confidencePct,
  }) = ScannedCoffeeBagTagAttachment;

  factory ThreadAttachment.fromJson(Map<String, dynamic> json) =>
      _$ThreadAttachmentFromJson(json);

  static ThreadAttachment? tryFromWireJson(Map<String, dynamic>? raw) {
    if (raw == null) return null;
    final tag = raw['type']?.toString();
    final data = raw['data'];
    if (tag == null || data is! Map<String, dynamic>) return null;
    try {
      switch (tag) {
        case 'interactive_recipe_card':
          return InteractiveRecipeCardAttachment.fromJson(data);
        case 'pouring_telemetry_curve':
          return PouringTelemetryCurveAttachment.fromJson(data);
        case 'scanned_coffee_bag_tag':
          return ScannedCoffeeBagTagAttachment.fromJson(data);
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toWireJson() {
    return map(
      interactiveRecipeCard: (v) => {
        'type': 'interactive_recipe_card',
        'data': {
          ...v.toJson(),
          'steps_preview': v.stepsPreview.map((s) => s.toJson()).toList(),
        }..remove('runtimeType'),
      },
      pouringTelemetryCurve: (v) => {
        'type': 'pouring_telemetry_curve',
        'data': {
          ...v.toJson(),
          'curve_points': v.curvePoints.map((p) => p.toJson()).toList(),
        }..remove('runtimeType'),
      },
      scannedCoffeeBagTag: (v) => {
        'type': 'scanned_coffee_bag_tag',
        'data': Map<String, dynamic>.from(v.toJson())..remove('runtimeType'),
      },
    );
  }
}

@freezed
abstract class QuotedThreadPreview with _$QuotedThreadPreview {
  const factory QuotedThreadPreview({
    required String id,
    @JsonKey(name: 'author_id') required String authorId,
    @JsonKey(name: 'author_username') required String authorUsername,
    @JsonKey(name: 'author_display_name') required String authorDisplayName,
    @JsonKey(name: 'author_avatar_url') String? authorAvatarUrl,
    @JsonKey(name: 'body_text') @Default('') String bodyText,
    @Default('STANDARD_POST') String kind,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _QuotedThreadPreview;

  factory QuotedThreadPreview.fromJson(Map<String, dynamic> json) =>
      _$QuotedThreadPreviewFromJson(json);
}

@freezed
abstract class SocialThreadItem with _$SocialThreadItem {
  const SocialThreadItem._();

  const factory SocialThreadItem({
    required String id,
    @JsonKey(name: 'author_id') required String authorId,
    @JsonKey(name: 'author_username') required String authorUsername,
    @JsonKey(name: 'author_display_name') required String authorDisplayName,
    @JsonKey(name: 'author_avatar_url') String? authorAvatarUrl,
    @JsonKey(name: 'author_tier') @Default('Trial') String authorTier,
    @JsonKey(name: 'author_barista_level') @Default(1) int authorBaristaLevel,
    @JsonKey(name: 'author_barista_rank_title')
    @Default('Home Brewer')
    String authorBaristaRankTitle,
    @Default('STANDARD_POST') String kind,
    @JsonKey(name: 'parent_thread_id') String? parentThreadId,
    @JsonKey(name: 'root_thread_id') String? rootThreadId,
    @JsonKey(name: 'quoted_thread_id') String? quotedThreadId,
    @JsonKey(name: 'quoted_preview') QuotedThreadPreview? quotedPreview,
    @JsonKey(name: 'depth_level') @Default(0) int depthLevel,
    @JsonKey(name: 'body_text') @Default('') String bodyText,
    @JsonKey(name: 'has_media') @Default(false) bool hasMedia,
    @JsonKey(name: 'media_urls')
    @Default([])
    List<MediaAttachmentItem> mediaUrls,
    @JsonKey(name: 'attachment') Map<String, dynamic>? rawAttachment,
    @JsonKey(name: 'likes_count') @Default(0) int likesCount,
    @JsonKey(name: 'replies_count') @Default(0) int repliesCount,
    @JsonKey(name: 'reposts_count') @Default(0) int repostsCount,
    @JsonKey(name: 'try_recipe_count') @Default(0) int tryRecipeCount,
    @JsonKey(name: 'is_pinned_on_profile')
    @Default(false)
    bool isPinnedOnProfile,
    @JsonKey(name: 'is_liked_by_me') @Default(false) bool isLikedByMe,
    @JsonKey(name: 'is_reposted_by_me') @Default(false) bool isRepostedByMe,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _SocialThreadItem;

  factory SocialThreadItem.fromJson(Map<String, dynamic> json) =>
      _$SocialThreadItemFromJson(json);

  ThreadAttachment? get parsedAttachment =>
      ThreadAttachment.tryFromWireJson(rawAttachment);
}

@freezed
abstract class ThreadReplyNode with _$ThreadReplyNode {
  const factory ThreadReplyNode({
    required SocialThreadItem thread,
    @Default([]) List<ThreadReplyNode> children,
  }) = _ThreadReplyNode;

  factory ThreadReplyNode.fromJson(Map<String, dynamic> json) =>
      _$ThreadReplyNodeFromJson(json);
}

@freezed
abstract class ThreadDetailResponse with _$ThreadDetailResponse {
  const factory ThreadDetailResponse({
    required SocialThreadItem root,
    @Default([]) List<ThreadReplyNode> replies,
  }) = _ThreadDetailResponse;

  factory ThreadDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$ThreadDetailResponseFromJson(json);
}

@freezed
abstract class CursorPaginatedThreadsState with _$CursorPaginatedThreadsState {
  const factory CursorPaginatedThreadsState({
    @Default([]) List<SocialThreadItem> items,
    String? nextCursor,
    @Default(false) bool hasMore,
    @Default(false) bool isLoadingNextPage,
  }) = _CursorPaginatedThreadsState;
}
