import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hydration_model.dart';
import '../repositories/hydration_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

final hydrationRepositoryProvider = Provider<HydrationRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HydrationRepository(prefs);
});

class HydrationState {
  final HydrationGoal goal;
  final List<HydrationLog> logs;
  final int todayTotalMl;
  final Map<DateTime, int> past7DaysTotals;

  HydrationState({
    required this.goal,
    required this.logs,
    required this.todayTotalMl,
    required this.past7DaysTotals,
  });

  double get todayProgress => (todayTotalMl / goal.dailyTargetMl).clamp(0.0, 1.0);
  int get remainingMl => (goal.dailyTargetMl - todayTotalMl).clamp(0, goal.dailyTargetMl);
  List<HydrationLog> get todayLogs {
    final now = DateTime.now();
    return logs.where((l) => l.timestamp.day == now.day && l.timestamp.month == now.month && l.timestamp.year == now.year).toList();
  }

  HydrationState copyWith({
    HydrationGoal? goal,
    List<HydrationLog>? logs,
    int? todayTotalMl,
    Map<DateTime, int>? past7DaysTotals,
  }) {
    return HydrationState(
      goal: goal ?? this.goal,
      logs: logs ?? this.logs,
      todayTotalMl: todayTotalMl ?? this.todayTotalMl,
      past7DaysTotals: past7DaysTotals ?? this.past7DaysTotals,
    );
  }
}

class HydrationNotifier extends StateNotifier<HydrationState> {
  final HydrationRepository _repository;

  HydrationNotifier(this._repository)
      : super(HydrationState(
          goal: _repository.getGoal(),
          logs: _repository.getLogs(),
          todayTotalMl: _repository.getTodayTotalMl(),
          past7DaysTotals: _repository.getPast7DaysTotals(),
        ));

  Future<void> logWater(int amountMl) async {
    final newLog = HydrationLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      amountMl: amountMl,
      unit: state.goal.preferredUnit,
    );

    await _repository.addLog(newLog);
    _refreshState();
  }

  Future<void> updateGoal(HydrationGoal newGoal) async {
    await _repository.saveGoal(newGoal);
    _refreshState();
  }

  Future<void> clearAllLogs() async {
    await _repository.clearLogs();
    _refreshState();
  }

  void _refreshState() {
    state = HydrationState(
      goal: _repository.getGoal(),
      logs: _repository.getLogs(),
      todayTotalMl: _repository.getTodayTotalMl(),
      past7DaysTotals: _repository.getPast7DaysTotals(),
    );
  }
}

final hydrationProvider = StateNotifierProvider<HydrationNotifier, HydrationState>((ref) {
  final repo = ref.watch(hydrationRepositoryProvider);
  return HydrationNotifier(repo);
});
