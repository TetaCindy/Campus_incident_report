import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'category_selector.dart';
import 'status_chip.dart';

class IncidentThumb extends StatelessWidget {
  final Incident incident;
  final double size;
  const IncidentThumb(this.incident, {super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      color: AppColors.primaryLight,
      child: Icon(categoryIcon(incident.category), color: AppColors.primary),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: incident.photoUrl == null
            ? placeholder
            : Image.network(incident.photoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => placeholder),
      ),
    );
  }
}

class IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onTap;
  const IncidentCard({super.key, required this.incident, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: cardDecoration(),
        child: Row(children: [
          IncidentThumb(incident),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(incident.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(incident.location, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.schedule, size: 13, color: AppColors.muted),
                const SizedBox(width: 4),
                Text(timeAgo(incident.createdAt), style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            StatusChip(incident.status),
            const SizedBox(height: 10),
            const Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
          ]),
        ]),
      ),
    );
  }
}
