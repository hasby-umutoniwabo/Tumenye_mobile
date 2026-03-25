import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                          color: AppColors.accentPurple, shape: BoxShape.circle),
                      child: const Icon(Icons.person, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Muraho, Teacher',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary)),
                          Text('Admin Dashboard',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const Icon(Icons.notifications_outlined, size: 24),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(child: _Stat('Total Students', '412', '+10%', AppColors.accentBlue)),
                    SizedBox(width: 12),
                    Expanded(child: _Stat('Active Lessons', '24', null, AppColors.primary)),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Quick Assign Lesson'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Class Groups',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontSize: 16)),
                        const Text('View All',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: const [
                        _ClassCard('Grade 8 - Kigali', '36 Students', 88, AppColors.primary),
                        _ClassCard('Grade 10 - Musanze', '36 Students', 64, AppColors.accentOrange),
                        _ClassCard('Grade 9 - Huye', '40 Students', 92, AppColors.accentBlue),
                        _ClassCard('Grade 12 - Rubavu', '31 Students', 78, AppColors.accentPurple),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Activity',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontSize: 16)),
                    const SizedBox(height: 12),
                    _actRow('Jean Bosco earned Silver Badge', '3 hrs ago',
                        Icons.emoji_events, AppColors.accentYellow),
                    _actRow('Divine M. completed Module 4 Quiz', '5 hrs ago',
                        Icons.check_circle_outline, AppColors.primary),
                    _actRow('New Student joined Grade 9 - Huye', '5 hrs ago',
                        Icons.person_add_outlined, AppColors.accentBlue),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border))),
        child: const SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBtn(Icons.home, 'Home', true),
                _NavBtn(Icons.menu_book_outlined, 'Curriculum', false),
                _NavBtn(Icons.people_outline, 'Students', false),
                _NavBtn(Icons.settings_outlined, 'Settings', false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _actRow(String text, String time, IconData icon, Color color) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              Text(time,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  final String label, value;
  final String? change;
  final Color color;
  const _Stat(this.label, this.value, this.change, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              if (change != null) ...[
                const SizedBox(width: 6),
                Text(change!,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white70)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final String name, sub;
  final int score;
  final Color color;
  const _ClassCard(this.name, this.sub, this.score, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 5,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
                Text('$score%',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ],
            ),
          ),
          const Spacer(),
          Text(name,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(sub,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _NavBtn(this.icon, this.label, this.active);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon,
            color: active ? AppColors.accentBlue : AppColors.textHint,
            size: 22),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: active ? AppColors.accentBlue : AppColors.textHint,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.w400)),
      ],
    );
  }
}