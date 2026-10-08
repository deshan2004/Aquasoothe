import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';

final audioServiceProvider = ChangeNotifierProvider<AudioServiceNotifier>((ref) {
  return AudioServiceNotifier();
});
