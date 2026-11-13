// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_thread_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecipeStepMiniDto {

@JsonKey(name: 'step_number') int get stepNumber; String get title;@JsonKey(name: 'duration_sec') int get durationSec;@JsonKey(name: 'water_added_ml') double get waterAddedMl;@JsonKey(name: 'target_temp_c') int? get targetTempC; String? get instruction;
/// Create a copy of RecipeStepMiniDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeStepMiniDtoCopyWith<RecipeStepMiniDto> get copyWith => _$RecipeStepMiniDtoCopyWithImpl<RecipeStepMiniDto>(this as RecipeStepMiniDto, _$identity);

  /// Serializes this RecipeStepMiniDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipeStepMiniDto&&(identical(other.stepNumber, stepNumber) || other.stepNumber == stepNumber)&&(identical(other.title, title) || other.title == title)&&(identical(other.durationSec, durationSec) || other.durationSec == durationSec)&&(identical(other.waterAddedMl, waterAddedMl) || other.waterAddedMl == waterAddedMl)&&(identical(other.targetTempC, targetTempC) || other.targetTempC == targetTempC)&&(identical(other.instruction, instruction) || other.instruction == instruction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stepNumber,title,durationSec,waterAddedMl,targetTempC,instruction);

@override
String toString() {
  return 'RecipeStepMiniDto(stepNumber: $stepNumber, title: $title, durationSec: $durationSec, waterAddedMl: $waterAddedMl, targetTempC: $targetTempC, instruction: $instruction)';
}


}

/// @nodoc
abstract mixin class $RecipeStepMiniDtoCopyWith<$Res>  {
  factory $RecipeStepMiniDtoCopyWith(RecipeStepMiniDto value, $Res Function(RecipeStepMiniDto) _then) = _$RecipeStepMiniDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'step_number') int stepNumber, String title,@JsonKey(name: 'duration_sec') int durationSec,@JsonKey(name: 'water_added_ml') double waterAddedMl,@JsonKey(name: 'target_temp_c') int? targetTempC, String? instruction
});




}
/// @nodoc
class _$RecipeStepMiniDtoCopyWithImpl<$Res>
    implements $RecipeStepMiniDtoCopyWith<$Res> {
  _$RecipeStepMiniDtoCopyWithImpl(this._self, this._then);

  final RecipeStepMiniDto _self;
  final $Res Function(RecipeStepMiniDto) _then;

/// Create a copy of RecipeStepMiniDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stepNumber = null,Object? title = null,Object? durationSec = null,Object? waterAddedMl = null,Object? targetTempC = freezed,Object? instruction = freezed,}) {
  return _then(RecipeStepMiniDto(
stepNumber: null == stepNumber ? _self.stepNumber : stepNumber // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,durationSec: null == durationSec ? _self.durationSec : durationSec // ignore: cast_nullable_to_non_nullable
as int,waterAddedMl: null == waterAddedMl ? _self.waterAddedMl : waterAddedMl // ignore: cast_nullable_to_non_nullable
as double,targetTempC: freezed == targetTempC ? _self.targetTempC : targetTempC // ignore: cast_nullable_to_non_nullable
as int?,instruction: freezed == instruction ? _self.instruction : instruction // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecipeStepMiniDto].
extension RecipeStepMiniDtoPatterns on RecipeStepMiniDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecipeStepMiniDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecipeStepMiniDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecipeStepMiniDto value)  $default,){
final _that = this;
switch (_that) {
case _RecipeStepMiniDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecipeStepMiniDto value)?  $default,){
final _that = this;
switch (_that) {
case _RecipeStepMiniDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'step_number')  int stepNumber,  String title, @JsonKey(name: 'duration_sec')  int durationSec, @JsonKey(name: 'water_added_ml')  double waterAddedMl, @JsonKey(name: 'target_temp_c')  int? targetTempC,  String? instruction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecipeStepMiniDto() when $default != null:
return $default(_that.stepNumber,_that.title,_that.durationSec,_that.waterAddedMl,_that.targetTempC,_that.instruction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'step_number')  int stepNumber,  String title, @JsonKey(name: 'duration_sec')  int durationSec, @JsonKey(name: 'water_added_ml')  double waterAddedMl, @JsonKey(name: 'target_temp_c')  int? targetTempC,  String? instruction)  $default,) {final _that = this;
switch (_that) {
case _RecipeStepMiniDto():
return $default(_that.stepNumber,_that.title,_that.durationSec,_that.waterAddedMl,_that.targetTempC,_that.instruction);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'step_number')  int stepNumber,  String title, @JsonKey(name: 'duration_sec')  int durationSec, @JsonKey(name: 'water_added_ml')  double waterAddedMl, @JsonKey(name: 'target_temp_c')  int? targetTempC,  String? instruction)?  $default,) {final _that = this;
switch (_that) {
case _RecipeStepMiniDto() when $default != null:
return $default(_that.stepNumber,_that.title,_that.durationSec,_that.waterAddedMl,_that.targetTempC,_that.instruction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecipeStepMiniDto implements RecipeStepMiniDto {
  const _RecipeStepMiniDto({@JsonKey(name: 'step_number') required this.stepNumber, required this.title, @JsonKey(name: 'duration_sec') required this.durationSec, @JsonKey(name: 'water_added_ml') required this.waterAddedMl, @JsonKey(name: 'target_temp_c') this.targetTempC, this.instruction});
  factory _RecipeStepMiniDto.fromJson(Map<String, dynamic> json) => _$RecipeStepMiniDtoFromJson(json);

@override@JsonKey(name: 'step_number') final  int stepNumber;
@override final  String title;
@override@JsonKey(name: 'duration_sec') final  int durationSec;
@override@JsonKey(name: 'water_added_ml') final  double waterAddedMl;
@override@JsonKey(name: 'target_temp_c') final  int? targetTempC;
@override final  String? instruction;

/// Create a copy of RecipeStepMiniDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeStepMiniDtoCopyWith<_RecipeStepMiniDto> get copyWith => __$RecipeStepMiniDtoCopyWithImpl<_RecipeStepMiniDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeStepMiniDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipeStepMiniDto&&(identical(other.stepNumber, stepNumber) || other.stepNumber == stepNumber)&&(identical(other.title, title) || other.title == title)&&(identical(other.durationSec, durationSec) || other.durationSec == durationSec)&&(identical(other.waterAddedMl, waterAddedMl) || other.waterAddedMl == waterAddedMl)&&(identical(other.targetTempC, targetTempC) || other.targetTempC == targetTempC)&&(identical(other.instruction, instruction) || other.instruction == instruction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stepNumber,title,durationSec,waterAddedMl,targetTempC,instruction);

@override
String toString() {
  return 'RecipeStepMiniDto(stepNumber: $stepNumber, title: $title, durationSec: $durationSec, waterAddedMl: $waterAddedMl, targetTempC: $targetTempC, instruction: $instruction)';
}


}

/// @nodoc
abstract mixin class _$RecipeStepMiniDtoCopyWith<$Res> implements $RecipeStepMiniDtoCopyWith<$Res> {
  factory _$RecipeStepMiniDtoCopyWith(_RecipeStepMiniDto value, $Res Function(_RecipeStepMiniDto) _then) = __$RecipeStepMiniDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'step_number') int stepNumber, String title,@JsonKey(name: 'duration_sec') int durationSec,@JsonKey(name: 'water_added_ml') double waterAddedMl,@JsonKey(name: 'target_temp_c') int? targetTempC, String? instruction
});




}
/// @nodoc
class __$RecipeStepMiniDtoCopyWithImpl<$Res>
    implements _$RecipeStepMiniDtoCopyWith<$Res> {
  __$RecipeStepMiniDtoCopyWithImpl(this._self, this._then);

  final _RecipeStepMiniDto _self;
  final $Res Function(_RecipeStepMiniDto) _then;

/// Create a copy of RecipeStepMiniDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stepNumber = null,Object? title = null,Object? durationSec = null,Object? waterAddedMl = null,Object? targetTempC = freezed,Object? instruction = freezed,}) {
  return _then(_RecipeStepMiniDto(
stepNumber: null == stepNumber ? _self.stepNumber : stepNumber // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,durationSec: null == durationSec ? _self.durationSec : durationSec // ignore: cast_nullable_to_non_nullable
as int,waterAddedMl: null == waterAddedMl ? _self.waterAddedMl : waterAddedMl // ignore: cast_nullable_to_non_nullable
as double,targetTempC: freezed == targetTempC ? _self.targetTempC : targetTempC // ignore: cast_nullable_to_non_nullable
as int?,instruction: freezed == instruction ? _self.instruction : instruction // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PourCurvePoint {

@JsonKey(name: 't_sec') int get tSec;@JsonKey(name: 'actual_ml') double get actualMl;@JsonKey(name: 'target_ml') double get targetMl;@JsonKey(name: 'temp_c') double get tempC;
/// Create a copy of PourCurvePoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PourCurvePointCopyWith<PourCurvePoint> get copyWith => _$PourCurvePointCopyWithImpl<PourCurvePoint>(this as PourCurvePoint, _$identity);

  /// Serializes this PourCurvePoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PourCurvePoint&&(identical(other.tSec, tSec) || other.tSec == tSec)&&(identical(other.actualMl, actualMl) || other.actualMl == actualMl)&&(identical(other.targetMl, targetMl) || other.targetMl == targetMl)&&(identical(other.tempC, tempC) || other.tempC == tempC));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tSec,actualMl,targetMl,tempC);

@override
String toString() {
  return 'PourCurvePoint(tSec: $tSec, actualMl: $actualMl, targetMl: $targetMl, tempC: $tempC)';
}


}

/// @nodoc
abstract mixin class $PourCurvePointCopyWith<$Res>  {
  factory $PourCurvePointCopyWith(PourCurvePoint value, $Res Function(PourCurvePoint) _then) = _$PourCurvePointCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 't_sec') int tSec,@JsonKey(name: 'actual_ml') double actualMl,@JsonKey(name: 'target_ml') double targetMl,@JsonKey(name: 'temp_c') double tempC
});




}
/// @nodoc
class _$PourCurvePointCopyWithImpl<$Res>
    implements $PourCurvePointCopyWith<$Res> {
  _$PourCurvePointCopyWithImpl(this._self, this._then);

  final PourCurvePoint _self;
  final $Res Function(PourCurvePoint) _then;

/// Create a copy of PourCurvePoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tSec = null,Object? actualMl = null,Object? targetMl = null,Object? tempC = null,}) {
  return _then(PourCurvePoint(
tSec: null == tSec ? _self.tSec : tSec // ignore: cast_nullable_to_non_nullable
as int,actualMl: null == actualMl ? _self.actualMl : actualMl // ignore: cast_nullable_to_non_nullable
as double,targetMl: null == targetMl ? _self.targetMl : targetMl // ignore: cast_nullable_to_non_nullable
as double,tempC: null == tempC ? _self.tempC : tempC // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PourCurvePoint].
extension PourCurvePointPatterns on PourCurvePoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PourCurvePoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PourCurvePoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PourCurvePoint value)  $default,){
final _that = this;
switch (_that) {
case _PourCurvePoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PourCurvePoint value)?  $default,){
final _that = this;
switch (_that) {
case _PourCurvePoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 't_sec')  int tSec, @JsonKey(name: 'actual_ml')  double actualMl, @JsonKey(name: 'target_ml')  double targetMl, @JsonKey(name: 'temp_c')  double tempC)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PourCurvePoint() when $default != null:
return $default(_that.tSec,_that.actualMl,_that.targetMl,_that.tempC);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 't_sec')  int tSec, @JsonKey(name: 'actual_ml')  double actualMl, @JsonKey(name: 'target_ml')  double targetMl, @JsonKey(name: 'temp_c')  double tempC)  $default,) {final _that = this;
switch (_that) {
case _PourCurvePoint():
return $default(_that.tSec,_that.actualMl,_that.targetMl,_that.tempC);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 't_sec')  int tSec, @JsonKey(name: 'actual_ml')  double actualMl, @JsonKey(name: 'target_ml')  double targetMl, @JsonKey(name: 'temp_c')  double tempC)?  $default,) {final _that = this;
switch (_that) {
case _PourCurvePoint() when $default != null:
return $default(_that.tSec,_that.actualMl,_that.targetMl,_that.tempC);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PourCurvePoint implements PourCurvePoint {
  const _PourCurvePoint({@JsonKey(name: 't_sec') required this.tSec, @JsonKey(name: 'actual_ml') required this.actualMl, @JsonKey(name: 'target_ml') required this.targetMl, @JsonKey(name: 'temp_c') required this.tempC});
  factory _PourCurvePoint.fromJson(Map<String, dynamic> json) => _$PourCurvePointFromJson(json);

@override@JsonKey(name: 't_sec') final  int tSec;
@override@JsonKey(name: 'actual_ml') final  double actualMl;
@override@JsonKey(name: 'target_ml') final  double targetMl;
@override@JsonKey(name: 'temp_c') final  double tempC;

/// Create a copy of PourCurvePoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PourCurvePointCopyWith<_PourCurvePoint> get copyWith => __$PourCurvePointCopyWithImpl<_PourCurvePoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PourCurvePointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PourCurvePoint&&(identical(other.tSec, tSec) || other.tSec == tSec)&&(identical(other.actualMl, actualMl) || other.actualMl == actualMl)&&(identical(other.targetMl, targetMl) || other.targetMl == targetMl)&&(identical(other.tempC, tempC) || other.tempC == tempC));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tSec,actualMl,targetMl,tempC);

@override
String toString() {
  return 'PourCurvePoint(tSec: $tSec, actualMl: $actualMl, targetMl: $targetMl, tempC: $tempC)';
}


}

/// @nodoc
abstract mixin class _$PourCurvePointCopyWith<$Res> implements $PourCurvePointCopyWith<$Res> {
  factory _$PourCurvePointCopyWith(_PourCurvePoint value, $Res Function(_PourCurvePoint) _then) = __$PourCurvePointCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 't_sec') int tSec,@JsonKey(name: 'actual_ml') double actualMl,@JsonKey(name: 'target_ml') double targetMl,@JsonKey(name: 'temp_c') double tempC
});




}
/// @nodoc
class __$PourCurvePointCopyWithImpl<$Res>
    implements _$PourCurvePointCopyWith<$Res> {
  __$PourCurvePointCopyWithImpl(this._self, this._then);

  final _PourCurvePoint _self;
  final $Res Function(_PourCurvePoint) _then;

/// Create a copy of PourCurvePoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tSec = null,Object? actualMl = null,Object? targetMl = null,Object? tempC = null,}) {
  return _then(_PourCurvePoint(
tSec: null == tSec ? _self.tSec : tSec // ignore: cast_nullable_to_non_nullable
as int,actualMl: null == actualMl ? _self.actualMl : actualMl // ignore: cast_nullable_to_non_nullable
as double,targetMl: null == targetMl ? _self.targetMl : targetMl // ignore: cast_nullable_to_non_nullable
as double,tempC: null == tempC ? _self.tempC : tempC // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$MediaAttachmentItem {

 String get url; int? get width; int? get height; String? get blurhash;
/// Create a copy of MediaAttachmentItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaAttachmentItemCopyWith<MediaAttachmentItem> get copyWith => _$MediaAttachmentItemCopyWithImpl<MediaAttachmentItem>(this as MediaAttachmentItem, _$identity);

  /// Serializes this MediaAttachmentItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaAttachmentItem&&(identical(other.url, url) || other.url == url)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.blurhash, blurhash) || other.blurhash == blurhash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,width,height,blurhash);

@override
String toString() {
  return 'MediaAttachmentItem(url: $url, width: $width, height: $height, blurhash: $blurhash)';
}


}

/// @nodoc
abstract mixin class $MediaAttachmentItemCopyWith<$Res>  {
  factory $MediaAttachmentItemCopyWith(MediaAttachmentItem value, $Res Function(MediaAttachmentItem) _then) = _$MediaAttachmentItemCopyWithImpl;
@useResult
$Res call({
 String url, int? width, int? height, String? blurhash
});




}
/// @nodoc
class _$MediaAttachmentItemCopyWithImpl<$Res>
    implements $MediaAttachmentItemCopyWith<$Res> {
  _$MediaAttachmentItemCopyWithImpl(this._self, this._then);

  final MediaAttachmentItem _self;
  final $Res Function(MediaAttachmentItem) _then;

/// Create a copy of MediaAttachmentItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? width = freezed,Object? height = freezed,Object? blurhash = freezed,}) {
  return _then(MediaAttachmentItem(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,blurhash: freezed == blurhash ? _self.blurhash : blurhash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaAttachmentItem].
extension MediaAttachmentItemPatterns on MediaAttachmentItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaAttachmentItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaAttachmentItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaAttachmentItem value)  $default,){
final _that = this;
switch (_that) {
case _MediaAttachmentItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaAttachmentItem value)?  $default,){
final _that = this;
switch (_that) {
case _MediaAttachmentItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  int? width,  int? height,  String? blurhash)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaAttachmentItem() when $default != null:
return $default(_that.url,_that.width,_that.height,_that.blurhash);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  int? width,  int? height,  String? blurhash)  $default,) {final _that = this;
switch (_that) {
case _MediaAttachmentItem():
return $default(_that.url,_that.width,_that.height,_that.blurhash);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  int? width,  int? height,  String? blurhash)?  $default,) {final _that = this;
switch (_that) {
case _MediaAttachmentItem() when $default != null:
return $default(_that.url,_that.width,_that.height,_that.blurhash);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaAttachmentItem implements MediaAttachmentItem {
  const _MediaAttachmentItem({required this.url, this.width, this.height, this.blurhash});
  factory _MediaAttachmentItem.fromJson(Map<String, dynamic> json) => _$MediaAttachmentItemFromJson(json);

@override final  String url;
@override final  int? width;
@override final  int? height;
@override final  String? blurhash;

/// Create a copy of MediaAttachmentItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaAttachmentItemCopyWith<_MediaAttachmentItem> get copyWith => __$MediaAttachmentItemCopyWithImpl<_MediaAttachmentItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaAttachmentItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaAttachmentItem&&(identical(other.url, url) || other.url == url)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.blurhash, blurhash) || other.blurhash == blurhash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,width,height,blurhash);

@override
String toString() {
  return 'MediaAttachmentItem(url: $url, width: $width, height: $height, blurhash: $blurhash)';
}


}

/// @nodoc
abstract mixin class _$MediaAttachmentItemCopyWith<$Res> implements $MediaAttachmentItemCopyWith<$Res> {
  factory _$MediaAttachmentItemCopyWith(_MediaAttachmentItem value, $Res Function(_MediaAttachmentItem) _then) = __$MediaAttachmentItemCopyWithImpl;
@override @useResult
$Res call({
 String url, int? width, int? height, String? blurhash
});




}
/// @nodoc
class __$MediaAttachmentItemCopyWithImpl<$Res>
    implements _$MediaAttachmentItemCopyWith<$Res> {
  __$MediaAttachmentItemCopyWithImpl(this._self, this._then);

  final _MediaAttachmentItem _self;
  final $Res Function(_MediaAttachmentItem) _then;

/// Create a copy of MediaAttachmentItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? width = freezed,Object? height = freezed,Object? blurhash = freezed,}) {
  return _then(_MediaAttachmentItem(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,blurhash: freezed == blurhash ? _self.blurhash : blurhash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

ThreadAttachment _$ThreadAttachmentFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'interactiveRecipeCard':
          return InteractiveRecipeCardAttachment.fromJson(
            json
          );
                case 'pouringTelemetryCurve':
          return PouringTelemetryCurveAttachment.fromJson(
            json
          );
                case 'scannedCoffeeBagTag':
          return ScannedCoffeeBagTagAttachment.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'ThreadAttachment',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$ThreadAttachment {



  /// Serializes this ThreadAttachment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThreadAttachment);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ThreadAttachment()';
}


}

/// @nodoc
class $ThreadAttachmentCopyWith<$Res>  {
$ThreadAttachmentCopyWith(ThreadAttachment _, $Res Function(ThreadAttachment) __);
}


/// Adds pattern-matching-related methods to [ThreadAttachment].
extension ThreadAttachmentPatterns on ThreadAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( InteractiveRecipeCardAttachment value)?  interactiveRecipeCard,TResult Function( PouringTelemetryCurveAttachment value)?  pouringTelemetryCurve,TResult Function( ScannedCoffeeBagTagAttachment value)?  scannedCoffeeBagTag,required TResult orElse(),}){
final _that = this;
switch (_that) {
case InteractiveRecipeCardAttachment() when interactiveRecipeCard != null:
return interactiveRecipeCard(_that);case PouringTelemetryCurveAttachment() when pouringTelemetryCurve != null:
return pouringTelemetryCurve(_that);case ScannedCoffeeBagTagAttachment() when scannedCoffeeBagTag != null:
return scannedCoffeeBagTag(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( InteractiveRecipeCardAttachment value)  interactiveRecipeCard,required TResult Function( PouringTelemetryCurveAttachment value)  pouringTelemetryCurve,required TResult Function( ScannedCoffeeBagTagAttachment value)  scannedCoffeeBagTag,}){
final _that = this;
switch (_that) {
case InteractiveRecipeCardAttachment():
return interactiveRecipeCard(_that);case PouringTelemetryCurveAttachment():
return pouringTelemetryCurve(_that);case ScannedCoffeeBagTagAttachment():
return scannedCoffeeBagTag(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( InteractiveRecipeCardAttachment value)?  interactiveRecipeCard,TResult? Function( PouringTelemetryCurveAttachment value)?  pouringTelemetryCurve,TResult? Function( ScannedCoffeeBagTagAttachment value)?  scannedCoffeeBagTag,}){
final _that = this;
switch (_that) {
case InteractiveRecipeCardAttachment() when interactiveRecipeCard != null:
return interactiveRecipeCard(_that);case PouringTelemetryCurveAttachment() when pouringTelemetryCurve != null:
return pouringTelemetryCurve(_that);case ScannedCoffeeBagTagAttachment() when scannedCoffeeBagTag != null:
return scannedCoffeeBagTag(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function(@JsonKey(name: 'recipe_id')  String recipeId,  String title, @JsonKey(name: 'brewer_name')  String brewerName,  String method, @JsonKey(name: 'coffee_dose_g')  double coffeeDoseG, @JsonKey(name: 'total_water_ml')  double totalWaterMl, @JsonKey(name: 'primary_temp_c')  int primaryTempC, @JsonKey(name: 'secondary_temp_c')  int? secondaryTempC, @JsonKey(name: 'target_duration_sec')  int targetDurationSec, @JsonKey(name: 'steps_preview')  List<RecipeStepMiniDto> stepsPreview)?  interactiveRecipeCard,TResult Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'recipe_title')  String recipeTitle, @JsonKey(name: 'bean_name')  String beanName, @JsonKey(name: 'accuracy_score_pct')  double accuracyScorePct, @JsonKey(name: 'total_duration_sec')  int totalDurationSec, @JsonKey(name: 'curve_points')  List<PourCurvePoint> curvePoints)?  pouringTelemetryCurve,TResult Function(@JsonKey(name: 'class_slug')  String classSlug,  String roastery, @JsonKey(name: 'bean_name')  String beanName,  String origin,  String process, @JsonKey(name: 'altitude_masl')  String altitudeMasl, @JsonKey(name: 'tasting_notes')  List<String> tastingNotes, @JsonKey(name: 'confidence_pct')  double confidencePct)?  scannedCoffeeBagTag,required TResult orElse(),}) {final _that = this;
switch (_that) {
case InteractiveRecipeCardAttachment() when interactiveRecipeCard != null:
return interactiveRecipeCard(_that.recipeId,_that.title,_that.brewerName,_that.method,_that.coffeeDoseG,_that.totalWaterMl,_that.primaryTempC,_that.secondaryTempC,_that.targetDurationSec,_that.stepsPreview);case PouringTelemetryCurveAttachment() when pouringTelemetryCurve != null:
return pouringTelemetryCurve(_that.sessionId,_that.recipeTitle,_that.beanName,_that.accuracyScorePct,_that.totalDurationSec,_that.curvePoints);case ScannedCoffeeBagTagAttachment() when scannedCoffeeBagTag != null:
return scannedCoffeeBagTag(_that.classSlug,_that.roastery,_that.beanName,_that.origin,_that.process,_that.altitudeMasl,_that.tastingNotes,_that.confidencePct);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function(@JsonKey(name: 'recipe_id')  String recipeId,  String title, @JsonKey(name: 'brewer_name')  String brewerName,  String method, @JsonKey(name: 'coffee_dose_g')  double coffeeDoseG, @JsonKey(name: 'total_water_ml')  double totalWaterMl, @JsonKey(name: 'primary_temp_c')  int primaryTempC, @JsonKey(name: 'secondary_temp_c')  int? secondaryTempC, @JsonKey(name: 'target_duration_sec')  int targetDurationSec, @JsonKey(name: 'steps_preview')  List<RecipeStepMiniDto> stepsPreview)  interactiveRecipeCard,required TResult Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'recipe_title')  String recipeTitle, @JsonKey(name: 'bean_name')  String beanName, @JsonKey(name: 'accuracy_score_pct')  double accuracyScorePct, @JsonKey(name: 'total_duration_sec')  int totalDurationSec, @JsonKey(name: 'curve_points')  List<PourCurvePoint> curvePoints)  pouringTelemetryCurve,required TResult Function(@JsonKey(name: 'class_slug')  String classSlug,  String roastery, @JsonKey(name: 'bean_name')  String beanName,  String origin,  String process, @JsonKey(name: 'altitude_masl')  String altitudeMasl, @JsonKey(name: 'tasting_notes')  List<String> tastingNotes, @JsonKey(name: 'confidence_pct')  double confidencePct)  scannedCoffeeBagTag,}) {final _that = this;
switch (_that) {
case InteractiveRecipeCardAttachment():
return interactiveRecipeCard(_that.recipeId,_that.title,_that.brewerName,_that.method,_that.coffeeDoseG,_that.totalWaterMl,_that.primaryTempC,_that.secondaryTempC,_that.targetDurationSec,_that.stepsPreview);case PouringTelemetryCurveAttachment():
return pouringTelemetryCurve(_that.sessionId,_that.recipeTitle,_that.beanName,_that.accuracyScorePct,_that.totalDurationSec,_that.curvePoints);case ScannedCoffeeBagTagAttachment():
return scannedCoffeeBagTag(_that.classSlug,_that.roastery,_that.beanName,_that.origin,_that.process,_that.altitudeMasl,_that.tastingNotes,_that.confidencePct);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function(@JsonKey(name: 'recipe_id')  String recipeId,  String title, @JsonKey(name: 'brewer_name')  String brewerName,  String method, @JsonKey(name: 'coffee_dose_g')  double coffeeDoseG, @JsonKey(name: 'total_water_ml')  double totalWaterMl, @JsonKey(name: 'primary_temp_c')  int primaryTempC, @JsonKey(name: 'secondary_temp_c')  int? secondaryTempC, @JsonKey(name: 'target_duration_sec')  int targetDurationSec, @JsonKey(name: 'steps_preview')  List<RecipeStepMiniDto> stepsPreview)?  interactiveRecipeCard,TResult? Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'recipe_title')  String recipeTitle, @JsonKey(name: 'bean_name')  String beanName, @JsonKey(name: 'accuracy_score_pct')  double accuracyScorePct, @JsonKey(name: 'total_duration_sec')  int totalDurationSec, @JsonKey(name: 'curve_points')  List<PourCurvePoint> curvePoints)?  pouringTelemetryCurve,TResult? Function(@JsonKey(name: 'class_slug')  String classSlug,  String roastery, @JsonKey(name: 'bean_name')  String beanName,  String origin,  String process, @JsonKey(name: 'altitude_masl')  String altitudeMasl, @JsonKey(name: 'tasting_notes')  List<String> tastingNotes, @JsonKey(name: 'confidence_pct')  double confidencePct)?  scannedCoffeeBagTag,}) {final _that = this;
switch (_that) {
case InteractiveRecipeCardAttachment() when interactiveRecipeCard != null:
return interactiveRecipeCard(_that.recipeId,_that.title,_that.brewerName,_that.method,_that.coffeeDoseG,_that.totalWaterMl,_that.primaryTempC,_that.secondaryTempC,_that.targetDurationSec,_that.stepsPreview);case PouringTelemetryCurveAttachment() when pouringTelemetryCurve != null:
return pouringTelemetryCurve(_that.sessionId,_that.recipeTitle,_that.beanName,_that.accuracyScorePct,_that.totalDurationSec,_that.curvePoints);case ScannedCoffeeBagTagAttachment() when scannedCoffeeBagTag != null:
return scannedCoffeeBagTag(_that.classSlug,_that.roastery,_that.beanName,_that.origin,_that.process,_that.altitudeMasl,_that.tastingNotes,_that.confidencePct);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class InteractiveRecipeCardAttachment extends ThreadAttachment {
  const InteractiveRecipeCardAttachment({@JsonKey(name: 'recipe_id') required this.recipeId, required this.title, @JsonKey(name: 'brewer_name') required this.brewerName, required this.method, @JsonKey(name: 'coffee_dose_g') required this.coffeeDoseG, @JsonKey(name: 'total_water_ml') required this.totalWaterMl, @JsonKey(name: 'primary_temp_c') required this.primaryTempC, @JsonKey(name: 'secondary_temp_c') this.secondaryTempC, @JsonKey(name: 'target_duration_sec') required this.targetDurationSec, @JsonKey(name: 'steps_preview')  List<RecipeStepMiniDto> stepsPreview = const [],  String? $type}): _stepsPreview = stepsPreview,$type = $type ?? 'interactiveRecipeCard',super._();
  factory InteractiveRecipeCardAttachment.fromJson(Map<String, dynamic> json) => _$InteractiveRecipeCardAttachmentFromJson(json);

@JsonKey(name: 'recipe_id') final  String recipeId;
 final  String title;
@JsonKey(name: 'brewer_name') final  String brewerName;
 final  String method;
@JsonKey(name: 'coffee_dose_g') final  double coffeeDoseG;
@JsonKey(name: 'total_water_ml') final  double totalWaterMl;
@JsonKey(name: 'primary_temp_c') final  int primaryTempC;
@JsonKey(name: 'secondary_temp_c') final  int? secondaryTempC;
@JsonKey(name: 'target_duration_sec') final  int targetDurationSec;
 final  List<RecipeStepMiniDto> _stepsPreview;
@JsonKey(name: 'steps_preview') List<RecipeStepMiniDto> get stepsPreview {
  if (_stepsPreview is EqualUnmodifiableListView) return _stepsPreview;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stepsPreview);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ThreadAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InteractiveRecipeCardAttachmentCopyWith<InteractiveRecipeCardAttachment> get copyWith => _$InteractiveRecipeCardAttachmentCopyWithImpl<InteractiveRecipeCardAttachment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InteractiveRecipeCardAttachmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InteractiveRecipeCardAttachment&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.title, title) || other.title == title)&&(identical(other.brewerName, brewerName) || other.brewerName == brewerName)&&(identical(other.method, method) || other.method == method)&&(identical(other.coffeeDoseG, coffeeDoseG) || other.coffeeDoseG == coffeeDoseG)&&(identical(other.totalWaterMl, totalWaterMl) || other.totalWaterMl == totalWaterMl)&&(identical(other.primaryTempC, primaryTempC) || other.primaryTempC == primaryTempC)&&(identical(other.secondaryTempC, secondaryTempC) || other.secondaryTempC == secondaryTempC)&&(identical(other.targetDurationSec, targetDurationSec) || other.targetDurationSec == targetDurationSec)&&const DeepCollectionEquality().equals(other._stepsPreview, _stepsPreview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recipeId,title,brewerName,method,coffeeDoseG,totalWaterMl,primaryTempC,secondaryTempC,targetDurationSec,const DeepCollectionEquality().hash(_stepsPreview));

@override
String toString() {
  return 'ThreadAttachment.interactiveRecipeCard(recipeId: $recipeId, title: $title, brewerName: $brewerName, method: $method, coffeeDoseG: $coffeeDoseG, totalWaterMl: $totalWaterMl, primaryTempC: $primaryTempC, secondaryTempC: $secondaryTempC, targetDurationSec: $targetDurationSec, stepsPreview: $stepsPreview)';
}


}

/// @nodoc
abstract mixin class $InteractiveRecipeCardAttachmentCopyWith<$Res> implements $ThreadAttachmentCopyWith<$Res> {
  factory $InteractiveRecipeCardAttachmentCopyWith(InteractiveRecipeCardAttachment value, $Res Function(InteractiveRecipeCardAttachment) _then) = _$InteractiveRecipeCardAttachmentCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'recipe_id') String recipeId, String title,@JsonKey(name: 'brewer_name') String brewerName, String method,@JsonKey(name: 'coffee_dose_g') double coffeeDoseG,@JsonKey(name: 'total_water_ml') double totalWaterMl,@JsonKey(name: 'primary_temp_c') int primaryTempC,@JsonKey(name: 'secondary_temp_c') int? secondaryTempC,@JsonKey(name: 'target_duration_sec') int targetDurationSec,@JsonKey(name: 'steps_preview') List<RecipeStepMiniDto> stepsPreview
});




}
/// @nodoc
class _$InteractiveRecipeCardAttachmentCopyWithImpl<$Res>
    implements $InteractiveRecipeCardAttachmentCopyWith<$Res> {
  _$InteractiveRecipeCardAttachmentCopyWithImpl(this._self, this._then);

  final InteractiveRecipeCardAttachment _self;
  final $Res Function(InteractiveRecipeCardAttachment) _then;

/// Create a copy of ThreadAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? recipeId = null,Object? title = null,Object? brewerName = null,Object? method = null,Object? coffeeDoseG = null,Object? totalWaterMl = null,Object? primaryTempC = null,Object? secondaryTempC = freezed,Object? targetDurationSec = null,Object? stepsPreview = null,}) {
  return _then(InteractiveRecipeCardAttachment(
recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,brewerName: null == brewerName ? _self.brewerName : brewerName // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,coffeeDoseG: null == coffeeDoseG ? _self.coffeeDoseG : coffeeDoseG // ignore: cast_nullable_to_non_nullable
as double,totalWaterMl: null == totalWaterMl ? _self.totalWaterMl : totalWaterMl // ignore: cast_nullable_to_non_nullable
as double,primaryTempC: null == primaryTempC ? _self.primaryTempC : primaryTempC // ignore: cast_nullable_to_non_nullable
as int,secondaryTempC: freezed == secondaryTempC ? _self.secondaryTempC : secondaryTempC // ignore: cast_nullable_to_non_nullable
as int?,targetDurationSec: null == targetDurationSec ? _self.targetDurationSec : targetDurationSec // ignore: cast_nullable_to_non_nullable
as int,stepsPreview: null == stepsPreview ? _self._stepsPreview : stepsPreview // ignore: cast_nullable_to_non_nullable
as List<RecipeStepMiniDto>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class PouringTelemetryCurveAttachment extends ThreadAttachment {
  const PouringTelemetryCurveAttachment({@JsonKey(name: 'session_id') required this.sessionId, @JsonKey(name: 'recipe_title') required this.recipeTitle, @JsonKey(name: 'bean_name') required this.beanName, @JsonKey(name: 'accuracy_score_pct') required this.accuracyScorePct, @JsonKey(name: 'total_duration_sec') required this.totalDurationSec, @JsonKey(name: 'curve_points')  List<PourCurvePoint> curvePoints = const [],  String? $type}): _curvePoints = curvePoints,$type = $type ?? 'pouringTelemetryCurve',super._();
  factory PouringTelemetryCurveAttachment.fromJson(Map<String, dynamic> json) => _$PouringTelemetryCurveAttachmentFromJson(json);

@JsonKey(name: 'session_id') final  String sessionId;
@JsonKey(name: 'recipe_title') final  String recipeTitle;
@JsonKey(name: 'bean_name') final  String beanName;
@JsonKey(name: 'accuracy_score_pct') final  double accuracyScorePct;
@JsonKey(name: 'total_duration_sec') final  int totalDurationSec;
 final  List<PourCurvePoint> _curvePoints;
@JsonKey(name: 'curve_points') List<PourCurvePoint> get curvePoints {
  if (_curvePoints is EqualUnmodifiableListView) return _curvePoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_curvePoints);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ThreadAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PouringTelemetryCurveAttachmentCopyWith<PouringTelemetryCurveAttachment> get copyWith => _$PouringTelemetryCurveAttachmentCopyWithImpl<PouringTelemetryCurveAttachment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PouringTelemetryCurveAttachmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PouringTelemetryCurveAttachment&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.recipeTitle, recipeTitle) || other.recipeTitle == recipeTitle)&&(identical(other.beanName, beanName) || other.beanName == beanName)&&(identical(other.accuracyScorePct, accuracyScorePct) || other.accuracyScorePct == accuracyScorePct)&&(identical(other.totalDurationSec, totalDurationSec) || other.totalDurationSec == totalDurationSec)&&const DeepCollectionEquality().equals(other._curvePoints, _curvePoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,recipeTitle,beanName,accuracyScorePct,totalDurationSec,const DeepCollectionEquality().hash(_curvePoints));

@override
String toString() {
  return 'ThreadAttachment.pouringTelemetryCurve(sessionId: $sessionId, recipeTitle: $recipeTitle, beanName: $beanName, accuracyScorePct: $accuracyScorePct, totalDurationSec: $totalDurationSec, curvePoints: $curvePoints)';
}


}

/// @nodoc
abstract mixin class $PouringTelemetryCurveAttachmentCopyWith<$Res> implements $ThreadAttachmentCopyWith<$Res> {
  factory $PouringTelemetryCurveAttachmentCopyWith(PouringTelemetryCurveAttachment value, $Res Function(PouringTelemetryCurveAttachment) _then) = _$PouringTelemetryCurveAttachmentCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'recipe_title') String recipeTitle,@JsonKey(name: 'bean_name') String beanName,@JsonKey(name: 'accuracy_score_pct') double accuracyScorePct,@JsonKey(name: 'total_duration_sec') int totalDurationSec,@JsonKey(name: 'curve_points') List<PourCurvePoint> curvePoints
});




}
/// @nodoc
class _$PouringTelemetryCurveAttachmentCopyWithImpl<$Res>
    implements $PouringTelemetryCurveAttachmentCopyWith<$Res> {
  _$PouringTelemetryCurveAttachmentCopyWithImpl(this._self, this._then);

  final PouringTelemetryCurveAttachment _self;
  final $Res Function(PouringTelemetryCurveAttachment) _then;

/// Create a copy of ThreadAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? recipeTitle = null,Object? beanName = null,Object? accuracyScorePct = null,Object? totalDurationSec = null,Object? curvePoints = null,}) {
  return _then(PouringTelemetryCurveAttachment(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,recipeTitle: null == recipeTitle ? _self.recipeTitle : recipeTitle // ignore: cast_nullable_to_non_nullable
as String,beanName: null == beanName ? _self.beanName : beanName // ignore: cast_nullable_to_non_nullable
as String,accuracyScorePct: null == accuracyScorePct ? _self.accuracyScorePct : accuracyScorePct // ignore: cast_nullable_to_non_nullable
as double,totalDurationSec: null == totalDurationSec ? _self.totalDurationSec : totalDurationSec // ignore: cast_nullable_to_non_nullable
as int,curvePoints: null == curvePoints ? _self._curvePoints : curvePoints // ignore: cast_nullable_to_non_nullable
as List<PourCurvePoint>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ScannedCoffeeBagTagAttachment extends ThreadAttachment {
  const ScannedCoffeeBagTagAttachment({@JsonKey(name: 'class_slug') required this.classSlug, required this.roastery, @JsonKey(name: 'bean_name') required this.beanName, required this.origin, required this.process, @JsonKey(name: 'altitude_masl') required this.altitudeMasl, @JsonKey(name: 'tasting_notes')  List<String> tastingNotes = const [], @JsonKey(name: 'confidence_pct') required this.confidencePct,  String? $type}): _tastingNotes = tastingNotes,$type = $type ?? 'scannedCoffeeBagTag',super._();
  factory ScannedCoffeeBagTagAttachment.fromJson(Map<String, dynamic> json) => _$ScannedCoffeeBagTagAttachmentFromJson(json);

@JsonKey(name: 'class_slug') final  String classSlug;
 final  String roastery;
@JsonKey(name: 'bean_name') final  String beanName;
 final  String origin;
 final  String process;
@JsonKey(name: 'altitude_masl') final  String altitudeMasl;
 final  List<String> _tastingNotes;
@JsonKey(name: 'tasting_notes') List<String> get tastingNotes {
  if (_tastingNotes is EqualUnmodifiableListView) return _tastingNotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tastingNotes);
}

@JsonKey(name: 'confidence_pct') final  double confidencePct;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ThreadAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScannedCoffeeBagTagAttachmentCopyWith<ScannedCoffeeBagTagAttachment> get copyWith => _$ScannedCoffeeBagTagAttachmentCopyWithImpl<ScannedCoffeeBagTagAttachment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScannedCoffeeBagTagAttachmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScannedCoffeeBagTagAttachment&&(identical(other.classSlug, classSlug) || other.classSlug == classSlug)&&(identical(other.roastery, roastery) || other.roastery == roastery)&&(identical(other.beanName, beanName) || other.beanName == beanName)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.process, process) || other.process == process)&&(identical(other.altitudeMasl, altitudeMasl) || other.altitudeMasl == altitudeMasl)&&const DeepCollectionEquality().equals(other._tastingNotes, _tastingNotes)&&(identical(other.confidencePct, confidencePct) || other.confidencePct == confidencePct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,classSlug,roastery,beanName,origin,process,altitudeMasl,const DeepCollectionEquality().hash(_tastingNotes),confidencePct);

@override
String toString() {
  return 'ThreadAttachment.scannedCoffeeBagTag(classSlug: $classSlug, roastery: $roastery, beanName: $beanName, origin: $origin, process: $process, altitudeMasl: $altitudeMasl, tastingNotes: $tastingNotes, confidencePct: $confidencePct)';
}


}

/// @nodoc
abstract mixin class $ScannedCoffeeBagTagAttachmentCopyWith<$Res> implements $ThreadAttachmentCopyWith<$Res> {
  factory $ScannedCoffeeBagTagAttachmentCopyWith(ScannedCoffeeBagTagAttachment value, $Res Function(ScannedCoffeeBagTagAttachment) _then) = _$ScannedCoffeeBagTagAttachmentCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'class_slug') String classSlug, String roastery,@JsonKey(name: 'bean_name') String beanName, String origin, String process,@JsonKey(name: 'altitude_masl') String altitudeMasl,@JsonKey(name: 'tasting_notes') List<String> tastingNotes,@JsonKey(name: 'confidence_pct') double confidencePct
});




}
/// @nodoc
class _$ScannedCoffeeBagTagAttachmentCopyWithImpl<$Res>
    implements $ScannedCoffeeBagTagAttachmentCopyWith<$Res> {
  _$ScannedCoffeeBagTagAttachmentCopyWithImpl(this._self, this._then);

  final ScannedCoffeeBagTagAttachment _self;
  final $Res Function(ScannedCoffeeBagTagAttachment) _then;

/// Create a copy of ThreadAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? classSlug = null,Object? roastery = null,Object? beanName = null,Object? origin = null,Object? process = null,Object? altitudeMasl = null,Object? tastingNotes = null,Object? confidencePct = null,}) {
  return _then(ScannedCoffeeBagTagAttachment(
classSlug: null == classSlug ? _self.classSlug : classSlug // ignore: cast_nullable_to_non_nullable
as String,roastery: null == roastery ? _self.roastery : roastery // ignore: cast_nullable_to_non_nullable
as String,beanName: null == beanName ? _self.beanName : beanName // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as String,process: null == process ? _self.process : process // ignore: cast_nullable_to_non_nullable
as String,altitudeMasl: null == altitudeMasl ? _self.altitudeMasl : altitudeMasl // ignore: cast_nullable_to_non_nullable
as String,tastingNotes: null == tastingNotes ? _self._tastingNotes : tastingNotes // ignore: cast_nullable_to_non_nullable
as List<String>,confidencePct: null == confidencePct ? _self.confidencePct : confidencePct // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$QuotedThreadPreview {

 String get id;@JsonKey(name: 'author_id') String get authorId;@JsonKey(name: 'author_username') String get authorUsername;@JsonKey(name: 'author_display_name') String get authorDisplayName;@JsonKey(name: 'author_avatar_url') String? get authorAvatarUrl;@JsonKey(name: 'body_text') String get bodyText; String get kind;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of QuotedThreadPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuotedThreadPreviewCopyWith<QuotedThreadPreview> get copyWith => _$QuotedThreadPreviewCopyWithImpl<QuotedThreadPreview>(this as QuotedThreadPreview, _$identity);

  /// Serializes this QuotedThreadPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuotedThreadPreview&&(identical(other.id, id) || other.id == id)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorUsername, authorUsername) || other.authorUsername == authorUsername)&&(identical(other.authorDisplayName, authorDisplayName) || other.authorDisplayName == authorDisplayName)&&(identical(other.authorAvatarUrl, authorAvatarUrl) || other.authorAvatarUrl == authorAvatarUrl)&&(identical(other.bodyText, bodyText) || other.bodyText == bodyText)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,authorId,authorUsername,authorDisplayName,authorAvatarUrl,bodyText,kind,createdAt);

@override
String toString() {
  return 'QuotedThreadPreview(id: $id, authorId: $authorId, authorUsername: $authorUsername, authorDisplayName: $authorDisplayName, authorAvatarUrl: $authorAvatarUrl, bodyText: $bodyText, kind: $kind, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $QuotedThreadPreviewCopyWith<$Res>  {
  factory $QuotedThreadPreviewCopyWith(QuotedThreadPreview value, $Res Function(QuotedThreadPreview) _then) = _$QuotedThreadPreviewCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'author_id') String authorId,@JsonKey(name: 'author_username') String authorUsername,@JsonKey(name: 'author_display_name') String authorDisplayName,@JsonKey(name: 'author_avatar_url') String? authorAvatarUrl,@JsonKey(name: 'body_text') String bodyText, String kind,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$QuotedThreadPreviewCopyWithImpl<$Res>
    implements $QuotedThreadPreviewCopyWith<$Res> {
  _$QuotedThreadPreviewCopyWithImpl(this._self, this._then);

  final QuotedThreadPreview _self;
  final $Res Function(QuotedThreadPreview) _then;

/// Create a copy of QuotedThreadPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? authorId = null,Object? authorUsername = null,Object? authorDisplayName = null,Object? authorAvatarUrl = freezed,Object? bodyText = null,Object? kind = null,Object? createdAt = null,}) {
  return _then(QuotedThreadPreview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,authorUsername: null == authorUsername ? _self.authorUsername : authorUsername // ignore: cast_nullable_to_non_nullable
as String,authorDisplayName: null == authorDisplayName ? _self.authorDisplayName : authorDisplayName // ignore: cast_nullable_to_non_nullable
as String,authorAvatarUrl: freezed == authorAvatarUrl ? _self.authorAvatarUrl : authorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bodyText: null == bodyText ? _self.bodyText : bodyText // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [QuotedThreadPreview].
extension QuotedThreadPreviewPatterns on QuotedThreadPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuotedThreadPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuotedThreadPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuotedThreadPreview value)  $default,){
final _that = this;
switch (_that) {
case _QuotedThreadPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuotedThreadPreview value)?  $default,){
final _that = this;
switch (_that) {
case _QuotedThreadPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'author_id')  String authorId, @JsonKey(name: 'author_username')  String authorUsername, @JsonKey(name: 'author_display_name')  String authorDisplayName, @JsonKey(name: 'author_avatar_url')  String? authorAvatarUrl, @JsonKey(name: 'body_text')  String bodyText,  String kind, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuotedThreadPreview() when $default != null:
return $default(_that.id,_that.authorId,_that.authorUsername,_that.authorDisplayName,_that.authorAvatarUrl,_that.bodyText,_that.kind,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'author_id')  String authorId, @JsonKey(name: 'author_username')  String authorUsername, @JsonKey(name: 'author_display_name')  String authorDisplayName, @JsonKey(name: 'author_avatar_url')  String? authorAvatarUrl, @JsonKey(name: 'body_text')  String bodyText,  String kind, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _QuotedThreadPreview():
return $default(_that.id,_that.authorId,_that.authorUsername,_that.authorDisplayName,_that.authorAvatarUrl,_that.bodyText,_that.kind,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'author_id')  String authorId, @JsonKey(name: 'author_username')  String authorUsername, @JsonKey(name: 'author_display_name')  String authorDisplayName, @JsonKey(name: 'author_avatar_url')  String? authorAvatarUrl, @JsonKey(name: 'body_text')  String bodyText,  String kind, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _QuotedThreadPreview() when $default != null:
return $default(_that.id,_that.authorId,_that.authorUsername,_that.authorDisplayName,_that.authorAvatarUrl,_that.bodyText,_that.kind,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuotedThreadPreview implements QuotedThreadPreview {
  const _QuotedThreadPreview({required this.id, @JsonKey(name: 'author_id') required this.authorId, @JsonKey(name: 'author_username') required this.authorUsername, @JsonKey(name: 'author_display_name') required this.authorDisplayName, @JsonKey(name: 'author_avatar_url') this.authorAvatarUrl, @JsonKey(name: 'body_text') this.bodyText = '', this.kind = 'STANDARD_POST', @JsonKey(name: 'created_at') required this.createdAt});
  factory _QuotedThreadPreview.fromJson(Map<String, dynamic> json) => _$QuotedThreadPreviewFromJson(json);

@override final  String id;
@override@JsonKey(name: 'author_id') final  String authorId;
@override@JsonKey(name: 'author_username') final  String authorUsername;
@override@JsonKey(name: 'author_display_name') final  String authorDisplayName;
@override@JsonKey(name: 'author_avatar_url') final  String? authorAvatarUrl;
@override@JsonKey(name: 'body_text') final  String bodyText;
@override@JsonKey() final  String kind;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of QuotedThreadPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuotedThreadPreviewCopyWith<_QuotedThreadPreview> get copyWith => __$QuotedThreadPreviewCopyWithImpl<_QuotedThreadPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuotedThreadPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuotedThreadPreview&&(identical(other.id, id) || other.id == id)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorUsername, authorUsername) || other.authorUsername == authorUsername)&&(identical(other.authorDisplayName, authorDisplayName) || other.authorDisplayName == authorDisplayName)&&(identical(other.authorAvatarUrl, authorAvatarUrl) || other.authorAvatarUrl == authorAvatarUrl)&&(identical(other.bodyText, bodyText) || other.bodyText == bodyText)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,authorId,authorUsername,authorDisplayName,authorAvatarUrl,bodyText,kind,createdAt);

@override
String toString() {
  return 'QuotedThreadPreview(id: $id, authorId: $authorId, authorUsername: $authorUsername, authorDisplayName: $authorDisplayName, authorAvatarUrl: $authorAvatarUrl, bodyText: $bodyText, kind: $kind, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$QuotedThreadPreviewCopyWith<$Res> implements $QuotedThreadPreviewCopyWith<$Res> {
  factory _$QuotedThreadPreviewCopyWith(_QuotedThreadPreview value, $Res Function(_QuotedThreadPreview) _then) = __$QuotedThreadPreviewCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'author_id') String authorId,@JsonKey(name: 'author_username') String authorUsername,@JsonKey(name: 'author_display_name') String authorDisplayName,@JsonKey(name: 'author_avatar_url') String? authorAvatarUrl,@JsonKey(name: 'body_text') String bodyText, String kind,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$QuotedThreadPreviewCopyWithImpl<$Res>
    implements _$QuotedThreadPreviewCopyWith<$Res> {
  __$QuotedThreadPreviewCopyWithImpl(this._self, this._then);

  final _QuotedThreadPreview _self;
  final $Res Function(_QuotedThreadPreview) _then;

/// Create a copy of QuotedThreadPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? authorId = null,Object? authorUsername = null,Object? authorDisplayName = null,Object? authorAvatarUrl = freezed,Object? bodyText = null,Object? kind = null,Object? createdAt = null,}) {
  return _then(_QuotedThreadPreview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,authorUsername: null == authorUsername ? _self.authorUsername : authorUsername // ignore: cast_nullable_to_non_nullable
as String,authorDisplayName: null == authorDisplayName ? _self.authorDisplayName : authorDisplayName // ignore: cast_nullable_to_non_nullable
as String,authorAvatarUrl: freezed == authorAvatarUrl ? _self.authorAvatarUrl : authorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bodyText: null == bodyText ? _self.bodyText : bodyText // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$SocialThreadItem {

 String get id;@JsonKey(name: 'author_id') String get authorId;@JsonKey(name: 'author_username') String get authorUsername;@JsonKey(name: 'author_display_name') String get authorDisplayName;@JsonKey(name: 'author_avatar_url') String? get authorAvatarUrl;@JsonKey(name: 'author_tier') String get authorTier;@JsonKey(name: 'author_barista_level') int get authorBaristaLevel;@JsonKey(name: 'author_barista_rank_title') String get authorBaristaRankTitle; String get kind;@JsonKey(name: 'parent_thread_id') String? get parentThreadId;@JsonKey(name: 'root_thread_id') String? get rootThreadId;@JsonKey(name: 'quoted_thread_id') String? get quotedThreadId;@JsonKey(name: 'quoted_preview') QuotedThreadPreview? get quotedPreview;@JsonKey(name: 'depth_level') int get depthLevel;@JsonKey(name: 'body_text') String get bodyText;@JsonKey(name: 'has_media') bool get hasMedia;@JsonKey(name: 'media_urls') List<MediaAttachmentItem> get mediaUrls;@JsonKey(name: 'attachment') Map<String, dynamic>? get rawAttachment;@JsonKey(name: 'likes_count') int get likesCount;@JsonKey(name: 'replies_count') int get repliesCount;@JsonKey(name: 'reposts_count') int get repostsCount;@JsonKey(name: 'try_recipe_count') int get tryRecipeCount;@JsonKey(name: 'is_pinned_on_profile') bool get isPinnedOnProfile;@JsonKey(name: 'is_liked_by_me') bool get isLikedByMe;@JsonKey(name: 'is_reposted_by_me') bool get isRepostedByMe;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of SocialThreadItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialThreadItemCopyWith<SocialThreadItem> get copyWith => _$SocialThreadItemCopyWithImpl<SocialThreadItem>(this as SocialThreadItem, _$identity);

  /// Serializes this SocialThreadItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialThreadItem&&(identical(other.id, id) || other.id == id)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorUsername, authorUsername) || other.authorUsername == authorUsername)&&(identical(other.authorDisplayName, authorDisplayName) || other.authorDisplayName == authorDisplayName)&&(identical(other.authorAvatarUrl, authorAvatarUrl) || other.authorAvatarUrl == authorAvatarUrl)&&(identical(other.authorTier, authorTier) || other.authorTier == authorTier)&&(identical(other.authorBaristaLevel, authorBaristaLevel) || other.authorBaristaLevel == authorBaristaLevel)&&(identical(other.authorBaristaRankTitle, authorBaristaRankTitle) || other.authorBaristaRankTitle == authorBaristaRankTitle)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.parentThreadId, parentThreadId) || other.parentThreadId == parentThreadId)&&(identical(other.rootThreadId, rootThreadId) || other.rootThreadId == rootThreadId)&&(identical(other.quotedThreadId, quotedThreadId) || other.quotedThreadId == quotedThreadId)&&(identical(other.quotedPreview, quotedPreview) || other.quotedPreview == quotedPreview)&&(identical(other.depthLevel, depthLevel) || other.depthLevel == depthLevel)&&(identical(other.bodyText, bodyText) || other.bodyText == bodyText)&&(identical(other.hasMedia, hasMedia) || other.hasMedia == hasMedia)&&const DeepCollectionEquality().equals(other.mediaUrls, mediaUrls)&&const DeepCollectionEquality().equals(other.rawAttachment, rawAttachment)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.repliesCount, repliesCount) || other.repliesCount == repliesCount)&&(identical(other.repostsCount, repostsCount) || other.repostsCount == repostsCount)&&(identical(other.tryRecipeCount, tryRecipeCount) || other.tryRecipeCount == tryRecipeCount)&&(identical(other.isPinnedOnProfile, isPinnedOnProfile) || other.isPinnedOnProfile == isPinnedOnProfile)&&(identical(other.isLikedByMe, isLikedByMe) || other.isLikedByMe == isLikedByMe)&&(identical(other.isRepostedByMe, isRepostedByMe) || other.isRepostedByMe == isRepostedByMe)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,authorId,authorUsername,authorDisplayName,authorAvatarUrl,authorTier,authorBaristaLevel,authorBaristaRankTitle,kind,parentThreadId,rootThreadId,quotedThreadId,quotedPreview,depthLevel,bodyText,hasMedia,const DeepCollectionEquality().hash(mediaUrls),const DeepCollectionEquality().hash(rawAttachment),likesCount,repliesCount,repostsCount,tryRecipeCount,isPinnedOnProfile,isLikedByMe,isRepostedByMe,createdAt]);

@override
String toString() {
  return 'SocialThreadItem(id: $id, authorId: $authorId, authorUsername: $authorUsername, authorDisplayName: $authorDisplayName, authorAvatarUrl: $authorAvatarUrl, authorTier: $authorTier, authorBaristaLevel: $authorBaristaLevel, authorBaristaRankTitle: $authorBaristaRankTitle, kind: $kind, parentThreadId: $parentThreadId, rootThreadId: $rootThreadId, quotedThreadId: $quotedThreadId, quotedPreview: $quotedPreview, depthLevel: $depthLevel, bodyText: $bodyText, hasMedia: $hasMedia, mediaUrls: $mediaUrls, rawAttachment: $rawAttachment, likesCount: $likesCount, repliesCount: $repliesCount, repostsCount: $repostsCount, tryRecipeCount: $tryRecipeCount, isPinnedOnProfile: $isPinnedOnProfile, isLikedByMe: $isLikedByMe, isRepostedByMe: $isRepostedByMe, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SocialThreadItemCopyWith<$Res>  {
  factory $SocialThreadItemCopyWith(SocialThreadItem value, $Res Function(SocialThreadItem) _then) = _$SocialThreadItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'author_id') String authorId,@JsonKey(name: 'author_username') String authorUsername,@JsonKey(name: 'author_display_name') String authorDisplayName,@JsonKey(name: 'author_avatar_url') String? authorAvatarUrl,@JsonKey(name: 'author_tier') String authorTier,@JsonKey(name: 'author_barista_level') int authorBaristaLevel,@JsonKey(name: 'author_barista_rank_title') String authorBaristaRankTitle, String kind,@JsonKey(name: 'parent_thread_id') String? parentThreadId,@JsonKey(name: 'root_thread_id') String? rootThreadId,@JsonKey(name: 'quoted_thread_id') String? quotedThreadId,@JsonKey(name: 'quoted_preview') QuotedThreadPreview? quotedPreview,@JsonKey(name: 'depth_level') int depthLevel,@JsonKey(name: 'body_text') String bodyText,@JsonKey(name: 'has_media') bool hasMedia,@JsonKey(name: 'media_urls') List<MediaAttachmentItem> mediaUrls,@JsonKey(name: 'attachment') Map<String, dynamic>? rawAttachment,@JsonKey(name: 'likes_count') int likesCount,@JsonKey(name: 'replies_count') int repliesCount,@JsonKey(name: 'reposts_count') int repostsCount,@JsonKey(name: 'try_recipe_count') int tryRecipeCount,@JsonKey(name: 'is_pinned_on_profile') bool isPinnedOnProfile,@JsonKey(name: 'is_liked_by_me') bool isLikedByMe,@JsonKey(name: 'is_reposted_by_me') bool isRepostedByMe,@JsonKey(name: 'created_at') DateTime createdAt
});


$QuotedThreadPreviewCopyWith<$Res>? get quotedPreview;

}
/// @nodoc
class _$SocialThreadItemCopyWithImpl<$Res>
    implements $SocialThreadItemCopyWith<$Res> {
  _$SocialThreadItemCopyWithImpl(this._self, this._then);

  final SocialThreadItem _self;
  final $Res Function(SocialThreadItem) _then;

/// Create a copy of SocialThreadItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? authorId = null,Object? authorUsername = null,Object? authorDisplayName = null,Object? authorAvatarUrl = freezed,Object? authorTier = null,Object? authorBaristaLevel = null,Object? authorBaristaRankTitle = null,Object? kind = null,Object? parentThreadId = freezed,Object? rootThreadId = freezed,Object? quotedThreadId = freezed,Object? quotedPreview = freezed,Object? depthLevel = null,Object? bodyText = null,Object? hasMedia = null,Object? mediaUrls = null,Object? rawAttachment = freezed,Object? likesCount = null,Object? repliesCount = null,Object? repostsCount = null,Object? tryRecipeCount = null,Object? isPinnedOnProfile = null,Object? isLikedByMe = null,Object? isRepostedByMe = null,Object? createdAt = null,}) {
  return _then(SocialThreadItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,authorUsername: null == authorUsername ? _self.authorUsername : authorUsername // ignore: cast_nullable_to_non_nullable
as String,authorDisplayName: null == authorDisplayName ? _self.authorDisplayName : authorDisplayName // ignore: cast_nullable_to_non_nullable
as String,authorAvatarUrl: freezed == authorAvatarUrl ? _self.authorAvatarUrl : authorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,authorTier: null == authorTier ? _self.authorTier : authorTier // ignore: cast_nullable_to_non_nullable
as String,authorBaristaLevel: null == authorBaristaLevel ? _self.authorBaristaLevel : authorBaristaLevel // ignore: cast_nullable_to_non_nullable
as int,authorBaristaRankTitle: null == authorBaristaRankTitle ? _self.authorBaristaRankTitle : authorBaristaRankTitle // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,parentThreadId: freezed == parentThreadId ? _self.parentThreadId : parentThreadId // ignore: cast_nullable_to_non_nullable
as String?,rootThreadId: freezed == rootThreadId ? _self.rootThreadId : rootThreadId // ignore: cast_nullable_to_non_nullable
as String?,quotedThreadId: freezed == quotedThreadId ? _self.quotedThreadId : quotedThreadId // ignore: cast_nullable_to_non_nullable
as String?,quotedPreview: freezed == quotedPreview ? _self.quotedPreview : quotedPreview // ignore: cast_nullable_to_non_nullable
as QuotedThreadPreview?,depthLevel: null == depthLevel ? _self.depthLevel : depthLevel // ignore: cast_nullable_to_non_nullable
as int,bodyText: null == bodyText ? _self.bodyText : bodyText // ignore: cast_nullable_to_non_nullable
as String,hasMedia: null == hasMedia ? _self.hasMedia : hasMedia // ignore: cast_nullable_to_non_nullable
as bool,mediaUrls: null == mediaUrls ? _self.mediaUrls : mediaUrls // ignore: cast_nullable_to_non_nullable
as List<MediaAttachmentItem>,rawAttachment: freezed == rawAttachment ? _self.rawAttachment : rawAttachment // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,repliesCount: null == repliesCount ? _self.repliesCount : repliesCount // ignore: cast_nullable_to_non_nullable
as int,repostsCount: null == repostsCount ? _self.repostsCount : repostsCount // ignore: cast_nullable_to_non_nullable
as int,tryRecipeCount: null == tryRecipeCount ? _self.tryRecipeCount : tryRecipeCount // ignore: cast_nullable_to_non_nullable
as int,isPinnedOnProfile: null == isPinnedOnProfile ? _self.isPinnedOnProfile : isPinnedOnProfile // ignore: cast_nullable_to_non_nullable
as bool,isLikedByMe: null == isLikedByMe ? _self.isLikedByMe : isLikedByMe // ignore: cast_nullable_to_non_nullable
as bool,isRepostedByMe: null == isRepostedByMe ? _self.isRepostedByMe : isRepostedByMe // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of SocialThreadItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuotedThreadPreviewCopyWith<$Res>? get quotedPreview {
    if (_self.quotedPreview == null) {
    return null;
  }

  return $QuotedThreadPreviewCopyWith<$Res>(_self.quotedPreview!, (value) {
    return _then(_self.copyWith(quotedPreview: value));
  });
}
}


/// Adds pattern-matching-related methods to [SocialThreadItem].
extension SocialThreadItemPatterns on SocialThreadItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocialThreadItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocialThreadItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocialThreadItem value)  $default,){
final _that = this;
switch (_that) {
case _SocialThreadItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocialThreadItem value)?  $default,){
final _that = this;
switch (_that) {
case _SocialThreadItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'author_id')  String authorId, @JsonKey(name: 'author_username')  String authorUsername, @JsonKey(name: 'author_display_name')  String authorDisplayName, @JsonKey(name: 'author_avatar_url')  String? authorAvatarUrl, @JsonKey(name: 'author_tier')  String authorTier, @JsonKey(name: 'author_barista_level')  int authorBaristaLevel, @JsonKey(name: 'author_barista_rank_title')  String authorBaristaRankTitle,  String kind, @JsonKey(name: 'parent_thread_id')  String? parentThreadId, @JsonKey(name: 'root_thread_id')  String? rootThreadId, @JsonKey(name: 'quoted_thread_id')  String? quotedThreadId, @JsonKey(name: 'quoted_preview')  QuotedThreadPreview? quotedPreview, @JsonKey(name: 'depth_level')  int depthLevel, @JsonKey(name: 'body_text')  String bodyText, @JsonKey(name: 'has_media')  bool hasMedia, @JsonKey(name: 'media_urls')  List<MediaAttachmentItem> mediaUrls, @JsonKey(name: 'attachment')  Map<String, dynamic>? rawAttachment, @JsonKey(name: 'likes_count')  int likesCount, @JsonKey(name: 'replies_count')  int repliesCount, @JsonKey(name: 'reposts_count')  int repostsCount, @JsonKey(name: 'try_recipe_count')  int tryRecipeCount, @JsonKey(name: 'is_pinned_on_profile')  bool isPinnedOnProfile, @JsonKey(name: 'is_liked_by_me')  bool isLikedByMe, @JsonKey(name: 'is_reposted_by_me')  bool isRepostedByMe, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocialThreadItem() when $default != null:
return $default(_that.id,_that.authorId,_that.authorUsername,_that.authorDisplayName,_that.authorAvatarUrl,_that.authorTier,_that.authorBaristaLevel,_that.authorBaristaRankTitle,_that.kind,_that.parentThreadId,_that.rootThreadId,_that.quotedThreadId,_that.quotedPreview,_that.depthLevel,_that.bodyText,_that.hasMedia,_that.mediaUrls,_that.rawAttachment,_that.likesCount,_that.repliesCount,_that.repostsCount,_that.tryRecipeCount,_that.isPinnedOnProfile,_that.isLikedByMe,_that.isRepostedByMe,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'author_id')  String authorId, @JsonKey(name: 'author_username')  String authorUsername, @JsonKey(name: 'author_display_name')  String authorDisplayName, @JsonKey(name: 'author_avatar_url')  String? authorAvatarUrl, @JsonKey(name: 'author_tier')  String authorTier, @JsonKey(name: 'author_barista_level')  int authorBaristaLevel, @JsonKey(name: 'author_barista_rank_title')  String authorBaristaRankTitle,  String kind, @JsonKey(name: 'parent_thread_id')  String? parentThreadId, @JsonKey(name: 'root_thread_id')  String? rootThreadId, @JsonKey(name: 'quoted_thread_id')  String? quotedThreadId, @JsonKey(name: 'quoted_preview')  QuotedThreadPreview? quotedPreview, @JsonKey(name: 'depth_level')  int depthLevel, @JsonKey(name: 'body_text')  String bodyText, @JsonKey(name: 'has_media')  bool hasMedia, @JsonKey(name: 'media_urls')  List<MediaAttachmentItem> mediaUrls, @JsonKey(name: 'attachment')  Map<String, dynamic>? rawAttachment, @JsonKey(name: 'likes_count')  int likesCount, @JsonKey(name: 'replies_count')  int repliesCount, @JsonKey(name: 'reposts_count')  int repostsCount, @JsonKey(name: 'try_recipe_count')  int tryRecipeCount, @JsonKey(name: 'is_pinned_on_profile')  bool isPinnedOnProfile, @JsonKey(name: 'is_liked_by_me')  bool isLikedByMe, @JsonKey(name: 'is_reposted_by_me')  bool isRepostedByMe, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _SocialThreadItem():
return $default(_that.id,_that.authorId,_that.authorUsername,_that.authorDisplayName,_that.authorAvatarUrl,_that.authorTier,_that.authorBaristaLevel,_that.authorBaristaRankTitle,_that.kind,_that.parentThreadId,_that.rootThreadId,_that.quotedThreadId,_that.quotedPreview,_that.depthLevel,_that.bodyText,_that.hasMedia,_that.mediaUrls,_that.rawAttachment,_that.likesCount,_that.repliesCount,_that.repostsCount,_that.tryRecipeCount,_that.isPinnedOnProfile,_that.isLikedByMe,_that.isRepostedByMe,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'author_id')  String authorId, @JsonKey(name: 'author_username')  String authorUsername, @JsonKey(name: 'author_display_name')  String authorDisplayName, @JsonKey(name: 'author_avatar_url')  String? authorAvatarUrl, @JsonKey(name: 'author_tier')  String authorTier, @JsonKey(name: 'author_barista_level')  int authorBaristaLevel, @JsonKey(name: 'author_barista_rank_title')  String authorBaristaRankTitle,  String kind, @JsonKey(name: 'parent_thread_id')  String? parentThreadId, @JsonKey(name: 'root_thread_id')  String? rootThreadId, @JsonKey(name: 'quoted_thread_id')  String? quotedThreadId, @JsonKey(name: 'quoted_preview')  QuotedThreadPreview? quotedPreview, @JsonKey(name: 'depth_level')  int depthLevel, @JsonKey(name: 'body_text')  String bodyText, @JsonKey(name: 'has_media')  bool hasMedia, @JsonKey(name: 'media_urls')  List<MediaAttachmentItem> mediaUrls, @JsonKey(name: 'attachment')  Map<String, dynamic>? rawAttachment, @JsonKey(name: 'likes_count')  int likesCount, @JsonKey(name: 'replies_count')  int repliesCount, @JsonKey(name: 'reposts_count')  int repostsCount, @JsonKey(name: 'try_recipe_count')  int tryRecipeCount, @JsonKey(name: 'is_pinned_on_profile')  bool isPinnedOnProfile, @JsonKey(name: 'is_liked_by_me')  bool isLikedByMe, @JsonKey(name: 'is_reposted_by_me')  bool isRepostedByMe, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SocialThreadItem() when $default != null:
return $default(_that.id,_that.authorId,_that.authorUsername,_that.authorDisplayName,_that.authorAvatarUrl,_that.authorTier,_that.authorBaristaLevel,_that.authorBaristaRankTitle,_that.kind,_that.parentThreadId,_that.rootThreadId,_that.quotedThreadId,_that.quotedPreview,_that.depthLevel,_that.bodyText,_that.hasMedia,_that.mediaUrls,_that.rawAttachment,_that.likesCount,_that.repliesCount,_that.repostsCount,_that.tryRecipeCount,_that.isPinnedOnProfile,_that.isLikedByMe,_that.isRepostedByMe,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SocialThreadItem extends SocialThreadItem {
  const _SocialThreadItem({required this.id, @JsonKey(name: 'author_id') required this.authorId, @JsonKey(name: 'author_username') required this.authorUsername, @JsonKey(name: 'author_display_name') required this.authorDisplayName, @JsonKey(name: 'author_avatar_url') this.authorAvatarUrl, @JsonKey(name: 'author_tier') this.authorTier = 'Trial', @JsonKey(name: 'author_barista_level') this.authorBaristaLevel = 1, @JsonKey(name: 'author_barista_rank_title') this.authorBaristaRankTitle = 'Home Brewer', this.kind = 'STANDARD_POST', @JsonKey(name: 'parent_thread_id') this.parentThreadId, @JsonKey(name: 'root_thread_id') this.rootThreadId, @JsonKey(name: 'quoted_thread_id') this.quotedThreadId, @JsonKey(name: 'quoted_preview') this.quotedPreview, @JsonKey(name: 'depth_level') this.depthLevel = 0, @JsonKey(name: 'body_text') this.bodyText = '', @JsonKey(name: 'has_media') this.hasMedia = false, @JsonKey(name: 'media_urls')  List<MediaAttachmentItem> mediaUrls = const [], @JsonKey(name: 'attachment')  Map<String, dynamic>? rawAttachment, @JsonKey(name: 'likes_count') this.likesCount = 0, @JsonKey(name: 'replies_count') this.repliesCount = 0, @JsonKey(name: 'reposts_count') this.repostsCount = 0, @JsonKey(name: 'try_recipe_count') this.tryRecipeCount = 0, @JsonKey(name: 'is_pinned_on_profile') this.isPinnedOnProfile = false, @JsonKey(name: 'is_liked_by_me') this.isLikedByMe = false, @JsonKey(name: 'is_reposted_by_me') this.isRepostedByMe = false, @JsonKey(name: 'created_at') required this.createdAt}): _mediaUrls = mediaUrls,_rawAttachment = rawAttachment,super._();
  factory _SocialThreadItem.fromJson(Map<String, dynamic> json) => _$SocialThreadItemFromJson(json);

@override final  String id;
@override@JsonKey(name: 'author_id') final  String authorId;
@override@JsonKey(name: 'author_username') final  String authorUsername;
@override@JsonKey(name: 'author_display_name') final  String authorDisplayName;
@override@JsonKey(name: 'author_avatar_url') final  String? authorAvatarUrl;
@override@JsonKey(name: 'author_tier') final  String authorTier;
@override@JsonKey(name: 'author_barista_level') final  int authorBaristaLevel;
@override@JsonKey(name: 'author_barista_rank_title') final  String authorBaristaRankTitle;
@override@JsonKey() final  String kind;
@override@JsonKey(name: 'parent_thread_id') final  String? parentThreadId;
@override@JsonKey(name: 'root_thread_id') final  String? rootThreadId;
@override@JsonKey(name: 'quoted_thread_id') final  String? quotedThreadId;
@override@JsonKey(name: 'quoted_preview') final  QuotedThreadPreview? quotedPreview;
@override@JsonKey(name: 'depth_level') final  int depthLevel;
@override@JsonKey(name: 'body_text') final  String bodyText;
@override@JsonKey(name: 'has_media') final  bool hasMedia;
 final  List<MediaAttachmentItem> _mediaUrls;
@override@JsonKey(name: 'media_urls') List<MediaAttachmentItem> get mediaUrls {
  if (_mediaUrls is EqualUnmodifiableListView) return _mediaUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaUrls);
}

 final  Map<String, dynamic>? _rawAttachment;
@override@JsonKey(name: 'attachment') Map<String, dynamic>? get rawAttachment {
  final value = _rawAttachment;
  if (value == null) return null;
  if (_rawAttachment is EqualUnmodifiableMapView) return _rawAttachment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'likes_count') final  int likesCount;
@override@JsonKey(name: 'replies_count') final  int repliesCount;
@override@JsonKey(name: 'reposts_count') final  int repostsCount;
@override@JsonKey(name: 'try_recipe_count') final  int tryRecipeCount;
@override@JsonKey(name: 'is_pinned_on_profile') final  bool isPinnedOnProfile;
@override@JsonKey(name: 'is_liked_by_me') final  bool isLikedByMe;
@override@JsonKey(name: 'is_reposted_by_me') final  bool isRepostedByMe;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of SocialThreadItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocialThreadItemCopyWith<_SocialThreadItem> get copyWith => __$SocialThreadItemCopyWithImpl<_SocialThreadItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocialThreadItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocialThreadItem&&(identical(other.id, id) || other.id == id)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorUsername, authorUsername) || other.authorUsername == authorUsername)&&(identical(other.authorDisplayName, authorDisplayName) || other.authorDisplayName == authorDisplayName)&&(identical(other.authorAvatarUrl, authorAvatarUrl) || other.authorAvatarUrl == authorAvatarUrl)&&(identical(other.authorTier, authorTier) || other.authorTier == authorTier)&&(identical(other.authorBaristaLevel, authorBaristaLevel) || other.authorBaristaLevel == authorBaristaLevel)&&(identical(other.authorBaristaRankTitle, authorBaristaRankTitle) || other.authorBaristaRankTitle == authorBaristaRankTitle)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.parentThreadId, parentThreadId) || other.parentThreadId == parentThreadId)&&(identical(other.rootThreadId, rootThreadId) || other.rootThreadId == rootThreadId)&&(identical(other.quotedThreadId, quotedThreadId) || other.quotedThreadId == quotedThreadId)&&(identical(other.quotedPreview, quotedPreview) || other.quotedPreview == quotedPreview)&&(identical(other.depthLevel, depthLevel) || other.depthLevel == depthLevel)&&(identical(other.bodyText, bodyText) || other.bodyText == bodyText)&&(identical(other.hasMedia, hasMedia) || other.hasMedia == hasMedia)&&const DeepCollectionEquality().equals(other._mediaUrls, _mediaUrls)&&const DeepCollectionEquality().equals(other._rawAttachment, _rawAttachment)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.repliesCount, repliesCount) || other.repliesCount == repliesCount)&&(identical(other.repostsCount, repostsCount) || other.repostsCount == repostsCount)&&(identical(other.tryRecipeCount, tryRecipeCount) || other.tryRecipeCount == tryRecipeCount)&&(identical(other.isPinnedOnProfile, isPinnedOnProfile) || other.isPinnedOnProfile == isPinnedOnProfile)&&(identical(other.isLikedByMe, isLikedByMe) || other.isLikedByMe == isLikedByMe)&&(identical(other.isRepostedByMe, isRepostedByMe) || other.isRepostedByMe == isRepostedByMe)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,authorId,authorUsername,authorDisplayName,authorAvatarUrl,authorTier,authorBaristaLevel,authorBaristaRankTitle,kind,parentThreadId,rootThreadId,quotedThreadId,quotedPreview,depthLevel,bodyText,hasMedia,const DeepCollectionEquality().hash(_mediaUrls),const DeepCollectionEquality().hash(_rawAttachment),likesCount,repliesCount,repostsCount,tryRecipeCount,isPinnedOnProfile,isLikedByMe,isRepostedByMe,createdAt]);

@override
String toString() {
  return 'SocialThreadItem(id: $id, authorId: $authorId, authorUsername: $authorUsername, authorDisplayName: $authorDisplayName, authorAvatarUrl: $authorAvatarUrl, authorTier: $authorTier, authorBaristaLevel: $authorBaristaLevel, authorBaristaRankTitle: $authorBaristaRankTitle, kind: $kind, parentThreadId: $parentThreadId, rootThreadId: $rootThreadId, quotedThreadId: $quotedThreadId, quotedPreview: $quotedPreview, depthLevel: $depthLevel, bodyText: $bodyText, hasMedia: $hasMedia, mediaUrls: $mediaUrls, rawAttachment: $rawAttachment, likesCount: $likesCount, repliesCount: $repliesCount, repostsCount: $repostsCount, tryRecipeCount: $tryRecipeCount, isPinnedOnProfile: $isPinnedOnProfile, isLikedByMe: $isLikedByMe, isRepostedByMe: $isRepostedByMe, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SocialThreadItemCopyWith<$Res> implements $SocialThreadItemCopyWith<$Res> {
  factory _$SocialThreadItemCopyWith(_SocialThreadItem value, $Res Function(_SocialThreadItem) _then) = __$SocialThreadItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'author_id') String authorId,@JsonKey(name: 'author_username') String authorUsername,@JsonKey(name: 'author_display_name') String authorDisplayName,@JsonKey(name: 'author_avatar_url') String? authorAvatarUrl,@JsonKey(name: 'author_tier') String authorTier,@JsonKey(name: 'author_barista_level') int authorBaristaLevel,@JsonKey(name: 'author_barista_rank_title') String authorBaristaRankTitle, String kind,@JsonKey(name: 'parent_thread_id') String? parentThreadId,@JsonKey(name: 'root_thread_id') String? rootThreadId,@JsonKey(name: 'quoted_thread_id') String? quotedThreadId,@JsonKey(name: 'quoted_preview') QuotedThreadPreview? quotedPreview,@JsonKey(name: 'depth_level') int depthLevel,@JsonKey(name: 'body_text') String bodyText,@JsonKey(name: 'has_media') bool hasMedia,@JsonKey(name: 'media_urls') List<MediaAttachmentItem> mediaUrls,@JsonKey(name: 'attachment') Map<String, dynamic>? rawAttachment,@JsonKey(name: 'likes_count') int likesCount,@JsonKey(name: 'replies_count') int repliesCount,@JsonKey(name: 'reposts_count') int repostsCount,@JsonKey(name: 'try_recipe_count') int tryRecipeCount,@JsonKey(name: 'is_pinned_on_profile') bool isPinnedOnProfile,@JsonKey(name: 'is_liked_by_me') bool isLikedByMe,@JsonKey(name: 'is_reposted_by_me') bool isRepostedByMe,@JsonKey(name: 'created_at') DateTime createdAt
});


@override $QuotedThreadPreviewCopyWith<$Res>? get quotedPreview;

}
/// @nodoc
class __$SocialThreadItemCopyWithImpl<$Res>
    implements _$SocialThreadItemCopyWith<$Res> {
  __$SocialThreadItemCopyWithImpl(this._self, this._then);

  final _SocialThreadItem _self;
  final $Res Function(_SocialThreadItem) _then;

/// Create a copy of SocialThreadItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? authorId = null,Object? authorUsername = null,Object? authorDisplayName = null,Object? authorAvatarUrl = freezed,Object? authorTier = null,Object? authorBaristaLevel = null,Object? authorBaristaRankTitle = null,Object? kind = null,Object? parentThreadId = freezed,Object? rootThreadId = freezed,Object? quotedThreadId = freezed,Object? quotedPreview = freezed,Object? depthLevel = null,Object? bodyText = null,Object? hasMedia = null,Object? mediaUrls = null,Object? rawAttachment = freezed,Object? likesCount = null,Object? repliesCount = null,Object? repostsCount = null,Object? tryRecipeCount = null,Object? isPinnedOnProfile = null,Object? isLikedByMe = null,Object? isRepostedByMe = null,Object? createdAt = null,}) {
  return _then(_SocialThreadItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,authorUsername: null == authorUsername ? _self.authorUsername : authorUsername // ignore: cast_nullable_to_non_nullable
as String,authorDisplayName: null == authorDisplayName ? _self.authorDisplayName : authorDisplayName // ignore: cast_nullable_to_non_nullable
as String,authorAvatarUrl: freezed == authorAvatarUrl ? _self.authorAvatarUrl : authorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,authorTier: null == authorTier ? _self.authorTier : authorTier // ignore: cast_nullable_to_non_nullable
as String,authorBaristaLevel: null == authorBaristaLevel ? _self.authorBaristaLevel : authorBaristaLevel // ignore: cast_nullable_to_non_nullable
as int,authorBaristaRankTitle: null == authorBaristaRankTitle ? _self.authorBaristaRankTitle : authorBaristaRankTitle // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,parentThreadId: freezed == parentThreadId ? _self.parentThreadId : parentThreadId // ignore: cast_nullable_to_non_nullable
as String?,rootThreadId: freezed == rootThreadId ? _self.rootThreadId : rootThreadId // ignore: cast_nullable_to_non_nullable
as String?,quotedThreadId: freezed == quotedThreadId ? _self.quotedThreadId : quotedThreadId // ignore: cast_nullable_to_non_nullable
as String?,quotedPreview: freezed == quotedPreview ? _self.quotedPreview : quotedPreview // ignore: cast_nullable_to_non_nullable
as QuotedThreadPreview?,depthLevel: null == depthLevel ? _self.depthLevel : depthLevel // ignore: cast_nullable_to_non_nullable
as int,bodyText: null == bodyText ? _self.bodyText : bodyText // ignore: cast_nullable_to_non_nullable
as String,hasMedia: null == hasMedia ? _self.hasMedia : hasMedia // ignore: cast_nullable_to_non_nullable
as bool,mediaUrls: null == mediaUrls ? _self._mediaUrls : mediaUrls // ignore: cast_nullable_to_non_nullable
as List<MediaAttachmentItem>,rawAttachment: freezed == rawAttachment ? _self._rawAttachment : rawAttachment // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,repliesCount: null == repliesCount ? _self.repliesCount : repliesCount // ignore: cast_nullable_to_non_nullable
as int,repostsCount: null == repostsCount ? _self.repostsCount : repostsCount // ignore: cast_nullable_to_non_nullable
as int,tryRecipeCount: null == tryRecipeCount ? _self.tryRecipeCount : tryRecipeCount // ignore: cast_nullable_to_non_nullable
as int,isPinnedOnProfile: null == isPinnedOnProfile ? _self.isPinnedOnProfile : isPinnedOnProfile // ignore: cast_nullable_to_non_nullable
as bool,isLikedByMe: null == isLikedByMe ? _self.isLikedByMe : isLikedByMe // ignore: cast_nullable_to_non_nullable
as bool,isRepostedByMe: null == isRepostedByMe ? _self.isRepostedByMe : isRepostedByMe // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of SocialThreadItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuotedThreadPreviewCopyWith<$Res>? get quotedPreview {
    if (_self.quotedPreview == null) {
    return null;
  }

  return $QuotedThreadPreviewCopyWith<$Res>(_self.quotedPreview!, (value) {
    return _then(_self.copyWith(quotedPreview: value));
  });
}
}


/// @nodoc
mixin _$ThreadReplyNode {

 SocialThreadItem get thread; List<ThreadReplyNode> get children;
/// Create a copy of ThreadReplyNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThreadReplyNodeCopyWith<ThreadReplyNode> get copyWith => _$ThreadReplyNodeCopyWithImpl<ThreadReplyNode>(this as ThreadReplyNode, _$identity);

  /// Serializes this ThreadReplyNode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThreadReplyNode&&(identical(other.thread, thread) || other.thread == thread)&&const DeepCollectionEquality().equals(other.children, children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,thread,const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'ThreadReplyNode(thread: $thread, children: $children)';
}


}

/// @nodoc
abstract mixin class $ThreadReplyNodeCopyWith<$Res>  {
  factory $ThreadReplyNodeCopyWith(ThreadReplyNode value, $Res Function(ThreadReplyNode) _then) = _$ThreadReplyNodeCopyWithImpl;
@useResult
$Res call({
 SocialThreadItem thread, List<ThreadReplyNode> children
});


$SocialThreadItemCopyWith<$Res> get thread;

}
/// @nodoc
class _$ThreadReplyNodeCopyWithImpl<$Res>
    implements $ThreadReplyNodeCopyWith<$Res> {
  _$ThreadReplyNodeCopyWithImpl(this._self, this._then);

  final ThreadReplyNode _self;
  final $Res Function(ThreadReplyNode) _then;

/// Create a copy of ThreadReplyNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? thread = null,Object? children = null,}) {
  return _then(ThreadReplyNode(
thread: null == thread ? _self.thread : thread // ignore: cast_nullable_to_non_nullable
as SocialThreadItem,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<ThreadReplyNode>,
  ));
}
/// Create a copy of ThreadReplyNode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialThreadItemCopyWith<$Res> get thread {
  
  return $SocialThreadItemCopyWith<$Res>(_self.thread, (value) {
    return _then(_self.copyWith(thread: value));
  });
}
}


/// Adds pattern-matching-related methods to [ThreadReplyNode].
extension ThreadReplyNodePatterns on ThreadReplyNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThreadReplyNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThreadReplyNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThreadReplyNode value)  $default,){
final _that = this;
switch (_that) {
case _ThreadReplyNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThreadReplyNode value)?  $default,){
final _that = this;
switch (_that) {
case _ThreadReplyNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SocialThreadItem thread,  List<ThreadReplyNode> children)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThreadReplyNode() when $default != null:
return $default(_that.thread,_that.children);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SocialThreadItem thread,  List<ThreadReplyNode> children)  $default,) {final _that = this;
switch (_that) {
case _ThreadReplyNode():
return $default(_that.thread,_that.children);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SocialThreadItem thread,  List<ThreadReplyNode> children)?  $default,) {final _that = this;
switch (_that) {
case _ThreadReplyNode() when $default != null:
return $default(_that.thread,_that.children);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThreadReplyNode implements ThreadReplyNode {
  const _ThreadReplyNode({required this.thread,  List<ThreadReplyNode> children = const []}): _children = children;
  factory _ThreadReplyNode.fromJson(Map<String, dynamic> json) => _$ThreadReplyNodeFromJson(json);

@override final  SocialThreadItem thread;
 final  List<ThreadReplyNode> _children;
@override@JsonKey() List<ThreadReplyNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of ThreadReplyNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThreadReplyNodeCopyWith<_ThreadReplyNode> get copyWith => __$ThreadReplyNodeCopyWithImpl<_ThreadReplyNode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThreadReplyNodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThreadReplyNode&&(identical(other.thread, thread) || other.thread == thread)&&const DeepCollectionEquality().equals(other._children, _children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,thread,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'ThreadReplyNode(thread: $thread, children: $children)';
}


}

/// @nodoc
abstract mixin class _$ThreadReplyNodeCopyWith<$Res> implements $ThreadReplyNodeCopyWith<$Res> {
  factory _$ThreadReplyNodeCopyWith(_ThreadReplyNode value, $Res Function(_ThreadReplyNode) _then) = __$ThreadReplyNodeCopyWithImpl;
@override @useResult
$Res call({
 SocialThreadItem thread, List<ThreadReplyNode> children
});


@override $SocialThreadItemCopyWith<$Res> get thread;

}
/// @nodoc
class __$ThreadReplyNodeCopyWithImpl<$Res>
    implements _$ThreadReplyNodeCopyWith<$Res> {
  __$ThreadReplyNodeCopyWithImpl(this._self, this._then);

  final _ThreadReplyNode _self;
  final $Res Function(_ThreadReplyNode) _then;

/// Create a copy of ThreadReplyNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? thread = null,Object? children = null,}) {
  return _then(_ThreadReplyNode(
thread: null == thread ? _self.thread : thread // ignore: cast_nullable_to_non_nullable
as SocialThreadItem,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<ThreadReplyNode>,
  ));
}

/// Create a copy of ThreadReplyNode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialThreadItemCopyWith<$Res> get thread {
  
  return $SocialThreadItemCopyWith<$Res>(_self.thread, (value) {
    return _then(_self.copyWith(thread: value));
  });
}
}


/// @nodoc
mixin _$ThreadDetailResponse {

 SocialThreadItem get root; List<ThreadReplyNode> get replies;
/// Create a copy of ThreadDetailResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThreadDetailResponseCopyWith<ThreadDetailResponse> get copyWith => _$ThreadDetailResponseCopyWithImpl<ThreadDetailResponse>(this as ThreadDetailResponse, _$identity);

  /// Serializes this ThreadDetailResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThreadDetailResponse&&(identical(other.root, root) || other.root == root)&&const DeepCollectionEquality().equals(other.replies, replies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,root,const DeepCollectionEquality().hash(replies));

@override
String toString() {
  return 'ThreadDetailResponse(root: $root, replies: $replies)';
}


}

/// @nodoc
abstract mixin class $ThreadDetailResponseCopyWith<$Res>  {
  factory $ThreadDetailResponseCopyWith(ThreadDetailResponse value, $Res Function(ThreadDetailResponse) _then) = _$ThreadDetailResponseCopyWithImpl;
@useResult
$Res call({
 SocialThreadItem root, List<ThreadReplyNode> replies
});


$SocialThreadItemCopyWith<$Res> get root;

}
/// @nodoc
class _$ThreadDetailResponseCopyWithImpl<$Res>
    implements $ThreadDetailResponseCopyWith<$Res> {
  _$ThreadDetailResponseCopyWithImpl(this._self, this._then);

  final ThreadDetailResponse _self;
  final $Res Function(ThreadDetailResponse) _then;

/// Create a copy of ThreadDetailResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? root = null,Object? replies = null,}) {
  return _then(ThreadDetailResponse(
root: null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as SocialThreadItem,replies: null == replies ? _self.replies : replies // ignore: cast_nullable_to_non_nullable
as List<ThreadReplyNode>,
  ));
}
/// Create a copy of ThreadDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialThreadItemCopyWith<$Res> get root {
  
  return $SocialThreadItemCopyWith<$Res>(_self.root, (value) {
    return _then(_self.copyWith(root: value));
  });
}
}


/// Adds pattern-matching-related methods to [ThreadDetailResponse].
extension ThreadDetailResponsePatterns on ThreadDetailResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThreadDetailResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThreadDetailResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThreadDetailResponse value)  $default,){
final _that = this;
switch (_that) {
case _ThreadDetailResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThreadDetailResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ThreadDetailResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SocialThreadItem root,  List<ThreadReplyNode> replies)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThreadDetailResponse() when $default != null:
return $default(_that.root,_that.replies);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SocialThreadItem root,  List<ThreadReplyNode> replies)  $default,) {final _that = this;
switch (_that) {
case _ThreadDetailResponse():
return $default(_that.root,_that.replies);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SocialThreadItem root,  List<ThreadReplyNode> replies)?  $default,) {final _that = this;
switch (_that) {
case _ThreadDetailResponse() when $default != null:
return $default(_that.root,_that.replies);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThreadDetailResponse implements ThreadDetailResponse {
  const _ThreadDetailResponse({required this.root,  List<ThreadReplyNode> replies = const []}): _replies = replies;
  factory _ThreadDetailResponse.fromJson(Map<String, dynamic> json) => _$ThreadDetailResponseFromJson(json);

@override final  SocialThreadItem root;
 final  List<ThreadReplyNode> _replies;
@override@JsonKey() List<ThreadReplyNode> get replies {
  if (_replies is EqualUnmodifiableListView) return _replies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_replies);
}


/// Create a copy of ThreadDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThreadDetailResponseCopyWith<_ThreadDetailResponse> get copyWith => __$ThreadDetailResponseCopyWithImpl<_ThreadDetailResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThreadDetailResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThreadDetailResponse&&(identical(other.root, root) || other.root == root)&&const DeepCollectionEquality().equals(other._replies, _replies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,root,const DeepCollectionEquality().hash(_replies));

@override
String toString() {
  return 'ThreadDetailResponse(root: $root, replies: $replies)';
}


}

/// @nodoc
abstract mixin class _$ThreadDetailResponseCopyWith<$Res> implements $ThreadDetailResponseCopyWith<$Res> {
  factory _$ThreadDetailResponseCopyWith(_ThreadDetailResponse value, $Res Function(_ThreadDetailResponse) _then) = __$ThreadDetailResponseCopyWithImpl;
@override @useResult
$Res call({
 SocialThreadItem root, List<ThreadReplyNode> replies
});


@override $SocialThreadItemCopyWith<$Res> get root;

}
/// @nodoc
class __$ThreadDetailResponseCopyWithImpl<$Res>
    implements _$ThreadDetailResponseCopyWith<$Res> {
  __$ThreadDetailResponseCopyWithImpl(this._self, this._then);

  final _ThreadDetailResponse _self;
  final $Res Function(_ThreadDetailResponse) _then;

/// Create a copy of ThreadDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? root = null,Object? replies = null,}) {
  return _then(_ThreadDetailResponse(
root: null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as SocialThreadItem,replies: null == replies ? _self._replies : replies // ignore: cast_nullable_to_non_nullable
as List<ThreadReplyNode>,
  ));
}

/// Create a copy of ThreadDetailResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialThreadItemCopyWith<$Res> get root {
  
  return $SocialThreadItemCopyWith<$Res>(_self.root, (value) {
    return _then(_self.copyWith(root: value));
  });
}
}

/// @nodoc
mixin _$CursorPaginatedThreadsState {

 List<SocialThreadItem> get items; String? get nextCursor; bool get hasMore; bool get isLoadingNextPage;
/// Create a copy of CursorPaginatedThreadsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CursorPaginatedThreadsStateCopyWith<CursorPaginatedThreadsState> get copyWith => _$CursorPaginatedThreadsStateCopyWithImpl<CursorPaginatedThreadsState>(this as CursorPaginatedThreadsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CursorPaginatedThreadsState&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isLoadingNextPage, isLoadingNextPage) || other.isLoadingNextPage == isLoadingNextPage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),nextCursor,hasMore,isLoadingNextPage);

@override
String toString() {
  return 'CursorPaginatedThreadsState(items: $items, nextCursor: $nextCursor, hasMore: $hasMore, isLoadingNextPage: $isLoadingNextPage)';
}


}

/// @nodoc
abstract mixin class $CursorPaginatedThreadsStateCopyWith<$Res>  {
  factory $CursorPaginatedThreadsStateCopyWith(CursorPaginatedThreadsState value, $Res Function(CursorPaginatedThreadsState) _then) = _$CursorPaginatedThreadsStateCopyWithImpl;
@useResult
$Res call({
 List<SocialThreadItem> items, String? nextCursor, bool hasMore, bool isLoadingNextPage
});




}
/// @nodoc
class _$CursorPaginatedThreadsStateCopyWithImpl<$Res>
    implements $CursorPaginatedThreadsStateCopyWith<$Res> {
  _$CursorPaginatedThreadsStateCopyWithImpl(this._self, this._then);

  final CursorPaginatedThreadsState _self;
  final $Res Function(CursorPaginatedThreadsState) _then;

/// Create a copy of CursorPaginatedThreadsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,Object? hasMore = null,Object? isLoadingNextPage = null,}) {
  return _then(CursorPaginatedThreadsState(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SocialThreadItem>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingNextPage: null == isLoadingNextPage ? _self.isLoadingNextPage : isLoadingNextPage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CursorPaginatedThreadsState].
extension CursorPaginatedThreadsStatePatterns on CursorPaginatedThreadsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CursorPaginatedThreadsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CursorPaginatedThreadsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CursorPaginatedThreadsState value)  $default,){
final _that = this;
switch (_that) {
case _CursorPaginatedThreadsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CursorPaginatedThreadsState value)?  $default,){
final _that = this;
switch (_that) {
case _CursorPaginatedThreadsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SocialThreadItem> items,  String? nextCursor,  bool hasMore,  bool isLoadingNextPage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CursorPaginatedThreadsState() when $default != null:
return $default(_that.items,_that.nextCursor,_that.hasMore,_that.isLoadingNextPage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SocialThreadItem> items,  String? nextCursor,  bool hasMore,  bool isLoadingNextPage)  $default,) {final _that = this;
switch (_that) {
case _CursorPaginatedThreadsState():
return $default(_that.items,_that.nextCursor,_that.hasMore,_that.isLoadingNextPage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SocialThreadItem> items,  String? nextCursor,  bool hasMore,  bool isLoadingNextPage)?  $default,) {final _that = this;
switch (_that) {
case _CursorPaginatedThreadsState() when $default != null:
return $default(_that.items,_that.nextCursor,_that.hasMore,_that.isLoadingNextPage);case _:
  return null;

}
}

}

/// @nodoc


class _CursorPaginatedThreadsState implements CursorPaginatedThreadsState {
  const _CursorPaginatedThreadsState({ List<SocialThreadItem> items = const [], this.nextCursor, this.hasMore = false, this.isLoadingNextPage = false}): _items = items;
  

 final  List<SocialThreadItem> _items;
@override@JsonKey() List<SocialThreadItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? nextCursor;
@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  bool isLoadingNextPage;

/// Create a copy of CursorPaginatedThreadsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CursorPaginatedThreadsStateCopyWith<_CursorPaginatedThreadsState> get copyWith => __$CursorPaginatedThreadsStateCopyWithImpl<_CursorPaginatedThreadsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CursorPaginatedThreadsState&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isLoadingNextPage, isLoadingNextPage) || other.isLoadingNextPage == isLoadingNextPage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor,hasMore,isLoadingNextPage);

@override
String toString() {
  return 'CursorPaginatedThreadsState(items: $items, nextCursor: $nextCursor, hasMore: $hasMore, isLoadingNextPage: $isLoadingNextPage)';
}


}

/// @nodoc
abstract mixin class _$CursorPaginatedThreadsStateCopyWith<$Res> implements $CursorPaginatedThreadsStateCopyWith<$Res> {
  factory _$CursorPaginatedThreadsStateCopyWith(_CursorPaginatedThreadsState value, $Res Function(_CursorPaginatedThreadsState) _then) = __$CursorPaginatedThreadsStateCopyWithImpl;
@override @useResult
$Res call({
 List<SocialThreadItem> items, String? nextCursor, bool hasMore, bool isLoadingNextPage
});




}
/// @nodoc
class __$CursorPaginatedThreadsStateCopyWithImpl<$Res>
    implements _$CursorPaginatedThreadsStateCopyWith<$Res> {
  __$CursorPaginatedThreadsStateCopyWithImpl(this._self, this._then);

  final _CursorPaginatedThreadsState _self;
  final $Res Function(_CursorPaginatedThreadsState) _then;

/// Create a copy of CursorPaginatedThreadsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,Object? hasMore = null,Object? isLoadingNextPage = null,}) {
  return _then(_CursorPaginatedThreadsState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SocialThreadItem>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingNextPage: null == isLoadingNextPage ? _self.isLoadingNextPage : isLoadingNextPage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
