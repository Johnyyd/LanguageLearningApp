import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsHelper {
  static Future<bool> speak(String text, {String lang = "ja", FlutterTts? tts}) async {
    if (kIsWeb) {
      if (tts != null) {
        try {
          await tts.setLanguage(lang);
          await tts.speak(text);
          return true;
        } catch (_) {}
      }
      return false;
    }

    // Trên Linux Desktop hoặc Desktop OS, ưu tiên phát âm chất lượng cao qua OS stream / Google TTS
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      final success = await _playDesktopTts(text, lang);
      if (success) return true;
    }

    if (tts != null) {
      try {
        await tts.setLanguage(lang);
        await tts.setSpeechRate(0.5);
        await tts.speak(text);
        return true;
      } catch (e) {
        debugPrint("FlutterTts speak error: $e");
        if (!Platform.isLinux && !Platform.isMacOS && !Platform.isWindows) {
          return await _playDesktopTts(text, lang);
        }
      }
    }
    return false;
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

  static Future<bool> _playDesktopTts(String text, String lang) async {
    try {
      final targetLang = lang.startsWith('vi') ? 'vi' : 'ja';
      final url = "https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=${Uri.encodeComponent(text)}&tl=$targetLang";

      if (Platform.isLinux) {
        // 1. Thử dùng các trình phát luồng (stream) trực tiếp trên Linux Desktop
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

        // 2. Thử tải file audio về /tmp và phát bằng các trình phát audio phổ biến
        try {
          final filePath = '/tmp/duo_tts_$targetLang.mp3';
          final client = HttpClient();
          final request = await client.getUrl(Uri.parse(url));
          request.headers.set('User-Agent', 'Mozilla/5.0');
          final response = await request.close();
          if (response.statusCode == 200) {
            final file = File(filePath);
            await response.pipe(file.openWrite());
            
            for (final cmd in [
              ['mpg123', '-q', filePath],
              ['mpg321', '-q', filePath],
              ['play', '-q', filePath], // sox
              ['paplay', filePath],
              ['mpv', '--no-video', '--quiet', filePath],
              ['ffplay', '-nodisp', '-autoexit', '-loglevel', 'quiet', filePath],
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
          debugPrint("Error downloading TTS file: $e");
        }

        // 3. Thử dùng trình tổng hợp giọng nói offline của Linux (Speech Dispatcher / eSpeak)
        try {
          final resSpd = await Process.run('which', ['spd-say']);
          if (resSpd.exitCode == 0) {
            await Process.run('spd-say', ['-l', targetLang, '-r', '-20', '-w', text]);
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
          await Process.run('say', ['-v', targetLang == 'ja' ? 'Kyoko' : 'default', text]);
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
