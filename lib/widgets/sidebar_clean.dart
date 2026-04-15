import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.currentSection,
    required this.onSelect,
  });

  final AppSection currentSection;
  final ValueChanged<AppSection> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = [
      (AppSection.home, '首頁', Icons.home_rounded),
      (AppSection.entries, '生活紀錄', Icons.menu_book_rounded),
      (AppSection.goals, '目標', Icons.flag_rounded),
      (AppSection.review, '回顧', Icons.auto_awesome_rounded),
      (AppSection.settings, '設定', Icons.tune_rounded),
    ];

    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF0F5), Color(0xFFEAF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            '暖暖生活手帳',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppTheme.cocoa,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '把日常、照片與小目標，都收藏成溫柔的陪伴。',
            style: TextStyle(height: 1.5, color: Color(0xFF7D6B64)),
          ),
          const SizedBox(height: 28),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SidebarButton(
                label: item.$2,
                icon: item.$3,
                selected: currentSection == item.$1,
                onTap: () => onSelect(item.$1),
              ),
            ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              children: [
                Text('🌷', style: TextStyle(fontSize: 20)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '今天也別忘了留一點時間給自己。',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.cocoa,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  const _SidebarButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: selected ? AppTheme.cocoa : const Color(0xFF8E7A73)),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppTheme.cocoa : const Color(0xFF8E7A73),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
