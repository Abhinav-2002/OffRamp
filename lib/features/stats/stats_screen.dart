import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 4, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Week', style: AppText.displaySm),
          const SizedBox(height: 4),
          Text('No shame. Only growth.', style: AppText.caption),
          const SizedBox(height: 20),
          // Stat bars
          ...kDefaultStats.map((s) {
            final pct = s.value / s.max;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: AppDecorations.card,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.label,
                        style: AppText.body.copyWith(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${s.value}/${s.max}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.sage),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '"${s.message}"',
                    style: AppText.caption.copyWith(
                      color: AppColors.sage,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          }),
          // This week vs last week
          Container(
            decoration: AppDecorations.card,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('THIS WEEK VS LAST WEEK', style: AppText.cardTitle),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text('↓', style: TextStyle(color: AppColors.sage, fontSize: 16)),
                    const SizedBox(width: 10),
                    Text('40% less evening screen time', style: AppText.body.copyWith(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('↑', style: TextStyle(color: AppColors.sage, fontSize: 16)),
                    const SizedBox(width: 10),
                    Text('2 more hours of sleep', style: AppText.body.copyWith(fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
