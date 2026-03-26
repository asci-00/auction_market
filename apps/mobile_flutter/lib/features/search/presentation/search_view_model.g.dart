// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchViewModelHash() => r'b1e838b2a432570997f94687398e403388c84e18';

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

abstract class _$SearchViewModel
    extends BuildlessAutoDisposeAsyncNotifier<SearchViewState> {
  late final String query;

  FutureOr<SearchViewState> build(
    String query,
  );
}

/// See also [SearchViewModel].
@ProviderFor(SearchViewModel)
const searchViewModelProvider = SearchViewModelFamily();

/// See also [SearchViewModel].
class SearchViewModelFamily extends Family<AsyncValue<SearchViewState>> {
  /// See also [SearchViewModel].
  const SearchViewModelFamily();

  /// See also [SearchViewModel].
  SearchViewModelProvider call(
    String query,
  ) {
    return SearchViewModelProvider(
      query,
    );
  }

  @override
  SearchViewModelProvider getProviderOverride(
    covariant SearchViewModelProvider provider,
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
  String? get name => r'searchViewModelProvider';
}

/// See also [SearchViewModel].
class SearchViewModelProvider extends AutoDisposeAsyncNotifierProviderImpl<
    SearchViewModel, SearchViewState> {
  /// See also [SearchViewModel].
  SearchViewModelProvider(
    String query,
  ) : this._internal(
          () => SearchViewModel()..query = query,
          from: searchViewModelProvider,
          name: r'searchViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchViewModelHash,
          dependencies: SearchViewModelFamily._dependencies,
          allTransitiveDependencies:
              SearchViewModelFamily._allTransitiveDependencies,
          query: query,
        );

  SearchViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  FutureOr<SearchViewState> runNotifierBuild(
    covariant SearchViewModel notifier,
  ) {
    return notifier.build(
      query,
    );
  }

  @override
  Override overrideWith(SearchViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: SearchViewModelProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<SearchViewModel, SearchViewState>
      createElement() {
    return _SearchViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchViewModelProvider && other.query == query;
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
mixin SearchViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<SearchViewState> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<SearchViewModel,
        SearchViewState> with SearchViewModelRef {
  _SearchViewModelProviderElement(super.provider);

  @override
  String get query => (origin as SearchViewModelProvider).query;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
