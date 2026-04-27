import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/patient_data.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.9:5000'; 
  

  static Future<PatientData?> getPatientData() async {
    try {
      print('  Fetching data from: $baseUrl/api/patient');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/patient'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('  Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('  Data received: $jsonData');
        return PatientData.fromJson(jsonData);
      } else {
        print('  Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('  Error fetching patient data: $e');
      return null;
    }
  }

  //   POST - تحديث بيانات المريض
  static Future<bool> updatePatientData(Map<String, dynamic> data) async {
    try {
      print('  Updating data: $data');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/patient'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      ).timeout(const Duration(seconds: 10));

      print('  Update response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('  Error updating patient data: $e');
      return false;
    }
  }

  //   POST - إرسال تنبيه نوبة طارئة
  static Future<bool> sendSeizureAlert({
    required String patientId,
    Map<String, dynamic>? location,
  }) async {
    try {
      print('Sending seizure alert for patient: $patientId');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/seizure-alert'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'patientId': patientId,
          'location': location ?? {'lat': 0.0, 'lng': 0.0},
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));

      print('📡 Alert response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print(' Alert sent: ${result['message']}');
        return true;
      }
      return false;
    } catch (e) {
      print(' Error sending seizure alert: $e');
      return false;
    }
  }

  
  static Future<bool> testConnection() async {
    try {
      print(' Testing connection to: $baseUrl');
      
      final response = await http.get(
        Uri.parse(baseUrl),
      ).timeout(const Duration(seconds: 5));

      print('Connection successful: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Connection failed: $e');
      return false;
    }
  }
}