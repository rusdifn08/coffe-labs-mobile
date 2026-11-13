// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationActorPreview {

@JsonKey(name: 'user_id') String get userId; String get username;@JsonKey(name: 'display_name') String get displayName;@JsonKey(name: 'avatar_url') String? get avatarUrl;
/// Create a copy of NotificationActorPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationActorPreviewCopyWith<NotificationActorPreview> get copyWith => _$NotificationActorPreviewCopyWithImpl<NotificationActorPreview>(this as NotificationActorPreview, _$identity);

  /// Serializes this NotificationActorPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationActorPreview&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl);

@override
String toString() {
  return 'NotificationActorPreview(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $NotificationActorPreviewCopyWith<$Res>  {
  factory $NotificationActorPreviewCopyWith(NotificationActorPreview value, $Res Function(NotificationActorPreview) _then) = _$NotificationActorPreviewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String username,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class _$NotificationActorPreviewCopyWithImpl<$Res>
    implements $NotificationActorPreviewCopyWith<$Res> {
  _$NotificationActorPreviewCopyWithImpl(this._self, this._then);

  final NotificationActorPreview _self;
  final $Res Function(NotificationActorPreview) _then;

/// Create a copy of NotificationActorPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = freezed,}) {
  return _then(NotificationActorPreview(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationActorPreview].
extension NotificationActorPreviewPatterns on NotificationActorPreview {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationActorPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationActorPreview() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationActorPreview value)  $default,){
final _that = this;
switch (_that) {
case _NotificationActorPreview():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationActorPreview value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationActorPreview() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationActorPreview() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _NotificationActorPreview():
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _NotificationActorPreview() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationActorPreview implements NotificationActorPreview {
  const _NotificationActorPreview({@JsonKey(name: 'user_id') required this.userId, this.username = '', @JsonKey(name: 'display_name') this.displayName = '', @JsonKey(name: 'avatar_url') this.avatarUrl});
  factory _NotificationActorPreview.fromJson(Map<String, dynamic> json) => _$NotificationActorPreviewFromJson(json);

@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey() final  String username;
@override@JsonKey(name: 'display_name') final  String displayName;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;

/// Create a copy of NotificationActorPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationActorPreviewCopyWith<_NotificationActorPreview> get copyWith => __$NotificationActorPreviewCopyWithImpl<_NotificationActorPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationActorPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationActorPreview&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl);

@override
String toString() {
  return 'NotificationActorPreview(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$NotificationActorPreviewCopyWith<$Res> implements $NotificationActorPreviewCopyWith<$Res> {
  factory _$NotificationActorPreviewCopyWith(_NotificationActorPreview value, $Res Function(_NotificationActorPreview) _then) = __$NotificationActorPreviewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String username,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class __$NotificationActorPreviewCopyWithImpl<$Res>
    implements _$NotificationActorPreviewCopyWith<$Res> {
  __$NotificationActorPreviewCopyWithImpl(this._self, this._then);

  final _NotificationActorPreview _self;
  final $Res Function(_NotificationActorPreview) _then;

/// Create a copy of NotificationActorPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = freezed,}) {
  return _then(_NotificationActorPreview(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$NotificationInboxItem {

 String get id;@JsonKey(name: 'coalesce_group_key') String? get coalesceGroupKey; String get category;@JsonKey(name: 'event_type') String get eventType; String get title; String get body;@JsonKey(name: 'deep_link_path') String get deepLinkPath;@JsonKey(name: 'action_payload') Map<String, dynamic> get actionPayload;@JsonKey(name: 'actors_preview') List<NotificationActorPreview> get actorsPreview;@JsonKey(name: 'aggregated_count') int get aggregatedCount;@JsonKey(name: 'is_read') bool get isRead;@JsonKey(name: 'read_at') DateTime? get readAt;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of NotificationInboxItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationInboxItemCopyWith<NotificationInboxItem> get copyWith => _$NotificationInboxItemCopyWithImpl<NotificationInboxItem>(this as NotificationInboxItem, _$identity);

  /// Serializes this NotificationInboxItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationInboxItem&&(identical(other.id, id) || other.id == id)&&(identical(other.coalesceGroupKey, coalesceGroupKey) || other.coalesceGroupKey == coalesceGroupKey)&&(identical(other.category, category) || other.category == category)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.deepLinkPath, deepLinkPath) || other.deepLinkPath == deepLinkPath)&&const DeepCollectionEquality().equals(other.actionPayload, actionPayload)&&const DeepCollectionEquality().equals(other.actorsPreview, actorsPreview)&&(identical(other.aggregatedCount, aggregatedCount) || other.aggregatedCount == aggregatedCount)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,coalesceGroupKey,category,eventType,title,body,deepLinkPath,const DeepCollectionEquality().hash(actionPayload),const DeepCollectionEquality().hash(actorsPreview),aggregatedCount,isRead,readAt,createdAt,updatedAt);

@override
String toString() {
  return 'NotificationInboxItem(id: $id, coalesceGroupKey: $coalesceGroupKey, category: $category, eventType: $eventType, title: $title, body: $body, deepLinkPath: $deepLinkPath, actionPayload: $actionPayload, actorsPreview: $actorsPreview, aggregatedCount: $aggregatedCount, isRead: $isRead, readAt: $readAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $NotificationInboxItemCopyWith<$Res>  {
  factory $NotificationInboxItemCopyWith(NotificationInboxItem value, $Res Function(NotificationInboxItem) _then) = _$NotificationInboxItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'coalesce_group_key') String? coalesceGroupKey, String category,@JsonKey(name: 'event_type') String eventType, String title, String body,@JsonKey(name: 'deep_link_path') String deepLinkPath,@JsonKey(name: 'action_payload') Map<String, dynamic> actionPayload,@JsonKey(name: 'actors_preview') List<NotificationActorPreview> actorsPreview,@JsonKey(name: 'aggregated_count') int aggregatedCount,@JsonKey(name: 'is_read') bool isRead,@JsonKey(name: 'read_at') DateTime? readAt,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$NotificationInboxItemCopyWithImpl<$Res>
    implements $NotificationInboxItemCopyWith<$Res> {
  _$NotificationInboxItemCopyWithImpl(this._self, this._then);

  final NotificationInboxItem _self;
  final $Res Function(NotificationInboxItem) _then;

/// Create a copy of NotificationInboxItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? coalesceGroupKey = freezed,Object? category = null,Object? eventType = null,Object? title = null,Object? body = null,Object? deepLinkPath = null,Object? actionPayload = null,Object? actorsPreview = null,Object? aggregatedCount = null,Object? isRead = null,Object? readAt = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(NotificationInboxItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,coalesceGroupKey: freezed == coalesceGroupKey ? _self.coalesceGroupKey : coalesceGroupKey // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,deepLinkPath: null == deepLinkPath ? _self.deepLinkPath : deepLinkPath // ignore: cast_nullable_to_non_nullable
as String,actionPayload: null == actionPayload ? _self.actionPayload : actionPayload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,actorsPreview: null == actorsPreview ? _self.actorsPreview : actorsPreview // ignore: cast_nullable_to_non_nullable
as List<NotificationActorPreview>,aggregatedCount: null == aggregatedCount ? _self.aggregatedCount : aggregatedCount // ignore: cast_nullable_to_non_nullable
as int,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationInboxItem].
extension NotificationInboxItemPatterns on NotificationInboxItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationInboxItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationInboxItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationInboxItem value)  $default,){
final _that = this;
switch (_that) {
case _NotificationInboxItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationInboxItem value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationInboxItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'coalesce_group_key')  String? coalesceGroupKey,  String category, @JsonKey(name: 'event_type')  String eventType,  String title,  String body, @JsonKey(name: 'deep_link_path')  String deepLinkPath, @JsonKey(name: 'action_payload')  Map<String, dynamic> actionPayload, @JsonKey(name: 'actors_preview')  List<NotificationActorPreview> actorsPreview, @JsonKey(name: 'aggregated_count')  int aggregatedCount, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'read_at')  DateTime? readAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationInboxItem() when $default != null:
return $default(_that.id,_that.coalesceGroupKey,_that.category,_that.eventType,_that.title,_that.body,_that.deepLinkPath,_that.actionPayload,_that.actorsPreview,_that.aggregatedCount,_that.isRead,_that.readAt,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'coalesce_group_key')  String? coalesceGroupKey,  String category, @JsonKey(name: 'event_type')  String eventType,  String title,  String body, @JsonKey(name: 'deep_link_path')  String deepLinkPath, @JsonKey(name: 'action_payload')  Map<String, dynamic> actionPayload, @JsonKey(name: 'actors_preview')  List<NotificationActorPreview> actorsPreview, @JsonKey(name: 'aggregated_count')  int aggregatedCount, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'read_at')  DateTime? readAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _NotificationInboxItem():
return $default(_that.id,_that.coalesceGroupKey,_that.category,_that.eventType,_that.title,_that.body,_that.deepLinkPath,_that.actionPayload,_that.actorsPreview,_that.aggregatedCount,_that.isRead,_that.readAt,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'coalesce_group_key')  String? coalesceGroupKey,  String category, @JsonKey(name: 'event_type')  String eventType,  String title,  String body, @JsonKey(name: 'deep_link_path')  String deepLinkPath, @JsonKey(name: 'action_payload')  Map<String, dynamic> actionPayload, @JsonKey(name: 'actors_preview')  List<NotificationActorPreview> actorsPreview, @JsonKey(name: 'aggregated_count')  int aggregatedCount, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'read_at')  DateTime? readAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _NotificationInboxItem() when $default != null:
return $default(_that.id,_that.coalesceGroupKey,_that.category,_that.eventType,_that.title,_that.body,_that.deepLinkPath,_that.actionPayload,_that.actorsPreview,_that.aggregatedCount,_that.isRead,_that.readAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationInboxItem extends NotificationInboxItem {
  const _NotificationInboxItem({required this.id, @JsonKey(name: 'coalesce_group_key') this.coalesceGroupKey, this.category = 'SOCIAL_GRAPH', @JsonKey(name: 'event_type') required this.eventType, required this.title, required this.body, @JsonKey(name: 'deep_link_path') required this.deepLinkPath, @JsonKey(name: 'action_payload')  Map<String, dynamic> actionPayload = const <String, dynamic>{}, @JsonKey(name: 'actors_preview')  List<NotificationActorPreview> actorsPreview = const <NotificationActorPreview>[], @JsonKey(name: 'aggregated_count') this.aggregatedCount = 1, @JsonKey(name: 'is_read') this.isRead = false, @JsonKey(name: 'read_at') this.readAt, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _actionPayload = actionPayload,_actorsPreview = actorsPreview,super._();
  factory _NotificationInboxItem.fromJson(Map<String, dynamic> json) => _$NotificationInboxItemFromJson(json);

@override final  String id;
@override@JsonKey(name: 'coalesce_group_key') final  String? coalesceGroupKey;
@override@JsonKey() final  String category;
@override@JsonKey(name: 'event_type') final  String eventType;
@override final  String title;
@override final  String body;
@override@JsonKey(name: 'deep_link_path') final  String deepLinkPath;
 final  Map<String, dynamic> _actionPayload;
@override@JsonKey(name: 'action_payload') Map<String, dynamic> get actionPayload {
  if (_actionPayload is EqualUnmodifiableMapView) return _actionPayload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_actionPayload);
}

 final  List<NotificationActorPreview> _actorsPreview;
@override@JsonKey(name: 'actors_preview') List<NotificationActorPreview> get actorsPreview {
  if (_actorsPreview is EqualUnmodifiableListView) return _actorsPreview;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actorsPreview);
}

@override@JsonKey(name: 'aggregated_count') final  int aggregatedCount;
@override@JsonKey(name: 'is_read') final  bool isRead;
@override@JsonKey(name: 'read_at') final  DateTime? readAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of NotificationInboxItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationInboxItemCopyWith<_NotificationInboxItem> get copyWith => __$NotificationInboxItemCopyWithImpl<_NotificationInboxItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationInboxItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationInboxItem&&(identical(other.id, id) || other.id == id)&&(identical(other.coalesceGroupKey, coalesceGroupKey) || other.coalesceGroupKey == coalesceGroupKey)&&(identical(other.category, category) || other.category == category)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.deepLinkPath, deepLinkPath) || other.deepLinkPath == deepLinkPath)&&const DeepCollectionEquality().equals(other._actionPayload, _actionPayload)&&const DeepCollectionEquality().equals(other._actorsPreview, _actorsPreview)&&(identical(other.aggregatedCount, aggregatedCount) || other.aggregatedCount == aggregatedCount)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,coalesceGroupKey,category,eventType,title,body,deepLinkPath,const DeepCollectionEquality().hash(_actionPayload),const DeepCollectionEquality().hash(_actorsPreview),aggregatedCount,isRead,readAt,createdAt,updatedAt);

@override
String toString() {
  return 'NotificationInboxItem(id: $id, coalesceGroupKey: $coalesceGroupKey, category: $category, eventType: $eventType, title: $title, body: $body, deepLinkPath: $deepLinkPath, actionPayload: $actionPayload, actorsPreview: $actorsPreview, aggregatedCount: $aggregatedCount, isRead: $isRead, readAt: $readAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$NotificationInboxItemCopyWith<$Res> implements $NotificationInboxItemCopyWith<$Res> {
  factory _$NotificationInboxItemCopyWith(_NotificationInboxItem value, $Res Function(_NotificationInboxItem) _then) = __$NotificationInboxItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'coalesce_group_key') String? coalesceGroupKey, String category,@JsonKey(name: 'event_type') String eventType, String title, String body,@JsonKey(name: 'deep_link_path') String deepLinkPath,@JsonKey(name: 'action_payload') Map<String, dynamic> actionPayload,@JsonKey(name: 'actors_preview') List<NotificationActorPreview> actorsPreview,@JsonKey(name: 'aggregated_count') int aggregatedCount,@JsonKey(name: 'is_read') bool isRead,@JsonKey(name: 'read_at') DateTime? readAt,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$NotificationInboxItemCopyWithImpl<$Res>
    implements _$NotificationInboxItemCopyWith<$Res> {
  __$NotificationInboxItemCopyWithImpl(this._self, this._then);

  final _NotificationInboxItem _self;
  final $Res Function(_NotificationInboxItem) _then;

/// Create a copy of NotificationInboxItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? coalesceGroupKey = freezed,Object? category = null,Object? eventType = null,Object? title = null,Object? body = null,Object? deepLinkPath = null,Object? actionPayload = null,Object? actorsPreview = null,Object? aggregatedCount = null,Object? isRead = null,Object? readAt = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_NotificationInboxItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,coalesceGroupKey: freezed == coalesceGroupKey ? _self.coalesceGroupKey : coalesceGroupKey // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,deepLinkPath: null == deepLinkPath ? _self.deepLinkPath : deepLinkPath // ignore: cast_nullable_to_non_nullable
as String,actionPayload: null == actionPayload ? _self._actionPayload : actionPayload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,actorsPreview: null == actorsPreview ? _self._actorsPreview : actorsPreview // ignore: cast_nullable_to_non_nullable
as List<NotificationActorPreview>,aggregatedCount: null == aggregatedCount ? _self.aggregatedCount : aggregatedCount // ignore: cast_nullable_to_non_nullable
as int,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$NotificationInboxPage {

 List<NotificationInboxItem> get items;@JsonKey(name: 'next_cursor') String? get nextCursor;@JsonKey(name: 'has_more') bool get hasMore;@JsonKey(name: 'unread_count') int get unreadCount;
/// Create a copy of NotificationInboxPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationInboxPageCopyWith<NotificationInboxPage> get copyWith => _$NotificationInboxPageCopyWithImpl<NotificationInboxPage>(this as NotificationInboxPage, _$identity);

  /// Serializes this NotificationInboxPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationInboxPage&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),nextCursor,hasMore,unreadCount);

@override
String toString() {
  return 'NotificationInboxPage(items: $items, nextCursor: $nextCursor, hasMore: $hasMore, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class $NotificationInboxPageCopyWith<$Res>  {
  factory $NotificationInboxPageCopyWith(NotificationInboxPage value, $Res Function(NotificationInboxPage) _then) = _$NotificationInboxPageCopyWithImpl;
@useResult
$Res call({
 List<NotificationInboxItem> items,@JsonKey(name: 'next_cursor') String? nextCursor,@JsonKey(name: 'has_more') bool hasMore,@JsonKey(name: 'unread_count') int unreadCount
});




}
/// @nodoc
class _$NotificationInboxPageCopyWithImpl<$Res>
    implements $NotificationInboxPageCopyWith<$Res> {
  _$NotificationInboxPageCopyWithImpl(this._self, this._then);

  final NotificationInboxPage _self;
  final $Res Function(NotificationInboxPage) _then;

/// Create a copy of NotificationInboxPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,Object? hasMore = null,Object? unreadCount = null,}) {
  return _then(NotificationInboxPage(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<NotificationInboxItem>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationInboxPage].
extension NotificationInboxPagePatterns on NotificationInboxPage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationInboxPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationInboxPage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationInboxPage value)  $default,){
final _that = this;
switch (_that) {
case _NotificationInboxPage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationInboxPage value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationInboxPage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<NotificationInboxItem> items, @JsonKey(name: 'next_cursor')  String? nextCursor, @JsonKey(name: 'has_more')  bool hasMore, @JsonKey(name: 'unread_count')  int unreadCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationInboxPage() when $default != null:
return $default(_that.items,_that.nextCursor,_that.hasMore,_that.unreadCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<NotificationInboxItem> items, @JsonKey(name: 'next_cursor')  String? nextCursor, @JsonKey(name: 'has_more')  bool hasMore, @JsonKey(name: 'unread_count')  int unreadCount)  $default,) {final _that = this;
switch (_that) {
case _NotificationInboxPage():
return $default(_that.items,_that.nextCursor,_that.hasMore,_that.unreadCount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<NotificationInboxItem> items, @JsonKey(name: 'next_cursor')  String? nextCursor, @JsonKey(name: 'has_more')  bool hasMore, @JsonKey(name: 'unread_count')  int unreadCount)?  $default,) {final _that = this;
switch (_that) {
case _NotificationInboxPage() when $default != null:
return $default(_that.items,_that.nextCursor,_that.hasMore,_that.unreadCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationInboxPage implements NotificationInboxPage {
  const _NotificationInboxPage({ List<NotificationInboxItem> items = const <NotificationInboxItem>[], @JsonKey(name: 'next_cursor') this.nextCursor, @JsonKey(name: 'has_more') this.hasMore = false, @JsonKey(name: 'unread_count') this.unreadCount = 0}): _items = items;
  factory _NotificationInboxPage.fromJson(Map<String, dynamic> json) => _$NotificationInboxPageFromJson(json);

 final  List<NotificationInboxItem> _items;
@override@JsonKey() List<NotificationInboxItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey(name: 'next_cursor') final  String? nextCursor;
@override@JsonKey(name: 'has_more') final  bool hasMore;
@override@JsonKey(name: 'unread_count') final  int unreadCount;

/// Create a copy of NotificationInboxPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationInboxPageCopyWith<_NotificationInboxPage> get copyWith => __$NotificationInboxPageCopyWithImpl<_NotificationInboxPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationInboxPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationInboxPage&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor,hasMore,unreadCount);

@override
String toString() {
  return 'NotificationInboxPage(items: $items, nextCursor: $nextCursor, hasMore: $hasMore, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class _$NotificationInboxPageCopyWith<$Res> implements $NotificationInboxPageCopyWith<$Res> {
  factory _$NotificationInboxPageCopyWith(_NotificationInboxPage value, $Res Function(_NotificationInboxPage) _then) = __$NotificationInboxPageCopyWithImpl;
@override @useResult
$Res call({
 List<NotificationInboxItem> items,@JsonKey(name: 'next_cursor') String? nextCursor,@JsonKey(name: 'has_more') bool hasMore,@JsonKey(name: 'unread_count') int unreadCount
});




}
/// @nodoc
class __$NotificationInboxPageCopyWithImpl<$Res>
    implements _$NotificationInboxPageCopyWith<$Res> {
  __$NotificationInboxPageCopyWithImpl(this._self, this._then);

  final _NotificationInboxPage _self;
  final $Res Function(_NotificationInboxPage) _then;

/// Create a copy of NotificationInboxPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,Object? hasMore = null,Object? unreadCount = null,}) {
  return _then(_NotificationInboxPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<NotificationInboxItem>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$NotificationPreferences {

@JsonKey(name: 'enable_chat_messages') bool get enableChatMessages;@JsonKey(name: 'enable_follow_follback') bool get enableFollowFollback;@JsonKey(name: 'enable_thread_replies') bool get enableThreadReplies;@JsonKey(name: 'enable_likes_and_recipe_tries') bool get enableLikesAndRecipeTries;@JsonKey(name: 'enable_live_brew_and_streak') bool get enableLiveBrewAndStreak;@JsonKey(name: 'enable_transactional_billing') bool get enableTransactionalBilling;@JsonKey(name: 'quiet_hours_start_minute') int? get quietHoursStartMinute;@JsonKey(name: 'quiet_hours_end_minute') int? get quietHoursEndMinute; String get timezone;
/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPreferencesCopyWith<NotificationPreferences> get copyWith => _$NotificationPreferencesCopyWithImpl<NotificationPreferences>(this as NotificationPreferences, _$identity);

  /// Serializes this NotificationPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPreferences&&(identical(other.enableChatMessages, enableChatMessages) || other.enableChatMessages == enableChatMessages)&&(identical(other.enableFollowFollback, enableFollowFollback) || other.enableFollowFollback == enableFollowFollback)&&(identical(other.enableThreadReplies, enableThreadReplies) || other.enableThreadReplies == enableThreadReplies)&&(identical(other.enableLikesAndRecipeTries, enableLikesAndRecipeTries) || other.enableLikesAndRecipeTries == enableLikesAndRecipeTries)&&(identical(other.enableLiveBrewAndStreak, enableLiveBrewAndStreak) || other.enableLiveBrewAndStreak == enableLiveBrewAndStreak)&&(identical(other.enableTransactionalBilling, enableTransactionalBilling) || other.enableTransactionalBilling == enableTransactionalBilling)&&(identical(other.quietHoursStartMinute, quietHoursStartMinute) || other.quietHoursStartMinute == quietHoursStartMinute)&&(identical(other.quietHoursEndMinute, quietHoursEndMinute) || other.quietHoursEndMinute == quietHoursEndMinute)&&(identical(other.timezone, timezone) || other.timezone == timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enableChatMessages,enableFollowFollback,enableThreadReplies,enableLikesAndRecipeTries,enableLiveBrewAndStreak,enableTransactionalBilling,quietHoursStartMinute,quietHoursEndMinute,timezone);

@override
String toString() {
  return 'NotificationPreferences(enableChatMessages: $enableChatMessages, enableFollowFollback: $enableFollowFollback, enableThreadReplies: $enableThreadReplies, enableLikesAndRecipeTries: $enableLikesAndRecipeTries, enableLiveBrewAndStreak: $enableLiveBrewAndStreak, enableTransactionalBilling: $enableTransactionalBilling, quietHoursStartMinute: $quietHoursStartMinute, quietHoursEndMinute: $quietHoursEndMinute, timezone: $timezone)';
}


}

/// @nodoc
abstract mixin class $NotificationPreferencesCopyWith<$Res>  {
  factory $NotificationPreferencesCopyWith(NotificationPreferences value, $Res Function(NotificationPreferences) _then) = _$NotificationPreferencesCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'enable_chat_messages') bool enableChatMessages,@JsonKey(name: 'enable_follow_follback') bool enableFollowFollback,@JsonKey(name: 'enable_thread_replies') bool enableThreadReplies,@JsonKey(name: 'enable_likes_and_recipe_tries') bool enableLikesAndRecipeTries,@JsonKey(name: 'enable_live_brew_and_streak') bool enableLiveBrewAndStreak,@JsonKey(name: 'enable_transactional_billing') bool enableTransactionalBilling,@JsonKey(name: 'quiet_hours_start_minute') int? quietHoursStartMinute,@JsonKey(name: 'quiet_hours_end_minute') int? quietHoursEndMinute, String timezone
});




}
/// @nodoc
class _$NotificationPreferencesCopyWithImpl<$Res>
    implements $NotificationPreferencesCopyWith<$Res> {
  _$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final NotificationPreferences _self;
  final $Res Function(NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enableChatMessages = null,Object? enableFollowFollback = null,Object? enableThreadReplies = null,Object? enableLikesAndRecipeTries = null,Object? enableLiveBrewAndStreak = null,Object? enableTransactionalBilling = null,Object? quietHoursStartMinute = freezed,Object? quietHoursEndMinute = freezed,Object? timezone = null,}) {
  return _then(NotificationPreferences(
enableChatMessages: null == enableChatMessages ? _self.enableChatMessages : enableChatMessages // ignore: cast_nullable_to_non_nullable
as bool,enableFollowFollback: null == enableFollowFollback ? _self.enableFollowFollback : enableFollowFollback // ignore: cast_nullable_to_non_nullable
as bool,enableThreadReplies: null == enableThreadReplies ? _self.enableThreadReplies : enableThreadReplies // ignore: cast_nullable_to_non_nullable
as bool,enableLikesAndRecipeTries: null == enableLikesAndRecipeTries ? _self.enableLikesAndRecipeTries : enableLikesAndRecipeTries // ignore: cast_nullable_to_non_nullable
as bool,enableLiveBrewAndStreak: null == enableLiveBrewAndStreak ? _self.enableLiveBrewAndStreak : enableLiveBrewAndStreak // ignore: cast_nullable_to_non_nullable
as bool,enableTransactionalBilling: null == enableTransactionalBilling ? _self.enableTransactionalBilling : enableTransactionalBilling // ignore: cast_nullable_to_non_nullable
as bool,quietHoursStartMinute: freezed == quietHoursStartMinute ? _self.quietHoursStartMinute : quietHoursStartMinute // ignore: cast_nullable_to_non_nullable
as int?,quietHoursEndMinute: freezed == quietHoursEndMinute ? _self.quietHoursEndMinute : quietHoursEndMinute // ignore: cast_nullable_to_non_nullable
as int?,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPreferences].
extension NotificationPreferencesPatterns on NotificationPreferences {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPreferences value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'enable_chat_messages')  bool enableChatMessages, @JsonKey(name: 'enable_follow_follback')  bool enableFollowFollback, @JsonKey(name: 'enable_thread_replies')  bool enableThreadReplies, @JsonKey(name: 'enable_likes_and_recipe_tries')  bool enableLikesAndRecipeTries, @JsonKey(name: 'enable_live_brew_and_streak')  bool enableLiveBrewAndStreak, @JsonKey(name: 'enable_transactional_billing')  bool enableTransactionalBilling, @JsonKey(name: 'quiet_hours_start_minute')  int? quietHoursStartMinute, @JsonKey(name: 'quiet_hours_end_minute')  int? quietHoursEndMinute,  String timezone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.enableChatMessages,_that.enableFollowFollback,_that.enableThreadReplies,_that.enableLikesAndRecipeTries,_that.enableLiveBrewAndStreak,_that.enableTransactionalBilling,_that.quietHoursStartMinute,_that.quietHoursEndMinute,_that.timezone);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'enable_chat_messages')  bool enableChatMessages, @JsonKey(name: 'enable_follow_follback')  bool enableFollowFollback, @JsonKey(name: 'enable_thread_replies')  bool enableThreadReplies, @JsonKey(name: 'enable_likes_and_recipe_tries')  bool enableLikesAndRecipeTries, @JsonKey(name: 'enable_live_brew_and_streak')  bool enableLiveBrewAndStreak, @JsonKey(name: 'enable_transactional_billing')  bool enableTransactionalBilling, @JsonKey(name: 'quiet_hours_start_minute')  int? quietHoursStartMinute, @JsonKey(name: 'quiet_hours_end_minute')  int? quietHoursEndMinute,  String timezone)  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences():
return $default(_that.enableChatMessages,_that.enableFollowFollback,_that.enableThreadReplies,_that.enableLikesAndRecipeTries,_that.enableLiveBrewAndStreak,_that.enableTransactionalBilling,_that.quietHoursStartMinute,_that.quietHoursEndMinute,_that.timezone);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'enable_chat_messages')  bool enableChatMessages, @JsonKey(name: 'enable_follow_follback')  bool enableFollowFollback, @JsonKey(name: 'enable_thread_replies')  bool enableThreadReplies, @JsonKey(name: 'enable_likes_and_recipe_tries')  bool enableLikesAndRecipeTries, @JsonKey(name: 'enable_live_brew_and_streak')  bool enableLiveBrewAndStreak, @JsonKey(name: 'enable_transactional_billing')  bool enableTransactionalBilling, @JsonKey(name: 'quiet_hours_start_minute')  int? quietHoursStartMinute, @JsonKey(name: 'quiet_hours_end_minute')  int? quietHoursEndMinute,  String timezone)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.enableChatMessages,_that.enableFollowFollback,_that.enableThreadReplies,_that.enableLikesAndRecipeTries,_that.enableLiveBrewAndStreak,_that.enableTransactionalBilling,_that.quietHoursStartMinute,_that.quietHoursEndMinute,_that.timezone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPreferences implements NotificationPreferences {
  const _NotificationPreferences({@JsonKey(name: 'enable_chat_messages') this.enableChatMessages = true, @JsonKey(name: 'enable_follow_follback') this.enableFollowFollback = true, @JsonKey(name: 'enable_thread_replies') this.enableThreadReplies = true, @JsonKey(name: 'enable_likes_and_recipe_tries') this.enableLikesAndRecipeTries = true, @JsonKey(name: 'enable_live_brew_and_streak') this.enableLiveBrewAndStreak = true, @JsonKey(name: 'enable_transactional_billing') this.enableTransactionalBilling = true, @JsonKey(name: 'quiet_hours_start_minute') this.quietHoursStartMinute, @JsonKey(name: 'quiet_hours_end_minute') this.quietHoursEndMinute, this.timezone = 'Asia/Jakarta'});
  factory _NotificationPreferences.fromJson(Map<String, dynamic> json) => _$NotificationPreferencesFromJson(json);

@override@JsonKey(name: 'enable_chat_messages') final  bool enableChatMessages;
@override@JsonKey(name: 'enable_follow_follback') final  bool enableFollowFollback;
@override@JsonKey(name: 'enable_thread_replies') final  bool enableThreadReplies;
@override@JsonKey(name: 'enable_likes_and_recipe_tries') final  bool enableLikesAndRecipeTries;
@override@JsonKey(name: 'enable_live_brew_and_streak') final  bool enableLiveBrewAndStreak;
@override@JsonKey(name: 'enable_transactional_billing') final  bool enableTransactionalBilling;
@override@JsonKey(name: 'quiet_hours_start_minute') final  int? quietHoursStartMinute;
@override@JsonKey(name: 'quiet_hours_end_minute') final  int? quietHoursEndMinute;
@override@JsonKey() final  String timezone;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPreferencesCopyWith<_NotificationPreferences> get copyWith => __$NotificationPreferencesCopyWithImpl<_NotificationPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPreferences&&(identical(other.enableChatMessages, enableChatMessages) || other.enableChatMessages == enableChatMessages)&&(identical(other.enableFollowFollback, enableFollowFollback) || other.enableFollowFollback == enableFollowFollback)&&(identical(other.enableThreadReplies, enableThreadReplies) || other.enableThreadReplies == enableThreadReplies)&&(identical(other.enableLikesAndRecipeTries, enableLikesAndRecipeTries) || other.enableLikesAndRecipeTries == enableLikesAndRecipeTries)&&(identical(other.enableLiveBrewAndStreak, enableLiveBrewAndStreak) || other.enableLiveBrewAndStreak == enableLiveBrewAndStreak)&&(identical(other.enableTransactionalBilling, enableTransactionalBilling) || other.enableTransactionalBilling == enableTransactionalBilling)&&(identical(other.quietHoursStartMinute, quietHoursStartMinute) || other.quietHoursStartMinute == quietHoursStartMinute)&&(identical(other.quietHoursEndMinute, quietHoursEndMinute) || other.quietHoursEndMinute == quietHoursEndMinute)&&(identical(other.timezone, timezone) || other.timezone == timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enableChatMessages,enableFollowFollback,enableThreadReplies,enableLikesAndRecipeTries,enableLiveBrewAndStreak,enableTransactionalBilling,quietHoursStartMinute,quietHoursEndMinute,timezone);

@override
String toString() {
  return 'NotificationPreferences(enableChatMessages: $enableChatMessages, enableFollowFollback: $enableFollowFollback, enableThreadReplies: $enableThreadReplies, enableLikesAndRecipeTries: $enableLikesAndRecipeTries, enableLiveBrewAndStreak: $enableLiveBrewAndStreak, enableTransactionalBilling: $enableTransactionalBilling, quietHoursStartMinute: $quietHoursStartMinute, quietHoursEndMinute: $quietHoursEndMinute, timezone: $timezone)';
}


}

/// @nodoc
abstract mixin class _$NotificationPreferencesCopyWith<$Res> implements $NotificationPreferencesCopyWith<$Res> {
  factory _$NotificationPreferencesCopyWith(_NotificationPreferences value, $Res Function(_NotificationPreferences) _then) = __$NotificationPreferencesCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'enable_chat_messages') bool enableChatMessages,@JsonKey(name: 'enable_follow_follback') bool enableFollowFollback,@JsonKey(name: 'enable_thread_replies') bool enableThreadReplies,@JsonKey(name: 'enable_likes_and_recipe_tries') bool enableLikesAndRecipeTries,@JsonKey(name: 'enable_live_brew_and_streak') bool enableLiveBrewAndStreak,@JsonKey(name: 'enable_transactional_billing') bool enableTransactionalBilling,@JsonKey(name: 'quiet_hours_start_minute') int? quietHoursStartMinute,@JsonKey(name: 'quiet_hours_end_minute') int? quietHoursEndMinute, String timezone
});




}
/// @nodoc
class __$NotificationPreferencesCopyWithImpl<$Res>
    implements _$NotificationPreferencesCopyWith<$Res> {
  __$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final _NotificationPreferences _self;
  final $Res Function(_NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enableChatMessages = null,Object? enableFollowFollback = null,Object? enableThreadReplies = null,Object? enableLikesAndRecipeTries = null,Object? enableLiveBrewAndStreak = null,Object? enableTransactionalBilling = null,Object? quietHoursStartMinute = freezed,Object? quietHoursEndMinute = freezed,Object? timezone = null,}) {
  return _then(_NotificationPreferences(
enableChatMessages: null == enableChatMessages ? _self.enableChatMessages : enableChatMessages // ignore: cast_nullable_to_non_nullable
as bool,enableFollowFollback: null == enableFollowFollback ? _self.enableFollowFollback : enableFollowFollback // ignore: cast_nullable_to_non_nullable
as bool,enableThreadReplies: null == enableThreadReplies ? _self.enableThreadReplies : enableThreadReplies // ignore: cast_nullable_to_non_nullable
as bool,enableLikesAndRecipeTries: null == enableLikesAndRecipeTries ? _self.enableLikesAndRecipeTries : enableLikesAndRecipeTries // ignore: cast_nullable_to_non_nullable
as bool,enableLiveBrewAndStreak: null == enableLiveBrewAndStreak ? _self.enableLiveBrewAndStreak : enableLiveBrewAndStreak // ignore: cast_nullable_to_non_nullable
as bool,enableTransactionalBilling: null == enableTransactionalBilling ? _self.enableTransactionalBilling : enableTransactionalBilling // ignore: cast_nullable_to_non_nullable
as bool,quietHoursStartMinute: freezed == quietHoursStartMinute ? _self.quietHoursStartMinute : quietHoursStartMinute // ignore: cast_nullable_to_non_nullable
as int?,quietHoursEndMinute: freezed == quietHoursEndMinute ? _self.quietHoursEndMinute : quietHoursEndMinute // ignore: cast_nullable_to_non_nullable
as int?,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
