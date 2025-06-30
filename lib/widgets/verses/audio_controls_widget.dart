// widgets/audio_controls_widget.dart
import 'package:flutter/material.dart';

class AudioControlsWidget extends StatelessWidget {
  final bool showAudioControls;
  final bool isDownloading;
  final double downloadProgress;
  final bool hasDuration;
  final Duration position;
  final Duration duration;
  final double playbackSpeed;
  final bool isPlaying;
  final Color primaryColor;
  final Color textColor;
  final String fontFamily;
  final bool isEnglish;
  final VoidCallback onChangePlaybackSpeed;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final Function(double) onSeek;

  const AudioControlsWidget({
    super.key,
    required this.showAudioControls,
    required this.isDownloading,
    required this.downloadProgress,
    required this.hasDuration,
    required this.position,
    required this.duration,
    required this.playbackSpeed,
    required this.isPlaying,
    required this.primaryColor,
    required this.textColor,
    required this.fontFamily,
    required this.isEnglish,
    required this.onChangePlaybackSpeed,
    required this.onPlayPause,
    required this.onStop,
    required this.onSeek,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [minutes, seconds].join(':');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: showAudioControls
          ? Container(
              key: const ValueKey('audioControlsVisible'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
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
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: downloadProgress.clamp(0.0, 1.0),
                          backgroundColor: primaryColor.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          minHeight: 2,
                        ),
                        Text(
                          '${(downloadProgress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            color: primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
                        onChanged: onSeek,
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
                            style: TextStyle(
                              fontFamily: fontFamily,
                              color: textColor,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: TextStyle(
                              fontFamily: fontFamily,
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
                        message: isEnglish ? 'Playback Speed' : 'سرعة التشغيل',
                        child: TextButton(
                          onPressed: onChangePlaybackSpeed,
                          child: Text(
                            '${playbackSpeed}x',
                            style: TextStyle(
                              fontFamily: fontFamily,
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
                        message: isEnglish ? 'Stop' : 'إيقاف',
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