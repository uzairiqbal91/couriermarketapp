import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeFormField extends FormField<DateTime> {
  DateTimeFormField({
    FormFieldSetter<DateTime>? onSaved,
    FormFieldValidator<DateTime>? validator,
    DateTime? initialValue,
    required DateTime firstDate,
    required DateTime lastDate,
    String Function(DateTime? value)? formatter,
    InputDecoration decoration = const InputDecoration(),
    bool autovalidate = false,
    bool enabled = true,
  }) : super(
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          autovalidate: autovalidate,
          enabled: enabled,
          builder: (state) {
            final effectiveDecoration =
                decoration.applyDefaults(Theme.of(state.context).inputDecorationTheme).copyWith(enabled: enabled);

            final effectiveFormatter =
                formatter != null ? formatter : DateFormat.yMd().add_jm().format as String Function(DateTime?);

            return GestureDetector(
              onTap: !enabled
                  ? null
                  : () async {
                      final now = DateTime.now();
                      final date = await showDatePicker(
                        context: state.context,
                        initialDate: initialValue ?? now,
                        firstDate: firstDate,
                        lastDate: lastDate,
                      );
                      if (date == null) return;

                      final time = await showTimePicker(
                        context: state.context,
                        initialTime: TimeOfDay.fromDateTime(now),
                      );
                      if (time == null) return;

                      state.didChange(DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      ));
                      state.save();
                    },
              child: DefaultTextStyle.merge(
                style: Theme.of(state.context).textTheme.subtitle1!.copyWith(
                      color: enabled ? null : Theme.of(state.context).hintColor,
                    ),
                child: InputDecorator(
                  isEmpty: state.value == null,
                  decoration: effectiveDecoration,
                  child: state.value == null ? null : Text("${effectiveFormatter(state.value)}"),
                ),
              ),
            );
          },
        );
}
