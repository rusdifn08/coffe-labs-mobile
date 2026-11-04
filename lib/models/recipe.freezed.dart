// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Recipe {

 String? get id; String get title; String get beanName; String get method; int get waterTempCelsius; String get steps; String? get forkedFromId; int get coffeeWeightGrams; int get totalWaterWeightGrams; int get totalTimeSeconds; bool get isCustom;
/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeCopyWith<Recipe> get copyWith => _$RecipeCopyWithImpl<Recipe>(this as Recipe, _$identity);

  /// Serializes this Recipe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recipe&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.beanName, beanName) || other.beanName == beanName)&&(identical(other.method, method) || other.method == method)&&(identical(other.waterTempCelsius, waterTempCelsius) || other.waterTempCelsius == waterTempCelsius)&&(identical(other.steps, steps) || other.steps == steps)&&(identical(other.forkedFromId, forkedFromId) || other.forkedFromId == forkedFromId)&&(identical(other.coffeeWeightGrams, coffeeWeightGrams) || other.coffeeWeightGrams == coffeeWeightGrams)&&(identical(other.totalWaterWeightGrams, totalWaterWeightGrams) || other.totalWaterWeightGrams == totalWaterWeightGrams)&&(identical(other.totalTimeSeconds, totalTimeSeconds) || other.totalTimeSeconds == totalTimeSeconds)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,beanName,method,waterTempCelsius,steps,forkedFromId,coffeeWeightGrams,totalWaterWeightGrams,totalTimeSeconds,isCustom);

@override
String toString() {
  return 'Recipe(id: $id, title: $title, beanName: $beanName, method: $method, waterTempCelsius: $waterTempCelsius, steps: $steps, forkedFromId: $forkedFromId, coffeeWeightGrams: $coffeeWeightGrams, totalWaterWeightGrams: $totalWaterWeightGrams, totalTimeSeconds: $totalTimeSeconds, isCustom: $isCustom)';
}


}

/// @nodoc
abstract mixin class $RecipeCopyWith<$Res>  {
  factory $RecipeCopyWith(Recipe value, $Res Function(Recipe) _then) = _$RecipeCopyWithImpl;
@useResult
$Res call({
 String? id, String title, String beanName, String method, int waterTempCelsius, String steps, String? forkedFromId, int coffeeWeightGrams, int totalWaterWeightGrams, int totalTimeSeconds, bool isCustom
});




}
/// @nodoc
class _$RecipeCopyWithImpl<$Res>
    implements $RecipeCopyWith<$Res> {
  _$RecipeCopyWithImpl(this._self, this._then);

  final Recipe _self;
  final $Res Function(Recipe) _then;

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? title = null,Object? beanName = null,Object? method = null,Object? waterTempCelsius = null,Object? steps = null,Object? forkedFromId = freezed,Object? coffeeWeightGrams = null,Object? totalWaterWeightGrams = null,Object? totalTimeSeconds = null,Object? isCustom = null,}) {
  return _then(Recipe(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,beanName: null == beanName ? _self.beanName : beanName // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,waterTempCelsius: null == waterTempCelsius ? _self.waterTempCelsius : waterTempCelsius // ignore: cast_nullable_to_non_nullable
as int,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as String,forkedFromId: freezed == forkedFromId ? _self.forkedFromId : forkedFromId // ignore: cast_nullable_to_non_nullable
as String?,coffeeWeightGrams: null == coffeeWeightGrams ? _self.coffeeWeightGrams : coffeeWeightGrams // ignore: cast_nullable_to_non_nullable
as int,totalWaterWeightGrams: null == totalWaterWeightGrams ? _self.totalWaterWeightGrams : totalWaterWeightGrams // ignore: cast_nullable_to_non_nullable
as int,totalTimeSeconds: null == totalTimeSeconds ? _self.totalTimeSeconds : totalTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Recipe].
extension RecipePatterns on Recipe {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Recipe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Recipe() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Recipe value)  $default,){
final _that = this;
switch (_that) {
case _Recipe():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Recipe value)?  $default,){
final _that = this;
switch (_that) {
case _Recipe() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String title,  String beanName,  String method,  int waterTempCelsius,  String steps,  String? forkedFromId,  int coffeeWeightGrams,  int totalWaterWeightGrams,  int totalTimeSeconds,  bool isCustom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Recipe() when $default != null:
return $default(_that.id,_that.title,_that.beanName,_that.method,_that.waterTempCelsius,_that.steps,_that.forkedFromId,_that.coffeeWeightGrams,_that.totalWaterWeightGrams,_that.totalTimeSeconds,_that.isCustom);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String title,  String beanName,  String method,  int waterTempCelsius,  String steps,  String? forkedFromId,  int coffeeWeightGrams,  int totalWaterWeightGrams,  int totalTimeSeconds,  bool isCustom)  $default,) {final _that = this;
switch (_that) {
case _Recipe():
return $default(_that.id,_that.title,_that.beanName,_that.method,_that.waterTempCelsius,_that.steps,_that.forkedFromId,_that.coffeeWeightGrams,_that.totalWaterWeightGrams,_that.totalTimeSeconds,_that.isCustom);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String title,  String beanName,  String method,  int waterTempCelsius,  String steps,  String? forkedFromId,  int coffeeWeightGrams,  int totalWaterWeightGrams,  int totalTimeSeconds,  bool isCustom)?  $default,) {final _that = this;
switch (_that) {
case _Recipe() when $default != null:
return $default(_that.id,_that.title,_that.beanName,_that.method,_that.waterTempCelsius,_that.steps,_that.forkedFromId,_that.coffeeWeightGrams,_that.totalWaterWeightGrams,_that.totalTimeSeconds,_that.isCustom);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Recipe implements Recipe {
  const _Recipe({this.id, required this.title, required this.beanName, required this.method, this.waterTempCelsius = 92, this.steps = '', this.forkedFromId, this.coffeeWeightGrams = 15, this.totalWaterWeightGrams = 240, this.totalTimeSeconds = 180, this.isCustom = false});
  factory _Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

@override final  String? id;
@override final  String title;
@override final  String beanName;
@override final  String method;
@override@JsonKey() final  int waterTempCelsius;
@override@JsonKey() final  String steps;
@override final  String? forkedFromId;
@override@JsonKey() final  int coffeeWeightGrams;
@override@JsonKey() final  int totalWaterWeightGrams;
@override@JsonKey() final  int totalTimeSeconds;
@override@JsonKey() final  bool isCustom;

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeCopyWith<_Recipe> get copyWith => __$RecipeCopyWithImpl<_Recipe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recipe&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.beanName, beanName) || other.beanName == beanName)&&(identical(other.method, method) || other.method == method)&&(identical(other.waterTempCelsius, waterTempCelsius) || other.waterTempCelsius == waterTempCelsius)&&(identical(other.steps, steps) || other.steps == steps)&&(identical(other.forkedFromId, forkedFromId) || other.forkedFromId == forkedFromId)&&(identical(other.coffeeWeightGrams, coffeeWeightGrams) || other.coffeeWeightGrams == coffeeWeightGrams)&&(identical(other.totalWaterWeightGrams, totalWaterWeightGrams) || other.totalWaterWeightGrams == totalWaterWeightGrams)&&(identical(other.totalTimeSeconds, totalTimeSeconds) || other.totalTimeSeconds == totalTimeSeconds)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,beanName,method,waterTempCelsius,steps,forkedFromId,coffeeWeightGrams,totalWaterWeightGrams,totalTimeSeconds,isCustom);

@override
String toString() {
  return 'Recipe(id: $id, title: $title, beanName: $beanName, method: $method, waterTempCelsius: $waterTempCelsius, steps: $steps, forkedFromId: $forkedFromId, coffeeWeightGrams: $coffeeWeightGrams, totalWaterWeightGrams: $totalWaterWeightGrams, totalTimeSeconds: $totalTimeSeconds, isCustom: $isCustom)';
}


}

/// @nodoc
abstract mixin class _$RecipeCopyWith<$Res> implements $RecipeCopyWith<$Res> {
  factory _$RecipeCopyWith(_Recipe value, $Res Function(_Recipe) _then) = __$RecipeCopyWithImpl;
@override @useResult
$Res call({
 String? id, String title, String beanName, String method, int waterTempCelsius, String steps, String? forkedFromId, int coffeeWeightGrams, int totalWaterWeightGrams, int totalTimeSeconds, bool isCustom
});




}
/// @nodoc
class __$RecipeCopyWithImpl<$Res>
    implements _$RecipeCopyWith<$Res> {
  __$RecipeCopyWithImpl(this._self, this._then);

  final _Recipe _self;
  final $Res Function(_Recipe) _then;

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? title = null,Object? beanName = null,Object? method = null,Object? waterTempCelsius = null,Object? steps = null,Object? forkedFromId = freezed,Object? coffeeWeightGrams = null,Object? totalWaterWeightGrams = null,Object? totalTimeSeconds = null,Object? isCustom = null,}) {
  return _then(_Recipe(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,beanName: null == beanName ? _self.beanName : beanName // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,waterTempCelsius: null == waterTempCelsius ? _self.waterTempCelsius : waterTempCelsius // ignore: cast_nullable_to_non_nullable
as int,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as String,forkedFromId: freezed == forkedFromId ? _self.forkedFromId : forkedFromId // ignore: cast_nullable_to_non_nullable
as String?,coffeeWeightGrams: null == coffeeWeightGrams ? _self.coffeeWeightGrams : coffeeWeightGrams // ignore: cast_nullable_to_non_nullable
as int,totalWaterWeightGrams: null == totalWaterWeightGrams ? _self.totalWaterWeightGrams : totalWaterWeightGrams // ignore: cast_nullable_to_non_nullable
as int,totalTimeSeconds: null == totalTimeSeconds ? _self.totalTimeSeconds : totalTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
