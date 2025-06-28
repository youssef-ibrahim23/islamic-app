import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:islamic_app/models/verse.dart';
import 'dart:io';

class QuranServices {

  static Future<QuranVerses> loadLocalVerses(int surahId) async {
    try {
      final String response = await rootBundle.loadString('assets/Surah.JSON');
      final Map<String, dynamic> data = json.decode(response);
      
      // Filter verses by surahId (verse_key format is "surahId:verseNumber")
      final allVerses = (data['verses'] as List)
          .map((verseJson) => Verse.fromJson(verseJson))
          .toList();
      
      final filteredVerses = allVerses.where((verse) {
        final parts = verse.verseKey.split(':');
        return parts.isNotEmpty && int.parse(parts[0]) == surahId;
      }).toList();

      return QuranVerses(verses: filteredVerses);
    } catch (e) {
      print("Error loading local verses: $e");
      throw Exception("Failed to load Quran verses for surah $surahId");
    }
  }

  static Future<void> saveScrollPosition(int surahId, double position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('scroll_position_$surahId', position);
  }

  static Future<double> loadScrollPosition(int surahId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('scroll_position_$surahId') ?? 0.0;
  }

  static Future<int> loadLastClickedVerse(int surahId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('last_clicked_$surahId') ?? 1;
  }

  static Future<void> saveLastClickedVerse(int surahId, int verse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_clicked_$surahId', verse);
  }

  static Future<String?> getAudioPath(int surahId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('audio_$surahId');
  }

  static Future<void> saveAudioPath(int surahId, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('audio_$surahId', path);
  }

  static Future<void> removeAudioPath(int surahId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('audio_$surahId');
  }

  static Future<String> downloadAudio({
    required int surahId,
    required String downloadUrl,
    required Function(double) onProgress,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/surah_$surahId.mp3';
    final file = File(filePath);

    if (await file.exists()) {
      await file.delete();
    }

    final dio = Dio();
    await dio.download(
      downloadUrl,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          onProgress(received / total);
        }
      },
    );

    return filePath;
  }

  static Future<void> playAudio({
    required AudioPlayer audioPlayer,
    required String? localPath,
    required String remoteUrl,
  }) async {
    if (localPath != null) {
      await audioPlayer.play(DeviceFileSource(localPath));
    } else {
      await audioPlayer.play(UrlSource(remoteUrl));
    }
  }
}

class QuranData {
  final List<Verse> verses;
  QuranData(this.verses);
}