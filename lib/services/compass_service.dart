// services/compass_service.dart
import 'package:flutter_qiblah/flutter_qiblah.dart';

class CompassService {
  static Stream<QiblahDirection> get qiblahStream => FlutterQiblah.qiblahStream;
}