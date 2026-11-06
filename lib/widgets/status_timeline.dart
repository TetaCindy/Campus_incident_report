import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

/// Submitted -> In Progress -> Resolved, with the time each step was reached.
class StatusTimeline extends StatelessWidget {
  final Incident incident;
  const StatusTimeline(this.incident, {super.key});

  @override
  Widget build(BuildContext context) {
    final idx = incident.stepIndex;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (var i = 0; i < statuses.length; i++) ...[
        if (i > 0)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Container(height: 2, color: i <= idx ? AppColors.primary : AppColors.border),
            ),
          ),
        _Step(
          label: statuses[i],
          time: i <= idx ? incident.statusTime(statuses[i]) : null,
          state: i < idx || (i == idx && statuses[i] == 'Resolved')
              ? _StepState.done
              : i == idx
                  ? _StepState.current
                  : _StepState.upcoming,
        ),
      ],
    ]);
  }
}

enum _StepState { done, current, upcoming }

class _Step extends StatelessWidget {
  final String label;
  final DateTime? time;
  final _StepState state;
  const _Step({required this.label, required this.time, required this.state});

  @override
  Widget build(BuildContext context) {
    final active = state != _StepState.upcoming;
    return SizedBox(
      width: 78,
      child: Column(children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.primary : Colors.white,
            border: Border.all(color: active ? AppColors.primary : AppColors.border, width: 2),
          ),
          child: Icon(
            state == _StepState.done ? Icons.check : state == _StepState.current ? Icons.more_horiz : Icons.circle,
            size: state == _StepState.upcoming ? 8 : 16,
            color: active ? Colors.white : AppColors.border,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? AppColors.primary : AppColors.muted)),
        Text(time == null ? '—' : shortStamp(time!),
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
      ]),
    );
  }
}
