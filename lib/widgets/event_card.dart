import 'package:flutter/material.dart';
import '../utils/time_utils.dart';
import '../utils/event_utils.dart';
import '../screens/calendar_page.dart';
import '../screens/app_strings.dart';

class EventCard extends StatelessWidget {
  final MyEvent ev;
  final bool isEnglish;

  const EventCard({super.key, required this.ev, this.isEnglish = false});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(isEnglish);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: ev.color.withOpacity(0.5), width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ev.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            EventUtils.iconFromCategory(ev.category),
            color: ev.color,
            size: 28,
          ),
        ),
        title: Text(
          ev.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                '${TimeUtils.fmtTOD(ev.startTime)} - ${TimeUtils.fmtTOD(ev.endTime)}',
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        trailing: Text(
          s.categoryDisplay(ev.category),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ),
    );
  }
}