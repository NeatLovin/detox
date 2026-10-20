// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(activeQuests)
final activeQuestsProvider = ActiveQuestsProvider._();

final class ActiveQuestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DailyQuest>>,
          List<DailyQuest>,
          FutureOr<List<DailyQuest>>
        >
    with $FutureModifier<List<DailyQuest>>, $FutureProvider<List<DailyQuest>> {
  ActiveQuestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeQuestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeQuestsHash();

  @$internal
  @override
  $FutureProviderElement<List<DailyQuest>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DailyQuest>> create(Ref ref) {
    return activeQuests(ref);
  }
}

String _$activeQuestsHash() => r'2629b22225006f67d467314050e96ba49caaf706';

@ProviderFor(questLogs)
final questLogsProvider = QuestLogsProvider._();

final class QuestLogsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<QuestLog>>,
          List<QuestLog>,
          FutureOr<List<QuestLog>>
        >
    with $FutureModifier<List<QuestLog>>, $FutureProvider<List<QuestLog>> {
  QuestLogsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questLogsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questLogsHash();

  @$internal
  @override
  $FutureProviderElement<List<QuestLog>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<QuestLog>> create(Ref ref) {
    return questLogs(ref);
  }
}

String _$questLogsHash() => r'486f0820a47478a210119b70951dc0ff1181bf9e';

/// Today's progress of every active quest.

@ProviderFor(questDay)
final questDayProvider = QuestDayProvider._();

/// Today's progress of every active quest.

final class QuestDayProvider
    extends
        $FunctionalProvider<AsyncValue<QuestDay>, QuestDay, FutureOr<QuestDay>>
    with $FutureModifier<QuestDay>, $FutureProvider<QuestDay> {
  /// Today's progress of every active quest.
  QuestDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questDayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questDayHash();

  @$internal
  @override
  $FutureProviderElement<QuestDay> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<QuestDay> create(Ref ref) {
    return questDay(ref);
  }
}

String _$questDayHash() => r'9baeab71c65b0d80f89100d698d74e32b520b71b';
