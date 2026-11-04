import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../services/auth_service.dart';

part 'auth_session_state.freezed.dart';

/// Freezed Union Type untuk representasi state sesi otentikasi yang exhaustively safe.
@freezed
sealed class AuthSessionState with _$AuthSessionState {
  const factory AuthSessionState.unauthenticated() = AuthSessionUnauthenticated;

  const factory AuthSessionState.trialMode({
    @Default(0) int brewsUsed,
    @Default(false) bool isLocked,
  }) = AuthSessionTrialMode;

  const factory AuthSessionState.authenticated({
    required AuthUser user,
    required String token,
  }) = AuthSessionAuthenticated;

  const factory AuthSessionState.pendingApproval({
    required String username,
    required String message,
  }) = AuthSessionPendingApproval;

  const factory AuthSessionState.declined({
    required String message,
  }) = AuthSessionDeclined;
}
