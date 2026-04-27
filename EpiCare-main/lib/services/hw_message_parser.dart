// lib/services/hw_message_parser.dart
import 'dart:convert';

class HwMessageParser {
  final StringBuffer _buf = StringBuffer();
  int _braceDepth = 0;
  bool _started = false;

  /// يدخل سطر واحد من البلوتوث ويرجع Map إذا اكتمل JSON
  Map<String, dynamic>? pushLine(String rawLine) {
    final line = _stripTimestamp(rawLine).trim();
    if (line.isEmpty) return null;

    // ندور على بداية JSON
    for (int i = 0; i < line.length; i++) {
      final ch = line[i];

      if (!_started) {
        if (ch == '{') {
          _started = true;
          _braceDepth = 1;
          _buf.write(ch);
        }
        continue;
      } else {
        _buf.write(ch);
        if (ch == '{') _braceDepth++;
        if (ch == '}') _braceDepth--;

        if (_started && _braceDepth == 0) {
          final jsonStr = _buf.toString();
          _buf.clear();
          _started = false;

          try {
            final obj = jsonDecode(jsonStr);
            if (obj is Map<String, dynamic>) return obj;
          } catch (_) {
            // إذا فشل parse: تجاهل وكمّل
            return null;
          }
        }
      }
    }

    // لو السطر ما كان فيه أقواس كاملة بس إحنا داخل JSON، نضيفه (مع فاصلة/مسافة)
    if (_started && !line.contains('{') && !line.contains('}')) {
      _buf.write(line);
    }

    return null;
  }

  /// يشيل timestamp زي: 10:41:05.056
  String _stripTimestamp(String s) {
    // نمط timestamp بالبداية: HH:MM:SS.mmm
    final re = RegExp(r'^\d{1,2}:\d{2}:\d{2}\.\d{3}\s+');
    return s.replaceFirst(re, '');
  }
}

extension on StringBuffer {
  void clear() {
    this
      ..write('')
      ..clear;
  }
}
