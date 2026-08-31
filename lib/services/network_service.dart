import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class NetworkService {
  /// Sends a message to the ElderLink device via its local IP address
  Future<bool> sendMessageToDevice({
    required String ipAddress,
    required String text,
    required String senderName,
  }) async {
    try {
      final url = Uri.parse('http://$ipAddress/send-message');

      final body = <String, dynamic>{
        'text': text,
        'sender': senderName,
      };

      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        developer.log('Message sent to $ipAddress');
        return true;
      } else {
        developer.log('Failed to send message. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      developer.log('Error communicating with ESP32 at $ipAddress: $e');
      return false;
    }
  }

  /// Sends a medication reminder to the ElderLink device
  Future<bool> sendMedicationReminder({
    required String ipAddress,
    required String medicineName,
    required String slot,
    required int hour,
    required int minute,
  }) async {
    try {
      final url = Uri.parse('http://$ipAddress/set-medication');

      final body = <String, dynamic>{
        'name': medicineName,
        'slot': slot,
        'hour': hour,
        'minute': minute,
      };

      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      developer.log('Error sending medication to $ipAddress: $e');
      return false;
    }
  }

  /// Sends an appointment reminder to the ElderLink device
  Future<bool> sendAppointmentReminder({
    required String ipAddress,
    required String title,
    required DateTime dateTime,
    String? notes,
  }) async {
    try {
      final url = Uri.parse('http://$ipAddress/set-appointment');

      final body = <String, dynamic>{
        'title': title,
        'year': dateTime.year,
        'month': dateTime.month,
        'day': dateTime.day,
        'hour': dateTime.hour,
        'minute': dateTime.minute,
        'notes': notes,
      };

      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      developer.log('Error sending appointment to $ipAddress: $e');
      return false;
    }
  }

  /// Checks if the device is reachable on the local network
  Future<bool> pingDevice(String ipAddress) async {
    try {
      final url = Uri.parse('http://$ipAddress/ping');
      final response =
          await http.get(url).timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Gets device status (temperature, humidity, etc.)
  Future<Map<String, dynamic>?> getDeviceStatus(String ipAddress) async {
    try {
      final url = Uri.parse('http://$ipAddress/status');
      final response =
          await http.get(url).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      developer.log('Error getting status from $ipAddress: $e');
      return null;
    }
  }
}
