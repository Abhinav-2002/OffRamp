import 'package:hive_flutter/hive_flutter.dart';
import '../models/four_things.dart';
import '../models/distracting_app.dart';
import '../models/user_stats.dart';
import '../models/user_settings.dart';
import '../models/human_buffer.dart';
import '../models/brain_dump.dart';

// ═════════════════════════════════════════════════════════════════════════════
// HIVE SERVICE - Central database management
// ═════════════════════════════════════════════════════════════════════════════

class HiveService {
  static const String fourThingsBox = 'fourThings';
  static const String distractingAppsBox = 'distractingApps';
  static const String userStatsBox = 'userStats';
  static const String userSettingsBox = 'userSettings';
  static const String humanBufferBox = 'humanBuffer';
  static const String brainDumpBox = 'brainDump';

  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(FourThingsAdapter());
    Hive.registerAdapter(DistractingAppAdapter());
    Hive.registerAdapter(UserStatsAdapter());
    Hive.registerAdapter(MoodEntryAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(HumanBufferAdapter());
    Hive.registerAdapter(ContactMethodAdapter());
    Hive.registerAdapter(BrainDumpAdapter());

    // Open boxes
    await Hive.openBox<FourThings>(fourThingsBox);
    await Hive.openBox<DistractingApp>(distractingAppsBox);
    await Hive.openBox<UserStats>(userStatsBox);
    await Hive.openBox<UserSettings>(userSettingsBox);
    await Hive.openBox<HumanBuffer>(humanBufferBox);
    await Hive.openBox<BrainDump>(brainDumpBox);

    // Initialize default data if needed
    await _initializeDefaults();

    _initialized = true;
  }

  Future<void> _initializeDefaults() async {
    // Initialize user settings if not exists
    final settingsBox = Hive.box<UserSettings>(userSettingsBox);
    if (settingsBox.isEmpty) {
      await settingsBox.add(UserSettings());
    }

    // Initialize distracting apps if not exists
    final appsBox = Hive.box<DistractingApp>(distractingAppsBox);
    if (appsBox.isEmpty) {
      final defaults = DistractingApp.getDefaultApps();
      for (final app in defaults) {
        await appsBox.add(app);
      }
    }

    // Initialize today's stats if not exists
    final statsBox = Hive.box<UserStats>(userStatsBox);
    final today = DateTime.now();
    final todayStats = statsBox.values.where((s) => _isSameDay(s.date, today));
    if (todayStats.isEmpty) {
      await statsBox.add(UserStats(date: today));
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ─── FOUR THINGS OPERATIONS ────────────────────────────────────────────────

  FourThings? getFourThings() {
    final box = Hive.box<FourThings>(fourThingsBox);
    return box.isNotEmpty ? box.getAt(0) : null;
  }

  Future<void> saveFourThings(FourThings fourThings) async {
    final box = Hive.box<FourThings>(fourThingsBox);
    if (box.isNotEmpty) {
      await box.putAt(0, fourThings);
    } else {
      await box.add(fourThings);
    }
  }

  // ─── DISTRACTING APPS OPERATIONS ───────────────────────────────────────────

  List<DistractingApp> getDistractingApps() {
    final box = Hive.box<DistractingApp>(distractingAppsBox);
    return box.values.toList();
  }

  List<DistractingApp> getSelectedApps() {
    final box = Hive.box<DistractingApp>(distractingAppsBox);
    return box.values.where((a) => a.isSelected).toList();
  }

  List<String> getSelectedPackageNames() {
    return getSelectedApps().map((a) => a.packageName).toList();
  }

  Future<void> saveDistractingApp(DistractingApp app) async {
    final box = Hive.box<DistractingApp>(distractingAppsBox);
    final existing = box.values.toList().indexWhere((a) => a.packageName == app.packageName);
    if (existing >= 0) {
      await box.putAt(existing, app);
    } else {
      await box.add(app);
    }
  }

  Future<void> toggleAppSelection(String packageName) async {
    final box = Hive.box<DistractingApp>(distractingAppsBox);
    final apps = box.values.toList();
    final index = apps.indexWhere((a) => a.packageName == packageName);
    if (index >= 0) {
      final app = apps[index];
      app.isSelected = !app.isSelected;
      await box.putAt(index, app);
    }
  }

  // ─── USER STATS OPERATIONS ─────────────────────────────────────────────────

  UserStats getTodayStats() {
    final box = Hive.box<UserStats>(userStatsBox);
    final today = DateTime.now();
    final todayStats = box.values.where((s) => _isSameDay(s.date, today));
    if (todayStats.isNotEmpty) {
      return todayStats.first;
    }
    // Create new stats for today
    final newStats = UserStats(date: today);
    box.add(newStats);
    return newStats;
  }

  List<UserStats> getWeeklyStats() {
    final box = Hive.box<UserStats>(userStatsBox);
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return box.values
        .where((s) => s.date.isAfter(weekAgo) || _isSameDay(s.date, weekAgo))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> recordUrge({bool resisted = false}) async {
    final stats = getTodayStats();
    stats.recordUrge(resisted: resisted);
  }

  Future<void> recordWinTask() async {
    final stats = getTodayStats();
    stats.recordWinTask();
  }

  Future<void> recordHumanConnection() async {
    final stats = getTodayStats();
    stats.recordHumanConnection();
  }

  // ─── USER SETTINGS OPERATIONS ──────────────────────────────────────────────

  UserSettings getSettings() {
    final box = Hive.box<UserSettings>(userSettingsBox);
    return box.getAt(0) ?? UserSettings();
  }

  Future<void> saveSettings(UserSettings settings) async {
    final box = Hive.box<UserSettings>(userSettingsBox);
    if (box.isNotEmpty) {
      await box.putAt(0, settings);
    } else {
      await box.add(settings);
    }
  }

  // ─── HUMAN BUFFER OPERATIONS ───────────────────────────────────────────────

  List<HumanBuffer> getHumanBuffers() {
    final box = Hive.box<HumanBuffer>(humanBufferBox);
    return box.values.toList();
  }

  Future<void> saveHumanBuffer(HumanBuffer buffer) async {
    final box = Hive.box<HumanBuffer>(humanBufferBox);
    final existing = box.values.toList().indexWhere((b) => b.contactId == buffer.contactId);
    if (existing >= 0) {
      await box.putAt(existing, buffer);
    } else {
      await box.add(buffer);
    }
  }

  Future<void> deleteHumanBuffer(String contactId) async {
    final box = Hive.box<HumanBuffer>(humanBufferBox);
    final index = box.values.toList().indexWhere((b) => b.contactId == contactId);
    if (index >= 0) {
      await box.deleteAt(index);
    }
  }

  // ─── BRAIN DUMP OPERATIONS ─────────────────────────────────────────────────

  List<BrainDump> getBrainDumps({bool includeArchived = false}) {
    final box = Hive.box<BrainDump>(brainDumpBox);
    return box.values
        .where((b) => includeArchived || !b.isArchived)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  BrainDump? getTodayBrainDump() {
    final dumps = getBrainDumps();
    final today = DateTime.now();
    try {
      return dumps.firstWhere((d) => _isSameDay(d.createdAt, today));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveBrainDump(BrainDump dump) async {
    final box = Hive.box<BrainDump>(brainDumpBox);
    final existing = box.values.toList().indexWhere((b) => b.id == dump.id);
    if (existing >= 0) {
      await box.putAt(existing, dump);
    } else {
      await box.add(dump);
    }
  }

  Future<void> archiveOldDumps() async {
    final box = Hive.box<BrainDump>(brainDumpBox);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final dumps = box.values.toList();
    for (int i = 0; i < dumps.length; i++) {
      if (dumps[i].createdAt.isBefore(yesterday) && !dumps[i].isArchived) {
        dumps[i].isArchived = true;
        dumps[i].archivedAt = DateTime.now();
        await box.putAt(i, dumps[i]);
      }
    }
  }

  // ─── EXPORT DATA ───────────────────────────────────────────────────────────

  Map<String, dynamic> exportAllData() {
    return {
      'fourThings': getFourThings()?.toJson(),
      'distractingApps': getDistractingApps().map((a) => a.toJson()).toList(),
      'userStats': getWeeklyStats().map((s) => s.toJson()).toList(),
      'settings': getSettings().toJson(),
      'humanBuffers': getHumanBuffers().map((b) => b.toJson()).toList(),
      'brainDumps': getBrainDumps(includeArchived: true).map((b) => b.toJson()).toList(),
    };
  }
}
