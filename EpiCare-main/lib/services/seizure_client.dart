import 'dart:convert';
import 'package:http/http.dart' as http;

class SeizureClient {
  final String baseUrl;
  final double thr;

  SeizureClient({required this.baseUrl, this.thr = 0.7});

  Future<Map<String, dynamic>> predict(List<List<double>> window10xF) async {
    // ✅ server expects: windows: (B,10,F) -> so wrap single window into batch
    final payload = {
      "windows": [window10xF], // <-- أهم سطر
      "thr": thr,
      "return_preds": true,
    };

    final r = await http
        .post(
          Uri.parse("$baseUrl/predict_batch"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 5));

    if (r.statusCode != 200) {
      throw Exception("API ${r.statusCode}: ${r.body}");
    }

    final data = jsonDecode(r.body) as Map<String, dynamic>;
    final probs = (data["probs"] as List).cast<num>();
    final preds = (data["preds"] as List?)?.cast<num>();

    final prob0 = probs.isNotEmpty ? probs[0].toDouble() : 0.0;
    final pred0 = preds != null && preds.isNotEmpty ? preds[0].toInt() : (prob0 >= thr ? 1 : 0);

    return {"prob": prob0, "pred": pred0};
  }
}

