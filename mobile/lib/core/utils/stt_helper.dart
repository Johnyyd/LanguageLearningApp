import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SttHelper {
  static final SpeechToText _speech = SpeechToText();
  static bool _isInitialized = false;
  static Timer? _silenceTimer;

  static Future<bool> init() async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) => debugPrint("STT Status: $status"),
        onError: (errorNotification) => debugPrint("STT Error: $errorNotification"),
      );
    } catch (e) {
      debugPrint("STT init exception: $e");
      _isInitialized = false;
    }
    return _isInitialized;
  }

  static Future<bool> startListening({
    required Function(String text, bool isFinal) onResult,
    String? localeId,
    Duration pauseDuration = const Duration(seconds: 2),
  }) async {
    final available = await init();
    if (!available) {
      debugPrint("STT not available or microphone permission denied");
      return false;
    }

    try {
      await stopListening();

      String? targetLocale = localeId;
      if (targetLocale == null) {
        final systemLocale = await _speech.systemLocale();
        targetLocale = systemLocale?.localeId ?? "vi_VN";
      }

      String lastRecognizedWords = "";

      await _speech.listen(
        onResult: (result) {
          lastRecognizedWords = result.recognizedWords;
          
          if (result.finalResult) {
            _silenceTimer?.cancel();
            onResult(lastRecognizedWords, true);
          } else {
            onResult(lastRecognizedWords, false);
            // Reset timer tự động kết thúc sau khi im lặng
            _silenceTimer?.cancel();
            if (lastRecognizedWords.trim().isNotEmpty) {
              _silenceTimer = Timer(pauseDuration, () async {
                await stopListening();
                onResult(lastRecognizedWords, true);
              });
            }
          }
        },
        localeId: targetLocale,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        pauseFor: pauseDuration,
        listenFor: const Duration(seconds: 30),
      );
      return true;
    } catch (e) {
      debugPrint("STT listen error: $e");
      return false;
    }
  }

  static Future<void> stopListening() async {
    _silenceTimer?.cancel();
    _silenceTimer = null;
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (e) {
      debugPrint("STT stop error: $e");
    }
  }

  static bool get isListening => _speech.isListening;
}
