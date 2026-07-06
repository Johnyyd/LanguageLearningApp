import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsHelper {
  static Future<bool> speak(
    String text, {
    String lang = "ja",
    FlutterTts? tts,
    String speakerId = "sensei_va_01",
  }) async {
    if (kIsWeb) {
      if (tts != null) {
        try {
          await tts.setLanguage(lang);
          await _applyVoiceConfig(tts, speakerId, lang);
          await tts.speak(text);
          return true;
        } catch (_) {}
      }
      return false;
    }

    // Trên Linux Desktop hoặc Desktop OS, ưu tiên phát âm chất lượng cao qua OS stream / Google TTS
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      final success = await _playDesktopTts(text, lang, speakerId);
      if (success) return true;
    }

    if (tts != null) {
      try {
        await tts.setLanguage(lang);
        await _applyVoiceConfig(tts, speakerId, lang);
        await tts.speak(text);
        return true;
      } catch (e) {
        debugPrint("FlutterTts speak error: $e");
        if (!Platform.isLinux && !Platform.isMacOS && !Platform.isWindows) {
          return await _playDesktopTts(text, lang, speakerId);
        }
      }
    }
    return false;
  }

  static Future<void> _applyVoiceConfig(FlutterTts tts, String speakerId, String lang) async {
    // Không sử dụng tăng/giảm pitch hay tốc độ để giả giọng
    await tts.setPitch(1.0);
    await tts.setSpeechRate(0.5);

    try {
      // Thử chọn các gói giọng (voices) khác nhau trong hệ thống Android/iOS nếu máy có cài đặt
      final voices = await tts.getVoices;
      if (voices != null && voices is List && voices.isNotEmpty) {
        final langPrefix = lang.split('-').first.toLowerCase(); // 'vi' hoặc 'ja'
        final matchingVoices = voices.where((v) {
          if (v is Map) {
            final loc = (v["locale"] ?? "").toString().toLowerCase();
            return loc.startsWith(langPrefix) || loc.contains(langPrefix);
          }
          return false;
        }).toList();

        if (matchingVoices.isNotEmpty) {
          int voiceIdx = 0;
          if (speakerId == "sensei_va_01") voiceIdx = 0;
          if (speakerId == "sensei_va_04") voiceIdx = (matchingVoices.length > 1) ? 1 : 0;
          if (speakerId == "sensei_va_02") voiceIdx = (matchingVoices.length > 2) ? 2 : (matchingVoices.length > 1 ? 1 : 0);
          if (speakerId == "sensei_va_03") voiceIdx = (matchingVoices.length > 3) ? 3 : (matchingVoices.length - 1);

          final selectedVoice = matchingVoices[voiceIdx % matchingVoices.length];
          if (selectedVoice is Map && selectedVoice["name"] != null && selectedVoice["locale"] != null) {
            await tts.setVoice({"name": selectedVoice["name"].toString(), "locale": selectedVoice["locale"].toString()});
          }
        }
      }
    } catch (e) {
      debugPrint("Error applying voice config: $e");
    }
  }

  static Future<bool> stop(FlutterTts? tts) async {
    try {
      if (tts != null) await tts.stop();
    } catch (_) {}
    if (!kIsWeb && Platform.isLinux) {
      for (final proc in ['mpv', 'ffplay', 'cvlc', 'mpg123', 'mpg321', 'play', 'paplay', 'spd-say', 'espeak-ng', 'espeak']) {
        try {
          await Process.run('killall', [proc]);
        } catch (_) {}
      }
    }
    return true;
  }

  static Future<bool> _playDesktopTts(String text, String lang, String speakerId) async {
    try {
      final targetLang = lang.startsWith('vi') ? 'vi' : 'ja';

      // 1. ƯU TIÊN SỐ 1: Tải âm thanh AI Voice Cloned thực thụ từ Backend Voice Engine API
      try {
        final clonedAudioUrl = "http://localhost:8000/api/v1/chat/audio?text=${Uri.encodeComponent(text)}&speaker_id=$speakerId&speed=1.0";
        final filePath = '/tmp/duo_ai_voice_$speakerId.wav';
        final client = HttpClient();
        final request = await client.getUrl(Uri.parse(clonedAudioUrl)).timeout(const Duration(seconds: 3));
        final response = await request.close().timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final file = File(filePath);
          await response.pipe(file.openWrite());
          
          for (final cmd in [
            ['mpv', '--no-video', '--quiet', filePath],
            ['ffplay', '-nodisp', '-autoexit', '-loglevel', 'quiet', filePath],
            ['paplay', filePath],
            ['play', '-q', filePath],
            ['aplay', '-q', filePath],
            ['cvlc', '--play-and-exit', filePath],
          ]) {
            try {
              final res = await Process.run('which', [cmd[0]]);
              if (res.exitCode == 0) {
                await Process.run(cmd[0], cmd.sublist(1));
                return true;
              }
            } catch (_) {}
          }
        }
      } catch (e) {
        debugPrint("Voice Engine API audio download failed: $e");
      }

      // 2. Nếu API không khả dụng, dùng trình phát luồng trực tiếp mà KHÔNG biến đổi cao độ
      final url = "https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=${Uri.encodeComponent(text)}&tl=$targetLang";
      if (Platform.isLinux) {
        for (final cmd in [
          ['mpv', '--no-video', '--quiet', url],
          ['ffplay', '-nodisp', '-autoexit', '-loglevel', 'quiet', url],
          ['cvlc', '--play-and-exit', url],
        ]) {
          try {
            final res = await Process.run('which', [cmd[0]]);
            if (res.exitCode == 0) {
              await Process.run(cmd[0], cmd.sublist(1));
              return true;
            }
          } catch (_) {}
        }

        // 3. Trình tổng hợp giọng nói offline của Linux (không đổi pitch)
        try {
          final resSpd = await Process.run('which', ['spd-say']);
          if (resSpd.exitCode == 0) {
            await Process.run('spd-say', ['-l', targetLang, '-w', text]);
            return true;
          }
        } catch (_) {}

        try {
          final resEspeak = await Process.run('which', ['espeak-ng']);
          if (resEspeak.exitCode == 0) {
            await Process.run('espeak-ng', ['-v', targetLang, text]);
            return true;
          }
        } catch (_) {}

        try {
          final resEspeakOld = await Process.run('which', ['espeak']);
          if (resEspeakOld.exitCode == 0) {
            await Process.run('espeak', ['-v', targetLang, text]);
            return true;
          }
        } catch (_) {}
      } else if (Platform.isMacOS) {
        try {
          String macVoice = 'default';
          if (targetLang == 'ja') {
            macVoice = (speakerId == "sensei_va_02") ? 'Otoya' : 'Kyoko';
          }
          await Process.run('say', ['-v', macVoice, text]);
          return true;
        } catch (_) {}
      } else if (Platform.isWindows) {
        try {
          final psCmd = "Add-Type -AssemblyName System.speech; \$synth = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer; \$synth.Speak('$text')";
          await Process.run('powershell', ['-Command', psCmd]);
          return true;
        } catch (_) {}
      }
    } catch (e) {
      debugPrint("Desktop TTS error: $e");
    }
    return false;
  }
}
