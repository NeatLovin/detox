// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(xpHistory)
final xpHistoryProvider = XpHistoryProvider._();

final class XpHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DayValue>>,
          List<DayValue>,
          FutureOr<List<DayValue>>
        >
    with $FutureModifier<List<DayValue>>, $FutureProvider<List<DayValue>> {
  XpHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'xpHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$xpHistoryHash();

  @$internal
  @override
  $FutureProviderElement<List<DayValue>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DayValue>> create(Ref ref) {
    return xpHistory(ref);
  }
}

String _$xpHistoryHash() => r'2757c3d795681dd30c4f674202c58f7a0bbf5156';
