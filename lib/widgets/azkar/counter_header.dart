import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/azkar/chip.dart';

class CounterHeader {
  static Widget buildCounterHeader(int index, int current, int total, int completed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomChip.buildChip(
          icon: Icons.repeat,
          label: Globals.languageState!
              ? 'Repeat $current/$total times'
              : 'كرر ${Globals.toArabicNumber(current.toString())}/${Globals.toArabicNumber(total.toString())} مرة',
        ),
        CustomChip.buildChip(
          label: Globals.languageState!
              ? 'Completed: $completed ${completed == 1 ? 'time' : 'times'}'
              : 'تمت: ${Globals.toArabicNumber(completed.toString())} ${completed == 1 ? 'مرة' : 'مرات'}',
        ),
      ],
    );
  }
}
