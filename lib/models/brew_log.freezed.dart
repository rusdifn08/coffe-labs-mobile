// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'brew_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BrewLog {

 String? get id; String get beanName; String get method; double get coffeeWeight; double get waterWeight; int get totalBrewTimeSeconds; DateTime get createdAt;
/// Create a copy of BrewLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrewLogCopyWith<BrewLog> get copyWith => _$BrewLogCopyWithImpl<BrewLog>(this as BrewLog, _$identity);

  /// Serializes this BrewLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BrewLog&&(identical(other.id, id) || other.id == id)&&(identical(other.beanName, beanName) || other.beanName == beanName)&&(identical(other.method, method) || other.method == method)&&(identical(other.coffeeWeight, coffeeWeight) || other.coffeeWeight == coffeeWeight)&&(identical(other.waterWeight, waterWeight) || other.waterWeight == waterWeight)&&(identical(other.totalBrewTimeSeconds, totalBrewTimeSeconds) || other.totalBrewTimeSeconds == totalBrewTimeSeconds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,beanName,method,coffeeWeight,waterWeight,totalBrewTimeSeconds,createdAt);

@override
String toString() {
  return 'BrewLog(id: $id, beanName: $beanName, method: $method, coffeeWeight: $coffeeWeight, waterWeight: $waterWeight, totalBrewTimeSeconds: $totalBrewTimeSeconds, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BrewLogCopyWith<$Res>  {
  factory $BrewLogCopyWith(BrewLog value, $Res Function(BrewLog) _then) = _$BrewLogCopyWithImpl;
@useResult
$Res call({
 String? id, String beanName, String method, double coffeeWeight, double waterWeight, int totalBrewTimeSeconds, DateTime createdAt
});




}
/// @nodoc
class _$BrewLogCopyWithImpl<$Res>
    implements $BrewLogCopyWith<$Res> {
  _$BrewLogCopyWithImpl(this._self, this._then);

  final BrewLog _self;
  final $Res Function(BrewLog) _then;

/// Create a copy of BrewLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? beanName = null,Object? method = null,Object? coffeeWeight = null,Object? waterWeight = null,Object? totalBrewTimeSeconds = null,Object? createdAt = null,}) {
  return _then(BrewLog(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,beanName: null == beanName ? _self.beanName : beanName // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,coffeeWeight: null == coffeeWeight ? _self.coffeeWeight : coffeeWeight // ignore: cast_nullable_to_non_nullable
as double,waterWeight: null == waterWeight ? _self.waterWeight : waterWeight // ignore: cast_nullable_to_non_nullable
as double,totalBrewTimeSeconds: null == totalBrewTimeSeconds ? _self.totalBrewTimeSeconds : totalBrewTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BrewLog].
extension BrewLogPatterns on BrewLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BrewLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BrewLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BrewLog value)  $default,){
final _that = this;
switch (_that) {
case _BrewLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BrewLog value)?  $default,){
final _that = this;
switch (_that) {
case _BrewLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String beanName,  String method,  double coffeeWeight,  double waterWeight,  int totalBrewTimeSeconds,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BrewLog() when $default != null:
return $default(_that.id,_that.beanName,_that.method,_that.coffeeWeight,_that.waterWeight,_that.totalBrewTimeSeconds,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String beanName,  String method,  double coffeeWeight,  double waterWeight,  int totalBrewTimeSeconds,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _BrewLog():
return $default(_that.id,_that.beanName,_that.method,_that.coffeeWeight,_that.waterWeight,_that.totalBrewTimeSeconds,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String beanName,  String method,  double coffeeWeight,  double waterWeight,  int totalBrewTimeSeconds,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BrewLog() when $default != null:
return $default(_that.id,_that.beanName,_that.method,_that.coffeeWeight,_that.waterWeight,_that.totalBrewTimeSeconds,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BrewLog implements BrewLog {
  const _BrewLog({this.id, required this.beanName, required this.method, this.coffeeWeight = 15.0, this.waterWeight = 240.0, this.totalBrewTimeSeconds = 180, required this.createdAt});
  factory _BrewLog.fromJson(Map<String, dynamic> json) => _$BrewLogFromJson(json);

@override final  String? id;
@override final  String beanName;
@override final  String method;
@override@JsonKey() final  double coffeeWeight;
@override@JsonKey() final  double waterWeight;
@override@JsonKey() final  int totalBrewTimeSeconds;
@override final  DateTime createdAt;

/// Create a copy of BrewLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BrewLogCopyWith<_BrewLog> get copyWith => __$BrewLogCopyWithImpl<_BrewLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BrewLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BrewLog&&(identical(other.id, id) || other.id == id)&&(identical(other.beanName, beanName) || other.beanName == beanName)&&(identical(other.method, method) || other.method == method)&&(identical(other.coffeeWeight, coffeeWeight) || other.coffeeWeight == coffeeWeight)&&(identical(other.waterWeight, waterWeight) || other.waterWeight == waterWeight)&&(identical(other.totalBrewTimeSeconds, totalBrewTimeSeconds) || other.totalBrewTimeSeconds == totalBrewTimeSeconds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,beanName,method,coffeeWeight,waterWeight,totalBrewTimeSeconds,createdAt);

@override
String toString() {
  return 'BrewLog(id: $id, beanName: $beanName, method: $method, coffeeWeight: $coffeeWeight, waterWeight: $waterWeight, totalBrewTimeSeconds: $totalBrewTimeSeconds, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BrewLogCopyWith<$Res> implements $BrewLogCopyWith<$Res> {
  factory _$BrewLogCopyWith(_BrewLog value, $Res Function(_BrewLog) _then) = __$BrewLogCopyWithImpl;
@override @useResult
$Res call({
 String? id, String beanName, String method, double coffeeWeight, double waterWeight, int totalBrewTimeSeconds, DateTime createdAt
});




}
/// @nodoc
class __$BrewLogCopyWithImpl<$Res>
    implements _$BrewLogCopyWith<$Res> {
  __$BrewLogCopyWithImpl(this._self, this._then);

  final _BrewLog _self;
  final $Res Function(_BrewLog) _then;

/// Create a copy of BrewLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? beanName = null,Object? method = null,Object? coffeeWeight = null,Object? waterWeight = null,Object? totalBrewTimeSeconds = null,Object? createdAt = null,}) {
  return _then(_BrewLog(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,beanName: null == beanName ? _self.beanName : beanName // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,coffeeWeight: null == coffeeWeight ? _self.coffeeWeight : coffeeWeight // ignore: cast_nullable_to_non_nullable
as double,waterWeight: null == waterWeight ? _self.waterWeight : waterWeight // ignore: cast_nullable_to_non_nullable
as double,totalBrewTimeSeconds: null == totalBrewTimeSeconds ? _self.totalBrewTimeSeconds : totalBrewTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
