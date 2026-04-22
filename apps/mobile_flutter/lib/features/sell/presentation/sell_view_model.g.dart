// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sell_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sellViewModelHash() => r'e50ec9ce180f6e7c3fb6670597f4dfd728f8e1ba';

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

abstract class _$SellViewModel
    extends BuildlessAutoDisposeAsyncNotifier<SellViewState> {
  late final String userId;

  FutureOr<SellViewState> build(String userId);
}

/// See also [SellViewModel].
@ProviderFor(SellViewModel)
const sellViewModelProvider = SellViewModelFamily();

/// See also [SellViewModel].
class SellViewModelFamily extends Family<AsyncValue<SellViewState>> {
  /// See also [SellViewModel].
  const SellViewModelFamily();

  /// See also [SellViewModel].
  SellViewModelProvider call(String userId) {
    return SellViewModelProvider(userId);
  }

  @override
  SellViewModelProvider getProviderOverride(
    covariant SellViewModelProvider provider,
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
  String? get name => r'sellViewModelProvider';
}

/// See also [SellViewModel].
class SellViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<SellViewModel, SellViewState> {
  /// See also [SellViewModel].
  SellViewModelProvider(String userId)
    : this._internal(
        () => SellViewModel()..userId = userId,
        from: sellViewModelProvider,
        name: r'sellViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sellViewModelHash,
        dependencies: SellViewModelFamily._dependencies,
        allTransitiveDependencies:
            SellViewModelFamily._allTransitiveDependencies,
        userId: userId,
      );

  SellViewModelProvider._internal(
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
  FutureOr<SellViewState> runNotifierBuild(covariant SellViewModel notifier) {
    return notifier.build(userId);
  }

  @override
  Override overrideWith(SellViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: SellViewModelProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<SellViewModel, SellViewState>
  createElement() {
    return _SellViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SellViewModelProvider && other.userId == userId;
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
mixin SellViewModelRef on AutoDisposeAsyncNotifierProviderRef<SellViewState> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _SellViewModelProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<SellViewModel, SellViewState>
    with SellViewModelRef {
  _SellViewModelProviderElement(super.provider);

  @override
  String get userId => (origin as SellViewModelProvider).userId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
