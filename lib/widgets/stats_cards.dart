import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.title, required this.value, this.subtitle, this.icon, this.color});
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = color ?? scheme.primaryContainer;
    final onC = scheme.onPrimaryContainer;
    return Container(
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (icon != null)
            Container(
              decoration: BoxDecoration(color: onC.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: onC),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: onC.withValues(alpha: .9))),
              const SizedBox(height: 6),
              Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: onC, fontWeight: FontWeight.w700)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: onC.withValues(alpha: .8))),
              ]
            ]),
          ),
        ],
      ),
    );
  }
}


