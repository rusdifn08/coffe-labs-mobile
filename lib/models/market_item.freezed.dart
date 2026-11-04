// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'market_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MarketItem {

 String? get id; String get title; String get description; double get price; String get itemType; String get condition;
/// Create a copy of MarketItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketItemCopyWith<MarketItem> get copyWith => _$MarketItemCopyWithImpl<MarketItem>(this as MarketItem, _$identity);

  /// Serializes this MarketItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.condition, condition) || other.condition == condition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,price,itemType,condition);

@override
String toString() {
  return 'MarketItem(id: $id, title: $title, description: $description, price: $price, itemType: $itemType, condition: $condition)';
}


}

/// @nodoc
abstract mixin class $MarketItemCopyWith<$Res>  {
  factory $MarketItemCopyWith(MarketItem value, $Res Function(MarketItem) _then) = _$MarketItemCopyWithImpl;
@useResult
$Res call({
 String? id, String title, String description, double price, String itemType, String condition
});




}
/// @nodoc
class _$MarketItemCopyWithImpl<$Res>
    implements $MarketItemCopyWith<$Res> {
  _$MarketItemCopyWithImpl(this._self, this._then);

  final MarketItem _self;
  final $Res Function(MarketItem) _then;

/// Create a copy of MarketItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? title = null,Object? description = null,Object? price = null,Object? itemType = null,Object? condition = null,}) {
  return _then(MarketItem(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MarketItem].
extension MarketItemPatterns on MarketItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketItem value)  $default,){
final _that = this;
switch (_that) {
case _MarketItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketItem value)?  $default,){
final _that = this;
switch (_that) {
case _MarketItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String title,  String description,  double price,  String itemType,  String condition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketItem() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.price,_that.itemType,_that.condition);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String title,  String description,  double price,  String itemType,  String condition)  $default,) {final _that = this;
switch (_that) {
case _MarketItem():
return $default(_that.id,_that.title,_that.description,_that.price,_that.itemType,_that.condition);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String title,  String description,  double price,  String itemType,  String condition)?  $default,) {final _that = this;
switch (_that) {
case _MarketItem() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.price,_that.itemType,_that.condition);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MarketItem implements MarketItem {
  const _MarketItem({this.id, required this.title, required this.description, required this.price, required this.itemType, required this.condition});
  factory _MarketItem.fromJson(Map<String, dynamic> json) => _$MarketItemFromJson(json);

@override final  String? id;
@override final  String title;
@override final  String description;
@override final  double price;
@override final  String itemType;
@override final  String condition;

/// Create a copy of MarketItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketItemCopyWith<_MarketItem> get copyWith => __$MarketItemCopyWithImpl<_MarketItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarketItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.condition, condition) || other.condition == condition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,price,itemType,condition);

@override
String toString() {
  return 'MarketItem(id: $id, title: $title, description: $description, price: $price, itemType: $itemType, condition: $condition)';
}


}

/// @nodoc
abstract mixin class _$MarketItemCopyWith<$Res> implements $MarketItemCopyWith<$Res> {
  factory _$MarketItemCopyWith(_MarketItem value, $Res Function(_MarketItem) _then) = __$MarketItemCopyWithImpl;
@override @useResult
$Res call({
 String? id, String title, String description, double price, String itemType, String condition
});




}
/// @nodoc
class __$MarketItemCopyWithImpl<$Res>
    implements _$MarketItemCopyWith<$Res> {
  __$MarketItemCopyWithImpl(this._self, this._then);

  final _MarketItem _self;
  final $Res Function(_MarketItem) _then;

/// Create a copy of MarketItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? title = null,Object? description = null,Object? price = null,Object? itemType = null,Object? condition = null,}) {
  return _then(_MarketItem(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
