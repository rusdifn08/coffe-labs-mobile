// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecipeFilterState {

 String get searchQuery; String get selectedCategory; String get selectedMethod; bool get favoritesOnly;
/// Create a copy of RecipeFilterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeFilterStateCopyWith<RecipeFilterState> get copyWith => _$RecipeFilterStateCopyWithImpl<RecipeFilterState>(this as RecipeFilterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipeFilterState&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.selectedCategory, selectedCategory) || other.selectedCategory == selectedCategory)&&(identical(other.selectedMethod, selectedMethod) || other.selectedMethod == selectedMethod)&&(identical(other.favoritesOnly, favoritesOnly) || other.favoritesOnly == favoritesOnly));
}


@override
int get hashCode => Object.hash(runtimeType,searchQuery,selectedCategory,selectedMethod,favoritesOnly);

@override
String toString() {
  return 'RecipeFilterState(searchQuery: $searchQuery, selectedCategory: $selectedCategory, selectedMethod: $selectedMethod, favoritesOnly: $favoritesOnly)';
}


}

/// @nodoc
abstract mixin class $RecipeFilterStateCopyWith<$Res>  {
  factory $RecipeFilterStateCopyWith(RecipeFilterState value, $Res Function(RecipeFilterState) _then) = _$RecipeFilterStateCopyWithImpl;
@useResult
$Res call({
 String searchQuery, String selectedCategory, String selectedMethod, bool favoritesOnly
});




}
/// @nodoc
class _$RecipeFilterStateCopyWithImpl<$Res>
    implements $RecipeFilterStateCopyWith<$Res> {
  _$RecipeFilterStateCopyWithImpl(this._self, this._then);

  final RecipeFilterState _self;
  final $Res Function(RecipeFilterState) _then;

/// Create a copy of RecipeFilterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchQuery = null,Object? selectedCategory = null,Object? selectedMethod = null,Object? favoritesOnly = null,}) {
  return _then(RecipeFilterState(
searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,selectedCategory: null == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as String,selectedMethod: null == selectedMethod ? _self.selectedMethod : selectedMethod // ignore: cast_nullable_to_non_nullable
as String,favoritesOnly: null == favoritesOnly ? _self.favoritesOnly : favoritesOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RecipeFilterState].
extension RecipeFilterStatePatterns on RecipeFilterState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecipeFilterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecipeFilterState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecipeFilterState value)  $default,){
final _that = this;
switch (_that) {
case _RecipeFilterState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecipeFilterState value)?  $default,){
final _that = this;
switch (_that) {
case _RecipeFilterState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String searchQuery,  String selectedCategory,  String selectedMethod,  bool favoritesOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecipeFilterState() when $default != null:
return $default(_that.searchQuery,_that.selectedCategory,_that.selectedMethod,_that.favoritesOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String searchQuery,  String selectedCategory,  String selectedMethod,  bool favoritesOnly)  $default,) {final _that = this;
switch (_that) {
case _RecipeFilterState():
return $default(_that.searchQuery,_that.selectedCategory,_that.selectedMethod,_that.favoritesOnly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String searchQuery,  String selectedCategory,  String selectedMethod,  bool favoritesOnly)?  $default,) {final _that = this;
switch (_that) {
case _RecipeFilterState() when $default != null:
return $default(_that.searchQuery,_that.selectedCategory,_that.selectedMethod,_that.favoritesOnly);case _:
  return null;

}
}

}

/// @nodoc


class _RecipeFilterState implements RecipeFilterState {
  const _RecipeFilterState({this.searchQuery = '', this.selectedCategory = 'Semua', this.selectedMethod = 'Semua', this.favoritesOnly = false});
  

@override@JsonKey() final  String searchQuery;
@override@JsonKey() final  String selectedCategory;
@override@JsonKey() final  String selectedMethod;
@override@JsonKey() final  bool favoritesOnly;

/// Create a copy of RecipeFilterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeFilterStateCopyWith<_RecipeFilterState> get copyWith => __$RecipeFilterStateCopyWithImpl<_RecipeFilterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipeFilterState&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.selectedCategory, selectedCategory) || other.selectedCategory == selectedCategory)&&(identical(other.selectedMethod, selectedMethod) || other.selectedMethod == selectedMethod)&&(identical(other.favoritesOnly, favoritesOnly) || other.favoritesOnly == favoritesOnly));
}


@override
int get hashCode => Object.hash(runtimeType,searchQuery,selectedCategory,selectedMethod,favoritesOnly);

@override
String toString() {
  return 'RecipeFilterState(searchQuery: $searchQuery, selectedCategory: $selectedCategory, selectedMethod: $selectedMethod, favoritesOnly: $favoritesOnly)';
}


}

/// @nodoc
abstract mixin class _$RecipeFilterStateCopyWith<$Res> implements $RecipeFilterStateCopyWith<$Res> {
  factory _$RecipeFilterStateCopyWith(_RecipeFilterState value, $Res Function(_RecipeFilterState) _then) = __$RecipeFilterStateCopyWithImpl;
@override @useResult
$Res call({
 String searchQuery, String selectedCategory, String selectedMethod, bool favoritesOnly
});




}
/// @nodoc
class __$RecipeFilterStateCopyWithImpl<$Res>
    implements _$RecipeFilterStateCopyWith<$Res> {
  __$RecipeFilterStateCopyWithImpl(this._self, this._then);

  final _RecipeFilterState _self;
  final $Res Function(_RecipeFilterState) _then;

/// Create a copy of RecipeFilterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchQuery = null,Object? selectedCategory = null,Object? selectedMethod = null,Object? favoritesOnly = null,}) {
  return _then(_RecipeFilterState(
searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,selectedCategory: null == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as String,selectedMethod: null == selectedMethod ? _self.selectedMethod : selectedMethod // ignore: cast_nullable_to_non_nullable
as String,favoritesOnly: null == favoritesOnly ? _self.favoritesOnly : favoritesOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
