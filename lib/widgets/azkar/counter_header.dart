import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/azkar/chip.dart';

class CounterHeader extends StatelessWidget {
  final int index;
  final int current;
  final int total;
  final int completed;

  const CounterHeader({
    Key? key,
    required this.index,
    required this.current,
    required this.total,
    required this.completed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomChip(
          icon: Icons.repeat,
          label: Globals.languageState!
              ? 'Repeat $current/$total times'
              : 'كرر ${Globals.toArabicNumber(current.toString())}/${Globals.toArabicNumber(total.toString())} مرة',
        ),
        CustomChip(
          label: Globals.languageState!
              ? 'Completed: $completed ${completed == 1 ? 'time' : 'times'}'
              : 'تمت: ${Globals.toArabicNumber(completed.toString())} ${completed == 1 ? 'مرة' : 'مرات'}',
        ),
      ],
    );
  }
}
