// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activityViewModelHash() => r'f5c16d021b8dc6057bdd6ed7e51346642f10c9f5';

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

abstract class _$ActivityViewModel
    extends BuildlessAutoDisposeAsyncNotifier<ActivityViewState> {
  late final String userId;

  FutureOr<ActivityViewState> build(
    String userId,
  );
}

/// See also [ActivityViewModel].
@ProviderFor(ActivityViewModel)
const activityViewModelProvider = ActivityViewModelFamily();

/// See also [ActivityViewModel].
class ActivityViewModelFamily extends Family<AsyncValue<ActivityViewState>> {
  /// See also [ActivityViewModel].
  const ActivityViewModelFamily();

  /// See also [ActivityViewModel].
  ActivityViewModelProvider call(
    String userId,
  ) {
    return ActivityViewModelProvider(
      userId,
    );
  }

  @override
  ActivityViewModelProvider getProviderOverride(
    covariant ActivityViewModelProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'activityViewModelProvider';
}

/// See also [ActivityViewModel].
class ActivityViewModelProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ActivityViewModel, ActivityViewState> {
  /// See also [ActivityViewModel].
  ActivityViewModelProvider(
    String userId,
  ) : this._internal(
          () => ActivityViewModel()..userId = userId,
          from: activityViewModelProvider,
          name: r'activityViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$activityViewModelHash,
          dependencies: ActivityViewModelFamily._dependencies,
          allTransitiveDependencies:
              ActivityViewModelFamily._allTransitiveDependencies,
          userId: userId,
        );

  ActivityViewModelProvider._internal(
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
  FutureOr<ActivityViewState> runNotifierBuild(
    covariant ActivityViewModel notifier,
  ) {
    return notifier.build(
      userId,
    );
  }

  @override
  Override overrideWith(ActivityViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ActivityViewModelProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ActivityViewModel, ActivityViewState>
      createElement() {
    return _ActivityViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActivityViewModelProvider && other.userId == userId;
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
mixin ActivityViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<ActivityViewState> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _ActivityViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ActivityViewModel,
        ActivityViewState> with ActivityViewModelRef {
  _ActivityViewModelProviderElement(super.provider);

  @override
  String get userId => (origin as ActivityViewModelProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
