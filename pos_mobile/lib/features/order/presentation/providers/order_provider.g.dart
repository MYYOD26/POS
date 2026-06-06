// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderHistoryHash() => r'57b9cbdc9d80e81d78c14ec74844d049fc17233d';

/// See also [OrderHistory].
@ProviderFor(OrderHistory)
final orderHistoryProvider =
    NotifierProvider<OrderHistory, List<OrderModel>>.internal(
      OrderHistory.new,
      name: r'orderHistoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$orderHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OrderHistory = Notifier<List<OrderModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
