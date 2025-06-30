import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/models/Azkar.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/azkar/counter_header.dart';
import 'package:islamic_app/widgets/azkar/reference.dart';
import 'package:islamic_app/widgets/azkar/zekr_description.dart';
import 'package:islamic_app/widgets/azkar/zekr_tab.dart';

class AzkarCard extends StatelessWidget {
  final int index;
  final String category;
  final Azkar azkar;
  final int count;
  final VoidCallback onChanged;

  const AzkarCard({
    super.key,
    required this.index,
    required this.category,
    required this.azkar,
    required this.count,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final int current = Globals.currentCounts[category]?[index] ?? count;
    final int completed = Globals.completionCounts[category]?[index] ?? 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildCard(current, completed),
        _buildFloatingButton(),
      ],
    );
  }

  Widget _buildCard(int current, int completed) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _handleTap,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F5EF),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (count > 1)
                CounterHeader(
                  index: index,
                  current: current,
                  total: count,
                  completed: completed,
                ),
              const SizedBox(height: 8),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  azkar.content,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.scheherazadeNew(
                    color: textColor,
                    fontSize: 24,
                    height: 1.8,
                  ),
                ),
              ),
              if (azkar.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                ZekrDescription(description: azkar.description),
              ],
              if (azkar.reference.isNotEmpty) ...[
                const SizedBox(height: 16),
                Reference(reference: azkar.reference),
              ],
              const SizedBox(height: 48), // spacing for floating button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton() {
    return Positioned(
      bottom: -12,
      left: 12,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  void _handleTap() {
    ZekrTab.handleZikrTap(category, index, count);
    onChanged();
  }
}
