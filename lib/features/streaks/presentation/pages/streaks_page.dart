import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_card.dart';
import 'package:one_percent_man/features/premium/presentation/pages/premium_subscription_page.dart';
import 'package:one_percent_man/features/premium/presentation/providers/premium_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/security_provider.dart';

// ─────────────────────────────────────────────
// Data models (local, static for now)
// ─────────────────────────────────────────────
class _Streak {
  final String title;
  final int days;
  final int record;
  final IconData icon;
  final Color color;
  const _Streak(this.title, this.days, this.record, this.icon, this.color);
}

class _Participant {
  final String name;
  final int score;
  final int streak;
  final String initials;
  final Color avatarColor;
  const _Participant(this.name, this.score, this.streak, this.initials, this.avatarColor);
}

// ─────────────────────────────────────────────
// Profile Page — 3 tab sections
// ─────────────────────────────────────────────
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverHeader(context, innerBoxIsScrolled, ref),
          ],
          body: TabBarView(
            children: [
              _ProfileTab(),
              _LogrosTab(),
              _ClasificacionTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context, bool innerBoxIsScrolled, WidgetRef ref) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      floating: false,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      forceElevated: innerBoxIsScrolled,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _buildProfileHeader(context, ref),
      ),
      bottom: TabBar(
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
        indicatorColor: Theme.of(context).colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 2.5,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Perfil'),
          Tab(text: 'Logros'),
          Tab(text: 'Clasificación'),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).colorScheme.primary, const Color(0xFF818CF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'JD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Consumer(
                  builder: (context, ref, child) {
                    final isPremium = ref.watch(isPremiumProvider);
                    return Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isPremium ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: isPremium 
                        ? const Icon(LucideIcons.crown, size: 12, color: Colors.white)
                        : null,
                    );
                  }
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'John Doe',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.displayLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '🔥 1% Better Every Day',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────
// TAB 1 — Perfil
// ─────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('profile_tab'),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        // Premium CTA
        const _PremiumCTACard(),
        const SizedBox(height: 20),

        // Stats row
        Row(
          children: [
            const _StatCard(label: 'Día actual', value: '42', icon: LucideIcons.flame, color: Colors.orange),
            const SizedBox(width: 12),
            _StatCard(label: 'Metas activas', value: '5', icon: LucideIcons.target, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const _StatCard(label: 'Tareas hoy', value: '4/6', icon: LucideIcons.checkCircle, color: Color(0xFF10B981)),
          ],
        ),
        const SizedBox(height: 20),

        // User info card
        CustomCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.user, size: 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text('Información personal',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              const _InfoRow(icon: LucideIcons.mail, label: 'Correo', value: 'john@lifeos.app'),
              const SizedBox(height: 12),
              const _InfoRow(icon: LucideIcons.mapPin, label: 'País', value: 'Colombia 🇨🇴'),
              const SizedBox(height: 12),
              const _InfoRow(icon: LucideIcons.calendar, label: 'Miembro desde', value: 'Enero 2026'),
              const SizedBox(height: 12),
              const _InfoRow(icon: LucideIcons.star, label: 'Nivel', value: 'Disciplinado ⭐⭐⭐'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Theme Settings
        Consumer(
          builder: (context, ref, child) {
            final themeMode = ref.watch(themeProvider);
            final isDark = themeMode == ThemeMode.dark;

            return CustomCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.palette, size: 18, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('Ajustes de tema',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isDark ? LucideIcons.moon : LucideIcons.sun,
                            size: 20,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isDark ? 'Modo Oscuro' : 'Modo Claro',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: isDark,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (value) {
                          ref.read(themeProvider.notifier).toggleTheme(value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Security Settings
        Consumer(
          builder: (context, ref, child) {
            final security = ref.watch(securityProvider);

            return CustomCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.shieldCheck, size: 18, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('Seguridad',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.lock,
                            size: 20,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Protección por PIN',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: security.isPinEnabled,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (value) async {
                          if (value) {
                            // Show PIN setup dialog
                            _showPinSetup(context, ref);
                          } else {
                            // Show disable confirmation
                            _showDisablePin(context, ref);
                          }
                        },
                      ),
                    ],
                  ),
                  if (security.isPinEnabled) ...[
                    const Divider(height: 32),
                    InkWell(
                      onTap: () => _showPinSetup(context, ref),
                      child: Row(
                        children: [
                          Icon(LucideIcons.key, size: 20, color: Theme.of(context).textTheme.bodyMedium?.color),
                          const SizedBox(width: 12),
                          const Text('Cambiar PIN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          const Spacer(),
                          const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Protege tus metas y finanzas con un código de seguridad.',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Weekly activity grid
        CustomCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.barChart2, size: 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text('Actividad semanal',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              _buildActivityGrid(context),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Edit profile button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.pencil, size: 16),
            label: const Text('Editar perfil',
                style: TextStyle(fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityGrid(BuildContext context) {
    final weeks = [
      [true, true, false, true, true, false, true],
      [true, false, true, true, true, true, false],
      [false, true, true, false, true, true, true],
      [true, true, true, true, false, true, false],
    ];

    final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: days
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w600)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        ...weeks.map((week) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: week
                    .map((active) => Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 3),
                            child: Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: active
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).dividerColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            )),
        const SizedBox(height: 4),
        Text('Últimas 4 semanas',
            style: TextStyle(
                fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color)),
      ],
    );
  }
}


// ─────────────────────────────────────────────
// TAB 2 — Logros (Streaks)
// ─────────────────────────────────────────────
class _LogrosTab extends StatelessWidget {
  const _LogrosTab();

  static const _streaks = [
    _Streak('Sin videojuegos', 15, 42, LucideIcons.gamepad2, Colors.orange),
    _Streak('Sin fumar', 42, 42, LucideIcons.cigarette, Colors.red),
    _Streak('Meditación', 7, 21, LucideIcons.brain, Color(0xFF6366F1)),
    _Streak('Días de gym', 12, 30, LucideIcons.dumbbell, Color(0xFF10B981)),
    _Streak('Lectura diaria', 5, 14, LucideIcons.bookOpen, Color(0xFF0EA5E9)),
    _Streak('Sin alcohol', 28, 60, LucideIcons.wine, Color(0xFF8B5CF6)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('logros_tab'),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        // Summary header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.flame, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Racha total activa',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    Text('6 logros activos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text('42 días máx.',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            mainAxisExtent: 240,
          ),
          itemCount: _streaks.length,
          itemBuilder: (context, index) =>
              _StreakCard(streak: _streaks[index]),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  final _Streak streak;
  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    final progress = (streak.days / streak.record).clamp(0.0, 1.0);
    final isRecord = streak.days >= streak.record;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRecord
              ? streak.color.withOpacity(0.5)
              : Theme.of(context).dividerColor,
          width: isRecord ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 35,
            lineWidth: 6,
            percent: progress,
            progressColor: streak.color,
            backgroundColor: streak.color.withOpacity(0.1),
            circularStrokeCap: CircularStrokeCap.round,
            center: Icon(streak.icon, color: streak.color, size: 20),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${streak.days}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: streak.color,
                ),
              ),
              const SizedBox(width: 4),
              Text('días',
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            streak.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (isRecord)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: streak.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.trophy, size: 10, color: streak.color),
                  const SizedBox(width: 4),
                  Text('¡Récord!',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: streak.color)),
                ],
              ),
            )
          else
            Text(
              'Récord: ${streak.record}d',
              style: TextStyle(
                  fontSize: 10, color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          const SizedBox(height: 4),
          const Icon(LucideIcons.flame, color: Colors.orange, size: 16),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────
// TAB 3 — Clasificación (Top 10)
// ─────────────────────────────────────────────
class _ClasificacionTab extends StatelessWidget {
  const _ClasificacionTab();

  static const _participants = [
    _Participant('Sebastián M.', 4850, 42, 'SM', Color(0xFF6366F1)),
    _Participant('John Doe', 4200, 35, 'JD', Color(0xFF4F46E5)),
    _Participant('Valentina R.', 3980, 28, 'VR', Color(0xFF10B981)),
    _Participant('Carlos A.', 3750, 21, 'CA', Color(0xFFF59E0B)),
    _Participant('María L.', 3500, 19, 'ML', Color(0xFFEF4444)),
    _Participant('Andrés P.', 3100, 15, 'AP', Color(0xFF8B5CF6)),
    _Participant('Luisa T.', 2900, 12, 'LT', Color(0xFF0EA5E9)),
    _Participant('Diego F.', 2600, 10, 'DF', Color(0xFF64748B)),
    _Participant('Ana S.', 2300, 8, 'AS', Color(0xFFF97316)),
    _Participant('Pedro G.', 2000, 5, 'PG', Color(0xFF14B8A6)),
  ];

  static const int _currentUserIndex = 1; // "John Doe" is index 1

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('clasificacion_tab'),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        // Top 3 podium
        _buildPodium(),
        const SizedBox(height: 20),

        // Resto del top 10 (posiciones 4–10)
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'TABLA COMPLETA',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1),
          ),
        ),
        ..._participants.asMap().entries.map(
              (e) => _LeaderboardRow(
                rank: e.key + 1,
                participant: e.value,
                isCurrentUser: e.key == _currentUserIndex,
              ),
            ),
      ],
    );
  }

  Widget _buildPodium() {
    final top3 = _participants.take(3).toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            '🏆 Top 3 del mes',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd place
              _PodiumItem(
                  rank: 2,
                  participant: top3[1],
                  height: 90,
                  medalColor: Colors.grey.shade300),
              // 1st place
              _PodiumItem(
                  rank: 1,
                  participant: top3[0],
                  height: 120,
                  medalColor: Colors.amber),
              // 3rd place
              _PodiumItem(
                  rank: 3,
                  participant: top3[2],
                  height: 70,
                  medalColor: Colors.brown.shade300),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final int rank;
  final _Participant participant;
  final double height;
  final Color medalColor;

  const _PodiumItem({
    required this.rank,
    required this.participant,
    required this.height,
    required this.medalColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          participant.name.split(' ')[0],
          style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        CircleAvatar(
          radius: rank == 1 ? 26 : 22,
          backgroundColor: participant.avatarColor,
          child: Text(
            participant.initials,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: rank == 1 ? 14 : 12,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 70,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                '${participant.score}',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final _Participant participant;
  final bool isCurrentUser;

  const _LeaderboardRow({
    required this.rank,
    required this.participant,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Theme.of(context).colorScheme.primary.withOpacity(0.07)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
          width: isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          _rankBadge(context, rank),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: participant.avatarColor,
            child: Text(
              participant.initials,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          // Name + streak
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      participant.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isCurrentUser
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).textTheme.displayLarge?.color,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text('Tú',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    const Icon(LucideIcons.flame,
                        size: 11, color: Colors.orange),
                    const SizedBox(width: 3),
                    Text(
                      '${participant.streak} días de racha',
                      style: TextStyle(
                          fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${participant.score}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text('puntos',
                  style: TextStyle(
                      fontSize: 10, color: Theme.of(context).textTheme.bodyMedium?.color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rankBadge(BuildContext context, int rank) {
    Color? bg;
    if (rank == 1) bg = Colors.amber;
    if (rank == 2) bg = Colors.grey.shade400;
    if (rank == 3) bg = Colors.brown.shade400;

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg ?? Colors.transparent,
        shape: BoxShape.circle,
        border: bg == null ? Border.all(color: Theme.of(context).dividerColor) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: bg != null ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color)),
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.displayLarge?.color)),
            ],
          ),
        ),
      ],
    );
  }
}

class _PremiumCTACard extends ConsumerWidget {
  const _PremiumCTACard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    return GestureDetector(
      onTap: () {
        if (!isPremium) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PremiumSubscriptionPage()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPremium 
              ? [const Color(0xFF059669), const Color(0xFF10B981)] // Green for active
              : [const Color(0xFF1E1B4B), const Color(0xFF4338CA)], // Indigo for CTA
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isPremium ? const Color(0xFF10B981) : const Color(0xFF4338CA)).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPremium ? LucideIcons.shieldCheck : LucideIcons.crown, 
                color: Colors.white, 
                size: 28
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPremium ? 'Suscripción Elite Activa' : 'Hazte Elite',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPremium 
                      ? 'Estás aprovechando el 100% de tu potencial.' 
                      : 'Desbloquea el 100% de tu potencial con funciones exclusivas.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (!isPremium) const Icon(LucideIcons.chevronRight, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

// ─── Security Helpers ─────────────────────────

void _showPinSetup(BuildContext context, WidgetRef ref) {
  String pin = '';
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Container(
        padding: EdgeInsets.only(
          top: 12, left: 24, right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Icon(LucideIcons.shieldCheck, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            const Text('Configurar PIN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Ingresa 4 dígitos para proteger tu información.', textAlign: TextAlign.center),
            const SizedBox(height: 32),
            
            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isActive = index < pin.length;
                return Container(
                  width: 16, height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            
            // Number Pad (Simplified for dialog)
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ...List.generate(9, (index) => _buildNum(context, (index + 1).toString(), (v) => setState(() => pin = _addDigit(pin, v, context, ref)))),
                const SizedBox(),
                _buildNum(context, '0', (v) => setState(() => pin = _addDigit(pin, v, context, ref))),
                IconButton(
                  onPressed: () => setState(() => pin = pin.isNotEmpty ? pin.substring(0, pin.length - 1) : ''),
                  icon: const Icon(LucideIcons.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

String _addDigit(String current, String digit, BuildContext context, WidgetRef ref) {
  if (current.length < 4) {
    HapticFeedback.lightImpact();
    final next = current + digit;
    if (next.length == 4) {
      // Save PIN
      ref.read(securityProvider.notifier).setPin(next);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN configurado correctamente')),
      );
    }
    return next;
  }
  return current;
}

Widget _buildNum(BuildContext context, String n, Function(String) onTap) {
  return InkWell(
    onTap: () => onTap(n),
    borderRadius: BorderRadius.circular(16),
    child: Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(n, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    ),
  );
}

void _showDisablePin(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('¿Desactivar protección?'),
      content: const Text('Tus metas y finanzas ya no estarán protegidas por PIN.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            ref.read(securityProvider.notifier).disablePin();
            Navigator.pop(context);
          },
          child: const Text('Desactivar'),
        ),
      ],
    ),
  );
}



