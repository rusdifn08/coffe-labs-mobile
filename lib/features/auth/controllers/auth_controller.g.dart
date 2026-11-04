// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AsyncNotifier untuk otentikasi pengguna, peran, status persetujuan, dan tier langganan.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// AsyncNotifier untuk otentikasi pengguna, peran, status persetujuan, dan tier langganan.
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, AuthUser?> {
  /// AsyncNotifier untuk otentikasi pengguna, peran, status persetujuan, dan tier langganan.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'ef860b2c9219b821ea451d15dc69f5cb23fb45da';

/// AsyncNotifier untuk otentikasi pengguna, peran, status persetujuan, dan tier langganan.

abstract class _$AuthController extends $AsyncNotifier<AuthUser?> {
  FutureOr<AuthUser?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthUser?>, AuthUser?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthUser?>, AuthUser?>,
              AsyncValue<AuthUser?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Selector sederhana untuk memeriksa apakah pengguna berstatus admin.

@ProviderFor(isUserAdmin)
final isUserAdminProvider = IsUserAdminProvider._();

/// Selector sederhana untuk memeriksa apakah pengguna berstatus admin.

final class IsUserAdminProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Selector sederhana untuk memeriksa apakah pengguna berstatus admin.
  IsUserAdminProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isUserAdminProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isUserAdminHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isUserAdmin(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isUserAdminHash() => r'510b1929798c0afe1588140c812c7c122ca77fa6';
