// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthSessionState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthSessionState()';
}


}

/// @nodoc
class $AuthSessionStateCopyWith<$Res>  {
$AuthSessionStateCopyWith(AuthSessionState _, $Res Function(AuthSessionState) __);
}


/// Adds pattern-matching-related methods to [AuthSessionState].
extension AuthSessionStatePatterns on AuthSessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AuthSessionUnauthenticated value)?  unauthenticated,TResult Function( AuthSessionTrialMode value)?  trialMode,TResult Function( AuthSessionAuthenticated value)?  authenticated,TResult Function( AuthSessionPendingApproval value)?  pendingApproval,TResult Function( AuthSessionDeclined value)?  declined,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AuthSessionUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case AuthSessionTrialMode() when trialMode != null:
return trialMode(_that);case AuthSessionAuthenticated() when authenticated != null:
return authenticated(_that);case AuthSessionPendingApproval() when pendingApproval != null:
return pendingApproval(_that);case AuthSessionDeclined() when declined != null:
return declined(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AuthSessionUnauthenticated value)  unauthenticated,required TResult Function( AuthSessionTrialMode value)  trialMode,required TResult Function( AuthSessionAuthenticated value)  authenticated,required TResult Function( AuthSessionPendingApproval value)  pendingApproval,required TResult Function( AuthSessionDeclined value)  declined,}){
final _that = this;
switch (_that) {
case AuthSessionUnauthenticated():
return unauthenticated(_that);case AuthSessionTrialMode():
return trialMode(_that);case AuthSessionAuthenticated():
return authenticated(_that);case AuthSessionPendingApproval():
return pendingApproval(_that);case AuthSessionDeclined():
return declined(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AuthSessionUnauthenticated value)?  unauthenticated,TResult? Function( AuthSessionTrialMode value)?  trialMode,TResult? Function( AuthSessionAuthenticated value)?  authenticated,TResult? Function( AuthSessionPendingApproval value)?  pendingApproval,TResult? Function( AuthSessionDeclined value)?  declined,}){
final _that = this;
switch (_that) {
case AuthSessionUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case AuthSessionTrialMode() when trialMode != null:
return trialMode(_that);case AuthSessionAuthenticated() when authenticated != null:
return authenticated(_that);case AuthSessionPendingApproval() when pendingApproval != null:
return pendingApproval(_that);case AuthSessionDeclined() when declined != null:
return declined(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  unauthenticated,TResult Function( int brewsUsed,  bool isLocked)?  trialMode,TResult Function( AuthUser user,  String token)?  authenticated,TResult Function( String username,  String message)?  pendingApproval,TResult Function( String message)?  declined,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AuthSessionUnauthenticated() when unauthenticated != null:
return unauthenticated();case AuthSessionTrialMode() when trialMode != null:
return trialMode(_that.brewsUsed,_that.isLocked);case AuthSessionAuthenticated() when authenticated != null:
return authenticated(_that.user,_that.token);case AuthSessionPendingApproval() when pendingApproval != null:
return pendingApproval(_that.username,_that.message);case AuthSessionDeclined() when declined != null:
return declined(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  unauthenticated,required TResult Function( int brewsUsed,  bool isLocked)  trialMode,required TResult Function( AuthUser user,  String token)  authenticated,required TResult Function( String username,  String message)  pendingApproval,required TResult Function( String message)  declined,}) {final _that = this;
switch (_that) {
case AuthSessionUnauthenticated():
return unauthenticated();case AuthSessionTrialMode():
return trialMode(_that.brewsUsed,_that.isLocked);case AuthSessionAuthenticated():
return authenticated(_that.user,_that.token);case AuthSessionPendingApproval():
return pendingApproval(_that.username,_that.message);case AuthSessionDeclined():
return declined(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  unauthenticated,TResult? Function( int brewsUsed,  bool isLocked)?  trialMode,TResult? Function( AuthUser user,  String token)?  authenticated,TResult? Function( String username,  String message)?  pendingApproval,TResult? Function( String message)?  declined,}) {final _that = this;
switch (_that) {
case AuthSessionUnauthenticated() when unauthenticated != null:
return unauthenticated();case AuthSessionTrialMode() when trialMode != null:
return trialMode(_that.brewsUsed,_that.isLocked);case AuthSessionAuthenticated() when authenticated != null:
return authenticated(_that.user,_that.token);case AuthSessionPendingApproval() when pendingApproval != null:
return pendingApproval(_that.username,_that.message);case AuthSessionDeclined() when declined != null:
return declined(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class AuthSessionUnauthenticated implements AuthSessionState {
  const AuthSessionUnauthenticated();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionUnauthenticated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthSessionState.unauthenticated()';
}


}




/// @nodoc


class AuthSessionTrialMode implements AuthSessionState {
  const AuthSessionTrialMode({this.brewsUsed = 0, this.isLocked = false});
  

@JsonKey() final  int brewsUsed;
@JsonKey() final  bool isLocked;

/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSessionTrialModeCopyWith<AuthSessionTrialMode> get copyWith => _$AuthSessionTrialModeCopyWithImpl<AuthSessionTrialMode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionTrialMode&&(identical(other.brewsUsed, brewsUsed) || other.brewsUsed == brewsUsed)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked));
}


@override
int get hashCode => Object.hash(runtimeType,brewsUsed,isLocked);

@override
String toString() {
  return 'AuthSessionState.trialMode(brewsUsed: $brewsUsed, isLocked: $isLocked)';
}


}

/// @nodoc
abstract mixin class $AuthSessionTrialModeCopyWith<$Res> implements $AuthSessionStateCopyWith<$Res> {
  factory $AuthSessionTrialModeCopyWith(AuthSessionTrialMode value, $Res Function(AuthSessionTrialMode) _then) = _$AuthSessionTrialModeCopyWithImpl;
@useResult
$Res call({
 int brewsUsed, bool isLocked
});




}
/// @nodoc
class _$AuthSessionTrialModeCopyWithImpl<$Res>
    implements $AuthSessionTrialModeCopyWith<$Res> {
  _$AuthSessionTrialModeCopyWithImpl(this._self, this._then);

  final AuthSessionTrialMode _self;
  final $Res Function(AuthSessionTrialMode) _then;

/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? brewsUsed = null,Object? isLocked = null,}) {
  return _then(AuthSessionTrialMode(
brewsUsed: null == brewsUsed ? _self.brewsUsed : brewsUsed // ignore: cast_nullable_to_non_nullable
as int,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class AuthSessionAuthenticated implements AuthSessionState {
  const AuthSessionAuthenticated({required this.user, required this.token});
  

 final  AuthUser user;
 final  String token;

/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSessionAuthenticatedCopyWith<AuthSessionAuthenticated> get copyWith => _$AuthSessionAuthenticatedCopyWithImpl<AuthSessionAuthenticated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionAuthenticated&&(identical(other.user, user) || other.user == user)&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode => Object.hash(runtimeType,user,token);

@override
String toString() {
  return 'AuthSessionState.authenticated(user: $user, token: $token)';
}


}

/// @nodoc
abstract mixin class $AuthSessionAuthenticatedCopyWith<$Res> implements $AuthSessionStateCopyWith<$Res> {
  factory $AuthSessionAuthenticatedCopyWith(AuthSessionAuthenticated value, $Res Function(AuthSessionAuthenticated) _then) = _$AuthSessionAuthenticatedCopyWithImpl;
@useResult
$Res call({
 AuthUser user, String token
});




}
/// @nodoc
class _$AuthSessionAuthenticatedCopyWithImpl<$Res>
    implements $AuthSessionAuthenticatedCopyWith<$Res> {
  _$AuthSessionAuthenticatedCopyWithImpl(this._self, this._then);

  final AuthSessionAuthenticated _self;
  final $Res Function(AuthSessionAuthenticated) _then;

/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? user = null,Object? token = null,}) {
  return _then(AuthSessionAuthenticated(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AuthUser,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthSessionPendingApproval implements AuthSessionState {
  const AuthSessionPendingApproval({required this.username, required this.message});
  

 final  String username;
 final  String message;

/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSessionPendingApprovalCopyWith<AuthSessionPendingApproval> get copyWith => _$AuthSessionPendingApprovalCopyWithImpl<AuthSessionPendingApproval>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionPendingApproval&&(identical(other.username, username) || other.username == username)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,username,message);

@override
String toString() {
  return 'AuthSessionState.pendingApproval(username: $username, message: $message)';
}


}

/// @nodoc
abstract mixin class $AuthSessionPendingApprovalCopyWith<$Res> implements $AuthSessionStateCopyWith<$Res> {
  factory $AuthSessionPendingApprovalCopyWith(AuthSessionPendingApproval value, $Res Function(AuthSessionPendingApproval) _then) = _$AuthSessionPendingApprovalCopyWithImpl;
@useResult
$Res call({
 String username, String message
});




}
/// @nodoc
class _$AuthSessionPendingApprovalCopyWithImpl<$Res>
    implements $AuthSessionPendingApprovalCopyWith<$Res> {
  _$AuthSessionPendingApprovalCopyWithImpl(this._self, this._then);

  final AuthSessionPendingApproval _self;
  final $Res Function(AuthSessionPendingApproval) _then;

/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? username = null,Object? message = null,}) {
  return _then(AuthSessionPendingApproval(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthSessionDeclined implements AuthSessionState {
  const AuthSessionDeclined({required this.message});
  

 final  String message;

/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSessionDeclinedCopyWith<AuthSessionDeclined> get copyWith => _$AuthSessionDeclinedCopyWithImpl<AuthSessionDeclined>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionDeclined&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AuthSessionState.declined(message: $message)';
}


}

/// @nodoc
abstract mixin class $AuthSessionDeclinedCopyWith<$Res> implements $AuthSessionStateCopyWith<$Res> {
  factory $AuthSessionDeclinedCopyWith(AuthSessionDeclined value, $Res Function(AuthSessionDeclined) _then) = _$AuthSessionDeclinedCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$AuthSessionDeclinedCopyWithImpl<$Res>
    implements $AuthSessionDeclinedCopyWith<$Res> {
  _$AuthSessionDeclinedCopyWithImpl(this._self, this._then);

  final AuthSessionDeclined _self;
  final $Res Function(AuthSessionDeclined) _then;

/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(AuthSessionDeclined(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
