import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/widget_sync_service.dart';

/// Central app state managed via Provider / ChangeNotifier.
class AppState extends ChangeNotifier {
  // ─── SCREEN NAVIGATION ───────────────────────────────────────
  String _screen = 'welcome'; // welcome, permissions, voice, apps, ready, home, loop, sleep, morning
  String get screen => _screen;

  String _tab = 'home'; // home, stats, settings
  String get tab => _tab;

  String? _overlay; // null, friction, focus, win
  String? get overlay => _overlay;

  // ─── TASKS ───────────────────────────────────────────────────
  List<TaskItem> _tasks = [];
  List<TaskItem> get tasks => _tasks;

  // ─── APP SELECTION ───────────────────────────────────────────
  List<int> _selectedApps = [0, 1, 2, 3];
  List<int> get selectedApps => _selectedApps;

  // ─── LOOPS ───────────────────────────────────────────────────
  List<LoopItem> _loops = [];
  List<LoopItem> get loops => _loops;

  // ─── MOOD ────────────────────────────────────────────────────
  int? _mood;
  int? get mood => _mood;

  // ─── SLEEP SOUND ─────────────────────────────────────────────
  SleepSound _sleepSound = SleepSound.brown;
  SleepSound get sleepSound => _sleepSound;

  // ─── ONBOARDING COMPLETE ─────────────────────────────────────
  bool _onboardingComplete = false;
  bool get onboardingComplete => _onboardingComplete;

  AppState() {
    _tasks = kDefaultTasks.map((t) => TaskItem(
      id: t.id,
      icon: t.icon,
      text: t.text,
      done: t.done,
    )).toList();

    _loops = kDefaultLoops.map((l) => LoopItem(
      id: l.id,
      text: l.text,
      color: l.color,
    )).toList();

    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    if (_onboardingComplete) {
      _screen = 'home';
    }
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    notifyListeners();
  }

  // ─── NAVIGATION ──────────────────────────────────────────────
  void goTo(String screen) {
    _screen = screen;
    if (screen == 'home') {
      _tab = 'home';
      _overlay = null;
    }
    notifyListeners();
  }

  void setTab(String tab) {
    _tab = tab;
    notifyListeners();
  }

  void setOverlay(String? overlay) {
    _overlay = overlay;
    notifyListeners();
  }

  // ─── TASK ACTIONS ────────────────────────────────────────────
  void toggleTask(int id) {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      _tasks[idx].done = !_tasks[idx].done;
      _syncWidget();
      notifyListeners();
    }
  }

  void setTasks(List<TaskItem> tasks) {
    _tasks = tasks;
    _syncWidget();
    notifyListeners();
  }

  void completeWinTask() {
    final idx = _tasks.indexWhere((t) => t.id == 4);
    if (idx >= 0) {
      _tasks[idx].done = true;
      _syncWidget();
      notifyListeners();
    }
  }

  void _syncWidget() {
    WidgetSyncService.updateWidgetData(
      tasks: _tasks.map((t) => {
        'text': t.text,
        'icon': t.icon,
        'done': t.done,
      }).toList(),
      completed: tasksDone,
      total: tasksTotal,
    );
  }

  int get tasksDone => _tasks.where((t) => t.done).length;
  int get tasksTotal => _tasks.length;
  double get taskProgress => tasksTotal == 0 ? 0 : tasksDone / tasksTotal;

  // ─── APP SELECTION ───────────────────────────────────────────
  void toggleApp(int index) {
    if (_selectedApps.contains(index)) {
      _selectedApps.remove(index);
    } else {
      _selectedApps.add(index);
    }
    notifyListeners();
  }

  // ─── LOOPS ───────────────────────────────────────────────────
  void toggleLoop(int id) {
    final idx = _loops.indexWhere((l) => l.id == id);
    if (idx >= 0) {
      _loops[idx].parked = !_loops[idx].parked;
      notifyListeners();
    }
  }

  bool get allLoopsParked => _loops.every((l) => l.parked);

  // ─── MOOD ────────────────────────────────────────────────────
  void setMood(int value) {
    _mood = value;
    notifyListeners();
  }

  // ─── SLEEP SOUND ─────────────────────────────────────────────
  void setSleepSound(SleepSound sound) {
    _sleepSound = sound;
    notifyListeners();
  }
}
