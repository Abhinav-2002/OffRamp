import 'package:flutter/material.dart';
import 'theme.dart';

// ─── DEFAULT TASK DATA ───────────────────────────────────────────
class TaskItem {
  final int id;
  final String icon;
  final String text;
  bool done;

  TaskItem({required this.id, required this.icon, required this.text, this.done = false});
}

final List<TaskItem> kDefaultTasks = [
  TaskItem(id: 1, icon: '👤', text: 'Text mom', done: true),
  TaskItem(id: 2, icon: '📖', text: 'Read chapter 4', done: false),
  TaskItem(id: 3, icon: '🍵', text: 'Make tea', done: false),
  TaskItem(id: 4, icon: '✅', text: 'Lab report (50 min)', done: false),
];

// ─── DISTRACTING APPS ───────────────────────────────────────────
class DistractingApp {
  final String icon;
  final String name;

  const DistractingApp({required this.icon, required this.name});
}

const List<DistractingApp> kApps = [
  DistractingApp(icon: '📸', name: 'Instagram'),
  DistractingApp(icon: '📱', name: 'TikTok'),
  DistractingApp(icon: '▶️', name: 'YouTube'),
  DistractingApp(icon: '𝕏', name: 'Twitter / X'),
  DistractingApp(icon: '👽', name: 'Reddit'),
  DistractingApp(icon: '👤', name: 'Facebook'),
];

// ─── DEFAULT LOOPS ──────────────────────────────────────────────
class LoopItem {
  final int id;
  final String text;
  final Color color;
  bool parked;

  LoopItem({required this.id, required this.text, required this.color, this.parked = false});
}

List<LoopItem> kDefaultLoops = [
  LoopItem(id: 0, text: 'Worried about presentation tomorrow', color: AppColors.coral),
  LoopItem(id: 1, text: 'Need to email professor', color: AppColors.warning),
  LoopItem(id: 2, text: 'Forgot to buy groceries', color: AppColors.info),
];

// ─── STATS ──────────────────────────────────────────────────────
class StatData {
  final String label;
  final int value;
  final int max;
  final String message;

  const StatData({required this.label, required this.value, required this.max, required this.message});
}

const List<StatData> kDefaultStats = [
  StatData(label: 'Urges Resisted', value: 23, max: 30, message: "You're building control"),
  StatData(label: 'Win Tasks Completed', value: 5, max: 7, message: "That's 4+ hours reclaimed"),
  StatData(label: 'Human Connections', value: 3, max: 7, message: 'Mood after calls: 85% positive'),
  StatData(label: 'Sleep Mode Activated', value: 6, max: 7, message: 'Average sleep time: 10:15 PM'),
];

// ─── HUMAN BUFFER CONTACTS ──────────────────────────────────────
class BufferContact {
  final String name;
  final String method;
  final String time;

  const BufferContact({required this.name, required this.method, required this.time});
}

const List<BufferContact> kDefaultContacts = [
  BufferContact(name: 'Mom', method: 'Call', time: '5:30 PM'),
  BufferContact(name: 'Alex (Best Friend)', method: 'Text', time: '7:00 PM'),
];

// ─── SLEEP SOUNDS ───────────────────────────────────────────────
enum SleepSound { brown, rain, silence }

const Map<SleepSound, String> kSleepSoundLabels = {
  SleepSound.brown: '🤎 Brown',
  SleepSound.rain: '🌧️ Rain',
  SleepSound.silence: '🤫 Silence',
};

// ─── ONBOARDING PERMISSIONS ─────────────────────────────────────
class PermissionStep {
  final String title;
  final String description;

  const PermissionStep({required this.title, required this.description});
}

const List<PermissionStep> kPermissionSteps = [
  PermissionStep(
    title: 'Usage Access',
    description: 'Detect when you open distracting apps. Stays on your device only.',
  ),
  PermissionStep(
    title: 'Display Over Apps',
    description: 'Required for the 30-second pause screen.',
  ),
  PermissionStep(
    title: 'Notifications',
    description: 'For human buffer reminders & win celebrations.',
  ),
];
