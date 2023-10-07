import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:recurring_alarm/core/common/formatting_utils.dart';
import 'package:recurring_alarm/domain/entities/reminder.dart';
import 'package:recurring_alarm/localization/string_hardcoded.dart';
import 'package:recurring_alarm/presentation/reminder/viewmodels/reminder_view_model.dart';
import 'package:recurring_alarm/theme/palette.dart';

class ReminderCard extends ConsumerWidget {
  const ReminderCard({Key? key, required this.reminder}) : super(key: key);

  final Reminder reminder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => ref
                        .read(reminderViewModel.notifier)
                        .openEditReminder(context: context, reminder: reminder),
                    child: Text(
                      reminder.time.format(context),
                      style: const TextStyle(
                          fontSize: 36, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => ref
                        .read(reminderViewModel.notifier)
                        .openEditReminder(context: context, reminder: reminder),
                    child: Text(
                      "Tap to edit".hardcoded,
                      style: TextStyle(
                          color: Palette.primaryColor.withOpacity(0.80)),
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat.MMMEd().format(reminder.remindersDate![0]),
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.40), fontSize: 14)),
                  if (reminder.days.length > 1)
                    Text(
                      _shortDayString(reminder.days),
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.40), fontSize: 14),
                    ),
                ],
              ),
              const SizedBox(
                height: 6,
              ),
              Text(
                reminder.description,
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lenghtBettewenReminding(reminder),
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.40),
                              fontSize: 14)),
                    ],
                  ),
                  const Spacer(),
                  Switch.adaptive(
                    value: reminder.reminderEnable,
                    onChanged: (value) => ref
                        .read(reminderViewModel.notifier)
                        .toggleSelected(reminder), // toogle activate
                  ),
                ],
              ),
              const SizedBox(
                height: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dayToString(int day) {
    switch (day) {
      case 1:
        return "monday".hardcoded;
      case 2:
        return "tuesday".hardcoded;
      case 3:
        return "wedesday".hardcoded;
      case 4:
        return "thuesday".hardcoded;
      case 5:
        return "friday".hardcoded;
      case 6:
        return "saturday".hardcoded;
      case 7:
        return "sunday".hardcoded;
      default:
        return ""; // Jour inconnu
    }
  }

  String _shortDayString(List<int> daysSelected) {
    if (daysSelected.length == 1) {
      return "";
    } else if (daysSelected.length == 2) {
      daysSelected.sort();
      return _dayToString(daysSelected[1]);
    }

    daysSelected.sort();

    List<String> dayNames = daysSelected.map((day) {
      if (day == 0) {
        return "";
      }
      return _dayToString(day).substring(0, 3);
    }).toList();

    return dayNames.join(", ").substring(1).trim();
  }
}
