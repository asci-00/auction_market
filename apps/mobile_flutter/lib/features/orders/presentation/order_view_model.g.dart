// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ordersViewModelHash() => r'3fa5e4d5a562fe24772efaf6941cd2cc173d6730';

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

abstract class _$OrdersViewModel
    extends BuildlessAutoDisposeAsyncNotifier<OrdersViewState> {
  late final OrderQuery query;

  FutureOr<OrdersViewState> build(
    OrderQuery query,
  );
}

/// See also [OrdersViewModel].
@ProviderFor(OrdersViewModel)
const ordersViewModelProvider = OrdersViewModelFamily();

/// See also [OrdersViewModel].
class OrdersViewModelFamily extends Family<AsyncValue<OrdersViewState>> {
  /// See also [OrdersViewModel].
  const OrdersViewModelFamily();

  /// See also [OrdersViewModel].
  OrdersViewModelProvider call(
    OrderQuery query,
  ) {
    return OrdersViewModelProvider(
      query,
    );
  }

  @override
  OrdersViewModelProvider getProviderOverride(
    covariant OrdersViewModelProvider provider,
  ) {
    return call(
      provider.query,
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
  String? get name => r'ordersViewModelProvider';
}

/// See also [OrdersViewModel].
class OrdersViewModelProvider extends AutoDisposeAsyncNotifierProviderImpl<
    OrdersViewModel, OrdersViewState> {
  /// See also [OrdersViewModel].
  OrdersViewModelProvider(
    OrderQuery query,
  ) : this._internal(
          () => OrdersViewModel()..query = query,
          from: ordersViewModelProvider,
          name: r'ordersViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$ordersViewModelHash,
          dependencies: OrdersViewModelFamily._dependencies,
          allTransitiveDependencies:
              OrdersViewModelFamily._allTransitiveDependencies,
          query: query,
        );

  OrdersViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final OrderQuery query;

  @override
  FutureOr<OrdersViewState> runNotifierBuild(
    covariant OrdersViewModel notifier,
  ) {
    return notifier.build(
      query,
    );
  }

  @override
  Override overrideWith(OrdersViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: OrdersViewModelProvider._internal(
        () => create()..query = query,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<OrdersViewModel, OrdersViewState>
      createElement() {
    return _OrdersViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrdersViewModelProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrdersViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<OrdersViewState> {
  /// The parameter `query` of this provider.
  OrderQuery get query;
}

class _OrdersViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<OrdersViewModel,
        OrdersViewState> with OrdersViewModelRef {
  _OrdersViewModelProviderElement(super.provider);

  @override
  OrderQuery get query => (origin as OrdersViewModelProvider).query;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
