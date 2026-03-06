import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/app_state.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final List<bool> _done = [false, false, false];

  void _toggleDone(int i) {
    setState(() {
      _done[i] = !_done[i];
    });
  }

  bool get _allDone => _done.every((d) => d);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Setup', style: AppText.displaySm),
          const SizedBox(height: 6),
          Text('3 permissions needed. That\'s it.', style: AppText.caption),
          const SizedBox(height: 24),
          // Progress dots
          Row(
            children: List.generate(3, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 6),
                width: _done[i] ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _done[i] ? AppColors.sage : AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          // Permission steps
          ...List.generate(3, (i) {
            return GestureDetector(
              onTap: () => _toggleDone(i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: const Cubic(0.34, 1.56, 0.64, 1),
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(top: 2, right: 14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _done[i] ? AppColors.sage : AppColors.coral,
                      ),
                      child: Center(
                        child: _done[i]
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kPermissionSteps[i].title,
                            style: AppText.title.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(kPermissionSteps[i].description, style: AppText.caption),
                          if (!_done[i]) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Tap to grant →',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.coral,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: AnimatedOpacity(
              opacity: _allDone ? 1.0 : 0.45,
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton(
                style: AppButtons.coral,
                onPressed: _allDone
                    ? () => context.read<AppState>().goTo('voice')
                    : null,
                child: Text(
                  _allDone
                      ? 'All Done ✓'
                      : '${_done.where((d) => d).length}/3 Granted',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
