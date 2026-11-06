import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../theme/app_theme.dart';

IconData categoryIcon(String c) => switch (c) {
      'Facilities' => Icons.apartment,
      'Water' => Icons.water_drop_outlined,
      'Electricity' => Icons.bolt,
      'Furniture' => Icons.chair_outlined,
      'Safety' => Icons.shield_outlined,
      'Sanitation' => Icons.delete_outline,
      _ => Icons.report_problem_outlined,
    };

class CategorySelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const CategorySelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: categories.map((c) {
        final on = c == selected;
        return GestureDetector(
          onTap: () => onChanged(c),
          child: Container(
            decoration: BoxDecoration(
              color: on ? AppColors.primary : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(categoryIcon(c), color: on ? Colors.white : AppColors.primary),
              const SizedBox(height: 4),
              Text(c, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: on ? Colors.white : AppColors.primary)),
            ]),
          ),
        );
      }).toList(),
    );
  }
}
