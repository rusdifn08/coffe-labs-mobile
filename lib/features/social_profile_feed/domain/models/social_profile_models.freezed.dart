// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_profile_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BaristaBadgeItem {

 int get id; String get slug; String get title; String get rarity;@JsonKey(name: 'rive_artboard') String? get riveArtboard;
/// Create a copy of BaristaBadgeItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BaristaBadgeItemCopyWith<BaristaBadgeItem> get copyWith => _$BaristaBadgeItemCopyWithImpl<BaristaBadgeItem>(this as BaristaBadgeItem, _$identity);

  /// Serializes this BaristaBadgeItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BaristaBadgeItem&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.rarity, rarity) || other.rarity == rarity)&&(identical(other.riveArtboard, riveArtboard) || other.riveArtboard == riveArtboard));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,title,rarity,riveArtboard);

@override
String toString() {
  return 'BaristaBadgeItem(id: $id, slug: $slug, title: $title, rarity: $rarity, riveArtboard: $riveArtboard)';
}


}

/// @nodoc
abstract mixin class $BaristaBadgeItemCopyWith<$Res>  {
  factory $BaristaBadgeItemCopyWith(BaristaBadgeItem value, $Res Function(BaristaBadgeItem) _then) = _$BaristaBadgeItemCopyWithImpl;
@useResult
$Res call({
 int id, String slug, String title, String rarity,@JsonKey(name: 'rive_artboard') String? riveArtboard
});




}
/// @nodoc
class _$BaristaBadgeItemCopyWithImpl<$Res>
    implements $BaristaBadgeItemCopyWith<$Res> {
  _$BaristaBadgeItemCopyWithImpl(this._self, this._then);

  final BaristaBadgeItem _self;
  final $Res Function(BaristaBadgeItem) _then;

/// Create a copy of BaristaBadgeItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? rarity = null,Object? riveArtboard = freezed,}) {
  return _then(BaristaBadgeItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,rarity: null == rarity ? _self.rarity : rarity // ignore: cast_nullable_to_non_nullable
as String,riveArtboard: freezed == riveArtboard ? _self.riveArtboard : riveArtboard // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BaristaBadgeItem].
extension BaristaBadgeItemPatterns on BaristaBadgeItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BaristaBadgeItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BaristaBadgeItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BaristaBadgeItem value)  $default,){
final _that = this;
switch (_that) {
case _BaristaBadgeItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BaristaBadgeItem value)?  $default,){
final _that = this;
switch (_that) {
case _BaristaBadgeItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String slug,  String title,  String rarity, @JsonKey(name: 'rive_artboard')  String? riveArtboard)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BaristaBadgeItem() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.rarity,_that.riveArtboard);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String slug,  String title,  String rarity, @JsonKey(name: 'rive_artboard')  String? riveArtboard)  $default,) {final _that = this;
switch (_that) {
case _BaristaBadgeItem():
return $default(_that.id,_that.slug,_that.title,_that.rarity,_that.riveArtboard);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String slug,  String title,  String rarity, @JsonKey(name: 'rive_artboard')  String? riveArtboard)?  $default,) {final _that = this;
switch (_that) {
case _BaristaBadgeItem() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.rarity,_that.riveArtboard);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BaristaBadgeItem implements BaristaBadgeItem {
  const _BaristaBadgeItem({required this.id, required this.slug, required this.title, required this.rarity, @JsonKey(name: 'rive_artboard') this.riveArtboard});
  factory _BaristaBadgeItem.fromJson(Map<String, dynamic> json) => _$BaristaBadgeItemFromJson(json);

@override final  int id;
@override final  String slug;
@override final  String title;
@override final  String rarity;
@override@JsonKey(name: 'rive_artboard') final  String? riveArtboard;

/// Create a copy of BaristaBadgeItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BaristaBadgeItemCopyWith<_BaristaBadgeItem> get copyWith => __$BaristaBadgeItemCopyWithImpl<_BaristaBadgeItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BaristaBadgeItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BaristaBadgeItem&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.rarity, rarity) || other.rarity == rarity)&&(identical(other.riveArtboard, riveArtboard) || other.riveArtboard == riveArtboard));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,title,rarity,riveArtboard);

@override
String toString() {
  return 'BaristaBadgeItem(id: $id, slug: $slug, title: $title, rarity: $rarity, riveArtboard: $riveArtboard)';
}


}

/// @nodoc
abstract mixin class _$BaristaBadgeItemCopyWith<$Res> implements $BaristaBadgeItemCopyWith<$Res> {
  factory _$BaristaBadgeItemCopyWith(_BaristaBadgeItem value, $Res Function(_BaristaBadgeItem) _then) = __$BaristaBadgeItemCopyWithImpl;
@override @useResult
$Res call({
 int id, String slug, String title, String rarity,@JsonKey(name: 'rive_artboard') String? riveArtboard
});




}
/// @nodoc
class __$BaristaBadgeItemCopyWithImpl<$Res>
    implements _$BaristaBadgeItemCopyWith<$Res> {
  __$BaristaBadgeItemCopyWithImpl(this._self, this._then);

  final _BaristaBadgeItem _self;
  final $Res Function(_BaristaBadgeItem) _then;

/// Create a copy of BaristaBadgeItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? rarity = null,Object? riveArtboard = freezed,}) {
  return _then(_BaristaBadgeItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,rarity: null == rarity ? _self.rarity : rarity // ignore: cast_nullable_to_non_nullable
as String,riveArtboard: freezed == riveArtboard ? _self.riveArtboard : riveArtboard // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RecentBrewSnapshot {

@JsonKey(name: 'recipe_id') String? get recipeId;@JsonKey(name: 'recipe_title') String get recipeTitle;@JsonKey(name: 'bean_name') String get beanName; String get roastery; String get process; String get method;@JsonKey(name: 'primary_temp_c') int? get primaryTempC;@JsonKey(name: 'secondary_temp_c') int? get secondaryTempC;@JsonKey(name: 'coffee_dose_g') double? get coffeeDoseG;@JsonKey(name: 'total_water_ml') double? get totalWaterMl;@JsonKey(name: 'target_duration_sec') int? get targetDurationSec;@JsonKey(name: 'brewed_at') DateTime get brewedAt;@JsonKey(name: 'is_live') bool get isLive;@JsonKey(name: 'accuracy_score') double? get accuracyScore;
/// Create a copy of RecentBrewSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentBrewSnapshotCopyWith<RecentBrewSnapshot> get copyWith => _$RecentBrewSnapshotCopyWithImpl<RecentBrewSnapshot>(this as RecentBrewSnapshot, _$identity);

  /// Serializes this RecentBrewSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentBrewSnapshot&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.recipeTitle, recipeTitle) || other.recipeTitle == recipeTitle)&&(identical(other.beanName, beanName) || other.beanName == beanName)&&(identical(other.roastery, roastery) || other.roastery == roastery)&&(identical(other.process, process) || other.process == process)&&(identical(other.method, method) || other.method == method)&&(identical(other.primaryTempC, primaryTempC) || other.primaryTempC == primaryTempC)&&(identical(other.secondaryTempC, secondaryTempC) || other.secondaryTempC == secondaryTempC)&&(identical(other.coffeeDoseG, coffeeDoseG) || other.coffeeDoseG == coffeeDoseG)&&(identical(other.totalWaterMl, totalWaterMl) || other.totalWaterMl == totalWaterMl)&&(identical(other.targetDurationSec, targetDurationSec) || other.targetDurationSec == targetDurationSec)&&(identical(other.brewedAt, brewedAt) || other.brewedAt == brewedAt)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.accuracyScore, accuracyScore) || other.accuracyScore == accuracyScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recipeId,recipeTitle,beanName,roastery,process,method,primaryTempC,secondaryTempC,coffeeDoseG,totalWaterMl,targetDurationSec,brewedAt,isLive,accuracyScore);

@override
String toString() {
  return 'RecentBrewSnapshot(recipeId: $recipeId, recipeTitle: $recipeTitle, beanName: $beanName, roastery: $roastery, process: $process, method: $method, primaryTempC: $primaryTempC, secondaryTempC: $secondaryTempC, coffeeDoseG: $coffeeDoseG, totalWaterMl: $totalWaterMl, targetDurationSec: $targetDurationSec, brewedAt: $brewedAt, isLive: $isLive, accuracyScore: $accuracyScore)';
}


}

/// @nodoc
abstract mixin class $RecentBrewSnapshotCopyWith<$Res>  {
  factory $RecentBrewSnapshotCopyWith(RecentBrewSnapshot value, $Res Function(RecentBrewSnapshot) _then) = _$RecentBrewSnapshotCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'recipe_id') String? recipeId,@JsonKey(name: 'recipe_title') String recipeTitle,@JsonKey(name: 'bean_name') String beanName, String roastery, String process, String method,@JsonKey(name: 'primary_temp_c') int? primaryTempC,@JsonKey(name: 'secondary_temp_c') int? secondaryTempC,@JsonKey(name: 'coffee_dose_g') double? coffeeDoseG,@JsonKey(name: 'total_water_ml') double? totalWaterMl,@JsonKey(name: 'target_duration_sec') int? targetDurationSec,@JsonKey(name: 'brewed_at') DateTime brewedAt,@JsonKey(name: 'is_live') bool isLive,@JsonKey(name: 'accuracy_score') double? accuracyScore
});




}
/// @nodoc
class _$RecentBrewSnapshotCopyWithImpl<$Res>
    implements $RecentBrewSnapshotCopyWith<$Res> {
  _$RecentBrewSnapshotCopyWithImpl(this._self, this._then);

  final RecentBrewSnapshot _self;
  final $Res Function(RecentBrewSnapshot) _then;

/// Create a copy of RecentBrewSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recipeId = freezed,Object? recipeTitle = null,Object? beanName = null,Object? roastery = null,Object? process = null,Object? method = null,Object? primaryTempC = freezed,Object? secondaryTempC = freezed,Object? coffeeDoseG = freezed,Object? totalWaterMl = freezed,Object? targetDurationSec = freezed,Object? brewedAt = null,Object? isLive = null,Object? accuracyScore = freezed,}) {
  return _then(RecentBrewSnapshot(
recipeId: freezed == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String?,recipeTitle: null == recipeTitle ? _self.recipeTitle : recipeTitle // ignore: cast_nullable_to_non_nullable
as String,beanName: null == beanName ? _self.beanName : beanName // ignore: cast_nullable_to_non_nullable
as String,roastery: null == roastery ? _self.roastery : roastery // ignore: cast_nullable_to_non_nullable
as String,process: null == process ? _self.process : process // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,primaryTempC: freezed == primaryTempC ? _self.primaryTempC : primaryTempC // ignore: cast_nullable_to_non_nullable
as int?,secondaryTempC: freezed == secondaryTempC ? _self.secondaryTempC : secondaryTempC // ignore: cast_nullable_to_non_nullable
as int?,coffeeDoseG: freezed == coffeeDoseG ? _self.coffeeDoseG : coffeeDoseG // ignore: cast_nullable_to_non_nullable
as double?,totalWaterMl: freezed == totalWaterMl ? _self.totalWaterMl : totalWaterMl // ignore: cast_nullable_to_non_nullable
as double?,targetDurationSec: freezed == targetDurationSec ? _self.targetDurationSec : targetDurationSec // ignore: cast_nullable_to_non_nullable
as int?,brewedAt: null == brewedAt ? _self.brewedAt : brewedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,accuracyScore: freezed == accuracyScore ? _self.accuracyScore : accuracyScore // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecentBrewSnapshot].
extension RecentBrewSnapshotPatterns on RecentBrewSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentBrewSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentBrewSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentBrewSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _RecentBrewSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentBrewSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _RecentBrewSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'recipe_id')  String? recipeId, @JsonKey(name: 'recipe_title')  String recipeTitle, @JsonKey(name: 'bean_name')  String beanName,  String roastery,  String process,  String method, @JsonKey(name: 'primary_temp_c')  int? primaryTempC, @JsonKey(name: 'secondary_temp_c')  int? secondaryTempC, @JsonKey(name: 'coffee_dose_g')  double? coffeeDoseG, @JsonKey(name: 'total_water_ml')  double? totalWaterMl, @JsonKey(name: 'target_duration_sec')  int? targetDurationSec, @JsonKey(name: 'brewed_at')  DateTime brewedAt, @JsonKey(name: 'is_live')  bool isLive, @JsonKey(name: 'accuracy_score')  double? accuracyScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentBrewSnapshot() when $default != null:
return $default(_that.recipeId,_that.recipeTitle,_that.beanName,_that.roastery,_that.process,_that.method,_that.primaryTempC,_that.secondaryTempC,_that.coffeeDoseG,_that.totalWaterMl,_that.targetDurationSec,_that.brewedAt,_that.isLive,_that.accuracyScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'recipe_id')  String? recipeId, @JsonKey(name: 'recipe_title')  String recipeTitle, @JsonKey(name: 'bean_name')  String beanName,  String roastery,  String process,  String method, @JsonKey(name: 'primary_temp_c')  int? primaryTempC, @JsonKey(name: 'secondary_temp_c')  int? secondaryTempC, @JsonKey(name: 'coffee_dose_g')  double? coffeeDoseG, @JsonKey(name: 'total_water_ml')  double? totalWaterMl, @JsonKey(name: 'target_duration_sec')  int? targetDurationSec, @JsonKey(name: 'brewed_at')  DateTime brewedAt, @JsonKey(name: 'is_live')  bool isLive, @JsonKey(name: 'accuracy_score')  double? accuracyScore)  $default,) {final _that = this;
switch (_that) {
case _RecentBrewSnapshot():
return $default(_that.recipeId,_that.recipeTitle,_that.beanName,_that.roastery,_that.process,_that.method,_that.primaryTempC,_that.secondaryTempC,_that.coffeeDoseG,_that.totalWaterMl,_that.targetDurationSec,_that.brewedAt,_that.isLive,_that.accuracyScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'recipe_id')  String? recipeId, @JsonKey(name: 'recipe_title')  String recipeTitle, @JsonKey(name: 'bean_name')  String beanName,  String roastery,  String process,  String method, @JsonKey(name: 'primary_temp_c')  int? primaryTempC, @JsonKey(name: 'secondary_temp_c')  int? secondaryTempC, @JsonKey(name: 'coffee_dose_g')  double? coffeeDoseG, @JsonKey(name: 'total_water_ml')  double? totalWaterMl, @JsonKey(name: 'target_duration_sec')  int? targetDurationSec, @JsonKey(name: 'brewed_at')  DateTime brewedAt, @JsonKey(name: 'is_live')  bool isLive, @JsonKey(name: 'accuracy_score')  double? accuracyScore)?  $default,) {final _that = this;
switch (_that) {
case _RecentBrewSnapshot() when $default != null:
return $default(_that.recipeId,_that.recipeTitle,_that.beanName,_that.roastery,_that.process,_that.method,_that.primaryTempC,_that.secondaryTempC,_that.coffeeDoseG,_that.totalWaterMl,_that.targetDurationSec,_that.brewedAt,_that.isLive,_that.accuracyScore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecentBrewSnapshot implements RecentBrewSnapshot {
  const _RecentBrewSnapshot({@JsonKey(name: 'recipe_id') this.recipeId, @JsonKey(name: 'recipe_title') required this.recipeTitle, @JsonKey(name: 'bean_name') required this.beanName, required this.roastery, required this.process, required this.method, @JsonKey(name: 'primary_temp_c') this.primaryTempC, @JsonKey(name: 'secondary_temp_c') this.secondaryTempC, @JsonKey(name: 'coffee_dose_g') this.coffeeDoseG, @JsonKey(name: 'total_water_ml') this.totalWaterMl, @JsonKey(name: 'target_duration_sec') this.targetDurationSec, @JsonKey(name: 'brewed_at') required this.brewedAt, @JsonKey(name: 'is_live') this.isLive = false, @JsonKey(name: 'accuracy_score') this.accuracyScore});
  factory _RecentBrewSnapshot.fromJson(Map<String, dynamic> json) => _$RecentBrewSnapshotFromJson(json);

@override@JsonKey(name: 'recipe_id') final  String? recipeId;
@override@JsonKey(name: 'recipe_title') final  String recipeTitle;
@override@JsonKey(name: 'bean_name') final  String beanName;
@override final  String roastery;
@override final  String process;
@override final  String method;
@override@JsonKey(name: 'primary_temp_c') final  int? primaryTempC;
@override@JsonKey(name: 'secondary_temp_c') final  int? secondaryTempC;
@override@JsonKey(name: 'coffee_dose_g') final  double? coffeeDoseG;
@override@JsonKey(name: 'total_water_ml') final  double? totalWaterMl;
@override@JsonKey(name: 'target_duration_sec') final  int? targetDurationSec;
@override@JsonKey(name: 'brewed_at') final  DateTime brewedAt;
@override@JsonKey(name: 'is_live') final  bool isLive;
@override@JsonKey(name: 'accuracy_score') final  double? accuracyScore;

/// Create a copy of RecentBrewSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentBrewSnapshotCopyWith<_RecentBrewSnapshot> get copyWith => __$RecentBrewSnapshotCopyWithImpl<_RecentBrewSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecentBrewSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentBrewSnapshot&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.recipeTitle, recipeTitle) || other.recipeTitle == recipeTitle)&&(identical(other.beanName, beanName) || other.beanName == beanName)&&(identical(other.roastery, roastery) || other.roastery == roastery)&&(identical(other.process, process) || other.process == process)&&(identical(other.method, method) || other.method == method)&&(identical(other.primaryTempC, primaryTempC) || other.primaryTempC == primaryTempC)&&(identical(other.secondaryTempC, secondaryTempC) || other.secondaryTempC == secondaryTempC)&&(identical(other.coffeeDoseG, coffeeDoseG) || other.coffeeDoseG == coffeeDoseG)&&(identical(other.totalWaterMl, totalWaterMl) || other.totalWaterMl == totalWaterMl)&&(identical(other.targetDurationSec, targetDurationSec) || other.targetDurationSec == targetDurationSec)&&(identical(other.brewedAt, brewedAt) || other.brewedAt == brewedAt)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.accuracyScore, accuracyScore) || other.accuracyScore == accuracyScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recipeId,recipeTitle,beanName,roastery,process,method,primaryTempC,secondaryTempC,coffeeDoseG,totalWaterMl,targetDurationSec,brewedAt,isLive,accuracyScore);

@override
String toString() {
  return 'RecentBrewSnapshot(recipeId: $recipeId, recipeTitle: $recipeTitle, beanName: $beanName, roastery: $roastery, process: $process, method: $method, primaryTempC: $primaryTempC, secondaryTempC: $secondaryTempC, coffeeDoseG: $coffeeDoseG, totalWaterMl: $totalWaterMl, targetDurationSec: $targetDurationSec, brewedAt: $brewedAt, isLive: $isLive, accuracyScore: $accuracyScore)';
}


}

/// @nodoc
abstract mixin class _$RecentBrewSnapshotCopyWith<$Res> implements $RecentBrewSnapshotCopyWith<$Res> {
  factory _$RecentBrewSnapshotCopyWith(_RecentBrewSnapshot value, $Res Function(_RecentBrewSnapshot) _then) = __$RecentBrewSnapshotCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'recipe_id') String? recipeId,@JsonKey(name: 'recipe_title') String recipeTitle,@JsonKey(name: 'bean_name') String beanName, String roastery, String process, String method,@JsonKey(name: 'primary_temp_c') int? primaryTempC,@JsonKey(name: 'secondary_temp_c') int? secondaryTempC,@JsonKey(name: 'coffee_dose_g') double? coffeeDoseG,@JsonKey(name: 'total_water_ml') double? totalWaterMl,@JsonKey(name: 'target_duration_sec') int? targetDurationSec,@JsonKey(name: 'brewed_at') DateTime brewedAt,@JsonKey(name: 'is_live') bool isLive,@JsonKey(name: 'accuracy_score') double? accuracyScore
});




}
/// @nodoc
class __$RecentBrewSnapshotCopyWithImpl<$Res>
    implements _$RecentBrewSnapshotCopyWith<$Res> {
  __$RecentBrewSnapshotCopyWithImpl(this._self, this._then);

  final _RecentBrewSnapshot _self;
  final $Res Function(_RecentBrewSnapshot) _then;

/// Create a copy of RecentBrewSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recipeId = freezed,Object? recipeTitle = null,Object? beanName = null,Object? roastery = null,Object? process = null,Object? method = null,Object? primaryTempC = freezed,Object? secondaryTempC = freezed,Object? coffeeDoseG = freezed,Object? totalWaterMl = freezed,Object? targetDurationSec = freezed,Object? brewedAt = null,Object? isLive = null,Object? accuracyScore = freezed,}) {
  return _then(_RecentBrewSnapshot(
recipeId: freezed == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String?,recipeTitle: null == recipeTitle ? _self.recipeTitle : recipeTitle // ignore: cast_nullable_to_non_nullable
as String,beanName: null == beanName ? _self.beanName : beanName // ignore: cast_nullable_to_non_nullable
as String,roastery: null == roastery ? _self.roastery : roastery // ignore: cast_nullable_to_non_nullable
as String,process: null == process ? _self.process : process // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,primaryTempC: freezed == primaryTempC ? _self.primaryTempC : primaryTempC // ignore: cast_nullable_to_non_nullable
as int?,secondaryTempC: freezed == secondaryTempC ? _self.secondaryTempC : secondaryTempC // ignore: cast_nullable_to_non_nullable
as int?,coffeeDoseG: freezed == coffeeDoseG ? _self.coffeeDoseG : coffeeDoseG // ignore: cast_nullable_to_non_nullable
as double?,totalWaterMl: freezed == totalWaterMl ? _self.totalWaterMl : totalWaterMl // ignore: cast_nullable_to_non_nullable
as double?,targetDurationSec: freezed == targetDurationSec ? _self.targetDurationSec : targetDurationSec // ignore: cast_nullable_to_non_nullable
as int?,brewedAt: null == brewedAt ? _self.brewedAt : brewedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,accuracyScore: freezed == accuracyScore ? _self.accuracyScore : accuracyScore // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$MaterializedProfileView {

@JsonKey(name: 'user_id') String get userId; String get username;@JsonKey(name: 'display_name') String get displayName; String get bio;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'banner_url') String? get bannerUrl;@JsonKey(name: 'account_tier') String get accountTier;@JsonKey(name: 'total_xp') int get totalXp;@JsonKey(name: 'barista_level') int get baristaLevel;@JsonKey(name: 'barista_rank_title') String get baristaRankTitle;@JsonKey(name: 'level_progress_ratio') double get levelProgressRatio;@JsonKey(name: 'next_level_xp') int get nextLevelXp;@JsonKey(name: 'current_streak_days') int get currentStreakDays;@JsonKey(name: 'unlocked_badge_ids') List<int> get unlockedBadgeIds;@JsonKey(name: 'top_featured_badges') List<BaristaBadgeItem> get topFeaturedBadges;@JsonKey(name: 'followers_count') int get followersCount;@JsonKey(name: 'following_count') int get followingCount;@JsonKey(name: 'total_threads_count') int get totalThreadsCount;@JsonKey(name: 'total_brews_count') int get totalBrewsCount;@JsonKey(name: 'total_recipes_created_count') int get totalRecipesCreatedCount;@JsonKey(name: 'total_recipe_tries_received') int get totalRecipeTriesReceived;@JsonKey(name: 'recent_brew_snapshot') RecentBrewSnapshot? get recentBrewSnapshot;@JsonKey(name: 'is_followed_by_viewer') bool get isFollowedByViewer;@JsonKey(name: 'is_following_viewer') bool get isFollowingViewer;@JsonKey(name: 'is_own_profile') bool get isOwnProfile;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of MaterializedProfileView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaterializedProfileViewCopyWith<MaterializedProfileView> get copyWith => _$MaterializedProfileViewCopyWithImpl<MaterializedProfileView>(this as MaterializedProfileView, _$identity);

  /// Serializes this MaterializedProfileView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaterializedProfileView&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.accountTier, accountTier) || other.accountTier == accountTier)&&(identical(other.totalXp, totalXp) || other.totalXp == totalXp)&&(identical(other.baristaLevel, baristaLevel) || other.baristaLevel == baristaLevel)&&(identical(other.baristaRankTitle, baristaRankTitle) || other.baristaRankTitle == baristaRankTitle)&&(identical(other.levelProgressRatio, levelProgressRatio) || other.levelProgressRatio == levelProgressRatio)&&(identical(other.nextLevelXp, nextLevelXp) || other.nextLevelXp == nextLevelXp)&&(identical(other.currentStreakDays, currentStreakDays) || other.currentStreakDays == currentStreakDays)&&const DeepCollectionEquality().equals(other.unlockedBadgeIds, unlockedBadgeIds)&&const DeepCollectionEquality().equals(other.topFeaturedBadges, topFeaturedBadges)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.totalThreadsCount, totalThreadsCount) || other.totalThreadsCount == totalThreadsCount)&&(identical(other.totalBrewsCount, totalBrewsCount) || other.totalBrewsCount == totalBrewsCount)&&(identical(other.totalRecipesCreatedCount, totalRecipesCreatedCount) || other.totalRecipesCreatedCount == totalRecipesCreatedCount)&&(identical(other.totalRecipeTriesReceived, totalRecipeTriesReceived) || other.totalRecipeTriesReceived == totalRecipeTriesReceived)&&(identical(other.recentBrewSnapshot, recentBrewSnapshot) || other.recentBrewSnapshot == recentBrewSnapshot)&&(identical(other.isFollowedByViewer, isFollowedByViewer) || other.isFollowedByViewer == isFollowedByViewer)&&(identical(other.isFollowingViewer, isFollowingViewer) || other.isFollowingViewer == isFollowingViewer)&&(identical(other.isOwnProfile, isOwnProfile) || other.isOwnProfile == isOwnProfile)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,userId,username,displayName,bio,avatarUrl,bannerUrl,accountTier,totalXp,baristaLevel,baristaRankTitle,levelProgressRatio,nextLevelXp,currentStreakDays,const DeepCollectionEquality().hash(unlockedBadgeIds),const DeepCollectionEquality().hash(topFeaturedBadges),followersCount,followingCount,totalThreadsCount,totalBrewsCount,totalRecipesCreatedCount,totalRecipeTriesReceived,recentBrewSnapshot,isFollowedByViewer,isFollowingViewer,isOwnProfile,updatedAt]);

@override
String toString() {
  return 'MaterializedProfileView(userId: $userId, username: $username, displayName: $displayName, bio: $bio, avatarUrl: $avatarUrl, bannerUrl: $bannerUrl, accountTier: $accountTier, totalXp: $totalXp, baristaLevel: $baristaLevel, baristaRankTitle: $baristaRankTitle, levelProgressRatio: $levelProgressRatio, nextLevelXp: $nextLevelXp, currentStreakDays: $currentStreakDays, unlockedBadgeIds: $unlockedBadgeIds, topFeaturedBadges: $topFeaturedBadges, followersCount: $followersCount, followingCount: $followingCount, totalThreadsCount: $totalThreadsCount, totalBrewsCount: $totalBrewsCount, totalRecipesCreatedCount: $totalRecipesCreatedCount, totalRecipeTriesReceived: $totalRecipeTriesReceived, recentBrewSnapshot: $recentBrewSnapshot, isFollowedByViewer: $isFollowedByViewer, isFollowingViewer: $isFollowingViewer, isOwnProfile: $isOwnProfile, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MaterializedProfileViewCopyWith<$Res>  {
  factory $MaterializedProfileViewCopyWith(MaterializedProfileView value, $Res Function(MaterializedProfileView) _then) = _$MaterializedProfileViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String username,@JsonKey(name: 'display_name') String displayName, String bio,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'banner_url') String? bannerUrl,@JsonKey(name: 'account_tier') String accountTier,@JsonKey(name: 'total_xp') int totalXp,@JsonKey(name: 'barista_level') int baristaLevel,@JsonKey(name: 'barista_rank_title') String baristaRankTitle,@JsonKey(name: 'level_progress_ratio') double levelProgressRatio,@JsonKey(name: 'next_level_xp') int nextLevelXp,@JsonKey(name: 'current_streak_days') int currentStreakDays,@JsonKey(name: 'unlocked_badge_ids') List<int> unlockedBadgeIds,@JsonKey(name: 'top_featured_badges') List<BaristaBadgeItem> topFeaturedBadges,@JsonKey(name: 'followers_count') int followersCount,@JsonKey(name: 'following_count') int followingCount,@JsonKey(name: 'total_threads_count') int totalThreadsCount,@JsonKey(name: 'total_brews_count') int totalBrewsCount,@JsonKey(name: 'total_recipes_created_count') int totalRecipesCreatedCount,@JsonKey(name: 'total_recipe_tries_received') int totalRecipeTriesReceived,@JsonKey(name: 'recent_brew_snapshot') RecentBrewSnapshot? recentBrewSnapshot,@JsonKey(name: 'is_followed_by_viewer') bool isFollowedByViewer,@JsonKey(name: 'is_following_viewer') bool isFollowingViewer,@JsonKey(name: 'is_own_profile') bool isOwnProfile,@JsonKey(name: 'updated_at') DateTime? updatedAt
});


$RecentBrewSnapshotCopyWith<$Res>? get recentBrewSnapshot;

}
/// @nodoc
class _$MaterializedProfileViewCopyWithImpl<$Res>
    implements $MaterializedProfileViewCopyWith<$Res> {
  _$MaterializedProfileViewCopyWithImpl(this._self, this._then);

  final MaterializedProfileView _self;
  final $Res Function(MaterializedProfileView) _then;

/// Create a copy of MaterializedProfileView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? bio = null,Object? avatarUrl = freezed,Object? bannerUrl = freezed,Object? accountTier = null,Object? totalXp = null,Object? baristaLevel = null,Object? baristaRankTitle = null,Object? levelProgressRatio = null,Object? nextLevelXp = null,Object? currentStreakDays = null,Object? unlockedBadgeIds = null,Object? topFeaturedBadges = null,Object? followersCount = null,Object? followingCount = null,Object? totalThreadsCount = null,Object? totalBrewsCount = null,Object? totalRecipesCreatedCount = null,Object? totalRecipeTriesReceived = null,Object? recentBrewSnapshot = freezed,Object? isFollowedByViewer = null,Object? isFollowingViewer = null,Object? isOwnProfile = null,Object? updatedAt = freezed,}) {
  return _then(MaterializedProfileView(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,accountTier: null == accountTier ? _self.accountTier : accountTier // ignore: cast_nullable_to_non_nullable
as String,totalXp: null == totalXp ? _self.totalXp : totalXp // ignore: cast_nullable_to_non_nullable
as int,baristaLevel: null == baristaLevel ? _self.baristaLevel : baristaLevel // ignore: cast_nullable_to_non_nullable
as int,baristaRankTitle: null == baristaRankTitle ? _self.baristaRankTitle : baristaRankTitle // ignore: cast_nullable_to_non_nullable
as String,levelProgressRatio: null == levelProgressRatio ? _self.levelProgressRatio : levelProgressRatio // ignore: cast_nullable_to_non_nullable
as double,nextLevelXp: null == nextLevelXp ? _self.nextLevelXp : nextLevelXp // ignore: cast_nullable_to_non_nullable
as int,currentStreakDays: null == currentStreakDays ? _self.currentStreakDays : currentStreakDays // ignore: cast_nullable_to_non_nullable
as int,unlockedBadgeIds: null == unlockedBadgeIds ? _self.unlockedBadgeIds : unlockedBadgeIds // ignore: cast_nullable_to_non_nullable
as List<int>,topFeaturedBadges: null == topFeaturedBadges ? _self.topFeaturedBadges : topFeaturedBadges // ignore: cast_nullable_to_non_nullable
as List<BaristaBadgeItem>,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,totalThreadsCount: null == totalThreadsCount ? _self.totalThreadsCount : totalThreadsCount // ignore: cast_nullable_to_non_nullable
as int,totalBrewsCount: null == totalBrewsCount ? _self.totalBrewsCount : totalBrewsCount // ignore: cast_nullable_to_non_nullable
as int,totalRecipesCreatedCount: null == totalRecipesCreatedCount ? _self.totalRecipesCreatedCount : totalRecipesCreatedCount // ignore: cast_nullable_to_non_nullable
as int,totalRecipeTriesReceived: null == totalRecipeTriesReceived ? _self.totalRecipeTriesReceived : totalRecipeTriesReceived // ignore: cast_nullable_to_non_nullable
as int,recentBrewSnapshot: freezed == recentBrewSnapshot ? _self.recentBrewSnapshot : recentBrewSnapshot // ignore: cast_nullable_to_non_nullable
as RecentBrewSnapshot?,isFollowedByViewer: null == isFollowedByViewer ? _self.isFollowedByViewer : isFollowedByViewer // ignore: cast_nullable_to_non_nullable
as bool,isFollowingViewer: null == isFollowingViewer ? _self.isFollowingViewer : isFollowingViewer // ignore: cast_nullable_to_non_nullable
as bool,isOwnProfile: null == isOwnProfile ? _self.isOwnProfile : isOwnProfile // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of MaterializedProfileView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecentBrewSnapshotCopyWith<$Res>? get recentBrewSnapshot {
    if (_self.recentBrewSnapshot == null) {
    return null;
  }

  return $RecentBrewSnapshotCopyWith<$Res>(_self.recentBrewSnapshot!, (value) {
    return _then(_self.copyWith(recentBrewSnapshot: value));
  });
}
}


/// Adds pattern-matching-related methods to [MaterializedProfileView].
extension MaterializedProfileViewPatterns on MaterializedProfileView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaterializedProfileView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaterializedProfileView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaterializedProfileView value)  $default,){
final _that = this;
switch (_that) {
case _MaterializedProfileView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaterializedProfileView value)?  $default,){
final _that = this;
switch (_that) {
case _MaterializedProfileView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'display_name')  String displayName,  String bio, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'banner_url')  String? bannerUrl, @JsonKey(name: 'account_tier')  String accountTier, @JsonKey(name: 'total_xp')  int totalXp, @JsonKey(name: 'barista_level')  int baristaLevel, @JsonKey(name: 'barista_rank_title')  String baristaRankTitle, @JsonKey(name: 'level_progress_ratio')  double levelProgressRatio, @JsonKey(name: 'next_level_xp')  int nextLevelXp, @JsonKey(name: 'current_streak_days')  int currentStreakDays, @JsonKey(name: 'unlocked_badge_ids')  List<int> unlockedBadgeIds, @JsonKey(name: 'top_featured_badges')  List<BaristaBadgeItem> topFeaturedBadges, @JsonKey(name: 'followers_count')  int followersCount, @JsonKey(name: 'following_count')  int followingCount, @JsonKey(name: 'total_threads_count')  int totalThreadsCount, @JsonKey(name: 'total_brews_count')  int totalBrewsCount, @JsonKey(name: 'total_recipes_created_count')  int totalRecipesCreatedCount, @JsonKey(name: 'total_recipe_tries_received')  int totalRecipeTriesReceived, @JsonKey(name: 'recent_brew_snapshot')  RecentBrewSnapshot? recentBrewSnapshot, @JsonKey(name: 'is_followed_by_viewer')  bool isFollowedByViewer, @JsonKey(name: 'is_following_viewer')  bool isFollowingViewer, @JsonKey(name: 'is_own_profile')  bool isOwnProfile, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaterializedProfileView() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.bio,_that.avatarUrl,_that.bannerUrl,_that.accountTier,_that.totalXp,_that.baristaLevel,_that.baristaRankTitle,_that.levelProgressRatio,_that.nextLevelXp,_that.currentStreakDays,_that.unlockedBadgeIds,_that.topFeaturedBadges,_that.followersCount,_that.followingCount,_that.totalThreadsCount,_that.totalBrewsCount,_that.totalRecipesCreatedCount,_that.totalRecipeTriesReceived,_that.recentBrewSnapshot,_that.isFollowedByViewer,_that.isFollowingViewer,_that.isOwnProfile,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'display_name')  String displayName,  String bio, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'banner_url')  String? bannerUrl, @JsonKey(name: 'account_tier')  String accountTier, @JsonKey(name: 'total_xp')  int totalXp, @JsonKey(name: 'barista_level')  int baristaLevel, @JsonKey(name: 'barista_rank_title')  String baristaRankTitle, @JsonKey(name: 'level_progress_ratio')  double levelProgressRatio, @JsonKey(name: 'next_level_xp')  int nextLevelXp, @JsonKey(name: 'current_streak_days')  int currentStreakDays, @JsonKey(name: 'unlocked_badge_ids')  List<int> unlockedBadgeIds, @JsonKey(name: 'top_featured_badges')  List<BaristaBadgeItem> topFeaturedBadges, @JsonKey(name: 'followers_count')  int followersCount, @JsonKey(name: 'following_count')  int followingCount, @JsonKey(name: 'total_threads_count')  int totalThreadsCount, @JsonKey(name: 'total_brews_count')  int totalBrewsCount, @JsonKey(name: 'total_recipes_created_count')  int totalRecipesCreatedCount, @JsonKey(name: 'total_recipe_tries_received')  int totalRecipeTriesReceived, @JsonKey(name: 'recent_brew_snapshot')  RecentBrewSnapshot? recentBrewSnapshot, @JsonKey(name: 'is_followed_by_viewer')  bool isFollowedByViewer, @JsonKey(name: 'is_following_viewer')  bool isFollowingViewer, @JsonKey(name: 'is_own_profile')  bool isOwnProfile, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MaterializedProfileView():
return $default(_that.userId,_that.username,_that.displayName,_that.bio,_that.avatarUrl,_that.bannerUrl,_that.accountTier,_that.totalXp,_that.baristaLevel,_that.baristaRankTitle,_that.levelProgressRatio,_that.nextLevelXp,_that.currentStreakDays,_that.unlockedBadgeIds,_that.topFeaturedBadges,_that.followersCount,_that.followingCount,_that.totalThreadsCount,_that.totalBrewsCount,_that.totalRecipesCreatedCount,_that.totalRecipeTriesReceived,_that.recentBrewSnapshot,_that.isFollowedByViewer,_that.isFollowingViewer,_that.isOwnProfile,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'display_name')  String displayName,  String bio, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'banner_url')  String? bannerUrl, @JsonKey(name: 'account_tier')  String accountTier, @JsonKey(name: 'total_xp')  int totalXp, @JsonKey(name: 'barista_level')  int baristaLevel, @JsonKey(name: 'barista_rank_title')  String baristaRankTitle, @JsonKey(name: 'level_progress_ratio')  double levelProgressRatio, @JsonKey(name: 'next_level_xp')  int nextLevelXp, @JsonKey(name: 'current_streak_days')  int currentStreakDays, @JsonKey(name: 'unlocked_badge_ids')  List<int> unlockedBadgeIds, @JsonKey(name: 'top_featured_badges')  List<BaristaBadgeItem> topFeaturedBadges, @JsonKey(name: 'followers_count')  int followersCount, @JsonKey(name: 'following_count')  int followingCount, @JsonKey(name: 'total_threads_count')  int totalThreadsCount, @JsonKey(name: 'total_brews_count')  int totalBrewsCount, @JsonKey(name: 'total_recipes_created_count')  int totalRecipesCreatedCount, @JsonKey(name: 'total_recipe_tries_received')  int totalRecipeTriesReceived, @JsonKey(name: 'recent_brew_snapshot')  RecentBrewSnapshot? recentBrewSnapshot, @JsonKey(name: 'is_followed_by_viewer')  bool isFollowedByViewer, @JsonKey(name: 'is_following_viewer')  bool isFollowingViewer, @JsonKey(name: 'is_own_profile')  bool isOwnProfile, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MaterializedProfileView() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.bio,_that.avatarUrl,_that.bannerUrl,_that.accountTier,_that.totalXp,_that.baristaLevel,_that.baristaRankTitle,_that.levelProgressRatio,_that.nextLevelXp,_that.currentStreakDays,_that.unlockedBadgeIds,_that.topFeaturedBadges,_that.followersCount,_that.followingCount,_that.totalThreadsCount,_that.totalBrewsCount,_that.totalRecipesCreatedCount,_that.totalRecipeTriesReceived,_that.recentBrewSnapshot,_that.isFollowedByViewer,_that.isFollowingViewer,_that.isOwnProfile,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MaterializedProfileView extends MaterializedProfileView {
  const _MaterializedProfileView({@JsonKey(name: 'user_id') required this.userId, required this.username, @JsonKey(name: 'display_name') required this.displayName, this.bio = '', @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'banner_url') this.bannerUrl, @JsonKey(name: 'account_tier') this.accountTier = 'Trial', @JsonKey(name: 'total_xp') this.totalXp = 0, @JsonKey(name: 'barista_level') this.baristaLevel = 1, @JsonKey(name: 'barista_rank_title') this.baristaRankTitle = 'Home Brewer', @JsonKey(name: 'level_progress_ratio') this.levelProgressRatio = 0.0, @JsonKey(name: 'next_level_xp') this.nextLevelXp = 313, @JsonKey(name: 'current_streak_days') this.currentStreakDays = 0, @JsonKey(name: 'unlocked_badge_ids')  List<int> unlockedBadgeIds = const [], @JsonKey(name: 'top_featured_badges')  List<BaristaBadgeItem> topFeaturedBadges = const [], @JsonKey(name: 'followers_count') this.followersCount = 0, @JsonKey(name: 'following_count') this.followingCount = 0, @JsonKey(name: 'total_threads_count') this.totalThreadsCount = 0, @JsonKey(name: 'total_brews_count') this.totalBrewsCount = 0, @JsonKey(name: 'total_recipes_created_count') this.totalRecipesCreatedCount = 0, @JsonKey(name: 'total_recipe_tries_received') this.totalRecipeTriesReceived = 0, @JsonKey(name: 'recent_brew_snapshot') this.recentBrewSnapshot, @JsonKey(name: 'is_followed_by_viewer') this.isFollowedByViewer = false, @JsonKey(name: 'is_following_viewer') this.isFollowingViewer = false, @JsonKey(name: 'is_own_profile') this.isOwnProfile = false, @JsonKey(name: 'updated_at') this.updatedAt}): _unlockedBadgeIds = unlockedBadgeIds,_topFeaturedBadges = topFeaturedBadges,super._();
  factory _MaterializedProfileView.fromJson(Map<String, dynamic> json) => _$MaterializedProfileViewFromJson(json);

@override@JsonKey(name: 'user_id') final  String userId;
@override final  String username;
@override@JsonKey(name: 'display_name') final  String displayName;
@override@JsonKey() final  String bio;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'banner_url') final  String? bannerUrl;
@override@JsonKey(name: 'account_tier') final  String accountTier;
@override@JsonKey(name: 'total_xp') final  int totalXp;
@override@JsonKey(name: 'barista_level') final  int baristaLevel;
@override@JsonKey(name: 'barista_rank_title') final  String baristaRankTitle;
@override@JsonKey(name: 'level_progress_ratio') final  double levelProgressRatio;
@override@JsonKey(name: 'next_level_xp') final  int nextLevelXp;
@override@JsonKey(name: 'current_streak_days') final  int currentStreakDays;
 final  List<int> _unlockedBadgeIds;
@override@JsonKey(name: 'unlocked_badge_ids') List<int> get unlockedBadgeIds {
  if (_unlockedBadgeIds is EqualUnmodifiableListView) return _unlockedBadgeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unlockedBadgeIds);
}

 final  List<BaristaBadgeItem> _topFeaturedBadges;
@override@JsonKey(name: 'top_featured_badges') List<BaristaBadgeItem> get topFeaturedBadges {
  if (_topFeaturedBadges is EqualUnmodifiableListView) return _topFeaturedBadges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topFeaturedBadges);
}

@override@JsonKey(name: 'followers_count') final  int followersCount;
@override@JsonKey(name: 'following_count') final  int followingCount;
@override@JsonKey(name: 'total_threads_count') final  int totalThreadsCount;
@override@JsonKey(name: 'total_brews_count') final  int totalBrewsCount;
@override@JsonKey(name: 'total_recipes_created_count') final  int totalRecipesCreatedCount;
@override@JsonKey(name: 'total_recipe_tries_received') final  int totalRecipeTriesReceived;
@override@JsonKey(name: 'recent_brew_snapshot') final  RecentBrewSnapshot? recentBrewSnapshot;
@override@JsonKey(name: 'is_followed_by_viewer') final  bool isFollowedByViewer;
@override@JsonKey(name: 'is_following_viewer') final  bool isFollowingViewer;
@override@JsonKey(name: 'is_own_profile') final  bool isOwnProfile;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of MaterializedProfileView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaterializedProfileViewCopyWith<_MaterializedProfileView> get copyWith => __$MaterializedProfileViewCopyWithImpl<_MaterializedProfileView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaterializedProfileViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaterializedProfileView&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.accountTier, accountTier) || other.accountTier == accountTier)&&(identical(other.totalXp, totalXp) || other.totalXp == totalXp)&&(identical(other.baristaLevel, baristaLevel) || other.baristaLevel == baristaLevel)&&(identical(other.baristaRankTitle, baristaRankTitle) || other.baristaRankTitle == baristaRankTitle)&&(identical(other.levelProgressRatio, levelProgressRatio) || other.levelProgressRatio == levelProgressRatio)&&(identical(other.nextLevelXp, nextLevelXp) || other.nextLevelXp == nextLevelXp)&&(identical(other.currentStreakDays, currentStreakDays) || other.currentStreakDays == currentStreakDays)&&const DeepCollectionEquality().equals(other._unlockedBadgeIds, _unlockedBadgeIds)&&const DeepCollectionEquality().equals(other._topFeaturedBadges, _topFeaturedBadges)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.totalThreadsCount, totalThreadsCount) || other.totalThreadsCount == totalThreadsCount)&&(identical(other.totalBrewsCount, totalBrewsCount) || other.totalBrewsCount == totalBrewsCount)&&(identical(other.totalRecipesCreatedCount, totalRecipesCreatedCount) || other.totalRecipesCreatedCount == totalRecipesCreatedCount)&&(identical(other.totalRecipeTriesReceived, totalRecipeTriesReceived) || other.totalRecipeTriesReceived == totalRecipeTriesReceived)&&(identical(other.recentBrewSnapshot, recentBrewSnapshot) || other.recentBrewSnapshot == recentBrewSnapshot)&&(identical(other.isFollowedByViewer, isFollowedByViewer) || other.isFollowedByViewer == isFollowedByViewer)&&(identical(other.isFollowingViewer, isFollowingViewer) || other.isFollowingViewer == isFollowingViewer)&&(identical(other.isOwnProfile, isOwnProfile) || other.isOwnProfile == isOwnProfile)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,userId,username,displayName,bio,avatarUrl,bannerUrl,accountTier,totalXp,baristaLevel,baristaRankTitle,levelProgressRatio,nextLevelXp,currentStreakDays,const DeepCollectionEquality().hash(_unlockedBadgeIds),const DeepCollectionEquality().hash(_topFeaturedBadges),followersCount,followingCount,totalThreadsCount,totalBrewsCount,totalRecipesCreatedCount,totalRecipeTriesReceived,recentBrewSnapshot,isFollowedByViewer,isFollowingViewer,isOwnProfile,updatedAt]);

@override
String toString() {
  return 'MaterializedProfileView(userId: $userId, username: $username, displayName: $displayName, bio: $bio, avatarUrl: $avatarUrl, bannerUrl: $bannerUrl, accountTier: $accountTier, totalXp: $totalXp, baristaLevel: $baristaLevel, baristaRankTitle: $baristaRankTitle, levelProgressRatio: $levelProgressRatio, nextLevelXp: $nextLevelXp, currentStreakDays: $currentStreakDays, unlockedBadgeIds: $unlockedBadgeIds, topFeaturedBadges: $topFeaturedBadges, followersCount: $followersCount, followingCount: $followingCount, totalThreadsCount: $totalThreadsCount, totalBrewsCount: $totalBrewsCount, totalRecipesCreatedCount: $totalRecipesCreatedCount, totalRecipeTriesReceived: $totalRecipeTriesReceived, recentBrewSnapshot: $recentBrewSnapshot, isFollowedByViewer: $isFollowedByViewer, isFollowingViewer: $isFollowingViewer, isOwnProfile: $isOwnProfile, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MaterializedProfileViewCopyWith<$Res> implements $MaterializedProfileViewCopyWith<$Res> {
  factory _$MaterializedProfileViewCopyWith(_MaterializedProfileView value, $Res Function(_MaterializedProfileView) _then) = __$MaterializedProfileViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String username,@JsonKey(name: 'display_name') String displayName, String bio,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'banner_url') String? bannerUrl,@JsonKey(name: 'account_tier') String accountTier,@JsonKey(name: 'total_xp') int totalXp,@JsonKey(name: 'barista_level') int baristaLevel,@JsonKey(name: 'barista_rank_title') String baristaRankTitle,@JsonKey(name: 'level_progress_ratio') double levelProgressRatio,@JsonKey(name: 'next_level_xp') int nextLevelXp,@JsonKey(name: 'current_streak_days') int currentStreakDays,@JsonKey(name: 'unlocked_badge_ids') List<int> unlockedBadgeIds,@JsonKey(name: 'top_featured_badges') List<BaristaBadgeItem> topFeaturedBadges,@JsonKey(name: 'followers_count') int followersCount,@JsonKey(name: 'following_count') int followingCount,@JsonKey(name: 'total_threads_count') int totalThreadsCount,@JsonKey(name: 'total_brews_count') int totalBrewsCount,@JsonKey(name: 'total_recipes_created_count') int totalRecipesCreatedCount,@JsonKey(name: 'total_recipe_tries_received') int totalRecipeTriesReceived,@JsonKey(name: 'recent_brew_snapshot') RecentBrewSnapshot? recentBrewSnapshot,@JsonKey(name: 'is_followed_by_viewer') bool isFollowedByViewer,@JsonKey(name: 'is_following_viewer') bool isFollowingViewer,@JsonKey(name: 'is_own_profile') bool isOwnProfile,@JsonKey(name: 'updated_at') DateTime? updatedAt
});


@override $RecentBrewSnapshotCopyWith<$Res>? get recentBrewSnapshot;

}
/// @nodoc
class __$MaterializedProfileViewCopyWithImpl<$Res>
    implements _$MaterializedProfileViewCopyWith<$Res> {
  __$MaterializedProfileViewCopyWithImpl(this._self, this._then);

  final _MaterializedProfileView _self;
  final $Res Function(_MaterializedProfileView) _then;

/// Create a copy of MaterializedProfileView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? bio = null,Object? avatarUrl = freezed,Object? bannerUrl = freezed,Object? accountTier = null,Object? totalXp = null,Object? baristaLevel = null,Object? baristaRankTitle = null,Object? levelProgressRatio = null,Object? nextLevelXp = null,Object? currentStreakDays = null,Object? unlockedBadgeIds = null,Object? topFeaturedBadges = null,Object? followersCount = null,Object? followingCount = null,Object? totalThreadsCount = null,Object? totalBrewsCount = null,Object? totalRecipesCreatedCount = null,Object? totalRecipeTriesReceived = null,Object? recentBrewSnapshot = freezed,Object? isFollowedByViewer = null,Object? isFollowingViewer = null,Object? isOwnProfile = null,Object? updatedAt = freezed,}) {
  return _then(_MaterializedProfileView(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,accountTier: null == accountTier ? _self.accountTier : accountTier // ignore: cast_nullable_to_non_nullable
as String,totalXp: null == totalXp ? _self.totalXp : totalXp // ignore: cast_nullable_to_non_nullable
as int,baristaLevel: null == baristaLevel ? _self.baristaLevel : baristaLevel // ignore: cast_nullable_to_non_nullable
as int,baristaRankTitle: null == baristaRankTitle ? _self.baristaRankTitle : baristaRankTitle // ignore: cast_nullable_to_non_nullable
as String,levelProgressRatio: null == levelProgressRatio ? _self.levelProgressRatio : levelProgressRatio // ignore: cast_nullable_to_non_nullable
as double,nextLevelXp: null == nextLevelXp ? _self.nextLevelXp : nextLevelXp // ignore: cast_nullable_to_non_nullable
as int,currentStreakDays: null == currentStreakDays ? _self.currentStreakDays : currentStreakDays // ignore: cast_nullable_to_non_nullable
as int,unlockedBadgeIds: null == unlockedBadgeIds ? _self._unlockedBadgeIds : unlockedBadgeIds // ignore: cast_nullable_to_non_nullable
as List<int>,topFeaturedBadges: null == topFeaturedBadges ? _self._topFeaturedBadges : topFeaturedBadges // ignore: cast_nullable_to_non_nullable
as List<BaristaBadgeItem>,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,totalThreadsCount: null == totalThreadsCount ? _self.totalThreadsCount : totalThreadsCount // ignore: cast_nullable_to_non_nullable
as int,totalBrewsCount: null == totalBrewsCount ? _self.totalBrewsCount : totalBrewsCount // ignore: cast_nullable_to_non_nullable
as int,totalRecipesCreatedCount: null == totalRecipesCreatedCount ? _self.totalRecipesCreatedCount : totalRecipesCreatedCount // ignore: cast_nullable_to_non_nullable
as int,totalRecipeTriesReceived: null == totalRecipeTriesReceived ? _self.totalRecipeTriesReceived : totalRecipeTriesReceived // ignore: cast_nullable_to_non_nullable
as int,recentBrewSnapshot: freezed == recentBrewSnapshot ? _self.recentBrewSnapshot : recentBrewSnapshot // ignore: cast_nullable_to_non_nullable
as RecentBrewSnapshot?,isFollowedByViewer: null == isFollowedByViewer ? _self.isFollowedByViewer : isFollowedByViewer // ignore: cast_nullable_to_non_nullable
as bool,isFollowingViewer: null == isFollowingViewer ? _self.isFollowingViewer : isFollowingViewer // ignore: cast_nullable_to_non_nullable
as bool,isOwnProfile: null == isOwnProfile ? _self.isOwnProfile : isOwnProfile // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of MaterializedProfileView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecentBrewSnapshotCopyWith<$Res>? get recentBrewSnapshot {
    if (_self.recentBrewSnapshot == null) {
    return null;
  }

  return $RecentBrewSnapshotCopyWith<$Res>(_self.recentBrewSnapshot!, (value) {
    return _then(_self.copyWith(recentBrewSnapshot: value));
  });
}
}


/// @nodoc
mixin _$ProfileDirectoryEntry {

@JsonKey(name: 'user_id') String get userId; String get username;@JsonKey(name: 'display_name') String get displayName; String get bio;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'account_tier') String get accountTier;@JsonKey(name: 'total_xp') int get totalXp;@JsonKey(name: 'barista_level') int get baristaLevel;@JsonKey(name: 'barista_rank_title') String get baristaRankTitle;@JsonKey(name: 'followers_count') int get followersCount;@JsonKey(name: 'total_threads_count') int get totalThreadsCount;@JsonKey(name: 'recent_brew_snapshot') RecentBrewSnapshot? get recentBrewSnapshot;@JsonKey(name: 'is_followed_by_viewer') bool get isFollowedByViewer;
/// Create a copy of ProfileDirectoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileDirectoryEntryCopyWith<ProfileDirectoryEntry> get copyWith => _$ProfileDirectoryEntryCopyWithImpl<ProfileDirectoryEntry>(this as ProfileDirectoryEntry, _$identity);

  /// Serializes this ProfileDirectoryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileDirectoryEntry&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.accountTier, accountTier) || other.accountTier == accountTier)&&(identical(other.totalXp, totalXp) || other.totalXp == totalXp)&&(identical(other.baristaLevel, baristaLevel) || other.baristaLevel == baristaLevel)&&(identical(other.baristaRankTitle, baristaRankTitle) || other.baristaRankTitle == baristaRankTitle)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.totalThreadsCount, totalThreadsCount) || other.totalThreadsCount == totalThreadsCount)&&(identical(other.recentBrewSnapshot, recentBrewSnapshot) || other.recentBrewSnapshot == recentBrewSnapshot)&&(identical(other.isFollowedByViewer, isFollowedByViewer) || other.isFollowedByViewer == isFollowedByViewer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,bio,avatarUrl,accountTier,totalXp,baristaLevel,baristaRankTitle,followersCount,totalThreadsCount,recentBrewSnapshot,isFollowedByViewer);

@override
String toString() {
  return 'ProfileDirectoryEntry(userId: $userId, username: $username, displayName: $displayName, bio: $bio, avatarUrl: $avatarUrl, accountTier: $accountTier, totalXp: $totalXp, baristaLevel: $baristaLevel, baristaRankTitle: $baristaRankTitle, followersCount: $followersCount, totalThreadsCount: $totalThreadsCount, recentBrewSnapshot: $recentBrewSnapshot, isFollowedByViewer: $isFollowedByViewer)';
}


}

/// @nodoc
abstract mixin class $ProfileDirectoryEntryCopyWith<$Res>  {
  factory $ProfileDirectoryEntryCopyWith(ProfileDirectoryEntry value, $Res Function(ProfileDirectoryEntry) _then) = _$ProfileDirectoryEntryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String username,@JsonKey(name: 'display_name') String displayName, String bio,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'account_tier') String accountTier,@JsonKey(name: 'total_xp') int totalXp,@JsonKey(name: 'barista_level') int baristaLevel,@JsonKey(name: 'barista_rank_title') String baristaRankTitle,@JsonKey(name: 'followers_count') int followersCount,@JsonKey(name: 'total_threads_count') int totalThreadsCount,@JsonKey(name: 'recent_brew_snapshot') RecentBrewSnapshot? recentBrewSnapshot,@JsonKey(name: 'is_followed_by_viewer') bool isFollowedByViewer
});


$RecentBrewSnapshotCopyWith<$Res>? get recentBrewSnapshot;

}
/// @nodoc
class _$ProfileDirectoryEntryCopyWithImpl<$Res>
    implements $ProfileDirectoryEntryCopyWith<$Res> {
  _$ProfileDirectoryEntryCopyWithImpl(this._self, this._then);

  final ProfileDirectoryEntry _self;
  final $Res Function(ProfileDirectoryEntry) _then;

/// Create a copy of ProfileDirectoryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? bio = null,Object? avatarUrl = freezed,Object? accountTier = null,Object? totalXp = null,Object? baristaLevel = null,Object? baristaRankTitle = null,Object? followersCount = null,Object? totalThreadsCount = null,Object? recentBrewSnapshot = freezed,Object? isFollowedByViewer = null,}) {
  return _then(ProfileDirectoryEntry(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,accountTier: null == accountTier ? _self.accountTier : accountTier // ignore: cast_nullable_to_non_nullable
as String,totalXp: null == totalXp ? _self.totalXp : totalXp // ignore: cast_nullable_to_non_nullable
as int,baristaLevel: null == baristaLevel ? _self.baristaLevel : baristaLevel // ignore: cast_nullable_to_non_nullable
as int,baristaRankTitle: null == baristaRankTitle ? _self.baristaRankTitle : baristaRankTitle // ignore: cast_nullable_to_non_nullable
as String,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,totalThreadsCount: null == totalThreadsCount ? _self.totalThreadsCount : totalThreadsCount // ignore: cast_nullable_to_non_nullable
as int,recentBrewSnapshot: freezed == recentBrewSnapshot ? _self.recentBrewSnapshot : recentBrewSnapshot // ignore: cast_nullable_to_non_nullable
as RecentBrewSnapshot?,isFollowedByViewer: null == isFollowedByViewer ? _self.isFollowedByViewer : isFollowedByViewer // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ProfileDirectoryEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecentBrewSnapshotCopyWith<$Res>? get recentBrewSnapshot {
    if (_self.recentBrewSnapshot == null) {
    return null;
  }

  return $RecentBrewSnapshotCopyWith<$Res>(_self.recentBrewSnapshot!, (value) {
    return _then(_self.copyWith(recentBrewSnapshot: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProfileDirectoryEntry].
extension ProfileDirectoryEntryPatterns on ProfileDirectoryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileDirectoryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileDirectoryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileDirectoryEntry value)  $default,){
final _that = this;
switch (_that) {
case _ProfileDirectoryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileDirectoryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileDirectoryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'display_name')  String displayName,  String bio, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'account_tier')  String accountTier, @JsonKey(name: 'total_xp')  int totalXp, @JsonKey(name: 'barista_level')  int baristaLevel, @JsonKey(name: 'barista_rank_title')  String baristaRankTitle, @JsonKey(name: 'followers_count')  int followersCount, @JsonKey(name: 'total_threads_count')  int totalThreadsCount, @JsonKey(name: 'recent_brew_snapshot')  RecentBrewSnapshot? recentBrewSnapshot, @JsonKey(name: 'is_followed_by_viewer')  bool isFollowedByViewer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileDirectoryEntry() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.bio,_that.avatarUrl,_that.accountTier,_that.totalXp,_that.baristaLevel,_that.baristaRankTitle,_that.followersCount,_that.totalThreadsCount,_that.recentBrewSnapshot,_that.isFollowedByViewer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'display_name')  String displayName,  String bio, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'account_tier')  String accountTier, @JsonKey(name: 'total_xp')  int totalXp, @JsonKey(name: 'barista_level')  int baristaLevel, @JsonKey(name: 'barista_rank_title')  String baristaRankTitle, @JsonKey(name: 'followers_count')  int followersCount, @JsonKey(name: 'total_threads_count')  int totalThreadsCount, @JsonKey(name: 'recent_brew_snapshot')  RecentBrewSnapshot? recentBrewSnapshot, @JsonKey(name: 'is_followed_by_viewer')  bool isFollowedByViewer)  $default,) {final _that = this;
switch (_that) {
case _ProfileDirectoryEntry():
return $default(_that.userId,_that.username,_that.displayName,_that.bio,_that.avatarUrl,_that.accountTier,_that.totalXp,_that.baristaLevel,_that.baristaRankTitle,_that.followersCount,_that.totalThreadsCount,_that.recentBrewSnapshot,_that.isFollowedByViewer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId,  String username, @JsonKey(name: 'display_name')  String displayName,  String bio, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'account_tier')  String accountTier, @JsonKey(name: 'total_xp')  int totalXp, @JsonKey(name: 'barista_level')  int baristaLevel, @JsonKey(name: 'barista_rank_title')  String baristaRankTitle, @JsonKey(name: 'followers_count')  int followersCount, @JsonKey(name: 'total_threads_count')  int totalThreadsCount, @JsonKey(name: 'recent_brew_snapshot')  RecentBrewSnapshot? recentBrewSnapshot, @JsonKey(name: 'is_followed_by_viewer')  bool isFollowedByViewer)?  $default,) {final _that = this;
switch (_that) {
case _ProfileDirectoryEntry() when $default != null:
return $default(_that.userId,_that.username,_that.displayName,_that.bio,_that.avatarUrl,_that.accountTier,_that.totalXp,_that.baristaLevel,_that.baristaRankTitle,_that.followersCount,_that.totalThreadsCount,_that.recentBrewSnapshot,_that.isFollowedByViewer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileDirectoryEntry implements ProfileDirectoryEntry {
  const _ProfileDirectoryEntry({@JsonKey(name: 'user_id') required this.userId, required this.username, @JsonKey(name: 'display_name') required this.displayName, this.bio = '', @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'account_tier') this.accountTier = 'Trial', @JsonKey(name: 'total_xp') this.totalXp = 0, @JsonKey(name: 'barista_level') this.baristaLevel = 1, @JsonKey(name: 'barista_rank_title') this.baristaRankTitle = 'Home Brewer', @JsonKey(name: 'followers_count') this.followersCount = 0, @JsonKey(name: 'total_threads_count') this.totalThreadsCount = 0, @JsonKey(name: 'recent_brew_snapshot') this.recentBrewSnapshot, @JsonKey(name: 'is_followed_by_viewer') this.isFollowedByViewer = false});
  factory _ProfileDirectoryEntry.fromJson(Map<String, dynamic> json) => _$ProfileDirectoryEntryFromJson(json);

@override@JsonKey(name: 'user_id') final  String userId;
@override final  String username;
@override@JsonKey(name: 'display_name') final  String displayName;
@override@JsonKey() final  String bio;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'account_tier') final  String accountTier;
@override@JsonKey(name: 'total_xp') final  int totalXp;
@override@JsonKey(name: 'barista_level') final  int baristaLevel;
@override@JsonKey(name: 'barista_rank_title') final  String baristaRankTitle;
@override@JsonKey(name: 'followers_count') final  int followersCount;
@override@JsonKey(name: 'total_threads_count') final  int totalThreadsCount;
@override@JsonKey(name: 'recent_brew_snapshot') final  RecentBrewSnapshot? recentBrewSnapshot;
@override@JsonKey(name: 'is_followed_by_viewer') final  bool isFollowedByViewer;

/// Create a copy of ProfileDirectoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileDirectoryEntryCopyWith<_ProfileDirectoryEntry> get copyWith => __$ProfileDirectoryEntryCopyWithImpl<_ProfileDirectoryEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileDirectoryEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileDirectoryEntry&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.accountTier, accountTier) || other.accountTier == accountTier)&&(identical(other.totalXp, totalXp) || other.totalXp == totalXp)&&(identical(other.baristaLevel, baristaLevel) || other.baristaLevel == baristaLevel)&&(identical(other.baristaRankTitle, baristaRankTitle) || other.baristaRankTitle == baristaRankTitle)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.totalThreadsCount, totalThreadsCount) || other.totalThreadsCount == totalThreadsCount)&&(identical(other.recentBrewSnapshot, recentBrewSnapshot) || other.recentBrewSnapshot == recentBrewSnapshot)&&(identical(other.isFollowedByViewer, isFollowedByViewer) || other.isFollowedByViewer == isFollowedByViewer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,displayName,bio,avatarUrl,accountTier,totalXp,baristaLevel,baristaRankTitle,followersCount,totalThreadsCount,recentBrewSnapshot,isFollowedByViewer);

@override
String toString() {
  return 'ProfileDirectoryEntry(userId: $userId, username: $username, displayName: $displayName, bio: $bio, avatarUrl: $avatarUrl, accountTier: $accountTier, totalXp: $totalXp, baristaLevel: $baristaLevel, baristaRankTitle: $baristaRankTitle, followersCount: $followersCount, totalThreadsCount: $totalThreadsCount, recentBrewSnapshot: $recentBrewSnapshot, isFollowedByViewer: $isFollowedByViewer)';
}


}

/// @nodoc
abstract mixin class _$ProfileDirectoryEntryCopyWith<$Res> implements $ProfileDirectoryEntryCopyWith<$Res> {
  factory _$ProfileDirectoryEntryCopyWith(_ProfileDirectoryEntry value, $Res Function(_ProfileDirectoryEntry) _then) = __$ProfileDirectoryEntryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId, String username,@JsonKey(name: 'display_name') String displayName, String bio,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'account_tier') String accountTier,@JsonKey(name: 'total_xp') int totalXp,@JsonKey(name: 'barista_level') int baristaLevel,@JsonKey(name: 'barista_rank_title') String baristaRankTitle,@JsonKey(name: 'followers_count') int followersCount,@JsonKey(name: 'total_threads_count') int totalThreadsCount,@JsonKey(name: 'recent_brew_snapshot') RecentBrewSnapshot? recentBrewSnapshot,@JsonKey(name: 'is_followed_by_viewer') bool isFollowedByViewer
});


@override $RecentBrewSnapshotCopyWith<$Res>? get recentBrewSnapshot;

}
/// @nodoc
class __$ProfileDirectoryEntryCopyWithImpl<$Res>
    implements _$ProfileDirectoryEntryCopyWith<$Res> {
  __$ProfileDirectoryEntryCopyWithImpl(this._self, this._then);

  final _ProfileDirectoryEntry _self;
  final $Res Function(_ProfileDirectoryEntry) _then;

/// Create a copy of ProfileDirectoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? displayName = null,Object? bio = null,Object? avatarUrl = freezed,Object? accountTier = null,Object? totalXp = null,Object? baristaLevel = null,Object? baristaRankTitle = null,Object? followersCount = null,Object? totalThreadsCount = null,Object? recentBrewSnapshot = freezed,Object? isFollowedByViewer = null,}) {
  return _then(_ProfileDirectoryEntry(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,accountTier: null == accountTier ? _self.accountTier : accountTier // ignore: cast_nullable_to_non_nullable
as String,totalXp: null == totalXp ? _self.totalXp : totalXp // ignore: cast_nullable_to_non_nullable
as int,baristaLevel: null == baristaLevel ? _self.baristaLevel : baristaLevel // ignore: cast_nullable_to_non_nullable
as int,baristaRankTitle: null == baristaRankTitle ? _self.baristaRankTitle : baristaRankTitle // ignore: cast_nullable_to_non_nullable
as String,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,totalThreadsCount: null == totalThreadsCount ? _self.totalThreadsCount : totalThreadsCount // ignore: cast_nullable_to_non_nullable
as int,recentBrewSnapshot: freezed == recentBrewSnapshot ? _self.recentBrewSnapshot : recentBrewSnapshot // ignore: cast_nullable_to_non_nullable
as RecentBrewSnapshot?,isFollowedByViewer: null == isFollowedByViewer ? _self.isFollowedByViewer : isFollowedByViewer // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ProfileDirectoryEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecentBrewSnapshotCopyWith<$Res>? get recentBrewSnapshot {
    if (_self.recentBrewSnapshot == null) {
    return null;
  }

  return $RecentBrewSnapshotCopyWith<$Res>(_self.recentBrewSnapshot!, (value) {
    return _then(_self.copyWith(recentBrewSnapshot: value));
  });
}
}


/// @nodoc
mixin _$FollowToggleResult {

@JsonKey(name: 'target_user_id') String get targetUserId;@JsonKey(name: 'is_followed_by_viewer') bool get isFollowedByViewer;@JsonKey(name: 'followers_count') int get followersCount;
/// Create a copy of FollowToggleResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowToggleResultCopyWith<FollowToggleResult> get copyWith => _$FollowToggleResultCopyWithImpl<FollowToggleResult>(this as FollowToggleResult, _$identity);

  /// Serializes this FollowToggleResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowToggleResult&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.isFollowedByViewer, isFollowedByViewer) || other.isFollowedByViewer == isFollowedByViewer)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,targetUserId,isFollowedByViewer,followersCount);

@override
String toString() {
  return 'FollowToggleResult(targetUserId: $targetUserId, isFollowedByViewer: $isFollowedByViewer, followersCount: $followersCount)';
}


}

/// @nodoc
abstract mixin class $FollowToggleResultCopyWith<$Res>  {
  factory $FollowToggleResultCopyWith(FollowToggleResult value, $Res Function(FollowToggleResult) _then) = _$FollowToggleResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'target_user_id') String targetUserId,@JsonKey(name: 'is_followed_by_viewer') bool isFollowedByViewer,@JsonKey(name: 'followers_count') int followersCount
});




}
/// @nodoc
class _$FollowToggleResultCopyWithImpl<$Res>
    implements $FollowToggleResultCopyWith<$Res> {
  _$FollowToggleResultCopyWithImpl(this._self, this._then);

  final FollowToggleResult _self;
  final $Res Function(FollowToggleResult) _then;

/// Create a copy of FollowToggleResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targetUserId = null,Object? isFollowedByViewer = null,Object? followersCount = null,}) {
  return _then(FollowToggleResult(
targetUserId: null == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String,isFollowedByViewer: null == isFollowedByViewer ? _self.isFollowedByViewer : isFollowedByViewer // ignore: cast_nullable_to_non_nullable
as bool,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowToggleResult].
extension FollowToggleResultPatterns on FollowToggleResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowToggleResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowToggleResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowToggleResult value)  $default,){
final _that = this;
switch (_that) {
case _FollowToggleResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowToggleResult value)?  $default,){
final _that = this;
switch (_that) {
case _FollowToggleResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'target_user_id')  String targetUserId, @JsonKey(name: 'is_followed_by_viewer')  bool isFollowedByViewer, @JsonKey(name: 'followers_count')  int followersCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowToggleResult() when $default != null:
return $default(_that.targetUserId,_that.isFollowedByViewer,_that.followersCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'target_user_id')  String targetUserId, @JsonKey(name: 'is_followed_by_viewer')  bool isFollowedByViewer, @JsonKey(name: 'followers_count')  int followersCount)  $default,) {final _that = this;
switch (_that) {
case _FollowToggleResult():
return $default(_that.targetUserId,_that.isFollowedByViewer,_that.followersCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'target_user_id')  String targetUserId, @JsonKey(name: 'is_followed_by_viewer')  bool isFollowedByViewer, @JsonKey(name: 'followers_count')  int followersCount)?  $default,) {final _that = this;
switch (_that) {
case _FollowToggleResult() when $default != null:
return $default(_that.targetUserId,_that.isFollowedByViewer,_that.followersCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FollowToggleResult implements FollowToggleResult {
  const _FollowToggleResult({@JsonKey(name: 'target_user_id') required this.targetUserId, @JsonKey(name: 'is_followed_by_viewer') required this.isFollowedByViewer, @JsonKey(name: 'followers_count') required this.followersCount});
  factory _FollowToggleResult.fromJson(Map<String, dynamic> json) => _$FollowToggleResultFromJson(json);

@override@JsonKey(name: 'target_user_id') final  String targetUserId;
@override@JsonKey(name: 'is_followed_by_viewer') final  bool isFollowedByViewer;
@override@JsonKey(name: 'followers_count') final  int followersCount;

/// Create a copy of FollowToggleResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowToggleResultCopyWith<_FollowToggleResult> get copyWith => __$FollowToggleResultCopyWithImpl<_FollowToggleResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowToggleResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowToggleResult&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.isFollowedByViewer, isFollowedByViewer) || other.isFollowedByViewer == isFollowedByViewer)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,targetUserId,isFollowedByViewer,followersCount);

@override
String toString() {
  return 'FollowToggleResult(targetUserId: $targetUserId, isFollowedByViewer: $isFollowedByViewer, followersCount: $followersCount)';
}


}

/// @nodoc
abstract mixin class _$FollowToggleResultCopyWith<$Res> implements $FollowToggleResultCopyWith<$Res> {
  factory _$FollowToggleResultCopyWith(_FollowToggleResult value, $Res Function(_FollowToggleResult) _then) = __$FollowToggleResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'target_user_id') String targetUserId,@JsonKey(name: 'is_followed_by_viewer') bool isFollowedByViewer,@JsonKey(name: 'followers_count') int followersCount
});




}
/// @nodoc
class __$FollowToggleResultCopyWithImpl<$Res>
    implements _$FollowToggleResultCopyWith<$Res> {
  __$FollowToggleResultCopyWithImpl(this._self, this._then);

  final _FollowToggleResult _self;
  final $Res Function(_FollowToggleResult) _then;

/// Create a copy of FollowToggleResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetUserId = null,Object? isFollowedByViewer = null,Object? followersCount = null,}) {
  return _then(_FollowToggleResult(
targetUserId: null == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as String,isFollowedByViewer: null == isFollowedByViewer ? _self.isFollowedByViewer : isFollowedByViewer // ignore: cast_nullable_to_non_nullable
as bool,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
