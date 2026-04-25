// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myViewModelHash() => r'0bad389dcb9b50ea6cd314beaecff65b81052b63';

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

abstract class _$MyViewModel
    extends BuildlessAutoDisposeAsyncNotifier<MyViewState> {
  late final String userId;

  FutureOr<MyViewState> build(String userId);
}

/// See also [MyViewModel].
@ProviderFor(MyViewModel)
const myViewModelProvider = MyViewModelFamily();

/// See also [MyViewModel].
class MyViewModelFamily extends Family<AsyncValue<MyViewState>> {
  /// See also [MyViewModel].
  const MyViewModelFamily();

  /// See also [MyViewModel].
  MyViewModelProvider call(String userId) {
    return MyViewModelProvider(userId);
  }

  @override
  MyViewModelProvider getProviderOverride(
    covariant MyViewModelProvider provider,
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
  String? get name => r'myViewModelProvider';
}

/// See also [MyViewModel].
class MyViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<MyViewModel, MyViewState> {
  /// See also [MyViewModel].
  MyViewModelProvider(String userId)
    : this._internal(
        () => MyViewModel()..userId = userId,
        from: myViewModelProvider,
        name: r'myViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$myViewModelHash,
        dependencies: MyViewModelFamily._dependencies,
        allTransitiveDependencies: MyViewModelFamily._allTransitiveDependencies,
        userId: userId,
      );

  MyViewModelProvider._internal(
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
  FutureOr<MyViewState> runNotifierBuild(covariant MyViewModel notifier) {
    return notifier.build(userId);
  }

  @override
  Override overrideWith(MyViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: MyViewModelProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<MyViewModel, MyViewState>
  createElement() {
    return _MyViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyViewModelProvider && other.userId == userId;
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
mixin MyViewModelRef on AutoDisposeAsyncNotifierProviderRef<MyViewState> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _MyViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MyViewModel, MyViewState>
    with MyViewModelRef {
  _MyViewModelProviderElement(super.provider);

  @override
  String get userId => (origin as MyViewModelProvider).userId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
