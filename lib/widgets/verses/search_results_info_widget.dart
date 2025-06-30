import 'package:flutter/material.dart';
import 'package:islamic_app/models/verse.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchResultsInfoWidget extends StatelessWidget {
  final String searchQuery;
  final List<Verse>? filteredVerses;
  final Color primaryColor;
  final String fontFamily;
  final bool isEnglish;

  const SearchResultsInfoWidget({
    super.key,
    required this.searchQuery,
    required this.filteredVerses,
    required this.primaryColor,
    required this.fontFamily,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    if (searchQuery.isEmpty || filteredVerses == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isEnglish
            ? '${filteredVerses!.length} verses found'
            : 'تم العثور على ${filteredVerses!.length} آية',
        style: GoogleFonts.getFont(
          fontFamily,
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}