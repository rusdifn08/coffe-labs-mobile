// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chatDriftDatabase)
final chatDriftDatabaseProvider = ChatDriftDatabaseProvider._();

final class ChatDriftDatabaseProvider
    extends
        $FunctionalProvider<
          ChatDriftDatabase,
          ChatDriftDatabase,
          ChatDriftDatabase
        >
    with $Provider<ChatDriftDatabase> {
  ChatDriftDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatDriftDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatDriftDatabaseHash();

  @$internal
  @override
  $ProviderElement<ChatDriftDatabase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChatDriftDatabase create(Ref ref) {
    return chatDriftDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatDriftDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatDriftDatabase>(value),
    );
  }
}

String _$chatDriftDatabaseHash() => r'13d1328efc77941c338f007209acacf80dea3d3e';

@ProviderFor(chatApiService)
final chatApiServiceProvider = ChatApiServiceProvider._();

final class ChatApiServiceProvider
    extends $FunctionalProvider<ChatApiService, ChatApiService, ChatApiService>
    with $Provider<ChatApiService> {
  ChatApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatApiServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatApiServiceHash();

  @$internal
  @override
  $ProviderElement<ChatApiService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChatApiService create(Ref ref) {
    return chatApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatApiService>(value),
    );
  }
}

String _$chatApiServiceHash() => r'b061a96231bb9270518a026c472be439f0ec6ad7';

@ProviderFor(chatWsService)
final chatWsServiceProvider = ChatWsServiceProvider._();

final class ChatWsServiceProvider
    extends $FunctionalProvider<ChatWsService, ChatWsService, ChatWsService>
    with $Provider<ChatWsService> {
  ChatWsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatWsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatWsServiceHash();

  @$internal
  @override
  $ProviderElement<ChatWsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChatWsService create(Ref ref) {
    return chatWsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatWsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatWsService>(value),
    );
  }
}

String _$chatWsServiceHash() => r'1ea5585ab280875bab2a31c4fa07bbe08b5a2da3';

@ProviderFor(chatConnectionState)
final chatConnectionStateProvider = ChatConnectionStateProvider._();

final class ChatConnectionStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<WsConnectionState>,
          WsConnectionState,
          Stream<WsConnectionState>
        >
    with
        $FutureModifier<WsConnectionState>,
        $StreamProvider<WsConnectionState> {
  ChatConnectionStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatConnectionStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatConnectionStateHash();

  @$internal
  @override
  $StreamProviderElement<WsConnectionState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<WsConnectionState> create(Ref ref) {
    return chatConnectionState(ref);
  }
}

String _$chatConnectionStateHash() =>
    r'60f0060eec8f964a23b2476fcbe6d197b21014ed';

@ProviderFor(ChatRoomListController)
final chatRoomListControllerProvider = ChatRoomListControllerProvider._();

final class ChatRoomListControllerProvider
    extends
        $StreamNotifierProvider<
          ChatRoomListController,
          List<ChatRoomListItemView>
        > {
  ChatRoomListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRoomListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRoomListControllerHash();

  @$internal
  @override
  ChatRoomListController create() => ChatRoomListController();
}

String _$chatRoomListControllerHash() =>
    r'39469abd655c8d075fdf1538894cefa5202189b5';

abstract class _$ChatRoomListController
    extends $StreamNotifier<List<ChatRoomListItemView>> {
  Stream<List<ChatRoomListItemView>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ChatRoomListItemView>>,
              List<ChatRoomListItemView>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ChatRoomListItemView>>,
                List<ChatRoomListItemView>
              >,
              AsyncValue<List<ChatRoomListItemView>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ActiveChatRoomController)
final activeChatRoomControllerProvider = ActiveChatRoomControllerFamily._();

final class ActiveChatRoomControllerProvider
    extends
        $StreamNotifierProvider<
          ActiveChatRoomController,
          List<LocalChatMessageView>
        > {
  ActiveChatRoomControllerProvider._({
    required ActiveChatRoomControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activeChatRoomControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeChatRoomControllerHash();

  @override
  String toString() {
    return r'activeChatRoomControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ActiveChatRoomController create() => ActiveChatRoomController();

  @override
  bool operator ==(Object other) {
    return other is ActiveChatRoomControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeChatRoomControllerHash() =>
    r'e62fdbc6782a857e03c8cd185e535e4c166ae6ea';

final class ActiveChatRoomControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ActiveChatRoomController,
          AsyncValue<List<LocalChatMessageView>>,
          List<LocalChatMessageView>,
          Stream<List<LocalChatMessageView>>,
          String
        > {
  ActiveChatRoomControllerFamily._()
    : super(
        retry: null,
        name: r'activeChatRoomControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ActiveChatRoomControllerProvider call(String conversationId) =>
      ActiveChatRoomControllerProvider._(argument: conversationId, from: this);

  @override
  String toString() => r'activeChatRoomControllerProvider';
}

abstract class _$ActiveChatRoomController
    extends $StreamNotifier<List<LocalChatMessageView>> {
  late final _$args = ref.$arg as String;
  String get conversationId => _$args;

  Stream<List<LocalChatMessageView>> build(String conversationId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<LocalChatMessageView>>,
              List<LocalChatMessageView>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<LocalChatMessageView>>,
                List<LocalChatMessageView>
              >,
              AsyncValue<List<LocalChatMessageView>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
