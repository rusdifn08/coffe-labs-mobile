// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'smart_scale_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SmartScaleState {

 bool get isConnected; bool get isScanning; double get currentWeight; double get flowRate; SmartScaleDevice? get activeDevice; List<SmartScaleDevice> get discoveredDevices;
/// Create a copy of SmartScaleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SmartScaleStateCopyWith<SmartScaleState> get copyWith => _$SmartScaleStateCopyWithImpl<SmartScaleState>(this as SmartScaleState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SmartScaleState&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&(identical(other.isScanning, isScanning) || other.isScanning == isScanning)&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.flowRate, flowRate) || other.flowRate == flowRate)&&(identical(other.activeDevice, activeDevice) || other.activeDevice == activeDevice)&&const DeepCollectionEquality().equals(other.discoveredDevices, discoveredDevices));
}


@override
int get hashCode => Object.hash(runtimeType,isConnected,isScanning,currentWeight,flowRate,activeDevice,const DeepCollectionEquality().hash(discoveredDevices));

@override
String toString() {
  return 'SmartScaleState(isConnected: $isConnected, isScanning: $isScanning, currentWeight: $currentWeight, flowRate: $flowRate, activeDevice: $activeDevice, discoveredDevices: $discoveredDevices)';
}


}

/// @nodoc
abstract mixin class $SmartScaleStateCopyWith<$Res>  {
  factory $SmartScaleStateCopyWith(SmartScaleState value, $Res Function(SmartScaleState) _then) = _$SmartScaleStateCopyWithImpl;
@useResult
$Res call({
 bool isConnected, bool isScanning, double currentWeight, double flowRate, SmartScaleDevice? activeDevice, List<SmartScaleDevice> discoveredDevices
});




}
/// @nodoc
class _$SmartScaleStateCopyWithImpl<$Res>
    implements $SmartScaleStateCopyWith<$Res> {
  _$SmartScaleStateCopyWithImpl(this._self, this._then);

  final SmartScaleState _self;
  final $Res Function(SmartScaleState) _then;

/// Create a copy of SmartScaleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isConnected = null,Object? isScanning = null,Object? currentWeight = null,Object? flowRate = null,Object? activeDevice = freezed,Object? discoveredDevices = null,}) {
  return _then(SmartScaleState(
isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,isScanning: null == isScanning ? _self.isScanning : isScanning // ignore: cast_nullable_to_non_nullable
as bool,currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,flowRate: null == flowRate ? _self.flowRate : flowRate // ignore: cast_nullable_to_non_nullable
as double,activeDevice: freezed == activeDevice ? _self.activeDevice : activeDevice // ignore: cast_nullable_to_non_nullable
as SmartScaleDevice?,discoveredDevices: null == discoveredDevices ? _self.discoveredDevices : discoveredDevices // ignore: cast_nullable_to_non_nullable
as List<SmartScaleDevice>,
  ));
}

}


/// Adds pattern-matching-related methods to [SmartScaleState].
extension SmartScaleStatePatterns on SmartScaleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SmartScaleState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SmartScaleState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SmartScaleState value)  $default,){
final _that = this;
switch (_that) {
case _SmartScaleState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SmartScaleState value)?  $default,){
final _that = this;
switch (_that) {
case _SmartScaleState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isConnected,  bool isScanning,  double currentWeight,  double flowRate,  SmartScaleDevice? activeDevice,  List<SmartScaleDevice> discoveredDevices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SmartScaleState() when $default != null:
return $default(_that.isConnected,_that.isScanning,_that.currentWeight,_that.flowRate,_that.activeDevice,_that.discoveredDevices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isConnected,  bool isScanning,  double currentWeight,  double flowRate,  SmartScaleDevice? activeDevice,  List<SmartScaleDevice> discoveredDevices)  $default,) {final _that = this;
switch (_that) {
case _SmartScaleState():
return $default(_that.isConnected,_that.isScanning,_that.currentWeight,_that.flowRate,_that.activeDevice,_that.discoveredDevices);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isConnected,  bool isScanning,  double currentWeight,  double flowRate,  SmartScaleDevice? activeDevice,  List<SmartScaleDevice> discoveredDevices)?  $default,) {final _that = this;
switch (_that) {
case _SmartScaleState() when $default != null:
return $default(_that.isConnected,_that.isScanning,_that.currentWeight,_that.flowRate,_that.activeDevice,_that.discoveredDevices);case _:
  return null;

}
}

}

/// @nodoc


class _SmartScaleState implements SmartScaleState {
  const _SmartScaleState({this.isConnected = false, this.isScanning = false, this.currentWeight = 0.0, this.flowRate = 0.0, this.activeDevice,  List<SmartScaleDevice> discoveredDevices = const <SmartScaleDevice>[]}): _discoveredDevices = discoveredDevices;
  

@override@JsonKey() final  bool isConnected;
@override@JsonKey() final  bool isScanning;
@override@JsonKey() final  double currentWeight;
@override@JsonKey() final  double flowRate;
@override final  SmartScaleDevice? activeDevice;
 final  List<SmartScaleDevice> _discoveredDevices;
@override@JsonKey() List<SmartScaleDevice> get discoveredDevices {
  if (_discoveredDevices is EqualUnmodifiableListView) return _discoveredDevices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_discoveredDevices);
}


/// Create a copy of SmartScaleState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SmartScaleStateCopyWith<_SmartScaleState> get copyWith => __$SmartScaleStateCopyWithImpl<_SmartScaleState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SmartScaleState&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&(identical(other.isScanning, isScanning) || other.isScanning == isScanning)&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.flowRate, flowRate) || other.flowRate == flowRate)&&(identical(other.activeDevice, activeDevice) || other.activeDevice == activeDevice)&&const DeepCollectionEquality().equals(other._discoveredDevices, _discoveredDevices));
}


@override
int get hashCode => Object.hash(runtimeType,isConnected,isScanning,currentWeight,flowRate,activeDevice,const DeepCollectionEquality().hash(_discoveredDevices));

@override
String toString() {
  return 'SmartScaleState(isConnected: $isConnected, isScanning: $isScanning, currentWeight: $currentWeight, flowRate: $flowRate, activeDevice: $activeDevice, discoveredDevices: $discoveredDevices)';
}


}

/// @nodoc
abstract mixin class _$SmartScaleStateCopyWith<$Res> implements $SmartScaleStateCopyWith<$Res> {
  factory _$SmartScaleStateCopyWith(_SmartScaleState value, $Res Function(_SmartScaleState) _then) = __$SmartScaleStateCopyWithImpl;
@override @useResult
$Res call({
 bool isConnected, bool isScanning, double currentWeight, double flowRate, SmartScaleDevice? activeDevice, List<SmartScaleDevice> discoveredDevices
});




}
/// @nodoc
class __$SmartScaleStateCopyWithImpl<$Res>
    implements _$SmartScaleStateCopyWith<$Res> {
  __$SmartScaleStateCopyWithImpl(this._self, this._then);

  final _SmartScaleState _self;
  final $Res Function(_SmartScaleState) _then;

/// Create a copy of SmartScaleState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isConnected = null,Object? isScanning = null,Object? currentWeight = null,Object? flowRate = null,Object? activeDevice = freezed,Object? discoveredDevices = null,}) {
  return _then(_SmartScaleState(
isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,isScanning: null == isScanning ? _self.isScanning : isScanning // ignore: cast_nullable_to_non_nullable
as bool,currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,flowRate: null == flowRate ? _self.flowRate : flowRate // ignore: cast_nullable_to_non_nullable
as double,activeDevice: freezed == activeDevice ? _self.activeDevice : activeDevice // ignore: cast_nullable_to_non_nullable
as SmartScaleDevice?,discoveredDevices: null == discoveredDevices ? _self._discoveredDevices : discoveredDevices // ignore: cast_nullable_to_non_nullable
as List<SmartScaleDevice>,
  ));
}


}

// dart format on
