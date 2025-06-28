// widgets/audio_controls.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AudioControls extends StatelessWidget {
  final bool showControls;
  final bool isPlaying;
  final bool isDownloading;
  final double downloadProgress;
  final Duration position;
  final Duration duration;
  final double playbackSpeed;
  final Function() onPlayPause;
  final Function() onStop;
  final Function() onChangeSpeed;
  final String fontFamily;
  final Color primaryColor;
  final Color textColor;
  final Color cardColor;

  const AudioControls({
    super.key,
    required this.showControls,
    required this.isPlaying,
    required this.isDownloading,
    required this.downloadProgress,
    required this.position,
    required this.duration,
    required this.playbackSpeed,
    required this.onPlayPause,
    required this.onStop,
    required this.onChangeSpeed,
    required this.fontFamily,
    required this.primaryColor,
    required this.textColor,
    required this.cardColor,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [minutes, seconds].join(':');
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDuration = duration.inSeconds > 0;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: showControls
          ? Container(
              key: const ValueKey('audioControlsVisible'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isDownloading)
                    LinearProgressIndicator(
                      value: downloadProgress.clamp(0.0, 1.0),
                      backgroundColor: primaryColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      minHeight: 2,
                    ),
                  if (hasDuration)
                    SliderTheme(
                      data: SliderThemeData(
                        overlayShape: SliderComponentShape.noOverlay,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: position.inSeconds.clamp(0, duration.inSeconds).toDouble(),
                        min: 0,
                        max: duration.inSeconds.toDouble(),
                        onChanged: (value) async {
                          // Handle seek here
                        },
                        activeColor: primaryColor,
                        inactiveColor: primaryColor.withOpacity(0.3),
                      ),
                    ),
                  if (hasDuration)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: GoogleFonts.getFont(
                              fontFamily,
                              color: textColor,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: GoogleFonts.getFont(
                              fontFamily,
                              color: textColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Tooltip(
                        message: 'Playback Speed',
                        child: TextButton(
                          onPressed: onChangeSpeed,
                          child: Text(
                            '${playbackSpeed}x',
                            style: GoogleFonts.getFont(
                              fontFamily,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: primaryColor,
                        child: IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: onPlayPause,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Tooltip(
                        message: 'Stop',
                        child: IconButton(
                          icon: Icon(
                            Icons.stop,
                            color: primaryColor,
                            size: 28,
                          ),
                          onPressed: onStop,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}