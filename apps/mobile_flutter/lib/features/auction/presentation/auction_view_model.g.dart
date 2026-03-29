// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$auctionViewModelHash() => r'971918bac5d13f673ae7d3062a67621c1d125722';

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

abstract class _$AuctionViewModel
    extends BuildlessAutoDisposeAsyncNotifier<AuctionViewState> {
  late final String auctionId;

  FutureOr<AuctionViewState> build(
    String auctionId,
  );
}

/// See also [AuctionViewModel].
@ProviderFor(AuctionViewModel)
const auctionViewModelProvider = AuctionViewModelFamily();

/// See also [AuctionViewModel].
class AuctionViewModelFamily extends Family<AsyncValue<AuctionViewState>> {
  /// See also [AuctionViewModel].
  const AuctionViewModelFamily();

  /// See also [AuctionViewModel].
  AuctionViewModelProvider call(
    String auctionId,
  ) {
    return AuctionViewModelProvider(
      auctionId,
    );
  }

  @override
  AuctionViewModelProvider getProviderOverride(
    covariant AuctionViewModelProvider provider,
  ) {
    return call(
      provider.auctionId,
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
  String? get name => r'auctionViewModelProvider';
}

/// See also [AuctionViewModel].
class AuctionViewModelProvider extends AutoDisposeAsyncNotifierProviderImpl<
    AuctionViewModel, AuctionViewState> {
  /// See also [AuctionViewModel].
  AuctionViewModelProvider(
    String auctionId,
  ) : this._internal(
          () => AuctionViewModel()..auctionId = auctionId,
          from: auctionViewModelProvider,
          name: r'auctionViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$auctionViewModelHash,
          dependencies: AuctionViewModelFamily._dependencies,
          allTransitiveDependencies:
              AuctionViewModelFamily._allTransitiveDependencies,
          auctionId: auctionId,
        );

  AuctionViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.auctionId,
  }) : super.internal();

  final String auctionId;

  @override
  FutureOr<AuctionViewState> runNotifierBuild(
    covariant AuctionViewModel notifier,
  ) {
    return notifier.build(
      auctionId,
    );
  }

  @override
  Override overrideWith(AuctionViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: AuctionViewModelProvider._internal(
        () => create()..auctionId = auctionId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        auctionId: auctionId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<AuctionViewModel, AuctionViewState>
      createElement() {
    return _AuctionViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AuctionViewModelProvider && other.auctionId == auctionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, auctionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AuctionViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<AuctionViewState> {
  /// The parameter `auctionId` of this provider.
  String get auctionId;
}

class _AuctionViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<AuctionViewModel,
        AuctionViewState> with AuctionViewModelRef {
  _AuctionViewModelProviderElement(super.provider);

  @override
  String get auctionId => (origin as AuctionViewModelProvider).auctionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
