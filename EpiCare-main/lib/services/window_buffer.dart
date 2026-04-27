// lib/services/window_buffer.dart
class WindowBuffer {
  final int windowSize;
  final void Function(List<List<double>> window) onWindowReady;
  final List<List<double>> _buf = [];

  WindowBuffer({this.windowSize = 10, required this.onWindowReady});

  void addVector(List<double> v) {
    _buf.add(v);

    if (_buf.length >= windowSize) {
      final w = _buf.sublist(_buf.length - windowSize);
      onWindowReady(w);

      // sliding: خلي عندك آخر 10 فقط لتخفيف الذاكرة
      if (_buf.length > windowSize) {
        _buf.removeRange(0, _buf.length - windowSize);
      }
    }
  }

  void clear() => _buf.clear();
}
