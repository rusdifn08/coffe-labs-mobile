// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'basecamp.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Basecamp {

 String? get id; String get name; String get description; bool get isPrivate;
/// Create a copy of Basecamp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BasecampCopyWith<Basecamp> get copyWith => _$BasecampCopyWithImpl<Basecamp>(this as Basecamp, _$identity);

  /// Serializes this Basecamp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Basecamp&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,isPrivate);

@override
String toString() {
  return 'Basecamp(id: $id, name: $name, description: $description, isPrivate: $isPrivate)';
}


}

/// @nodoc
abstract mixin class $BasecampCopyWith<$Res>  {
  factory $BasecampCopyWith(Basecamp value, $Res Function(Basecamp) _then) = _$BasecampCopyWithImpl;
@useResult
$Res call({
 String? id, String name, String description, bool isPrivate
});




}
/// @nodoc
class _$BasecampCopyWithImpl<$Res>
    implements $BasecampCopyWith<$Res> {
  _$BasecampCopyWithImpl(this._self, this._then);

  final Basecamp _self;
  final $Res Function(Basecamp) _then;

/// Create a copy of Basecamp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? description = null,Object? isPrivate = null,}) {
  return _then(Basecamp(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Basecamp].
extension BasecampPatterns on Basecamp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Basecamp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Basecamp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Basecamp value)  $default,){
final _that = this;
switch (_that) {
case _Basecamp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Basecamp value)?  $default,){
final _that = this;
switch (_that) {
case _Basecamp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String name,  String description,  bool isPrivate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Basecamp() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.isPrivate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String name,  String description,  bool isPrivate)  $default,) {final _that = this;
switch (_that) {
case _Basecamp():
return $default(_that.id,_that.name,_that.description,_that.isPrivate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String name,  String description,  bool isPrivate)?  $default,) {final _that = this;
switch (_that) {
case _Basecamp() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.isPrivate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Basecamp implements Basecamp {
  const _Basecamp({this.id, required this.name, required this.description, this.isPrivate = false});
  factory _Basecamp.fromJson(Map<String, dynamic> json) => _$BasecampFromJson(json);

@override final  String? id;
@override final  String name;
@override final  String description;
@override@JsonKey() final  bool isPrivate;

/// Create a copy of Basecamp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BasecampCopyWith<_Basecamp> get copyWith => __$BasecampCopyWithImpl<_Basecamp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BasecampToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Basecamp&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,isPrivate);

@override
String toString() {
  return 'Basecamp(id: $id, name: $name, description: $description, isPrivate: $isPrivate)';
}


}

/// @nodoc
abstract mixin class _$BasecampCopyWith<$Res> implements $BasecampCopyWith<$Res> {
  factory _$BasecampCopyWith(_Basecamp value, $Res Function(_Basecamp) _then) = __$BasecampCopyWithImpl;
@override @useResult
$Res call({
 String? id, String name, String description, bool isPrivate
});




}
/// @nodoc
class __$BasecampCopyWithImpl<$Res>
    implements _$BasecampCopyWith<$Res> {
  __$BasecampCopyWithImpl(this._self, this._then);

  final _Basecamp _self;
  final $Res Function(_Basecamp) _then;

/// Create a copy of Basecamp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? description = null,Object? isPrivate = null,}) {
  return _then(_Basecamp(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
