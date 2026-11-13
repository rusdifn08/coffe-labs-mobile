// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_graph_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MiniUserAvatar {

@JsonKey(name: 'user_id') String get userId; String get username;@JsonKey(name: 'display_name') String get displayName;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'barista_rank_title') String get baristaRankTitle;
/// Create a copy of MiniUserAvatar
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MiniUserAvatarCopyWith<MiniUserAvatar> get copyWith => _$MiniUserAvatarCopyWithImpl<MiniUserAvatar>(this as MiniUserAvatar, _$identity);

  /// Serializes this MiniUserAvatar to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MiniUserAvatar&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.baristaRankTitle, baristaRankTitle) || other.baristaRankTitle == baristaRankTitle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl,baristaRankTitle);

@override
String toString() {
  return 'MiniUserAvatar(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, baristaRankTitle: $baristaRankTitle)';
}


}

/// @nodoc
abstract mixin class $MiniUserAvatarCopyWith<$Res>  {
  factory $MiniUserAvatarCopyWith(MiniUserAvatar value, $Res Function(MiniUserAvatar) _then) = _$MiniUserAvatarCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String username,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'barista_rank_title') String baristaRankTitle
});




}
/// @nodoc
class _$MiniUserAvatarCopyWithImpl<$Res>
    implements $MiniUserAvatarCopyWith<$Res> {
  _$MiniUserAvatarCopyWithImpl(this._self, this._then);

  final MiniUserAvatar _self;
  final $Res Function(MiniUserAvatar) _then;

/// Create a copy of MiniUserAvatar
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = freezed,Object? baristaRankTitle = null,}) {
  return _then(MiniUserAvatar(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,baristaRankTitle: null == baristaRankTitle ? _self.baristaRankTitle : baristaRankTitle // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MiniUserAvatar].
extension MiniUserAvatarPatterns on MiniUserAvatar {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MiniUserAvatar value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MiniUserAvatar() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MiniUserAvatar value)  $default,){
final _that = this;
switch (_that) {
case _MiniUserAvatar():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MiniUserAvatar value)?  $default,){
final _that = this;
switch (_that) {
case _MiniUserAvatar() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'barista_rank_title')  String baristaRankTitle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MiniUserAvatar() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.baristaRankTitle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'barista_rank_title')  String baristaRankTitle)  $default,) {final _that = this;
switch (_that) {
case _MiniUserAvatar():
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.baristaRankTitle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'barista_rank_title')  String baristaRankTitle)?  $default,) {final _that = this;
switch (_that) {
case _MiniUserAvatar() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.baristaRankTitle);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MiniUserAvatar implements MiniUserAvatar {
  const _MiniUserAvatar({@JsonKey(name: 'user_id') required this.userId, required this.username, @JsonKey(name: 'display_name') required this.displayName, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'barista_rank_title') this.baristaRankTitle = 'Home Brewer'});
  factory _MiniUserAvatar.fromJson(Map<String, dynamic> json) => _$MiniUserAvatarFromJson(json);

@override@JsonKey(name: 'user_id') final  String userId;
@override final  String username;
@override@JsonKey(name: 'display_name') final  String displayName;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'barista_rank_title') final  String baristaRankTitle;

/// Create a copy of MiniUserAvatar
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MiniUserAvatarCopyWith<_MiniUserAvatar> get copyWith => __$MiniUserAvatarCopyWithImpl<_MiniUserAvatar>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MiniUserAvatarToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MiniUserAvatar&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.baristaRankTitle, baristaRankTitle) || other.baristaRankTitle == baristaRankTitle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl,baristaRankTitle);

@override
String toString() {
  return 'MiniUserAvatar(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, baristaRankTitle: $baristaRankTitle)';
}


}

/// @nodoc
abstract mixin class _$MiniUserAvatarCopyWith<$Res> implements $MiniUserAvatarCopyWith<$Res> {
  factory _$MiniUserAvatarCopyWith(_MiniUserAvatar value, $Res Function(_MiniUserAvatar) _then) = __$MiniUserAvatarCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String username,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'barista_rank_title') String baristaRankTitle
});




}
/// @nodoc
class __$MiniUserAvatarCopyWithImpl<$Res>
    implements _$MiniUserAvatarCopyWith<$Res> {
  __$MiniUserAvatarCopyWithImpl(this._self, this._then);

  final _MiniUserAvatar _self;
  final $Res Function(_MiniUserAvatar) _then;

/// Create a copy of MiniUserAvatar
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = freezed,Object? baristaRankTitle = null,}) {
  return _then(_MiniUserAvatar(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,baristaRankTitle: null == baristaRankTitle ? _self.baristaRankTitle : baristaRankTitle // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RelationshipSnapshot {

@JsonKey(name: 'target_user_id') String get targetUserId; RelationshipState get state;@JsonKey(name: 'is_mutual') bool get isMutual;@JsonKey(name: 'is_followed_by_target') bool get isFollowedByTarget;@JsonKey(name: 'has_pending_incoming_request') bool get hasPendingIncomingRequest;@JsonKey(name: 'target_is_private') bool get targetIsPrivate;@JsonKey(name: 'mutual_followers_count') int get mutualFollowersCount;@JsonKey(name: 'mutual_avatars') List<MiniUserAvatar> get mutualAvatars;@JsonKey(name: 'followers_count') int get followersCount;@JsonKey(name: 'following_count') int get followingCount;
/// Create a copy of RelationshipSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RelationshipSnapshotCopyWith<RelationshipSnapshot> get copyWith => _$RelationshipSnapshotCopyWithImpl<RelationshipSnapshot>(this as RelationshipSnapshot, _$identity);

  /// Serializes this RelationshipSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RelationshipSnapshot&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.state, state) || other.state == state)&&(identical(other.isMutual, isMutual) || other.isMutual == isMutual)&&(identical(other.isFollowedByTarget, isFollowedByTarget) || other.isFollowedByTarget == isFollowedByTarget)&&(identical(other.hasPendingIncomingRequest, hasPendingIncomingRequest) || other.hasPendingIncomingRequest == hasPendingIncomingRequest)&&(identical(other.targetIsPrivate, targetIsPrivate) || other.targetIsPrivate == targetIsPrivate)&&(identical(other.mutualFollowersCount, mutualFollowersCount) || other.mutualFollowersCount == mutualFollowersCount)&&const DeepCollectionEquality().equals(other.mutualAvatars, mutualAvatars)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,targetUserId,state,isMutual,isFollowedByTarget,hasPendingIncomingRequest,targetIsPrivate,mutualFollowersCount,const DeepCollectionEquality().hash(mutualAvatars),followersCount,followingCount);

@override
String toString() {
  return 'RelationshipSnapshot(targetUserId: $targetUserId, state: $state, isMutual: $isMutual, isFollowedByTarget: $isFollowedByTarget, hasPendingIncomingRequest: $hasPendingIncomingRequest, targetIsPrivate: $targetIsPrivate, mutualFollowersCount: $mutualFollowersCount, mutualAvatars: $mutualAvatars, followersCount: $followersCount, followingCount: $followingCount)';
}


}

/// @nodoc
abstract mixin class $RelationshipSnapshotCopyWith<$Res>  {
  factory $RelationshipSnapshotCopyWith(RelationshipSnapshot value, $Res Function(RelationshipSnapshot) _then) = _$RelationshipSnapshotCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'target_user_id') String targetUserId, RelationshipState state,@JsonKey(name: 'is_mutual') bool isMutual,@JsonKey(name: 'is_followed_by_target') bool isFollowedByTarget,@JsonKey(name: 'has_pending_incoming_request') bool hasPendingIncomingRequest,@JsonKey(name: 'target_is_private') bool targetIsPrivate,@JsonKey(name: 'mutual_followers_count') int mutualFollowersCount,@JsonKey(name: 'mutual_avatars') List<MiniUserAvatar> mutualAvatars,@JsonKey(name: 'followers_count') int followersCount,@JsonKey(name: 'following_count') int followingCount
});




}
/// @nodoc
class _$RelationshipSnapshotCopyWithImpl<$Res>
    implements $RelationshipSnapshotCopyWith<$Res> {
  _$RelationshipSnapshotCopyWithImpl(this._self, this._then);

  final RelationshipSnapshot _self;
  final $Res Function(RelationshipSnapshot) _then;

/// Create a copy of RelationshipSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targetUserId = null,Object? state = null,Object? isMutual = null,Object? isFollowedByTarget = null,Object? hasPendingIncomingRequest = null,Object? targetIsPrivate = null,Object? mutualFollowersCount = null,Object? mutualAvatars = null,Object? followersCount = null,Object? followingCount = null,}) {
  return _then(RelationshipSnapshot(
targetUserId: null == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RelationshipState,isMutual: null == isMutual ? _self.isMutual : isMutual // ignore: cast_nullable_to_non_nullable
as bool,isFollowedByTarget: null == isFollowedByTarget ? _self.isFollowedByTarget : isFollowedByTarget // ignore: cast_nullable_to_non_nullable
as bool,hasPendingIncomingRequest: null == hasPendingIncomingRequest ? _self.hasPendingIncomingRequest : hasPendingIncomingRequest // ignore: cast_nullable_to_non_nullable
as bool,targetIsPrivate: null == targetIsPrivate ? _self.targetIsPrivate : targetIsPrivate // ignore: cast_nullable_to_non_nullable
as bool,mutualFollowersCount: null == mutualFollowersCount ? _self.mutualFollowersCount : mutualFollowersCount // ignore: cast_nullable_to_non_nullable
as int,mutualAvatars: null == mutualAvatars ? _self.mutualAvatars : mutualAvatars // ignore: cast_nullable_to_non_nullable
as List<MiniUserAvatar>,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RelationshipSnapshot].
extension RelationshipSnapshotPatterns on RelationshipSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RelationshipSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RelationshipSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RelationshipSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _RelationshipSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RelationshipSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _RelationshipSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'target_user_id')  String targetUserId,  RelationshipState state, @JsonKey(name: 'is_mutual')  bool isMutual, @JsonKey(name: 'is_followed_by_target')  bool isFollowedByTarget, @JsonKey(name: 'has_pending_incoming_request')  bool hasPendingIncomingRequest, @JsonKey(name: 'target_is_private')  bool targetIsPrivate, @JsonKey(name: 'mutual_followers_count')  int mutualFollowersCount, @JsonKey(name: 'mutual_avatars')  List<MiniUserAvatar> mutualAvatars, @JsonKey(name: 'followers_count')  int followersCount, @JsonKey(name: 'following_count')  int followingCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RelationshipSnapshot() when $default != null:
return $default(_that.targetUserId,_that.state,_that.isMutual,_that.isFollowedByTarget,_that.hasPendingIncomingRequest,_that.targetIsPrivate,_that.mutualFollowersCount,_that.mutualAvatars,_that.followersCount,_that.followingCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'target_user_id')  String targetUserId,  RelationshipState state, @JsonKey(name: 'is_mutual')  bool isMutual, @JsonKey(name: 'is_followed_by_target')  bool isFollowedByTarget, @JsonKey(name: 'has_pending_incoming_request')  bool hasPendingIncomingRequest, @JsonKey(name: 'target_is_private')  bool targetIsPrivate, @JsonKey(name: 'mutual_followers_count')  int mutualFollowersCount, @JsonKey(name: 'mutual_avatars')  List<MiniUserAvatar> mutualAvatars, @JsonKey(name: 'followers_count')  int followersCount, @JsonKey(name: 'following_count')  int followingCount)  $default,) {final _that = this;
switch (_that) {
case _RelationshipSnapshot():
return $default(_that.targetUserId,_that.state,_that.isMutual,_that.isFollowedByTarget,_that.hasPendingIncomingRequest,_that.targetIsPrivate,_that.mutualFollowersCount,_that.mutualAvatars,_that.followersCount,_that.followingCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'target_user_id')  String targetUserId,  RelationshipState state, @JsonKey(name: 'is_mutual')  bool isMutual, @JsonKey(name: 'is_followed_by_target')  bool isFollowedByTarget, @JsonKey(name: 'has_pending_incoming_request')  bool hasPendingIncomingRequest, @JsonKey(name: 'target_is_private')  bool targetIsPrivate, @JsonKey(name: 'mutual_followers_count')  int mutualFollowersCount, @JsonKey(name: 'mutual_avatars')  List<MiniUserAvatar> mutualAvatars, @JsonKey(name: 'followers_count')  int followersCount, @JsonKey(name: 'following_count')  int followingCount)?  $default,) {final _that = this;
switch (_that) {
case _RelationshipSnapshot() when $default != null:
return $default(_that.targetUserId,_that.state,_that.isMutual,_that.isFollowedByTarget,_that.hasPendingIncomingRequest,_that.targetIsPrivate,_that.mutualFollowersCount,_that.mutualAvatars,_that.followersCount,_that.followingCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RelationshipSnapshot extends RelationshipSnapshot {
  const _RelationshipSnapshot({@JsonKey(name: 'target_user_id') required this.targetUserId, this.state = RelationshipState.none, @JsonKey(name: 'is_mutual') this.isMutual = false, @JsonKey(name: 'is_followed_by_target') this.isFollowedByTarget = false, @JsonKey(name: 'has_pending_incoming_request') this.hasPendingIncomingRequest = false, @JsonKey(name: 'target_is_private') this.targetIsPrivate = false, @JsonKey(name: 'mutual_followers_count') this.mutualFollowersCount = 0, @JsonKey(name: 'mutual_avatars')  List<MiniUserAvatar> mutualAvatars = const [], @JsonKey(name: 'followers_count') this.followersCount = 0, @JsonKey(name: 'following_count') this.followingCount = 0}): _mutualAvatars = mutualAvatars,super._();
  factory _RelationshipSnapshot.fromJson(Map<String, dynamic> json) => _$RelationshipSnapshotFromJson(json);

@override@JsonKey(name: 'target_user_id') final  String targetUserId;
@override@JsonKey() final  RelationshipState state;
@override@JsonKey(name: 'is_mutual') final  bool isMutual;
@override@JsonKey(name: 'is_followed_by_target') final  bool isFollowedByTarget;
@override@JsonKey(name: 'has_pending_incoming_request') final  bool hasPendingIncomingRequest;
@override@JsonKey(name: 'target_is_private') final  bool targetIsPrivate;
@override@JsonKey(name: 'mutual_followers_count') final  int mutualFollowersCount;
 final  List<MiniUserAvatar> _mutualAvatars;
@override@JsonKey(name: 'mutual_avatars') List<MiniUserAvatar> get mutualAvatars {
  if (_mutualAvatars is EqualUnmodifiableListView) return _mutualAvatars;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mutualAvatars);
}

@override@JsonKey(name: 'followers_count') final  int followersCount;
@override@JsonKey(name: 'following_count') final  int followingCount;

/// Create a copy of RelationshipSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RelationshipSnapshotCopyWith<_RelationshipSnapshot> get copyWith => __$RelationshipSnapshotCopyWithImpl<_RelationshipSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RelationshipSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RelationshipSnapshot&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.state, state) || other.state == state)&&(identical(other.isMutual, isMutual) || other.isMutual == isMutual)&&(identical(other.isFollowedByTarget, isFollowedByTarget) || other.isFollowedByTarget == isFollowedByTarget)&&(identical(other.hasPendingIncomingRequest, hasPendingIncomingRequest) || other.hasPendingIncomingRequest == hasPendingIncomingRequest)&&(identical(other.targetIsPrivate, targetIsPrivate) || other.targetIsPrivate == targetIsPrivate)&&(identical(other.mutualFollowersCount, mutualFollowersCount) || other.mutualFollowersCount == mutualFollowersCount)&&const DeepCollectionEquality().equals(other._mutualAvatars, _mutualAvatars)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,targetUserId,state,isMutual,isFollowedByTarget,hasPendingIncomingRequest,targetIsPrivate,mutualFollowersCount,const DeepCollectionEquality().hash(_mutualAvatars),followersCount,followingCount);

@override
String toString() {
  return 'RelationshipSnapshot(targetUserId: $targetUserId, state: $state, isMutual: $isMutual, isFollowedByTarget: $isFollowedByTarget, hasPendingIncomingRequest: $hasPendingIncomingRequest, targetIsPrivate: $targetIsPrivate, mutualFollowersCount: $mutualFollowersCount, mutualAvatars: $mutualAvatars, followersCount: $followersCount, followingCount: $followingCount)';
}


}

/// @nodoc
abstract mixin class _$RelationshipSnapshotCopyWith<$Res> implements $RelationshipSnapshotCopyWith<$Res> {
  factory _$RelationshipSnapshotCopyWith(_RelationshipSnapshot value, $Res Function(_RelationshipSnapshot) _then) = __$RelationshipSnapshotCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'target_user_id') String targetUserId, RelationshipState state,@JsonKey(name: 'is_mutual') bool isMutual,@JsonKey(name: 'is_followed_by_target') bool isFollowedByTarget,@JsonKey(name: 'has_pending_incoming_request') bool hasPendingIncomingRequest,@JsonKey(name: 'target_is_private') bool targetIsPrivate,@JsonKey(name: 'mutual_followers_count') int mutualFollowersCount,@JsonKey(name: 'mutual_avatars') List<MiniUserAvatar> mutualAvatars,@JsonKey(name: 'followers_count') int followersCount,@JsonKey(name: 'following_count') int followingCount
});




}
/// @nodoc
class __$RelationshipSnapshotCopyWithImpl<$Res>
    implements _$RelationshipSnapshotCopyWith<$Res> {
  __$RelationshipSnapshotCopyWithImpl(this._self, this._then);

  final _RelationshipSnapshot _self;
  final $Res Function(_RelationshipSnapshot) _then;

/// Create a copy of RelationshipSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetUserId = null,Object? state = null,Object? isMutual = null,Object? isFollowedByTarget = null,Object? hasPendingIncomingRequest = null,Object? targetIsPrivate = null,Object? mutualFollowersCount = null,Object? mutualAvatars = null,Object? followersCount = null,Object? followingCount = null,}) {
  return _then(_RelationshipSnapshot(
targetUserId: null == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RelationshipState,isMutual: null == isMutual ? _self.isMutual : isMutual // ignore: cast_nullable_to_non_nullable
as bool,isFollowedByTarget: null == isFollowedByTarget ? _self.isFollowedByTarget : isFollowedByTarget // ignore: cast_nullable_to_non_nullable
as bool,hasPendingIncomingRequest: null == hasPendingIncomingRequest ? _self.hasPendingIncomingRequest : hasPendingIncomingRequest // ignore: cast_nullable_to_non_nullable
as bool,targetIsPrivate: null == targetIsPrivate ? _self.targetIsPrivate : targetIsPrivate // ignore: cast_nullable_to_non_nullable
as bool,mutualFollowersCount: null == mutualFollowersCount ? _self.mutualFollowersCount : mutualFollowersCount // ignore: cast_nullable_to_non_nullable
as int,mutualAvatars: null == mutualAvatars ? _self._mutualAvatars : mutualAvatars // ignore: cast_nullable_to_non_nullable
as List<MiniUserAvatar>,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$FollowMutationResult {

@JsonKey(name: 'target_user_id') String get targetUserId; RelationshipState get state; String get status;@JsonKey(name: 'is_idempotent_replay') bool get isIdempotentReplay;@JsonKey(name: 'target_followers_count') int get targetFollowersCount;@JsonKey(name: 'target_following_count') int get targetFollowingCount;@JsonKey(name: 'actor_following_count') int get actorFollowingCount;@JsonKey(name: 'mutual_followers_count') int get mutualFollowersCount;
/// Create a copy of FollowMutationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowMutationResultCopyWith<FollowMutationResult> get copyWith => _$FollowMutationResultCopyWithImpl<FollowMutationResult>(this as FollowMutationResult, _$identity);

  /// Serializes this FollowMutationResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowMutationResult&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.state, state) || other.state == state)&&(identical(other.status, status) || other.status == status)&&(identical(other.isIdempotentReplay, isIdempotentReplay) || other.isIdempotentReplay == isIdempotentReplay)&&(identical(other.targetFollowersCount, targetFollowersCount) || other.targetFollowersCount == targetFollowersCount)&&(identical(other.targetFollowingCount, targetFollowingCount) || other.targetFollowingCount == targetFollowingCount)&&(identical(other.actorFollowingCount, actorFollowingCount) || other.actorFollowingCount == actorFollowingCount)&&(identical(other.mutualFollowersCount, mutualFollowersCount) || other.mutualFollowersCount == mutualFollowersCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,targetUserId,state,status,isIdempotentReplay,targetFollowersCount,targetFollowingCount,actorFollowingCount,mutualFollowersCount);

@override
String toString() {
  return 'FollowMutationResult(targetUserId: $targetUserId, state: $state, status: $status, isIdempotentReplay: $isIdempotentReplay, targetFollowersCount: $targetFollowersCount, targetFollowingCount: $targetFollowingCount, actorFollowingCount: $actorFollowingCount, mutualFollowersCount: $mutualFollowersCount)';
}


}

/// @nodoc
abstract mixin class $FollowMutationResultCopyWith<$Res>  {
  factory $FollowMutationResultCopyWith(FollowMutationResult value, $Res Function(FollowMutationResult) _then) = _$FollowMutationResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'target_user_id') String targetUserId, RelationshipState state, String status,@JsonKey(name: 'is_idempotent_replay') bool isIdempotentReplay,@JsonKey(name: 'target_followers_count') int targetFollowersCount,@JsonKey(name: 'target_following_count') int targetFollowingCount,@JsonKey(name: 'actor_following_count') int actorFollowingCount,@JsonKey(name: 'mutual_followers_count') int mutualFollowersCount
});




}
/// @nodoc
class _$FollowMutationResultCopyWithImpl<$Res>
    implements $FollowMutationResultCopyWith<$Res> {
  _$FollowMutationResultCopyWithImpl(this._self, this._then);

  final FollowMutationResult _self;
  final $Res Function(FollowMutationResult) _then;

/// Create a copy of FollowMutationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targetUserId = null,Object? state = null,Object? status = null,Object? isIdempotentReplay = null,Object? targetFollowersCount = null,Object? targetFollowingCount = null,Object? actorFollowingCount = null,Object? mutualFollowersCount = null,}) {
  return _then(FollowMutationResult(
targetUserId: null == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RelationshipState,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isIdempotentReplay: null == isIdempotentReplay ? _self.isIdempotentReplay : isIdempotentReplay // ignore: cast_nullable_to_non_nullable
as bool,targetFollowersCount: null == targetFollowersCount ? _self.targetFollowersCount : targetFollowersCount // ignore: cast_nullable_to_non_nullable
as int,targetFollowingCount: null == targetFollowingCount ? _self.targetFollowingCount : targetFollowingCount // ignore: cast_nullable_to_non_nullable
as int,actorFollowingCount: null == actorFollowingCount ? _self.actorFollowingCount : actorFollowingCount // ignore: cast_nullable_to_non_nullable
as int,mutualFollowersCount: null == mutualFollowersCount ? _self.mutualFollowersCount : mutualFollowersCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowMutationResult].
extension FollowMutationResultPatterns on FollowMutationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowMutationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowMutationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowMutationResult value)  $default,){
final _that = this;
switch (_that) {
case _FollowMutationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowMutationResult value)?  $default,){
final _that = this;
switch (_that) {
case _FollowMutationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'target_user_id')  String targetUserId,  RelationshipState state,  String status, @JsonKey(name: 'is_idempotent_replay')  bool isIdempotentReplay, @JsonKey(name: 'target_followers_count')  int targetFollowersCount, @JsonKey(name: 'target_following_count')  int targetFollowingCount, @JsonKey(name: 'actor_following_count')  int actorFollowingCount, @JsonKey(name: 'mutual_followers_count')  int mutualFollowersCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowMutationResult() when $default != null:
return $default(_that.targetUserId,_that.state,_that.status,_that.isIdempotentReplay,_that.targetFollowersCount,_that.targetFollowingCount,_that.actorFollowingCount,_that.mutualFollowersCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'target_user_id')  String targetUserId,  RelationshipState state,  String status, @JsonKey(name: 'is_idempotent_replay')  bool isIdempotentReplay, @JsonKey(name: 'target_followers_count')  int targetFollowersCount, @JsonKey(name: 'target_following_count')  int targetFollowingCount, @JsonKey(name: 'actor_following_count')  int actorFollowingCount, @JsonKey(name: 'mutual_followers_count')  int mutualFollowersCount)  $default,) {final _that = this;
switch (_that) {
case _FollowMutationResult():
return $default(_that.targetUserId,_that.state,_that.status,_that.isIdempotentReplay,_that.targetFollowersCount,_that.targetFollowingCount,_that.actorFollowingCount,_that.mutualFollowersCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'target_user_id')  String targetUserId,  RelationshipState state,  String status, @JsonKey(name: 'is_idempotent_replay')  bool isIdempotentReplay, @JsonKey(name: 'target_followers_count')  int targetFollowersCount, @JsonKey(name: 'target_following_count')  int targetFollowingCount, @JsonKey(name: 'actor_following_count')  int actorFollowingCount, @JsonKey(name: 'mutual_followers_count')  int mutualFollowersCount)?  $default,) {final _that = this;
switch (_that) {
case _FollowMutationResult() when $default != null:
return $default(_that.targetUserId,_that.state,_that.status,_that.isIdempotentReplay,_that.targetFollowersCount,_that.targetFollowingCount,_that.actorFollowingCount,_that.mutualFollowersCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FollowMutationResult implements FollowMutationResult {
  const _FollowMutationResult({@JsonKey(name: 'target_user_id') required this.targetUserId, required this.state, required this.status, @JsonKey(name: 'is_idempotent_replay') this.isIdempotentReplay = false, @JsonKey(name: 'target_followers_count') this.targetFollowersCount = 0, @JsonKey(name: 'target_following_count') this.targetFollowingCount = 0, @JsonKey(name: 'actor_following_count') this.actorFollowingCount = 0, @JsonKey(name: 'mutual_followers_count') this.mutualFollowersCount = 0});
  factory _FollowMutationResult.fromJson(Map<String, dynamic> json) => _$FollowMutationResultFromJson(json);

@override@JsonKey(name: 'target_user_id') final  String targetUserId;
@override final  RelationshipState state;
@override final  String status;
@override@JsonKey(name: 'is_idempotent_replay') final  bool isIdempotentReplay;
@override@JsonKey(name: 'target_followers_count') final  int targetFollowersCount;
@override@JsonKey(name: 'target_following_count') final  int targetFollowingCount;
@override@JsonKey(name: 'actor_following_count') final  int actorFollowingCount;
@override@JsonKey(name: 'mutual_followers_count') final  int mutualFollowersCount;

/// Create a copy of FollowMutationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowMutationResultCopyWith<_FollowMutationResult> get copyWith => __$FollowMutationResultCopyWithImpl<_FollowMutationResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowMutationResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowMutationResult&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.state, state) || other.state == state)&&(identical(other.status, status) || other.status == status)&&(identical(other.isIdempotentReplay, isIdempotentReplay) || other.isIdempotentReplay == isIdempotentReplay)&&(identical(other.targetFollowersCount, targetFollowersCount) || other.targetFollowersCount == targetFollowersCount)&&(identical(other.targetFollowingCount, targetFollowingCount) || other.targetFollowingCount == targetFollowingCount)&&(identical(other.actorFollowingCount, actorFollowingCount) || other.actorFollowingCount == actorFollowingCount)&&(identical(other.mutualFollowersCount, mutualFollowersCount) || other.mutualFollowersCount == mutualFollowersCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,targetUserId,state,status,isIdempotentReplay,targetFollowersCount,targetFollowingCount,actorFollowingCount,mutualFollowersCount);

@override
String toString() {
  return 'FollowMutationResult(targetUserId: $targetUserId, state: $state, status: $status, isIdempotentReplay: $isIdempotentReplay, targetFollowersCount: $targetFollowersCount, targetFollowingCount: $targetFollowingCount, actorFollowingCount: $actorFollowingCount, mutualFollowersCount: $mutualFollowersCount)';
}


}

/// @nodoc
abstract mixin class _$FollowMutationResultCopyWith<$Res> implements $FollowMutationResultCopyWith<$Res> {
  factory _$FollowMutationResultCopyWith(_FollowMutationResult value, $Res Function(_FollowMutationResult) _then) = __$FollowMutationResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'target_user_id') String targetUserId, RelationshipState state, String status,@JsonKey(name: 'is_idempotent_replay') bool isIdempotentReplay,@JsonKey(name: 'target_followers_count') int targetFollowersCount,@JsonKey(name: 'target_following_count') int targetFollowingCount,@JsonKey(name: 'actor_following_count') int actorFollowingCount,@JsonKey(name: 'mutual_followers_count') int mutualFollowersCount
});




}
/// @nodoc
class __$FollowMutationResultCopyWithImpl<$Res>
    implements _$FollowMutationResultCopyWith<$Res> {
  __$FollowMutationResultCopyWithImpl(this._self, this._then);

  final _FollowMutationResult _self;
  final $Res Function(_FollowMutationResult) _then;

/// Create a copy of FollowMutationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetUserId = null,Object? state = null,Object? status = null,Object? isIdempotentReplay = null,Object? targetFollowersCount = null,Object? targetFollowingCount = null,Object? actorFollowingCount = null,Object? mutualFollowersCount = null,}) {
  return _then(_FollowMutationResult(
targetUserId: null == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RelationshipState,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isIdempotentReplay: null == isIdempotentReplay ? _self.isIdempotentReplay : isIdempotentReplay // ignore: cast_nullable_to_non_nullable
as bool,targetFollowersCount: null == targetFollowersCount ? _self.targetFollowersCount : targetFollowersCount // ignore: cast_nullable_to_non_nullable
as int,targetFollowingCount: null == targetFollowingCount ? _self.targetFollowingCount : targetFollowingCount // ignore: cast_nullable_to_non_nullable
as int,actorFollowingCount: null == actorFollowingCount ? _self.actorFollowingCount : actorFollowingCount // ignore: cast_nullable_to_non_nullable
as int,mutualFollowersCount: null == mutualFollowersCount ? _self.mutualFollowersCount : mutualFollowersCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$BatchRelationshipItem {

@JsonKey(name: 'target_user_id') String get targetUserId; RelationshipState get state;@JsonKey(name: 'is_mutual') bool get isMutual;@JsonKey(name: 'is_followed_by_target') bool get isFollowedByTarget;
/// Create a copy of BatchRelationshipItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchRelationshipItemCopyWith<BatchRelationshipItem> get copyWith => _$BatchRelationshipItemCopyWithImpl<BatchRelationshipItem>(this as BatchRelationshipItem, _$identity);

  /// Serializes this BatchRelationshipItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatchRelationshipItem&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.state, state) || other.state == state)&&(identical(other.isMutual, isMutual) || other.isMutual == isMutual)&&(identical(other.isFollowedByTarget, isFollowedByTarget) || other.isFollowedByTarget == isFollowedByTarget));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,targetUserId,state,isMutual,isFollowedByTarget);

@override
String toString() {
  return 'BatchRelationshipItem(targetUserId: $targetUserId, state: $state, isMutual: $isMutual, isFollowedByTarget: $isFollowedByTarget)';
}


}

/// @nodoc
abstract mixin class $BatchRelationshipItemCopyWith<$Res>  {
  factory $BatchRelationshipItemCopyWith(BatchRelationshipItem value, $Res Function(BatchRelationshipItem) _then) = _$BatchRelationshipItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'target_user_id') String targetUserId, RelationshipState state,@JsonKey(name: 'is_mutual') bool isMutual,@JsonKey(name: 'is_followed_by_target') bool isFollowedByTarget
});




}
/// @nodoc
class _$BatchRelationshipItemCopyWithImpl<$Res>
    implements $BatchRelationshipItemCopyWith<$Res> {
  _$BatchRelationshipItemCopyWithImpl(this._self, this._then);

  final BatchRelationshipItem _self;
  final $Res Function(BatchRelationshipItem) _then;

/// Create a copy of BatchRelationshipItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targetUserId = null,Object? state = null,Object? isMutual = null,Object? isFollowedByTarget = null,}) {
  return _then(BatchRelationshipItem(
targetUserId: null == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RelationshipState,isMutual: null == isMutual ? _self.isMutual : isMutual // ignore: cast_nullable_to_non_nullable
as bool,isFollowedByTarget: null == isFollowedByTarget ? _self.isFollowedByTarget : isFollowedByTarget // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BatchRelationshipItem].
extension BatchRelationshipItemPatterns on BatchRelationshipItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BatchRelationshipItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BatchRelationshipItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BatchRelationshipItem value)  $default,){
final _that = this;
switch (_that) {
case _BatchRelationshipItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BatchRelationshipItem value)?  $default,){
final _that = this;
switch (_that) {
case _BatchRelationshipItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'target_user_id')  String targetUserId,  RelationshipState state, @JsonKey(name: 'is_mutual')  bool isMutual, @JsonKey(name: 'is_followed_by_target')  bool isFollowedByTarget)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BatchRelationshipItem() when $default != null:
return $default(_that.targetUserId,_that.state,_that.isMutual,_that.isFollowedByTarget);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'target_user_id')  String targetUserId,  RelationshipState state, @JsonKey(name: 'is_mutual')  bool isMutual, @JsonKey(name: 'is_followed_by_target')  bool isFollowedByTarget)  $default,) {final _that = this;
switch (_that) {
case _BatchRelationshipItem():
return $default(_that.targetUserId,_that.state,_that.isMutual,_that.isFollowedByTarget);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'target_user_id')  String targetUserId,  RelationshipState state, @JsonKey(name: 'is_mutual')  bool isMutual, @JsonKey(name: 'is_followed_by_target')  bool isFollowedByTarget)?  $default,) {final _that = this;
switch (_that) {
case _BatchRelationshipItem() when $default != null:
return $default(_that.targetUserId,_that.state,_that.isMutual,_that.isFollowedByTarget);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BatchRelationshipItem implements BatchRelationshipItem {
  const _BatchRelationshipItem({@JsonKey(name: 'target_user_id') required this.targetUserId, required this.state, @JsonKey(name: 'is_mutual') this.isMutual = false, @JsonKey(name: 'is_followed_by_target') this.isFollowedByTarget = false});
  factory _BatchRelationshipItem.fromJson(Map<String, dynamic> json) => _$BatchRelationshipItemFromJson(json);

@override@JsonKey(name: 'target_user_id') final  String targetUserId;
@override final  RelationshipState state;
@override@JsonKey(name: 'is_mutual') final  bool isMutual;
@override@JsonKey(name: 'is_followed_by_target') final  bool isFollowedByTarget;

/// Create a copy of BatchRelationshipItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchRelationshipItemCopyWith<_BatchRelationshipItem> get copyWith => __$BatchRelationshipItemCopyWithImpl<_BatchRelationshipItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatchRelationshipItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatchRelationshipItem&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.state, state) || other.state == state)&&(identical(other.isMutual, isMutual) || other.isMutual == isMutual)&&(identical(other.isFollowedByTarget, isFollowedByTarget) || other.isFollowedByTarget == isFollowedByTarget));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,targetUserId,state,isMutual,isFollowedByTarget);

@override
String toString() {
  return 'BatchRelationshipItem(targetUserId: $targetUserId, state: $state, isMutual: $isMutual, isFollowedByTarget: $isFollowedByTarget)';
}


}

/// @nodoc
abstract mixin class _$BatchRelationshipItemCopyWith<$Res> implements $BatchRelationshipItemCopyWith<$Res> {
  factory _$BatchRelationshipItemCopyWith(_BatchRelationshipItem value, $Res Function(_BatchRelationshipItem) _then) = __$BatchRelationshipItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'target_user_id') String targetUserId, RelationshipState state,@JsonKey(name: 'is_mutual') bool isMutual,@JsonKey(name: 'is_followed_by_target') bool isFollowedByTarget
});




}
/// @nodoc
class __$BatchRelationshipItemCopyWithImpl<$Res>
    implements _$BatchRelationshipItemCopyWith<$Res> {
  __$BatchRelationshipItemCopyWithImpl(this._self, this._then);

  final _BatchRelationshipItem _self;
  final $Res Function(_BatchRelationshipItem) _then;

/// Create a copy of BatchRelationshipItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetUserId = null,Object? state = null,Object? isMutual = null,Object? isFollowedByTarget = null,}) {
  return _then(_BatchRelationshipItem(
targetUserId: null == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RelationshipState,isMutual: null == isMutual ? _self.isMutual : isMutual // ignore: cast_nullable_to_non_nullable
as bool,isFollowedByTarget: null == isFollowedByTarget ? _self.isFollowedByTarget : isFollowedByTarget // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SocialGraphUserItem {

@JsonKey(name: 'user_id') String get userId; String get username;@JsonKey(name: 'display_name') String get displayName;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'barista_level') int get baristaLevel;@JsonKey(name: 'barista_rank_title') String get baristaRankTitle;@JsonKey(name: 'account_tier') String get accountTier;@JsonKey(name: 'is_private_account') bool get isPrivateAccount;@JsonKey(name: 'relationship_state') RelationshipState get relationshipState;@JsonKey(name: 'followed_at') DateTime get followedAt;
/// Create a copy of SocialGraphUserItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialGraphUserItemCopyWith<SocialGraphUserItem> get copyWith => _$SocialGraphUserItemCopyWithImpl<SocialGraphUserItem>(this as SocialGraphUserItem, _$identity);

  /// Serializes this SocialGraphUserItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialGraphUserItem&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.baristaLevel, baristaLevel) || other.baristaLevel == baristaLevel)&&(identical(other.baristaRankTitle, baristaRankTitle) || other.baristaRankTitle == baristaRankTitle)&&(identical(other.accountTier, accountTier) || other.accountTier == accountTier)&&(identical(other.isPrivateAccount, isPrivateAccount) || other.isPrivateAccount == isPrivateAccount)&&(identical(other.relationshipState, relationshipState) || other.relationshipState == relationshipState)&&(identical(other.followedAt, followedAt) || other.followedAt == followedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl,baristaLevel,baristaRankTitle,accountTier,isPrivateAccount,relationshipState,followedAt);

@override
String toString() {
  return 'SocialGraphUserItem(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, baristaLevel: $baristaLevel, baristaRankTitle: $baristaRankTitle, accountTier: $accountTier, isPrivateAccount: $isPrivateAccount, relationshipState: $relationshipState, followedAt: $followedAt)';
}


}

/// @nodoc
abstract mixin class $SocialGraphUserItemCopyWith<$Res>  {
  factory $SocialGraphUserItemCopyWith(SocialGraphUserItem value, $Res Function(SocialGraphUserItem) _then) = _$SocialGraphUserItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String username,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'barista_level') int baristaLevel,@JsonKey(name: 'barista_rank_title') String baristaRankTitle,@JsonKey(name: 'account_tier') String accountTier,@JsonKey(name: 'is_private_account') bool isPrivateAccount,@JsonKey(name: 'relationship_state') RelationshipState relationshipState,@JsonKey(name: 'followed_at') DateTime followedAt
});




}
/// @nodoc
class _$SocialGraphUserItemCopyWithImpl<$Res>
    implements $SocialGraphUserItemCopyWith<$Res> {
  _$SocialGraphUserItemCopyWithImpl(this._self, this._then);

  final SocialGraphUserItem _self;
  final $Res Function(SocialGraphUserItem) _then;

/// Create a copy of SocialGraphUserItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = freezed,Object? baristaLevel = null,Object? baristaRankTitle = null,Object? accountTier = null,Object? isPrivateAccount = null,Object? relationshipState = null,Object? followedAt = null,}) {
  return _then(SocialGraphUserItem(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,baristaLevel: null == baristaLevel ? _self.baristaLevel : baristaLevel // ignore: cast_nullable_to_non_nullable
as int,baristaRankTitle: null == baristaRankTitle ? _self.baristaRankTitle : baristaRankTitle // ignore: cast_nullable_to_non_nullable
as String,accountTier: null == accountTier ? _self.accountTier : accountTier // ignore: cast_nullable_to_non_nullable
as String,isPrivateAccount: null == isPrivateAccount ? _self.isPrivateAccount : isPrivateAccount // ignore: cast_nullable_to_non_nullable
as bool,relationshipState: null == relationshipState ? _self.relationshipState : relationshipState // ignore: cast_nullable_to_non_nullable
as RelationshipState,followedAt: null == followedAt ? _self.followedAt : followedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SocialGraphUserItem].
extension SocialGraphUserItemPatterns on SocialGraphUserItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocialGraphUserItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocialGraphUserItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocialGraphUserItem value)  $default,){
final _that = this;
switch (_that) {
case _SocialGraphUserItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocialGraphUserItem value)?  $default,){
final _that = this;
switch (_that) {
case _SocialGraphUserItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'barista_level')  int baristaLevel, @JsonKey(name: 'barista_rank_title')  String baristaRankTitle, @JsonKey(name: 'account_tier')  String accountTier, @JsonKey(name: 'is_private_account')  bool isPrivateAccount, @JsonKey(name: 'relationship_state')  RelationshipState relationshipState, @JsonKey(name: 'followed_at')  DateTime followedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocialGraphUserItem() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.baristaLevel,_that.baristaRankTitle,_that.accountTier,_that.isPrivateAccount,_that.relationshipState,_that.followedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'barista_level')  int baristaLevel, @JsonKey(name: 'barista_rank_title')  String baristaRankTitle, @JsonKey(name: 'account_tier')  String accountTier, @JsonKey(name: 'is_private_account')  bool isPrivateAccount, @JsonKey(name: 'relationship_state')  RelationshipState relationshipState, @JsonKey(name: 'followed_at')  DateTime followedAt)  $default,) {final _that = this;
switch (_that) {
case _SocialGraphUserItem():
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.baristaLevel,_that.baristaRankTitle,_that.accountTier,_that.isPrivateAccount,_that.relationshipState,_that.followedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'barista_level')  int baristaLevel, @JsonKey(name: 'barista_rank_title')  String baristaRankTitle, @JsonKey(name: 'account_tier')  String accountTier, @JsonKey(name: 'is_private_account')  bool isPrivateAccount, @JsonKey(name: 'relationship_state')  RelationshipState relationshipState, @JsonKey(name: 'followed_at')  DateTime followedAt)?  $default,) {final _that = this;
switch (_that) {
case _SocialGraphUserItem() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.baristaLevel,_that.baristaRankTitle,_that.accountTier,_that.isPrivateAccount,_that.relationshipState,_that.followedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SocialGraphUserItem implements SocialGraphUserItem {
  const _SocialGraphUserItem({@JsonKey(name: 'user_id') required this.userId, required this.username, @JsonKey(name: 'display_name') required this.displayName, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'barista_level') this.baristaLevel = 1, @JsonKey(name: 'barista_rank_title') this.baristaRankTitle = 'Home Brewer', @JsonKey(name: 'account_tier') this.accountTier = 'Trial', @JsonKey(name: 'is_private_account') this.isPrivateAccount = false, @JsonKey(name: 'relationship_state') this.relationshipState = RelationshipState.none, @JsonKey(name: 'followed_at') required this.followedAt});
  factory _SocialGraphUserItem.fromJson(Map<String, dynamic> json) => _$SocialGraphUserItemFromJson(json);

@override@JsonKey(name: 'user_id') final  String userId;
@override final  String username;
@override@JsonKey(name: 'display_name') final  String displayName;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'barista_level') final  int baristaLevel;
@override@JsonKey(name: 'barista_rank_title') final  String baristaRankTitle;
@override@JsonKey(name: 'account_tier') final  String accountTier;
@override@JsonKey(name: 'is_private_account') final  bool isPrivateAccount;
@override@JsonKey(name: 'relationship_state') final  RelationshipState relationshipState;
@override@JsonKey(name: 'followed_at') final  DateTime followedAt;

/// Create a copy of SocialGraphUserItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocialGraphUserItemCopyWith<_SocialGraphUserItem> get copyWith => __$SocialGraphUserItemCopyWithImpl<_SocialGraphUserItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocialGraphUserItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocialGraphUserItem&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.baristaLevel, baristaLevel) || other.baristaLevel == baristaLevel)&&(identical(other.baristaRankTitle, baristaRankTitle) || other.baristaRankTitle == baristaRankTitle)&&(identical(other.accountTier, accountTier) || other.accountTier == accountTier)&&(identical(other.isPrivateAccount, isPrivateAccount) || other.isPrivateAccount == isPrivateAccount)&&(identical(other.relationshipState, relationshipState) || other.relationshipState == relationshipState)&&(identical(other.followedAt, followedAt) || other.followedAt == followedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,avatarUrl,baristaLevel,baristaRankTitle,accountTier,isPrivateAccount,relationshipState,followedAt);

@override
String toString() {
  return 'SocialGraphUserItem(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, baristaLevel: $baristaLevel, baristaRankTitle: $baristaRankTitle, accountTier: $accountTier, isPrivateAccount: $isPrivateAccount, relationshipState: $relationshipState, followedAt: $followedAt)';
}


}

/// @nodoc
abstract mixin class _$SocialGraphUserItemCopyWith<$Res> implements $SocialGraphUserItemCopyWith<$Res> {
  factory _$SocialGraphUserItemCopyWith(_SocialGraphUserItem value, $Res Function(_SocialGraphUserItem) _then) = __$SocialGraphUserItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String username,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'barista_level') int baristaLevel,@JsonKey(name: 'barista_rank_title') String baristaRankTitle,@JsonKey(name: 'account_tier') String accountTier,@JsonKey(name: 'is_private_account') bool isPrivateAccount,@JsonKey(name: 'relationship_state') RelationshipState relationshipState,@JsonKey(name: 'followed_at') DateTime followedAt
});




}
/// @nodoc
class __$SocialGraphUserItemCopyWithImpl<$Res>
    implements _$SocialGraphUserItemCopyWith<$Res> {
  __$SocialGraphUserItemCopyWithImpl(this._self, this._then);

  final _SocialGraphUserItem _self;
  final $Res Function(_SocialGraphUserItem) _then;

/// Create a copy of SocialGraphUserItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = freezed,Object? baristaLevel = null,Object? baristaRankTitle = null,Object? accountTier = null,Object? isPrivateAccount = null,Object? relationshipState = null,Object? followedAt = null,}) {
  return _then(_SocialGraphUserItem(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,baristaLevel: null == baristaLevel ? _self.baristaLevel : baristaLevel // ignore: cast_nullable_to_non_nullable
as int,baristaRankTitle: null == baristaRankTitle ? _self.baristaRankTitle : baristaRankTitle // ignore: cast_nullable_to_non_nullable
as String,accountTier: null == accountTier ? _self.accountTier : accountTier // ignore: cast_nullable_to_non_nullable
as String,isPrivateAccount: null == isPrivateAccount ? _self.isPrivateAccount : isPrivateAccount // ignore: cast_nullable_to_non_nullable
as bool,relationshipState: null == relationshipState ? _self.relationshipState : relationshipState // ignore: cast_nullable_to_non_nullable
as RelationshipState,followedAt: null == followedAt ? _self.followedAt : followedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$FollowRequestItem {

@JsonKey(name: 'requester_id') String get requesterId; String get username;@JsonKey(name: 'display_name') String get displayName;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'barista_level') int get baristaLevel;@JsonKey(name: 'barista_rank_title') String get baristaRankTitle;@JsonKey(name: 'account_tier') String get accountTier;@JsonKey(name: 'requested_at') DateTime get requestedAt;
/// Create a copy of FollowRequestItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowRequestItemCopyWith<FollowRequestItem> get copyWith => _$FollowRequestItemCopyWithImpl<FollowRequestItem>(this as FollowRequestItem, _$identity);

  /// Serializes this FollowRequestItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowRequestItem&&(identical(other.requesterId, requesterId) || other.requesterId == requesterId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.baristaLevel, baristaLevel) || other.baristaLevel == baristaLevel)&&(identical(other.baristaRankTitle, baristaRankTitle) || other.baristaRankTitle == baristaRankTitle)&&(identical(other.accountTier, accountTier) || other.accountTier == accountTier)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requesterId,username,displayName,avatarUrl,baristaLevel,baristaRankTitle,accountTier,requestedAt);

@override
String toString() {
  return 'FollowRequestItem(requesterId: $requesterId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, baristaLevel: $baristaLevel, baristaRankTitle: $baristaRankTitle, accountTier: $accountTier, requestedAt: $requestedAt)';
}


}

/// @nodoc
abstract mixin class $FollowRequestItemCopyWith<$Res>  {
  factory $FollowRequestItemCopyWith(FollowRequestItem value, $Res Function(FollowRequestItem) _then) = _$FollowRequestItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'requester_id') String requesterId, String username,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'barista_level') int baristaLevel,@JsonKey(name: 'barista_rank_title') String baristaRankTitle,@JsonKey(name: 'account_tier') String accountTier,@JsonKey(name: 'requested_at') DateTime requestedAt
});




}
/// @nodoc
class _$FollowRequestItemCopyWithImpl<$Res>
    implements $FollowRequestItemCopyWith<$Res> {
  _$FollowRequestItemCopyWithImpl(this._self, this._then);

  final FollowRequestItem _self;
  final $Res Function(FollowRequestItem) _then;

/// Create a copy of FollowRequestItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requesterId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = freezed,Object? baristaLevel = null,Object? baristaRankTitle = null,Object? accountTier = null,Object? requestedAt = null,}) {
  return _then(FollowRequestItem(
requesterId: null == requesterId ? _self.requesterId : requesterId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,baristaLevel: null == baristaLevel ? _self.baristaLevel : baristaLevel // ignore: cast_nullable_to_non_nullable
as int,baristaRankTitle: null == baristaRankTitle ? _self.baristaRankTitle : baristaRankTitle // ignore: cast_nullable_to_non_nullable
as String,accountTier: null == accountTier ? _self.accountTier : accountTier // ignore: cast_nullable_to_non_nullable
as String,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowRequestItem].
extension FollowRequestItemPatterns on FollowRequestItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowRequestItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowRequestItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowRequestItem value)  $default,){
final _that = this;
switch (_that) {
case _FollowRequestItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowRequestItem value)?  $default,){
final _that = this;
switch (_that) {
case _FollowRequestItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'requester_id')  String requesterId,  String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'barista_level')  int baristaLevel, @JsonKey(name: 'barista_rank_title')  String baristaRankTitle, @JsonKey(name: 'account_tier')  String accountTier, @JsonKey(name: 'requested_at')  DateTime requestedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowRequestItem() when $default != null:
return $default(_that.requesterId,_that.username,_that.displayName,_that.avatarUrl,_that.baristaLevel,_that.baristaRankTitle,_that.accountTier,_that.requestedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'requester_id')  String requesterId,  String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'barista_level')  int baristaLevel, @JsonKey(name: 'barista_rank_title')  String baristaRankTitle, @JsonKey(name: 'account_tier')  String accountTier, @JsonKey(name: 'requested_at')  DateTime requestedAt)  $default,) {final _that = this;
switch (_that) {
case _FollowRequestItem():
return $default(_that.requesterId,_that.username,_that.displayName,_that.avatarUrl,_that.baristaLevel,_that.baristaRankTitle,_that.accountTier,_that.requestedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'requester_id')  String requesterId,  String username, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'barista_level')  int baristaLevel, @JsonKey(name: 'barista_rank_title')  String baristaRankTitle, @JsonKey(name: 'account_tier')  String accountTier, @JsonKey(name: 'requested_at')  DateTime requestedAt)?  $default,) {final _that = this;
switch (_that) {
case _FollowRequestItem() when $default != null:
return $default(_that.requesterId,_that.username,_that.displayName,_that.avatarUrl,_that.baristaLevel,_that.baristaRankTitle,_that.accountTier,_that.requestedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FollowRequestItem implements FollowRequestItem {
  const _FollowRequestItem({@JsonKey(name: 'requester_id') required this.requesterId, required this.username, @JsonKey(name: 'display_name') required this.displayName, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'barista_level') this.baristaLevel = 1, @JsonKey(name: 'barista_rank_title') this.baristaRankTitle = 'Home Brewer', @JsonKey(name: 'account_tier') this.accountTier = 'Trial', @JsonKey(name: 'requested_at') required this.requestedAt});
  factory _FollowRequestItem.fromJson(Map<String, dynamic> json) => _$FollowRequestItemFromJson(json);

@override@JsonKey(name: 'requester_id') final  String requesterId;
@override final  String username;
@override@JsonKey(name: 'display_name') final  String displayName;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'barista_level') final  int baristaLevel;
@override@JsonKey(name: 'barista_rank_title') final  String baristaRankTitle;
@override@JsonKey(name: 'account_tier') final  String accountTier;
@override@JsonKey(name: 'requested_at') final  DateTime requestedAt;

/// Create a copy of FollowRequestItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowRequestItemCopyWith<_FollowRequestItem> get copyWith => __$FollowRequestItemCopyWithImpl<_FollowRequestItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowRequestItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowRequestItem&&(identical(other.requesterId, requesterId) || other.requesterId == requesterId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.baristaLevel, baristaLevel) || other.baristaLevel == baristaLevel)&&(identical(other.baristaRankTitle, baristaRankTitle) || other.baristaRankTitle == baristaRankTitle)&&(identical(other.accountTier, accountTier) || other.accountTier == accountTier)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requesterId,username,displayName,avatarUrl,baristaLevel,baristaRankTitle,accountTier,requestedAt);

@override
String toString() {
  return 'FollowRequestItem(requesterId: $requesterId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, baristaLevel: $baristaLevel, baristaRankTitle: $baristaRankTitle, accountTier: $accountTier, requestedAt: $requestedAt)';
}


}

/// @nodoc
abstract mixin class _$FollowRequestItemCopyWith<$Res> implements $FollowRequestItemCopyWith<$Res> {
  factory _$FollowRequestItemCopyWith(_FollowRequestItem value, $Res Function(_FollowRequestItem) _then) = __$FollowRequestItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'requester_id') String requesterId, String username,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'barista_level') int baristaLevel,@JsonKey(name: 'barista_rank_title') String baristaRankTitle,@JsonKey(name: 'account_tier') String accountTier,@JsonKey(name: 'requested_at') DateTime requestedAt
});




}
/// @nodoc
class __$FollowRequestItemCopyWithImpl<$Res>
    implements _$FollowRequestItemCopyWith<$Res> {
  __$FollowRequestItemCopyWithImpl(this._self, this._then);

  final _FollowRequestItem _self;
  final $Res Function(_FollowRequestItem) _then;

/// Create a copy of FollowRequestItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requesterId = null,Object? username = null,Object? displayName = null,Object? avatarUrl = freezed,Object? baristaLevel = null,Object? baristaRankTitle = null,Object? accountTier = null,Object? requestedAt = null,}) {
  return _then(_FollowRequestItem(
requesterId: null == requesterId ? _self.requesterId : requesterId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,baristaLevel: null == baristaLevel ? _self.baristaLevel : baristaLevel // ignore: cast_nullable_to_non_nullable
as int,baristaRankTitle: null == baristaRankTitle ? _self.baristaRankTitle : baristaRankTitle // ignore: cast_nullable_to_non_nullable
as String,accountTier: null == accountTier ? _self.accountTier : accountTier // ignore: cast_nullable_to_non_nullable
as String,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$PrivacySettingSnapshot {

@JsonKey(name: 'is_private_account') bool get isPrivateAccount;@JsonKey(name: 'pending_follow_requests_count') int get pendingFollowRequestsCount;
/// Create a copy of PrivacySettingSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrivacySettingSnapshotCopyWith<PrivacySettingSnapshot> get copyWith => _$PrivacySettingSnapshotCopyWithImpl<PrivacySettingSnapshot>(this as PrivacySettingSnapshot, _$identity);

  /// Serializes this PrivacySettingSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrivacySettingSnapshot&&(identical(other.isPrivateAccount, isPrivateAccount) || other.isPrivateAccount == isPrivateAccount)&&(identical(other.pendingFollowRequestsCount, pendingFollowRequestsCount) || other.pendingFollowRequestsCount == pendingFollowRequestsCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isPrivateAccount,pendingFollowRequestsCount);

@override
String toString() {
  return 'PrivacySettingSnapshot(isPrivateAccount: $isPrivateAccount, pendingFollowRequestsCount: $pendingFollowRequestsCount)';
}


}

/// @nodoc
abstract mixin class $PrivacySettingSnapshotCopyWith<$Res>  {
  factory $PrivacySettingSnapshotCopyWith(PrivacySettingSnapshot value, $Res Function(PrivacySettingSnapshot) _then) = _$PrivacySettingSnapshotCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'is_private_account') bool isPrivateAccount,@JsonKey(name: 'pending_follow_requests_count') int pendingFollowRequestsCount
});




}
/// @nodoc
class _$PrivacySettingSnapshotCopyWithImpl<$Res>
    implements $PrivacySettingSnapshotCopyWith<$Res> {
  _$PrivacySettingSnapshotCopyWithImpl(this._self, this._then);

  final PrivacySettingSnapshot _self;
  final $Res Function(PrivacySettingSnapshot) _then;

/// Create a copy of PrivacySettingSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isPrivateAccount = null,Object? pendingFollowRequestsCount = null,}) {
  return _then(PrivacySettingSnapshot(
isPrivateAccount: null == isPrivateAccount ? _self.isPrivateAccount : isPrivateAccount // ignore: cast_nullable_to_non_nullable
as bool,pendingFollowRequestsCount: null == pendingFollowRequestsCount ? _self.pendingFollowRequestsCount : pendingFollowRequestsCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PrivacySettingSnapshot].
extension PrivacySettingSnapshotPatterns on PrivacySettingSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrivacySettingSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrivacySettingSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrivacySettingSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _PrivacySettingSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrivacySettingSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _PrivacySettingSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'is_private_account')  bool isPrivateAccount, @JsonKey(name: 'pending_follow_requests_count')  int pendingFollowRequestsCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrivacySettingSnapshot() when $default != null:
return $default(_that.isPrivateAccount,_that.pendingFollowRequestsCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'is_private_account')  bool isPrivateAccount, @JsonKey(name: 'pending_follow_requests_count')  int pendingFollowRequestsCount)  $default,) {final _that = this;
switch (_that) {
case _PrivacySettingSnapshot():
return $default(_that.isPrivateAccount,_that.pendingFollowRequestsCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'is_private_account')  bool isPrivateAccount, @JsonKey(name: 'pending_follow_requests_count')  int pendingFollowRequestsCount)?  $default,) {final _that = this;
switch (_that) {
case _PrivacySettingSnapshot() when $default != null:
return $default(_that.isPrivateAccount,_that.pendingFollowRequestsCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrivacySettingSnapshot implements PrivacySettingSnapshot {
  const _PrivacySettingSnapshot({@JsonKey(name: 'is_private_account') this.isPrivateAccount = false, @JsonKey(name: 'pending_follow_requests_count') this.pendingFollowRequestsCount = 0});
  factory _PrivacySettingSnapshot.fromJson(Map<String, dynamic> json) => _$PrivacySettingSnapshotFromJson(json);

@override@JsonKey(name: 'is_private_account') final  bool isPrivateAccount;
@override@JsonKey(name: 'pending_follow_requests_count') final  int pendingFollowRequestsCount;

/// Create a copy of PrivacySettingSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrivacySettingSnapshotCopyWith<_PrivacySettingSnapshot> get copyWith => __$PrivacySettingSnapshotCopyWithImpl<_PrivacySettingSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrivacySettingSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrivacySettingSnapshot&&(identical(other.isPrivateAccount, isPrivateAccount) || other.isPrivateAccount == isPrivateAccount)&&(identical(other.pendingFollowRequestsCount, pendingFollowRequestsCount) || other.pendingFollowRequestsCount == pendingFollowRequestsCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isPrivateAccount,pendingFollowRequestsCount);

@override
String toString() {
  return 'PrivacySettingSnapshot(isPrivateAccount: $isPrivateAccount, pendingFollowRequestsCount: $pendingFollowRequestsCount)';
}


}

/// @nodoc
abstract mixin class _$PrivacySettingSnapshotCopyWith<$Res> implements $PrivacySettingSnapshotCopyWith<$Res> {
  factory _$PrivacySettingSnapshotCopyWith(_PrivacySettingSnapshot value, $Res Function(_PrivacySettingSnapshot) _then) = __$PrivacySettingSnapshotCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'is_private_account') bool isPrivateAccount,@JsonKey(name: 'pending_follow_requests_count') int pendingFollowRequestsCount
});




}
/// @nodoc
class __$PrivacySettingSnapshotCopyWithImpl<$Res>
    implements _$PrivacySettingSnapshotCopyWith<$Res> {
  __$PrivacySettingSnapshotCopyWithImpl(this._self, this._then);

  final _PrivacySettingSnapshot _self;
  final $Res Function(_PrivacySettingSnapshot) _then;

/// Create a copy of PrivacySettingSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isPrivateAccount = null,Object? pendingFollowRequestsCount = null,}) {
  return _then(_PrivacySettingSnapshot(
isPrivateAccount: null == isPrivateAccount ? _self.isPrivateAccount : isPrivateAccount // ignore: cast_nullable_to_non_nullable
as bool,pendingFollowRequestsCount: null == pendingFollowRequestsCount ? _self.pendingFollowRequestsCount : pendingFollowRequestsCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PendingRequestActionResult {

@JsonKey(name: 'requester_id') String get requesterId; String get action; RelationshipState get state;@JsonKey(name: 'pending_follow_requests_count') int get pendingFollowRequestsCount;@JsonKey(name: 'followers_count') int get followersCount;
/// Create a copy of PendingRequestActionResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingRequestActionResultCopyWith<PendingRequestActionResult> get copyWith => _$PendingRequestActionResultCopyWithImpl<PendingRequestActionResult>(this as PendingRequestActionResult, _$identity);

  /// Serializes this PendingRequestActionResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingRequestActionResult&&(identical(other.requesterId, requesterId) || other.requesterId == requesterId)&&(identical(other.action, action) || other.action == action)&&(identical(other.state, state) || other.state == state)&&(identical(other.pendingFollowRequestsCount, pendingFollowRequestsCount) || other.pendingFollowRequestsCount == pendingFollowRequestsCount)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requesterId,action,state,pendingFollowRequestsCount,followersCount);

@override
String toString() {
  return 'PendingRequestActionResult(requesterId: $requesterId, action: $action, state: $state, pendingFollowRequestsCount: $pendingFollowRequestsCount, followersCount: $followersCount)';
}


}

/// @nodoc
abstract mixin class $PendingRequestActionResultCopyWith<$Res>  {
  factory $PendingRequestActionResultCopyWith(PendingRequestActionResult value, $Res Function(PendingRequestActionResult) _then) = _$PendingRequestActionResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'requester_id') String requesterId, String action, RelationshipState state,@JsonKey(name: 'pending_follow_requests_count') int pendingFollowRequestsCount,@JsonKey(name: 'followers_count') int followersCount
});




}
/// @nodoc
class _$PendingRequestActionResultCopyWithImpl<$Res>
    implements $PendingRequestActionResultCopyWith<$Res> {
  _$PendingRequestActionResultCopyWithImpl(this._self, this._then);

  final PendingRequestActionResult _self;
  final $Res Function(PendingRequestActionResult) _then;

/// Create a copy of PendingRequestActionResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requesterId = null,Object? action = null,Object? state = null,Object? pendingFollowRequestsCount = null,Object? followersCount = null,}) {
  return _then(PendingRequestActionResult(
requesterId: null == requesterId ? _self.requesterId : requesterId // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RelationshipState,pendingFollowRequestsCount: null == pendingFollowRequestsCount ? _self.pendingFollowRequestsCount : pendingFollowRequestsCount // ignore: cast_nullable_to_non_nullable
as int,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingRequestActionResult].
extension PendingRequestActionResultPatterns on PendingRequestActionResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingRequestActionResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingRequestActionResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingRequestActionResult value)  $default,){
final _that = this;
switch (_that) {
case _PendingRequestActionResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingRequestActionResult value)?  $default,){
final _that = this;
switch (_that) {
case _PendingRequestActionResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'requester_id')  String requesterId,  String action,  RelationshipState state, @JsonKey(name: 'pending_follow_requests_count')  int pendingFollowRequestsCount, @JsonKey(name: 'followers_count')  int followersCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingRequestActionResult() when $default != null:
return $default(_that.requesterId,_that.action,_that.state,_that.pendingFollowRequestsCount,_that.followersCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'requester_id')  String requesterId,  String action,  RelationshipState state, @JsonKey(name: 'pending_follow_requests_count')  int pendingFollowRequestsCount, @JsonKey(name: 'followers_count')  int followersCount)  $default,) {final _that = this;
switch (_that) {
case _PendingRequestActionResult():
return $default(_that.requesterId,_that.action,_that.state,_that.pendingFollowRequestsCount,_that.followersCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'requester_id')  String requesterId,  String action,  RelationshipState state, @JsonKey(name: 'pending_follow_requests_count')  int pendingFollowRequestsCount, @JsonKey(name: 'followers_count')  int followersCount)?  $default,) {final _that = this;
switch (_that) {
case _PendingRequestActionResult() when $default != null:
return $default(_that.requesterId,_that.action,_that.state,_that.pendingFollowRequestsCount,_that.followersCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingRequestActionResult implements PendingRequestActionResult {
  const _PendingRequestActionResult({@JsonKey(name: 'requester_id') required this.requesterId, required this.action, this.state = RelationshipState.none, @JsonKey(name: 'pending_follow_requests_count') this.pendingFollowRequestsCount = 0, @JsonKey(name: 'followers_count') this.followersCount = 0});
  factory _PendingRequestActionResult.fromJson(Map<String, dynamic> json) => _$PendingRequestActionResultFromJson(json);

@override@JsonKey(name: 'requester_id') final  String requesterId;
@override final  String action;
@override@JsonKey() final  RelationshipState state;
@override@JsonKey(name: 'pending_follow_requests_count') final  int pendingFollowRequestsCount;
@override@JsonKey(name: 'followers_count') final  int followersCount;

/// Create a copy of PendingRequestActionResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingRequestActionResultCopyWith<_PendingRequestActionResult> get copyWith => __$PendingRequestActionResultCopyWithImpl<_PendingRequestActionResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingRequestActionResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingRequestActionResult&&(identical(other.requesterId, requesterId) || other.requesterId == requesterId)&&(identical(other.action, action) || other.action == action)&&(identical(other.state, state) || other.state == state)&&(identical(other.pendingFollowRequestsCount, pendingFollowRequestsCount) || other.pendingFollowRequestsCount == pendingFollowRequestsCount)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requesterId,action,state,pendingFollowRequestsCount,followersCount);

@override
String toString() {
  return 'PendingRequestActionResult(requesterId: $requesterId, action: $action, state: $state, pendingFollowRequestsCount: $pendingFollowRequestsCount, followersCount: $followersCount)';
}


}

/// @nodoc
abstract mixin class _$PendingRequestActionResultCopyWith<$Res> implements $PendingRequestActionResultCopyWith<$Res> {
  factory _$PendingRequestActionResultCopyWith(_PendingRequestActionResult value, $Res Function(_PendingRequestActionResult) _then) = __$PendingRequestActionResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'requester_id') String requesterId, String action, RelationshipState state,@JsonKey(name: 'pending_follow_requests_count') int pendingFollowRequestsCount,@JsonKey(name: 'followers_count') int followersCount
});




}
/// @nodoc
class __$PendingRequestActionResultCopyWithImpl<$Res>
    implements _$PendingRequestActionResultCopyWith<$Res> {
  __$PendingRequestActionResultCopyWithImpl(this._self, this._then);

  final _PendingRequestActionResult _self;
  final $Res Function(_PendingRequestActionResult) _then;

/// Create a copy of PendingRequestActionResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requesterId = null,Object? action = null,Object? state = null,Object? pendingFollowRequestsCount = null,Object? followersCount = null,}) {
  return _then(_PendingRequestActionResult(
requesterId: null == requesterId ? _self.requesterId : requesterId // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RelationshipState,pendingFollowRequestsCount: null == pendingFollowRequestsCount ? _self.pendingFollowRequestsCount : pendingFollowRequestsCount // ignore: cast_nullable_to_non_nullable
as int,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
