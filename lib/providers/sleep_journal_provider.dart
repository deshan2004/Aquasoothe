import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sleep_journal_model.dart';
import '../repositories/sleep_journal_repository.dart';
import 'hydration_provider.dart';

final sleepJournalRepositoryProvider = Provider<SleepJournalRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SleepJournalRepository(prefs);
});

class SleepJournalState {
  final List<SleepLog> logs;
  final SleepLog? todayLog;

  SleepJournalState({
    required this.logs,
    this.todayLog,
  });
}

class SleepJournalNotifier extends StateNotifier<SleepJournalState> {
  final SleepJournalRepository _repository;

  SleepJournalNotifier(this._repository)
      : super(SleepJournalState(
          logs: _repository.getLogs(),
          todayLog: _repository.getTodayLog(),
        ));

  Future<void> logSleep({
    required SleepRating rating,
    required int previousDayWaterMl,
    String? notes,
  }) async {
    final newLog = SleepLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      rating: rating,
      previousDayWaterMl: previousDayWaterMl,
      notes: notes,
    );

    await _repository.logSleep(newLog);
    state = SleepJournalState(
      logs: _repository.getLogs(),
      todayLog: _repository.getTodayLog(),
    );
  }
}

final sleepJournalProvider = StateNotifierProvider<SleepJournalNotifier, SleepJournalState>((ref) {
  final repo = ref.watch(sleepJournalRepositoryProvider);
  return SleepJournalNotifier(repo);
});
