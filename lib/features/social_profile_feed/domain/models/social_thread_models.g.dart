// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_thread_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecipeStepMiniDto _$RecipeStepMiniDtoFromJson(Map<String, dynamic> json) =>
    _RecipeStepMiniDto(
      stepNumber: (json['step_number'] as num).toInt(),
      title: json['title'] as String,
      durationSec: (json['duration_sec'] as num).toInt(),
      waterAddedMl: (json['water_added_ml'] as num).toDouble(),
      targetTempC: (json['target_temp_c'] as num?)?.toInt(),
      instruction: json['instruction'] as String?,
    );

Map<String, dynamic> _$RecipeStepMiniDtoToJson(_RecipeStepMiniDto instance) =>
    <String, dynamic>{
      'step_number': instance.stepNumber,
      'title': instance.title,
      'duration_sec': instance.durationSec,
      'water_added_ml': instance.waterAddedMl,
      'target_temp_c': instance.targetTempC,
      'instruction': instance.instruction,
    };

_PourCurvePoint _$PourCurvePointFromJson(Map<String, dynamic> json) =>
    _PourCurvePoint(
      tSec: (json['t_sec'] as num).toInt(),
      actualMl: (json['actual_ml'] as num).toDouble(),
      targetMl: (json['target_ml'] as num).toDouble(),
      tempC: (json['temp_c'] as num).toDouble(),
    );

Map<String, dynamic> _$PourCurvePointToJson(_PourCurvePoint instance) =>
    <String, dynamic>{
      't_sec': instance.tSec,
      'actual_ml': instance.actualMl,
      'target_ml': instance.targetMl,
      'temp_c': instance.tempC,
    };

_MediaAttachmentItem _$MediaAttachmentItemFromJson(Map<String, dynamic> json) =>
    _MediaAttachmentItem(
      url: json['url'] as String,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      blurhash: json['blurhash'] as String?,
    );

Map<String, dynamic> _$MediaAttachmentItemToJson(
  _MediaAttachmentItem instance,
) => <String, dynamic>{
  'url': instance.url,
  'width': instance.width,
  'height': instance.height,
  'blurhash': instance.blurhash,
};

InteractiveRecipeCardAttachment _$InteractiveRecipeCardAttachmentFromJson(
  Map<String, dynamic> json,
) => InteractiveRecipeCardAttachment(
  recipeId: json['recipe_id'] as String,
  title: json['title'] as String,
  brewerName: json['brewer_name'] as String,
  method: json['method'] as String,
  coffeeDoseG: (json['coffee_dose_g'] as num).toDouble(),
  totalWaterMl: (json['total_water_ml'] as num).toDouble(),
  primaryTempC: (json['primary_temp_c'] as num).toInt(),
  secondaryTempC: (json['secondary_temp_c'] as num?)?.toInt(),
  targetDurationSec: (json['target_duration_sec'] as num).toInt(),
  stepsPreview:
      (json['steps_preview'] as List<dynamic>?)
          ?.map((e) => RecipeStepMiniDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$InteractiveRecipeCardAttachmentToJson(
  InteractiveRecipeCardAttachment instance,
) => <String, dynamic>{
  'recipe_id': instance.recipeId,
  'title': instance.title,
  'brewer_name': instance.brewerName,
  'method': instance.method,
  'coffee_dose_g': instance.coffeeDoseG,
  'total_water_ml': instance.totalWaterMl,
  'primary_temp_c': instance.primaryTempC,
  'secondary_temp_c': instance.secondaryTempC,
  'target_duration_sec': instance.targetDurationSec,
  'steps_preview': instance.stepsPreview,
  'runtimeType': instance.$type,
};

PouringTelemetryCurveAttachment _$PouringTelemetryCurveAttachmentFromJson(
  Map<String, dynamic> json,
) => PouringTelemetryCurveAttachment(
  sessionId: json['session_id'] as String,
  recipeTitle: json['recipe_title'] as String,
  beanName: json['bean_name'] as String,
  accuracyScorePct: (json['accuracy_score_pct'] as num).toDouble(),
  totalDurationSec: (json['total_duration_sec'] as num).toInt(),
  curvePoints:
      (json['curve_points'] as List<dynamic>?)
          ?.map((e) => PourCurvePoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$PouringTelemetryCurveAttachmentToJson(
  PouringTelemetryCurveAttachment instance,
) => <String, dynamic>{
  'session_id': instance.sessionId,
  'recipe_title': instance.recipeTitle,
  'bean_name': instance.beanName,
  'accuracy_score_pct': instance.accuracyScorePct,
  'total_duration_sec': instance.totalDurationSec,
  'curve_points': instance.curvePoints,
  'runtimeType': instance.$type,
};

ScannedCoffeeBagTagAttachment _$ScannedCoffeeBagTagAttachmentFromJson(
  Map<String, dynamic> json,
) => ScannedCoffeeBagTagAttachment(
  classSlug: json['class_slug'] as String,
  roastery: json['roastery'] as String,
  beanName: json['bean_name'] as String,
  origin: json['origin'] as String,
  process: json['process'] as String,
  altitudeMasl: json['altitude_masl'] as String,
  tastingNotes:
      (json['tasting_notes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  confidencePct: (json['confidence_pct'] as num).toDouble(),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$ScannedCoffeeBagTagAttachmentToJson(
  ScannedCoffeeBagTagAttachment instance,
) => <String, dynamic>{
  'class_slug': instance.classSlug,
  'roastery': instance.roastery,
  'bean_name': instance.beanName,
  'origin': instance.origin,
  'process': instance.process,
  'altitude_masl': instance.altitudeMasl,
  'tasting_notes': instance.tastingNotes,
  'confidence_pct': instance.confidencePct,
  'runtimeType': instance.$type,
};

_QuotedThreadPreview _$QuotedThreadPreviewFromJson(Map<String, dynamic> json) =>
    _QuotedThreadPreview(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      authorUsername: json['author_username'] as String,
      authorDisplayName: json['author_display_name'] as String,
      authorAvatarUrl: json['author_avatar_url'] as String?,
      bodyText: json['body_text'] as String? ?? '',
      kind: json['kind'] as String? ?? 'STANDARD_POST',
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$QuotedThreadPreviewToJson(
  _QuotedThreadPreview instance,
) => <String, dynamic>{
  'id': instance.id,
  'author_id': instance.authorId,
  'author_username': instance.authorUsername,
  'author_display_name': instance.authorDisplayName,
  'author_avatar_url': instance.authorAvatarUrl,
  'body_text': instance.bodyText,
  'kind': instance.kind,
  'created_at': instance.createdAt.toIso8601String(),
};

_SocialThreadItem _$SocialThreadItemFromJson(Map<String, dynamic> json) =>
    _SocialThreadItem(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      authorUsername: json['author_username'] as String,
      authorDisplayName: json['author_display_name'] as String,
      authorAvatarUrl: json['author_avatar_url'] as String?,
      authorTier: json['author_tier'] as String? ?? 'Trial',
      authorBaristaLevel: (json['author_barista_level'] as num?)?.toInt() ?? 1,
      authorBaristaRankTitle:
          json['author_barista_rank_title'] as String? ?? 'Home Brewer',
      kind: json['kind'] as String? ?? 'STANDARD_POST',
      parentThreadId: json['parent_thread_id'] as String?,
      rootThreadId: json['root_thread_id'] as String?,
      quotedThreadId: json['quoted_thread_id'] as String?,
      quotedPreview: json['quoted_preview'] == null
          ? null
          : QuotedThreadPreview.fromJson(
              json['quoted_preview'] as Map<String, dynamic>,
            ),
      depthLevel: (json['depth_level'] as num?)?.toInt() ?? 0,
      bodyText: json['body_text'] as String? ?? '',
      hasMedia: json['has_media'] as bool? ?? false,
      mediaUrls:
          (json['media_urls'] as List<dynamic>?)
              ?.map(
                (e) => MediaAttachmentItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      rawAttachment: json['attachment'] as Map<String, dynamic>?,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      repliesCount: (json['replies_count'] as num?)?.toInt() ?? 0,
      repostsCount: (json['reposts_count'] as num?)?.toInt() ?? 0,
      tryRecipeCount: (json['try_recipe_count'] as num?)?.toInt() ?? 0,
      isPinnedOnProfile: json['is_pinned_on_profile'] as bool? ?? false,
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
      isRepostedByMe: json['is_reposted_by_me'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$SocialThreadItemToJson(_SocialThreadItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author_id': instance.authorId,
      'author_username': instance.authorUsername,
      'author_display_name': instance.authorDisplayName,
      'author_avatar_url': instance.authorAvatarUrl,
      'author_tier': instance.authorTier,
      'author_barista_level': instance.authorBaristaLevel,
      'author_barista_rank_title': instance.authorBaristaRankTitle,
      'kind': instance.kind,
      'parent_thread_id': instance.parentThreadId,
      'root_thread_id': instance.rootThreadId,
      'quoted_thread_id': instance.quotedThreadId,
      'quoted_preview': instance.quotedPreview,
      'depth_level': instance.depthLevel,
      'body_text': instance.bodyText,
      'has_media': instance.hasMedia,
      'media_urls': instance.mediaUrls,
      'attachment': instance.rawAttachment,
      'likes_count': instance.likesCount,
      'replies_count': instance.repliesCount,
      'reposts_count': instance.repostsCount,
      'try_recipe_count': instance.tryRecipeCount,
      'is_pinned_on_profile': instance.isPinnedOnProfile,
      'is_liked_by_me': instance.isLikedByMe,
      'is_reposted_by_me': instance.isRepostedByMe,
      'created_at': instance.createdAt.toIso8601String(),
    };

_ThreadReplyNode _$ThreadReplyNodeFromJson(Map<String, dynamic> json) =>
    _ThreadReplyNode(
      thread: SocialThreadItem.fromJson(json['thread'] as Map<String, dynamic>),
      children:
          (json['children'] as List<dynamic>?)
              ?.map((e) => ThreadReplyNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ThreadReplyNodeToJson(_ThreadReplyNode instance) =>
    <String, dynamic>{'thread': instance.thread, 'children': instance.children};

_ThreadDetailResponse _$ThreadDetailResponseFromJson(
  Map<String, dynamic> json,
) => _ThreadDetailResponse(
  root: SocialThreadItem.fromJson(json['root'] as Map<String, dynamic>),
  replies:
      (json['replies'] as List<dynamic>?)
          ?.map((e) => ThreadReplyNode.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ThreadDetailResponseToJson(
  _ThreadDetailResponse instance,
) => <String, dynamic>{'root': instance.root, 'replies': instance.replies};
