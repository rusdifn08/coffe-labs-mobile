// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_user_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminUserStats {

@JsonKey(name: 'total_users') int get totalUsers;@JsonKey(name: 'new_registrations_7d') int get newRegistrations7d;@JsonKey(name: 'active_users') int get activeUsers;@JsonKey(name: 'pending_or_declined') int get pendingOrDeclined;
/// Create a copy of AdminUserStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminUserStatsCopyWith<AdminUserStats> get copyWith => _$AdminUserStatsCopyWithImpl<AdminUserStats>(this as AdminUserStats, _$identity);

  /// Serializes this AdminUserStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminUserStats&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.newRegistrations7d, newRegistrations7d) || other.newRegistrations7d == newRegistrations7d)&&(identical(other.activeUsers, activeUsers) || other.activeUsers == activeUsers)&&(identical(other.pendingOrDeclined, pendingOrDeclined) || other.pendingOrDeclined == pendingOrDeclined));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUsers,newRegistrations7d,activeUsers,pendingOrDeclined);

@override
String toString() {
  return 'AdminUserStats(totalUsers: $totalUsers, newRegistrations7d: $newRegistrations7d, activeUsers: $activeUsers, pendingOrDeclined: $pendingOrDeclined)';
}


}

/// @nodoc
abstract mixin class $AdminUserStatsCopyWith<$Res>  {
  factory $AdminUserStatsCopyWith(AdminUserStats value, $Res Function(AdminUserStats) _then) = _$AdminUserStatsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'total_users') int totalUsers,@JsonKey(name: 'new_registrations_7d') int newRegistrations7d,@JsonKey(name: 'active_users') int activeUsers,@JsonKey(name: 'pending_or_declined') int pendingOrDeclined
});




}
/// @nodoc
class _$AdminUserStatsCopyWithImpl<$Res>
    implements $AdminUserStatsCopyWith<$Res> {
  _$AdminUserStatsCopyWithImpl(this._self, this._then);

  final AdminUserStats _self;
  final $Res Function(AdminUserStats) _then;

/// Create a copy of AdminUserStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalUsers = null,Object? newRegistrations7d = null,Object? activeUsers = null,Object? pendingOrDeclined = null,}) {
  return _then(AdminUserStats(
totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,newRegistrations7d: null == newRegistrations7d ? _self.newRegistrations7d : newRegistrations7d // ignore: cast_nullable_to_non_nullable
as int,activeUsers: null == activeUsers ? _self.activeUsers : activeUsers // ignore: cast_nullable_to_non_nullable
as int,pendingOrDeclined: null == pendingOrDeclined ? _self.pendingOrDeclined : pendingOrDeclined // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminUserStats].
extension AdminUserStatsPatterns on AdminUserStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminUserStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminUserStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminUserStats value)  $default,){
final _that = this;
switch (_that) {
case _AdminUserStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminUserStats value)?  $default,){
final _that = this;
switch (_that) {
case _AdminUserStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_users')  int totalUsers, @JsonKey(name: 'new_registrations_7d')  int newRegistrations7d, @JsonKey(name: 'active_users')  int activeUsers, @JsonKey(name: 'pending_or_declined')  int pendingOrDeclined)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminUserStats() when $default != null:
return $default(_that.totalUsers,_that.newRegistrations7d,_that.activeUsers,_that.pendingOrDeclined);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_users')  int totalUsers, @JsonKey(name: 'new_registrations_7d')  int newRegistrations7d, @JsonKey(name: 'active_users')  int activeUsers, @JsonKey(name: 'pending_or_declined')  int pendingOrDeclined)  $default,) {final _that = this;
switch (_that) {
case _AdminUserStats():
return $default(_that.totalUsers,_that.newRegistrations7d,_that.activeUsers,_that.pendingOrDeclined);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'total_users')  int totalUsers, @JsonKey(name: 'new_registrations_7d')  int newRegistrations7d, @JsonKey(name: 'active_users')  int activeUsers, @JsonKey(name: 'pending_or_declined')  int pendingOrDeclined)?  $default,) {final _that = this;
switch (_that) {
case _AdminUserStats() when $default != null:
return $default(_that.totalUsers,_that.newRegistrations7d,_that.activeUsers,_that.pendingOrDeclined);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminUserStats implements AdminUserStats {
  const _AdminUserStats({@JsonKey(name: 'total_users') this.totalUsers = 0, @JsonKey(name: 'new_registrations_7d') this.newRegistrations7d = 0, @JsonKey(name: 'active_users') this.activeUsers = 0, @JsonKey(name: 'pending_or_declined') this.pendingOrDeclined = 0});
  factory _AdminUserStats.fromJson(Map<String, dynamic> json) => _$AdminUserStatsFromJson(json);

@override@JsonKey(name: 'total_users') final  int totalUsers;
@override@JsonKey(name: 'new_registrations_7d') final  int newRegistrations7d;
@override@JsonKey(name: 'active_users') final  int activeUsers;
@override@JsonKey(name: 'pending_or_declined') final  int pendingOrDeclined;

/// Create a copy of AdminUserStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminUserStatsCopyWith<_AdminUserStats> get copyWith => __$AdminUserStatsCopyWithImpl<_AdminUserStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminUserStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminUserStats&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.newRegistrations7d, newRegistrations7d) || other.newRegistrations7d == newRegistrations7d)&&(identical(other.activeUsers, activeUsers) || other.activeUsers == activeUsers)&&(identical(other.pendingOrDeclined, pendingOrDeclined) || other.pendingOrDeclined == pendingOrDeclined));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUsers,newRegistrations7d,activeUsers,pendingOrDeclined);

@override
String toString() {
  return 'AdminUserStats(totalUsers: $totalUsers, newRegistrations7d: $newRegistrations7d, activeUsers: $activeUsers, pendingOrDeclined: $pendingOrDeclined)';
}


}

/// @nodoc
abstract mixin class _$AdminUserStatsCopyWith<$Res> implements $AdminUserStatsCopyWith<$Res> {
  factory _$AdminUserStatsCopyWith(_AdminUserStats value, $Res Function(_AdminUserStats) _then) = __$AdminUserStatsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'total_users') int totalUsers,@JsonKey(name: 'new_registrations_7d') int newRegistrations7d,@JsonKey(name: 'active_users') int activeUsers,@JsonKey(name: 'pending_or_declined') int pendingOrDeclined
});




}
/// @nodoc
class __$AdminUserStatsCopyWithImpl<$Res>
    implements _$AdminUserStatsCopyWith<$Res> {
  __$AdminUserStatsCopyWithImpl(this._self, this._then);

  final _AdminUserStats _self;
  final $Res Function(_AdminUserStats) _then;

/// Create a copy of AdminUserStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalUsers = null,Object? newRegistrations7d = null,Object? activeUsers = null,Object? pendingOrDeclined = null,}) {
  return _then(_AdminUserStats(
totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,newRegistrations7d: null == newRegistrations7d ? _self.newRegistrations7d : newRegistrations7d // ignore: cast_nullable_to_non_nullable
as int,activeUsers: null == activeUsers ? _self.activeUsers : activeUsers // ignore: cast_nullable_to_non_nullable
as int,pendingOrDeclined: null == pendingOrDeclined ? _self.pendingOrDeclined : pendingOrDeclined // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
