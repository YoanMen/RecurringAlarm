import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recurring_alarm/core/common/widgets/confirmation_pop_up.dart';
import 'package:recurring_alarm/core/common/widgets/material_button.dart';
import 'package:recurring_alarm/presentation/reminder/widgets/error_validator_text.dart';
import 'package:recurring_alarm/presentation/reminder/widgets/monthly_widget.dart';
import 'package:recurring_alarm/presentation/reminder/widgets/reminder_type_selection.dart';
import 'package:recurring_alarm/core/common/widgets/text_form_field_material.dart';
import 'package:recurring_alarm/presentation/reminder/widgets/select_date.dart';
import 'package:recurring_alarm/presentation/reminder/widgets/select_time.dart';
import 'package:recurring_alarm/presentation/reminder/widgets/weekly_widget.dart';
import 'package:recurring_alarm/core/constant.dart';
import 'package:recurring_alarm/presentation/reminder/viewmodels/reminder_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future editReminderBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    isDismissible: true,
    enableDrag: true,
    isScrollControlled: true,
    useSafeArea: true,
    context: context,
    builder: (BuildContext context) {
      return Consumer(
        builder: (context, ref, child) {
          final reminderViewModelWatch = ref.watch(reminderViewModel);
          final reminderViewModelRead = ref.read(reminderViewModel.notifier);

          return SingleChildScrollView(
            child: Container(
              height: 700,
              width: double.infinity,
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: kDefaultPadding),
              child: Column(
                children: [
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)!.editReminder,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => confirmatiomPopUp(
                            context: context,
                            ref: ref,
                            confirmButton: () {
                              _closeEdit(context);
                              ref
                                  .read(reminderViewModel.notifier)
                                  .removeReminder(
                                      ref
                                          .watch(reminderViewModel)
                                          .reminderOnEdit!,
                                      context);
                              Navigator.of(context).pop();
                            },
                            content: "Do you want delete this reminder ?",
                            title: "Delete Reminder"),
                        icon: const Icon(Icons.delete),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: kDefaultPadding,
                  ),
                  if (reminderViewModelWatch.validatorErrorText.isNotEmpty)
                    const ErrorValidatorText(),
                  TextFormFieldMaterial(
                    onChanged: (value) =>
                        reminderViewModelRead.updateText(value!),
                    labelText: AppLocalizations.of(context)!.task,
                    initialValue: reminderViewModelWatch.description,
                    maxLength: 80,
                  ),
                  const SizedBox(
                    height: kDefaultPadding,
                  ),
                  const ReminderTypeSelection(),
                  switch (ref.watch(reminderViewModel).reminderType) {
                    ReminderType.daily => const SizedBox.shrink(),
                    ReminderType.weekly => const WeeklyWidget(),
                    ReminderType.monthly => const MonthlyWidget(),
                  },
                  Expanded(
                    child: Column(children: [
                      const SizedBox(
                        height: kDefaultPadding,
                      ),
                      const SelectDate(),
                      const SizedBox(
                        height: kDefaultPadding,
                      ),
                      const SelectTime(),
                      const SizedBox(
                        height: kDefaultPadding,
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: ButtonMaterial.blue(
                                child: Text(AppLocalizations.of(context)!.save),
                                onPressed: () => reminderViewModelRead
                                    .checkIfvalidate(context),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            SizedBox(
                              width: 100,
                              child: ButtonMaterial.transparent(
                                child:
                                    Text(AppLocalizations.of(context)!.cancel),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: kDefaultPadding,
                      ),
                    ]),
                  )
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void _closeEdit(BuildContext context) {
  Navigator.of(context).pop();
}
