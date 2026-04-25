// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationsViewModelHash() =>
    r'075083c6f7407df2523c1bf6d40bcaff48ae35c2';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$NotificationsViewModel
    extends BuildlessAutoDisposeAsyncNotifier<NotificationsViewState> {
  late final String userId;

  FutureOr<NotificationsViewState> build(String userId);
}

/// See also [NotificationsViewModel].
@ProviderFor(NotificationsViewModel)
const notificationsViewModelProvider = NotificationsViewModelFamily();

/// See also [NotificationsViewModel].
class NotificationsViewModelFamily
    extends Family<AsyncValue<NotificationsViewState>> {
  /// See also [NotificationsViewModel].
  const NotificationsViewModelFamily();

  /// See also [NotificationsViewModel].
  NotificationsViewModelProvider call(String userId) {
    return NotificationsViewModelProvider(userId);
  }

  @override
  NotificationsViewModelProvider getProviderOverride(
    covariant NotificationsViewModelProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'notificationsViewModelProvider';
}

/// See also [NotificationsViewModel].
class NotificationsViewModelProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          NotificationsViewModel,
          NotificationsViewState
        > {
  /// See also [NotificationsViewModel].
  NotificationsViewModelProvider(String userId)
    : this._internal(
        () => NotificationsViewModel()..userId = userId,
        from: notificationsViewModelProvider,
        name: r'notificationsViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$notificationsViewModelHash,
        dependencies: NotificationsViewModelFamily._dependencies,
        allTransitiveDependencies:
            NotificationsViewModelFamily._allTransitiveDependencies,
        userId: userId,
      );

  NotificationsViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  FutureOr<NotificationsViewState> runNotifierBuild(
    covariant NotificationsViewModel notifier,
  ) {
    return notifier.build(userId);
  }

  @override
  Override overrideWith(NotificationsViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: NotificationsViewModelProvider._internal(
        () => create()..userId = userId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    NotificationsViewModel,
    NotificationsViewState
  >
  createElement() {
    return _NotificationsViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationsViewModelProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NotificationsViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<NotificationsViewState> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _NotificationsViewModelProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          NotificationsViewModel,
          NotificationsViewState
        >
    with NotificationsViewModelRef {
  _NotificationsViewModelProviderElement(super.provider);

  @override
  String get userId => (origin as NotificationsViewModelProvider).userId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
