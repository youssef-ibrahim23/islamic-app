import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';

class CategoryRow extends StatelessWidget {
  final List<Widget> items;

  const CategoryRow({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Globals.languageState! ? TextDirection.ltr : TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items,
      ),
    );
  }
}
