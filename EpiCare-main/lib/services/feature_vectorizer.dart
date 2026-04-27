// lib/services/feature_vectorizer.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class FeatureVectorizer {
  late final List<String> featureCols;

  Future<void> init() async {
    final s = await rootBundle.loadString('assets/ML/feature_cols.json');
    final arr = jsonDecode(s) as List<dynamic>;
    featureCols = arr.map((e) => e.toString()).toList();
  }

  /// يرجع Map اللي جوّا "window" لو موجودة
  Map<String, dynamic> extractWindow(Map<String, dynamic> msg) {
    if (msg.containsKey('window') && msg['window'] is Map) {
      return Map<String, dynamic>.from(msg['window'] as Map);
    }
    return msg;
  }

  String normalizeKey(String k) {
    k = k.trim().replaceAll('"', '');

    if (k.isEmpty) return k;

    // keys مثل hr, o2sat, steps ما بدنا padding
    // بس M/X/Y/Z بدنا padding
    final prefix = k[0];

    if (!RegExp(r'[MXYZ]').hasMatch(prefix)) return k;

    final rest = k.substring(1);
    final n = int.tryParse(rest);
    if (n == null) return k;

    return '$prefix${n.toString().padLeft(3, '0')}'; // M0 -> M000
  }

  List<double> toVector(Map<String, dynamic> rawWindow) {
    final norm = <String, dynamic>{};
    rawWindow.forEach((k, v) {
      norm[normalizeKey(k)] = v;
    });

    final vec = List<double>.filled(featureCols.length, 0.0);

    for (int i = 0; i < featureCols.length; i++) {
      final key = featureCols[i];
      final val = norm[key];
      if (val == null) {
        vec[i] = 0.0;
      } else if (val is num) {
        vec[i] = val.toDouble();
      } else {
        vec[i] = double.tryParse(val.toString()) ?? 0.0;
      }
    }
    return vec;
  }
}
