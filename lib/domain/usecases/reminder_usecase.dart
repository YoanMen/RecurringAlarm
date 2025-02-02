import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recurring_alarm/core/failure.dart';
import 'package:recurring_alarm/data/local/local_database.dart';
import 'package:recurring_alarm/domain/entities/notification_reminder.dart';
import 'package:recurring_alarm/domain/entities/reminder.dart';
import 'package:recurring_alarm/services/notification_services.dart';
import 'package:recurring_alarm/domain/reminder_calculator.dart';

final reminderUsecaseProvider = Provider<ReminderUsecase>((ref) {
  final localDdb = ref.watch(reminderlocalDdbProvider);

  return ReminderUsecase(localDdb);
});

class ReminderUsecase {
  final LocalDatabase _reminderlocalDdbProvider;
  ReminderUsecase(this._reminderlocalDdbProvider);

  Future<List<Reminder>> fetchAllReminders() async {
    try {
      final response = await _reminderlocalDdbProvider.fetchAllReminders();

      final reminders = response
          .map((reminderResponse) => reminderResponse.toEntity())
          .toList();
      return reminders;
    } catch (e) {
      throw Failure(message: e.toString());
    }
  }

  Future addReminder(Reminder newReminder) async {
    try {
      List<DateTime> calculatedDates = await calculateNextReminder(newReminder);

      Reminder reminder =
          Reminder.withCalculatedDates(newReminder, calculatedDates);
      final reminderSend = reminder.fromEntity();

      await _reminderlocalDdbProvider.addReminder(reminderSend);
      await manageNotification(reminder);
    } catch (e) {
      throw Failure(message: e.toString());
    }
  }

  Future updateReminder(Reminder newReminder) async {
    try {
      List<DateTime> calculatedDates = await calculateNextReminder(newReminder);
      Reminder reminder =
          Reminder.withCalculatedDates(newReminder, calculatedDates);

      final reminderSend = reminder.fromEntity();
      await _reminderlocalDdbProvider.updateReminder(reminderSend);
      await manageNotification(reminder);
    } catch (e) {
      throw Failure(message: e.toString());
    }
  }

  Future updateToggleReminder(Reminder newReminder) async {
    try {
      List<DateTime> calculatedDates = await calculateNextReminder(newReminder);
      Reminder reminder =
          Reminder.withCalculatedDates(newReminder, calculatedDates);

      final reminderSend = reminder.fromEntity();
      await _reminderlocalDdbProvider.updateReminder(reminderSend);

      await manageNotification(reminder);
    } catch (e) {
      throw Failure(message: e.toString());
    }
  }

  Future manageNotification(Reminder reminder) async {
    // Delete Scheduled Notifications before recreate notifications
    NotificationServices.cancelScheduledNotifications(reminder.uuid.toString());
    for (var element in reminder.remindersDate!) {
      if (reminder.reminderEnable) {
        // CREATE NOTIFICATION
        NotificationServices.scheduleNotification(
            reminder: NotificationReminder(
                uuid: reminder.uuid, task: reminder.description, date: element),
            id: reminder.remindersDate!.indexOf(element));
      }
    }
  }

  Future updatesReminders() async {
    final currentTime = DateTime.now();
    final reminders = await fetchAllReminders();
    final remindersToUpdate = <Reminder>[];
    for (var reminder in reminders) {
      if (reminder.remindersDate != null) {
        bool needUpdate = false;
        for (var i = 0; i < reminder.remindersDate!.length; i++) {
          if (reminder.remindersDate![i].isBefore(currentTime)) {
            needUpdate = true;
            break;
          }
        }

        if (needUpdate) {
          remindersToUpdate.add(reminder);
        }
      }
    }
    for (var reminderToUpdate in remindersToUpdate) {
      await updateReminder(reminderToUpdate);
    }
  }

  Future removeReminder(Reminder reminder) async {
    try {
      final reminderSend = reminder.fromEntity();
      await _reminderlocalDdbProvider.removeReminder(reminderSend);
      await NotificationServices.cancelScheduledNotifications(
          reminder.uuid.toString());
    } catch (e) {
      throw Failure(message: e.toString());
    }
  }

  Future<List<DateTime>> calculNextReminder(
      {required Reminder reminder}) async {
    List<DateTime> nextReminderList = [];

    try {
      nextReminderList = await calculateNextReminder(reminder);
    } catch (e) {
      throw Failure(message: "Error cant get next reminder date");
    }

    return nextReminderList;
  }

  Future deleteAll() async {
    try {
      await _reminderlocalDdbProvider.deleteAll();
    } catch (e) {
      throw Failure(message: "error $e");
    }
  }
}
