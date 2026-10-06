import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_card.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CustomCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              borderRadius: 16,
              child: Row(
                children: [
                  _buildRankBadge(context, index + 1),
                  const SizedBox(width: 16),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).dividerColor,
                    child: Icon(LucideIcons.user, size: 20, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Productivity Score',
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${2500 - (index * 150)} pts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRankBadge(BuildContext context, int rank) {
    Color? badgeColor;
    if (rank == 1) badgeColor = Colors.amber;
    if (rank == 2) badgeColor = Colors.grey[400];
    if (rank == 3) badgeColor = Colors.brown[400];

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: badgeColor ?? Colors.transparent,
        shape: BoxShape.circle,
        border: badgeColor == null ? Border.all(color: Theme.of(context).dividerColor) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        rank.toString(),
        style: TextStyle(
          color: badgeColor != null ? Colors.white : Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

