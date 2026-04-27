// // import 'dart:async';
// // import 'dart:typed_data';
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// // class BluetoothService {
// //   static final BluetoothService _instance = BluetoothService._internal();
// //   factory BluetoothService() => _instance;
// //   BluetoothService._internal();

// //   BluetoothConnection? _connection;
// //   StreamSubscription<Uint8List>? _sub;

// //   final StreamController<Uint8List> _controller =
// //       StreamController<Uint8List>.broadcast();

// //   Stream<Uint8List> get dataStream => _controller.stream;

// //   bool get isConnected => _connection?.isConnected ?? false;

// //   bool _connecting = false;

// //   Future<void> connect(String deviceName) async {
// //     if (_connecting || isConnected) return;
// //     _connecting = true;

// //     try {
// //       // 🔹 تأكدي أن البلوتوث شغال
// //       await FlutterBluetoothSerial.instance.requestEnable();

// //       final bonded =
// //           await FlutterBluetoothSerial.instance.getBondedDevices();

// //       // 🔍 طباعة الأجهزة المقترنة (مهم جدًا)
// //       for (var d in bonded) {
// //         debugPrint("📱 Bonded: '${d.name}' | ${d.address}");
// //       }

// //       final device = bonded.firstWhere(
// //         (d) =>
// //             (d.name ?? "")
// //                 .toUpperCase()
// //                 .contains(deviceName.toUpperCase()),
// //       );

// //       debugPrint("🔵 Connecting to ${device.name}");

// //       _connection =
// //           await BluetoothConnection.toAddress(device.address);

// //       _sub = _connection!.input!.listen(
// //         (data) {
// //           _controller.add(data);
// //         },
// //         onDone: () async {
// //   debugPrint("🔴 Bluetooth disconnected, retrying...");
// //   _sub?.cancel();
// //   _connection?.dispose();
// //   _connection = null;
// //   await Future.delayed(const Duration(seconds: 2));
// //   await connect(deviceName); // إعادة الاتصال
// // },

// //         onError: (e) {
// //           debugPrint("❌ Bluetooth error: $e");
// //         },
// //       );

// //       debugPrint("🟢 Bluetooth connected");
// //     } catch (e) {
// //       debugPrint("❌ Bluetooth connect failed: $e");
// //     } finally {
// //       _connecting = false;
// //     }
// //   }

// //   void disconnect() {
// //     _sub?.cancel();
// //     _connection?.dispose();
// //     _connection = null;
// //   }
// // }

// import 'dart:async';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// class BluetoothService {
//   static final BluetoothService _instance = BluetoothService._internal();
//   factory BluetoothService() => _instance;
//   BluetoothService._internal();

//   BluetoothConnection? _connection;
//   StreamSubscription<Uint8List>? _sub;

//   final StreamController<Uint8List> _controller =
//       StreamController<Uint8List>.broadcast();

//   Stream<Uint8List> get dataStream => _controller.stream;

//   bool get isConnected => _connection?.isConnected ?? false;
//   bool _connecting = false;

//   /// اسم الجهاز المراد الاتصال به
//   final String targetDeviceName = "ESP32_HEALTH_MONITOR";

//   /// الاتصال بالجهاز
//   Future<void> connect() async {
//     if (_connecting || isConnected) return;
//     _connecting = true;

//     try {
//       // ✅ تأكدي أن البلوتوث مفعل
//       await FlutterBluetoothSerial.instance.requestEnable();

//       // 🔹 جلب جميع الأجهزة المقترنة
//       final bonded = await FlutterBluetoothSerial.instance.getBondedDevices();

//       if (bonded.isEmpty) {
//         debugPrint("❌ No bonded devices found! Please pair your ESP32 first.");
//         _connecting = false;
//         return;
//       }

//       // 🔹 طباعة الأجهزة المقترنة
//       for (var d in bonded) {
//         debugPrint("📱 Bonded: '${d.name}' | ${d.address}");
//       }

//       // 🔹 البحث عن الجهاز المطلوب
//       BluetoothDevice? device;
//       try {
//         device = bonded.firstWhere(
//           (d) => (d.name ?? "").toUpperCase().contains(targetDeviceName.toUpperCase()),
//         );
//       } catch (e) {
//         debugPrint("❌ Device '$targetDeviceName' not found among bonded devices!");
//         _connecting = false;
//         return;
//       }

//       debugPrint("🔵 Connecting to ${device.name} (${device.address})...");

//       // ✅ إنشاء الاتصال
//       _connection = await BluetoothConnection.toAddress(device.address);

//       // ✅ الاستماع للبيانات
//       _sub = _connection!.input!.listen(
//         (data) {
//           _controller.add(data);
//         },
//         onDone: () async {
//           debugPrint("🔴 Bluetooth disconnected, retrying in 2s...");
//           await _retryConnection();
//         },
//         onError: (e) {
//           debugPrint("❌ Bluetooth error: $e");
//         },
//       );

//       debugPrint("🟢 Bluetooth connected to ${device.name}");
//     } catch (e) {
//       debugPrint("❌ Bluetooth connect failed: $e");
//     } finally {
//       _connecting = false;
//     }
//   }

//   /// إعادة الاتصال تلقائيًا بعد الانقطاع
//   Future<void> _retryConnection() async {
//     _sub?.cancel();
//     _connection?.dispose();
//     _connection = null;
//     await Future.delayed(const Duration(seconds: 2));
//     await connect();
//   }

//   /// قطع الاتصال
//   void disconnect() {
//     _sub?.cancel();
//     _connection?.dispose();
//     _connection = null;
//     debugPrint("🔴 Bluetooth disconnected manually");
//   }
// }

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  BluetoothConnection? _connection;
  StreamSubscription<Uint8List>? _inputSub;
  final StreamController<Uint8List> _controller = StreamController<Uint8List>.broadcast();

  Stream<Uint8List> get dataStream => _controller.stream;

  bool get isConnected => _connection?.isConnected ?? false;

  bool _connecting = false;
  bool _autoReconnect = true;

  Timer? _reconnectTimer;
  Timer? _keepAliveTimer;

  String targetDeviceName = "ESP32_HEALTH_MONITOR";

  // ✅ Start service - يتم استدعاؤه من main.dart
  Future<void> start() async {
    debugPrint("[BT] 🚀 Service starting...");
    
    // ✅ راقب حالة البلوتوث على الجهاز
    FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
      debugPrint("[BT] 📡 Adapter state = $state");
      if (state == BluetoothState.STATE_ON && !isConnected) {
        _ensureConnected();
      } else if (state == BluetoothState.STATE_OFF) {
        debugPrint("[BT] ⚠️ Bluetooth turned off");
        _handleDisconnect();
      }
    });

    // ✅ محاولة الاتصال الأولي
    await _ensureConnected();
  }

  // ✅ Stop service - فقط عند تسجيل الخروج
  Future<void> stop() async {
    debugPrint("[BT] 🛑 Service stopping...");
    _autoReconnect = false;
    _reconnectTimer?.cancel();
    _keepAliveTimer?.cancel();
    await disconnect();
    await _controller.close();
  }

  // ✅ الاتصال التلقائي
  Future<void> _ensureConnected() async {
    if (_connecting || isConnected) return;
    
    _connecting = true;
    try {
      // ✅ تحقق إذا البلوتوث شغال
      final isEnabled = await FlutterBluetoothSerial.instance.isEnabled;
      if (isEnabled != true) {
        debugPrint("[BT] ⚠️ Bluetooth not enabled");
        _connecting = false;
        _scheduleReconnect();
        return;
      }

      // ✅ جلب الأجهزة المرتبطة
      final bonded = await FlutterBluetoothSerial.instance.getBondedDevices();
      debugPrint("[BT] 📋 Bonded devices: ${bonded.length}");

      final device = bonded.firstWhere(
        (d) => (d.name ?? "").toUpperCase().contains(targetDeviceName.toUpperCase()),
        orElse: () => throw Exception("Target device '$targetDeviceName' not bonded"),
      );

      debugPrint("[BT] 🔗 Connecting to ${device.name} (${device.address})...");
      _connection = await BluetoothConnection.toAddress(device.address);
      debugPrint("[BT] ✅ Connected successfully!");

      // ✅ الاستماع للبيانات
      _inputSub?.cancel();
      _inputSub = _connection!.input!.listen(
        (data) {
          if (!_controller.isClosed) {
            _controller.add(data);
          }
        },
        onDone: () {
          debugPrint("[BT] 🔴 Connection closed (onDone)");
          _handleDisconnect();
        },
        onError: (e) {
          debugPrint("[BT] ❌ Connection error: $e");
          _handleDisconnect();
        },
        cancelOnError: true,
      );

      // ✅ بدء KeepAlive
      _startKeepAlive();

    } catch (e) {
      debugPrint("[BT] ❌ Connect failed: $e");
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  // ✅ معالجة الانقطاع وإعادة الاتصال
  void _handleDisconnect() {
    try {
      _inputSub?.cancel();
    } catch (_) {}
    try {
      _connection?.dispose();
    } catch (_) {}
    
    _connection = null;
    _inputSub = null;
    _keepAliveTimer?.cancel();

    if (_autoReconnect) {
      _scheduleReconnect();
    }
  }

  // ✅ جدولة إعادة الاتصال
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      debugPrint("[BT] 🔄 Attempting reconnect...");
      _ensureConnected();
    });
  }

  // ✅ قطع الاتصال يدويًا (فقط عند الحاجة)
  Future<void> disconnect() async {
    debugPrint("[BT] 🔌 Disconnecting...");
    _reconnectTimer?.cancel();
    _keepAliveTimer?.cancel();

    try {
      await _inputSub?.cancel();
    } catch (_) {}
    try {
      _connection?.dispose();
    } catch (_) {}
    
    _connection = null;
    _inputSub = null;
  }

  // ✅ KeepAlive للحفاظ على الاتصال
  void _startKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_connection != null && _connection!.isConnected) {
        try {
          // ✅ إرسال newline بسيط
          _connection!.output.add(Uint8List.fromList([10]));
          await _connection!.output.allSent;
        } catch (e) {
          debugPrint("[BT] ⚠️ KeepAlive failed: $e");
        }
      }
    });
  }
}