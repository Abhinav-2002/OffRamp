import 'package:hive/hive.dart';

part 'distracting_app.g.dart';

// ═════════════════════════════════════════════════════════════════════════════
// DISTRACTING APP MODEL - Apps that trigger friction overlay
// ═════════════════════════════════════════════════════════════════════════════

@HiveType(typeId: 2)
class DistractingApp extends HiveObject {
  @HiveField(0)
  String packageName;

  @HiveField(1)
  String appName;

  @HiveField(2)
  bool isSelected;

  @HiveField(3)
  DateTime addedAt;

  @HiveField(4)
  int urgeCount;

  @HiveField(5)
  int resistedCount;

  DistractingApp({
    required this.packageName,
    required this.appName,
    this.isSelected = false,
    DateTime? addedAt,
    this.urgeCount = 0,
    this.resistedCount = 0,
  }) : addedAt = addedAt ?? DateTime.now();

  double get resistanceRate => urgeCount > 0 ? resistedCount / urgeCount : 0.0;

  void recordUrge({bool resisted = false}) {
    urgeCount++;
    if (resisted) resistedCount++;
    save();
  }

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'appName': appName,
        'isSelected': isSelected,
        'addedAt': addedAt.toIso8601String(),
        'urgeCount': urgeCount,
        'resistedCount': resistedCount,
      };

  static List<DistractingApp> getDefaultApps() {
    return [
      DistractingApp(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        isSelected: true,
      ),
      DistractingApp(
        packageName: 'com.zhiliaoapp.musically',
        appName: 'TikTok',
        isSelected: true,
      ),
      DistractingApp(
        packageName: 'com.google.android.youtube',
        appName: 'YouTube',
        isSelected: true,
      ),
      DistractingApp(
        packageName: 'com.twitter.android',
        appName: 'Twitter/X',
        isSelected: false,
      ),
      DistractingApp(
        packageName: 'com.reddit.frontpage',
        appName: 'Reddit',
        isSelected: false,
      ),
      DistractingApp(
        packageName: 'com.facebook.katana',
        appName: 'Facebook',
        isSelected: false,
      ),
      DistractingApp(
        packageName: 'com.snapchat.android',
        appName: 'Snapchat',
        isSelected: false,
      ),
    ];
  }
}
