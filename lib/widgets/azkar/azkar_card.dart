import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/models/Azkar.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/azkar/counter_header.dart';
import 'package:islamic_app/widgets/azkar/reference.dart';
import 'package:islamic_app/widgets/azkar/zekr_description.dart';
import 'package:islamic_app/widgets/azkar/zekr_tab.dart';

class AzkarCard extends StatefulWidget {
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
  State<AzkarCard> createState() => _AzkarCardState();
}

class _AzkarCardState extends State<AzkarCard>
    with SingleTickerProviderStateMixin {
  bool _isBrowseMode = false;
  late AnimationController _clickAnimationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _clickAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(
        parent: _clickAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _clickAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleAnimatedTap(bool isLocked) async {
    // Run click animation
    await _clickAnimationController.forward();
    await _clickAnimationController.reverse();
    await _handleTap(isLocked);
  }

  @override
  Widget build(BuildContext context) {
    final int current =
        Globals.currentCounts[widget.category]?[widget.index] ?? widget.count;
    final int completed =
        Globals.completionCounts[widget.category]?[widget.index] ?? 0;
    final bool isLocked =
        Globals.azkarCardLocked[widget.category]?[widget.index] == true;

    print(
        '🎴 AzkarCard ${widget.index} build: isLocked=$isLocked, _isBrowseMode=$_isBrowseMode');

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _buildCard(current, completed, isLocked),
              _buildFloatingButton(isLocked),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(int current, int completed, bool isLocked) {
    // In browse mode, show card without blur and without counting
    final bool showAsBrowse = isLocked && _isBrowseMode;
    final bool showBasmala = widget.azkar.basmala;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: isLocked && !showAsBrowse
                  ? null
                  : () async => _handleAnimatedTap(isLocked),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F5EF),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basmala at top if enabled
                    if (showBasmala) ...[
                      _buildBasmala(),
                      const SizedBox(height: 12),
                    ],
                    if (widget.count > 1 && !showAsBrowse)
                      CounterHeader(
                        index: widget.index,
                        current: current,
                        total: widget.count,
                        completed: completed,
                      ),
                    if (showAsBrowse) _buildBrowseModeHeader(),
                    const SizedBox(height: 8),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        widget.azkar.content,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.scheherazadeNew(
                          color: textColor,
                          fontSize: 24,
                          height: 1.8,
                        ),
                      ),
                    ),
                    if (widget.azkar.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ZekrDescription(description: widget.azkar.description),
                    ],
                    if (widget.azkar.reference.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Reference(reference: widget.azkar.reference),
                    ],
                    const SizedBox(height: 48), // spacing for floating button
                  ],
                ),
              ),
            ),
            // Show locked overlay only when locked and NOT in browse mode
            if (isLocked && !showAsBrowse)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    color: Colors.white.withOpacity(0.3),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Completed badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  Globals.languageState ?? true
                                      ? 'Completed'
                                      : 'تم',
                                  style: GoogleFonts.getFont(
                                    Globals.languageState ?? true
                                        ? 'Roboto'
                                        : 'Tajawal',
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Browse button
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isBrowseMode = true;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    color: primaryColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    Globals.languageState ?? true
                                        ? 'Browse'
                                        : 'قراءة',
                                    style: GoogleFonts.getFont(
                                      Globals.languageState ?? true
                                          ? 'Roboto'
                                          : 'Tajawal',
                                      color: primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseModeHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility,
            color: primaryColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            Globals.languageState ?? true ? 'Browse Mode' : 'وضع القراءة',
            style: GoogleFonts.getFont(
              Globals.languageState ?? true ? 'Roboto' : 'Tajawal',
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(bool isLocked) {
    // Hide button in browse mode or when locked
    if (isLocked || _isBrowseMode) return const SizedBox.shrink();

    return Positioned(
      bottom: -12,
      left: 12,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () async => _handleAnimatedTap(isLocked),
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

  Future<void> _handleTap(bool isLocked) async {
    if (_isBrowseMode) {
      // Exit browse mode on tap
      setState(() {
        _isBrowseMode = false;
      });
      return;
    }
    await ZekrTab.handleZikrTap(widget.category, widget.index, widget.count);
    widget.onChanged();
  }

  Widget _buildBasmala() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
          textAlign: TextAlign.center,
          style: GoogleFonts.scheherazadeNew(
            color: primaryColor,
            fontSize: 22,
            height: 1.6,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
