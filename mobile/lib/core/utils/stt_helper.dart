import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SttHelper {
  static final SpeechToText _speech = SpeechToText();
  static bool _isInitialized = false;
  static Timer? _silenceTimer;
  static Function(String text, bool isFinal)? _activeCallback;
  static String _lastRecognizedWords = "";
  static bool _isSessionActive = false;

  static Future<bool> init() async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          debugPrint("STT Status: $status");
          if (status == "done" || status == "notListening") {
            _silenceTimer?.cancel();
            if (_isSessionActive) {
              _isSessionActive = false;
              _activeCallback?.call(_lastRecognizedWords, true);
            }
          }
        },
        onError: (errorNotification) {
          debugPrint("STT Error: $errorNotification");
          _silenceTimer?.cancel();
          if (_isSessionActive) {
            _isSessionActive = false;
            _activeCallback?.call(_lastRecognizedWords, true);
          }
        },
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

      _lastRecognizedWords = "";
      _activeCallback = onResult;
      _isSessionActive = true;

      // Timer mặc định: nếu bật mic mà không nói gì trong 4 giây thì tự tắt
      _silenceTimer = Timer(const Duration(seconds: 4), () async {
        if (_isSessionActive) {
          await stopListening();
        }
      });

      await _speech.listen(
        onResult: (result) {
          _lastRecognizedWords = result.recognizedWords;
          
          if (result.finalResult) {
            _silenceTimer?.cancel();
            if (_isSessionActive) {
              _isSessionActive = false;
              onResult(_lastRecognizedWords, true);
            }
          } else {
            onResult(_lastRecognizedWords, false);
            // Reset timer tự động kết thúc sau 2 giây im lặng
            _silenceTimer?.cancel();
            _silenceTimer = Timer(pauseDuration, () async {
              if (_isSessionActive) {
                await stopListening();
              }
            });
          }
        },
        listenOptions: SpeechListenOptions(
          localeId: targetLocale,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
          pauseFor: pauseDuration,
          listenFor: const Duration(seconds: 30),
        ),
      );
      return true;
    } catch (e) {
      debugPrint("STT listen error: $e");
      _isSessionActive = false;
      return false;
    }
  }

  static Future<void> stopListening() async {
    _silenceTimer?.cancel();
    _silenceTimer = null;
    final wasActive = _isSessionActive;
    _isSessionActive = false;
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (e) {
      debugPrint("STT stop error: $e");
    }
    if (wasActive) {
      _activeCallback?.call(_lastRecognizedWords, true);
    }
  }

  static bool get isListening => _isSessionActive || _speech.isListening;
}
