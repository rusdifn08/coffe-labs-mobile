// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coffee_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoffeeCard {

 String? get id; String get beanName; String get origin; String get roaster; int get acidityLevel; int get bodyLevel; int get sweetnessLevel; String get flavorNotes; DateTime get tastedAt;
/// Create a copy of CoffeeCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoffeeCardCopyWith<CoffeeCard> get copyWith => _$CoffeeCardCopyWithImpl<CoffeeCard>(this as CoffeeCard, _$identity);

  /// Serializes this CoffeeCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoffeeCard&&(identical(other.id, id) || other.id == id)&&(identical(other.beanName, beanName) || other.beanName == beanName)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.roaster, roaster) || other.roaster == roaster)&&(identical(other.acidityLevel, acidityLevel) || other.acidityLevel == acidityLevel)&&(identical(other.bodyLevel, bodyLevel) || other.bodyLevel == bodyLevel)&&(identical(other.sweetnessLevel, sweetnessLevel) || other.sweetnessLevel == sweetnessLevel)&&(identical(other.flavorNotes, flavorNotes) || other.flavorNotes == flavorNotes)&&(identical(other.tastedAt, tastedAt) || other.tastedAt == tastedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,beanName,origin,roaster,acidityLevel,bodyLevel,sweetnessLevel,flavorNotes,tastedAt);

@override
String toString() {
  return 'CoffeeCard(id: $id, beanName: $beanName, origin: $origin, roaster: $roaster, acidityLevel: $acidityLevel, bodyLevel: $bodyLevel, sweetnessLevel: $sweetnessLevel, flavorNotes: $flavorNotes, tastedAt: $tastedAt)';
}


}

/// @nodoc
abstract mixin class $CoffeeCardCopyWith<$Res>  {
  factory $CoffeeCardCopyWith(CoffeeCard value, $Res Function(CoffeeCard) _then) = _$CoffeeCardCopyWithImpl;
@useResult
$Res call({
 String? id, String beanName, String origin, String roaster, int acidityLevel, int bodyLevel, int sweetnessLevel, String flavorNotes, DateTime tastedAt
});




}
/// @nodoc
class _$CoffeeCardCopyWithImpl<$Res>
    implements $CoffeeCardCopyWith<$Res> {
  _$CoffeeCardCopyWithImpl(this._self, this._then);

  final CoffeeCard _self;
  final $Res Function(CoffeeCard) _then;

/// Create a copy of CoffeeCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? beanName = null,Object? origin = null,Object? roaster = null,Object? acidityLevel = null,Object? bodyLevel = null,Object? sweetnessLevel = null,Object? flavorNotes = null,Object? tastedAt = null,}) {
  return _then(CoffeeCard(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,beanName: null == beanName ? _self.beanName : beanName // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,roaster: null == roaster ? _self.roaster : roaster // ignore: cast_nullable_to_non_nullable
as String,acidityLevel: null == acidityLevel ? _self.acidityLevel : acidityLevel // ignore: cast_nullable_to_non_nullable
as int,bodyLevel: null == bodyLevel ? _self.bodyLevel : bodyLevel // ignore: cast_nullable_to_non_nullable
as int,sweetnessLevel: null == sweetnessLevel ? _self.sweetnessLevel : sweetnessLevel // ignore: cast_nullable_to_non_nullable
as int,flavorNotes: null == flavorNotes ? _self.flavorNotes : flavorNotes // ignore: cast_nullable_to_non_nullable
as String,tastedAt: null == tastedAt ? _self.tastedAt : tastedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CoffeeCard].
extension CoffeeCardPatterns on CoffeeCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoffeeCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoffeeCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoffeeCard value)  $default,){
final _that = this;
switch (_that) {
case _CoffeeCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoffeeCard value)?  $default,){
final _that = this;
switch (_that) {
case _CoffeeCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String beanName,  String origin,  String roaster,  int acidityLevel,  int bodyLevel,  int sweetnessLevel,  String flavorNotes,  DateTime tastedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoffeeCard() when $default != null:
return $default(_that.id,_that.beanName,_that.origin,_that.roaster,_that.acidityLevel,_that.bodyLevel,_that.sweetnessLevel,_that.flavorNotes,_that.tastedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String beanName,  String origin,  String roaster,  int acidityLevel,  int bodyLevel,  int sweetnessLevel,  String flavorNotes,  DateTime tastedAt)  $default,) {final _that = this;
switch (_that) {
case _CoffeeCard():
return $default(_that.id,_that.beanName,_that.origin,_that.roaster,_that.acidityLevel,_that.bodyLevel,_that.sweetnessLevel,_that.flavorNotes,_that.tastedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String beanName,  String origin,  String roaster,  int acidityLevel,  int bodyLevel,  int sweetnessLevel,  String flavorNotes,  DateTime tastedAt)?  $default,) {final _that = this;
switch (_that) {
case _CoffeeCard() when $default != null:
return $default(_that.id,_that.beanName,_that.origin,_that.roaster,_that.acidityLevel,_that.bodyLevel,_that.sweetnessLevel,_that.flavorNotes,_that.tastedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoffeeCard implements CoffeeCard {
  const _CoffeeCard({this.id, required this.beanName, required this.origin, required this.roaster, this.acidityLevel = 0, this.bodyLevel = 0, this.sweetnessLevel = 0, required this.flavorNotes, required this.tastedAt});
  factory _CoffeeCard.fromJson(Map<String, dynamic> json) => _$CoffeeCardFromJson(json);

@override final  String? id;
@override final  String beanName;
@override final  String origin;
@override final  String roaster;
@override@JsonKey() final  int acidityLevel;
@override@JsonKey() final  int bodyLevel;
@override@JsonKey() final  int sweetnessLevel;
@override final  String flavorNotes;
@override final  DateTime tastedAt;

/// Create a copy of CoffeeCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoffeeCardCopyWith<_CoffeeCard> get copyWith => __$CoffeeCardCopyWithImpl<_CoffeeCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoffeeCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoffeeCard&&(identical(other.id, id) || other.id == id)&&(identical(other.beanName, beanName) || other.beanName == beanName)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.roaster, roaster) || other.roaster == roaster)&&(identical(other.acidityLevel, acidityLevel) || other.acidityLevel == acidityLevel)&&(identical(other.bodyLevel, bodyLevel) || other.bodyLevel == bodyLevel)&&(identical(other.sweetnessLevel, sweetnessLevel) || other.sweetnessLevel == sweetnessLevel)&&(identical(other.flavorNotes, flavorNotes) || other.flavorNotes == flavorNotes)&&(identical(other.tastedAt, tastedAt) || other.tastedAt == tastedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,beanName,origin,roaster,acidityLevel,bodyLevel,sweetnessLevel,flavorNotes,tastedAt);

@override
String toString() {
  return 'CoffeeCard(id: $id, beanName: $beanName, origin: $origin, roaster: $roaster, acidityLevel: $acidityLevel, bodyLevel: $bodyLevel, sweetnessLevel: $sweetnessLevel, flavorNotes: $flavorNotes, tastedAt: $tastedAt)';
}


}

/// @nodoc
abstract mixin class _$CoffeeCardCopyWith<$Res> implements $CoffeeCardCopyWith<$Res> {
  factory _$CoffeeCardCopyWith(_CoffeeCard value, $Res Function(_CoffeeCard) _then) = __$CoffeeCardCopyWithImpl;
@override @useResult
$Res call({
 String? id, String beanName, String origin, String roaster, int acidityLevel, int bodyLevel, int sweetnessLevel, String flavorNotes, DateTime tastedAt
});




}
/// @nodoc
class __$CoffeeCardCopyWithImpl<$Res>
    implements _$CoffeeCardCopyWith<$Res> {
  __$CoffeeCardCopyWithImpl(this._self, this._then);

  final _CoffeeCard _self;
  final $Res Function(_CoffeeCard) _then;

/// Create a copy of CoffeeCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? beanName = null,Object? origin = null,Object? roaster = null,Object? acidityLevel = null,Object? bodyLevel = null,Object? sweetnessLevel = null,Object? flavorNotes = null,Object? tastedAt = null,}) {
  return _then(_CoffeeCard(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,beanName: null == beanName ? _self.beanName : beanName // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,roaster: null == roaster ? _self.roaster : roaster // ignore: cast_nullable_to_non_nullable
as String,acidityLevel: null == acidityLevel ? _self.acidityLevel : acidityLevel // ignore: cast_nullable_to_non_nullable
as int,bodyLevel: null == bodyLevel ? _self.bodyLevel : bodyLevel // ignore: cast_nullable_to_non_nullable
as int,sweetnessLevel: null == sweetnessLevel ? _self.sweetnessLevel : sweetnessLevel // ignore: cast_nullable_to_non_nullable
as int,flavorNotes: null == flavorNotes ? _self.flavorNotes : flavorNotes // ignore: cast_nullable_to_non_nullable
as String,tastedAt: null == tastedAt ? _self.tastedAt : tastedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
