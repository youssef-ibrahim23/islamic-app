import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';

class CategoryRow {
  static Widget buildCategoryRow(BuildContext context, List<Widget> items) {
    return Directionality(
      textDirection: Globals.languageState! ? TextDirection.ltr : TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items,
      ),
    );
  }
}
