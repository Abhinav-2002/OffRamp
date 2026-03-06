import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';

class HumanBufferScreen extends StatefulWidget {
  const HumanBufferScreen({super.key});

  @override
  State<HumanBufferScreen> createState() => _HumanBufferScreenState();
}

class _HumanBufferScreenState extends State<HumanBufferScreen> {
  int? _mood;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 4, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Human Buffer', style: AppText.displaySm),
          const SizedBox(height: 4),
          Text(
            '"Real connection kills stimulus hunger."',
            style: AppText.caption.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: AppPills.sage,
            child: Text(
              '90% urge reduction per user reports',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.sage,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Contact cards
          ...List.generate(kDefaultContacts.length, (i) {
            final c = kDefaultContacts[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: AppDecorations.card,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Contact ${i + 1}: ${c.name}',
                        style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                      OutlinedButton(
                        style: AppButtons.ghostSmall,
                        onPressed: () {},
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '📱 Preferred: ${c.method} · ⏰ Best time: ${c.time}',
                    style: AppText.caption,
                  ),
                ],
              ),
            );
          }),
          // Add contact
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: AppButtons.ghost,
              onPressed: () {},
              child: const Text('+ Add Another Contact'),
            ),
          ),
          const SizedBox(height: 20),
          // Reminder settings
          Container(
            decoration: AppDecorations.card,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('REMINDER SETTINGS', style: AppText.cardTitle),
                const SizedBox(height: 14),
                ...['Notify 30 min before commute', 'Pre-write messages for low-energy days', 'Track mood after connection']
                    .map((s) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.sage,
                          ),
                          child: const Center(
                            child: Icon(Icons.check, color: Colors.white, size: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(s, style: AppText.body.copyWith(fontSize: 13)),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Mood check
          Container(
            decoration: AppDecorations.card,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('POST-CONNECTION MOOD CHECK', style: AppText.cardTitle),
                const SizedBox(height: 8),
                Text(
                  'How do you feel after talking to someone?',
                  style: AppText.caption,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final emojis = ['😞', '😐', '😊', '🤩'];
                    return GestureDetector(
                      onTap: () => setState(() => _mood = i),
                      child: AnimatedScale(
                        scale: _mood == i ? 1.3 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            emojis[i],
                            style: TextStyle(
                              fontSize: 32,
                              shadows: _mood == i
                                  ? [
                                      Shadow(
                                        color: AppColors.sage.withValues(alpha: 0.6),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                if (_mood != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Center(
                      child: Text(
                        'Recorded ✓',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.sage,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
