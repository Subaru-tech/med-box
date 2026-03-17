import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class NetworkService {
  /// Sends a notice to the ESP32 via its local IP address
  /// Supports animation type and optional scheduling
  Future<bool> sendNoticeToDevice({
    required String ipAddress,
    required String title,
    required String message,
    DateTime? scheduledAt,
  }) async {
    try {
      final url = Uri.parse('http://$ipAddress/update-notice');
      
      final body = <String, dynamic>{
        'title': title,
        'message': message,
      };

      // Add scheduling fields if scheduled
      if (scheduledAt != null) {
        body['year'] = scheduledAt.year;
        body['month'] = scheduledAt.month;
        body['day'] = scheduledAt.day;
        body['hour'] = scheduledAt.hour;
        body['minute'] = scheduledAt.minute;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final status = result['status'] ?? 'unknown';
        developer.log('Notice sent to $ipAddress — status: $status');
        return true;
      } else {
        developer.log('Failed to send notice. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      developer.log('Error communicating with ESP32 at $ipAddress: $e');
      return false;
    }
  }

  /// Checks if the device is reachable on the local network
  Future<bool> pingDevice(String ipAddress) async {
    try {
      final url = Uri.parse('http://$ipAddress/ping');
      final response = await http.get(url).timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Gets the current time and timezone from the ESP32
  Future<Map<String, dynamic>?> getDeviceTime(String ipAddress) async {
    try {
      final url = Uri.parse('http://$ipAddress/get-time');
      final response = await http.get(url).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      developer.log('Error getting device time from $ipAddress: $e');
      return null;
    }
  }

  /// Sets the timezone on the ESP32 device
  Future<bool> setDeviceTimezone({
    required String ipAddress,
    required int gmtOffsetSec,
    int dstOffsetSec = 0,
    bool dstEnabled = false,
    required String name,
  }) async {
    try {
      final url = Uri.parse('http://$ipAddress/set-timezone');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'gmt_offset': gmtOffsetSec,
          'dst_offset': dstOffsetSec,
          'dst_enabled': dstEnabled,
          'name': name,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        developer.log('Timezone set to $name on $ipAddress');
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error setting timezone on $ipAddress: $e');
      return false;
    }
  }

  /// Lists all notices stored on the ESP32
  Future<List<Map<String, dynamic>>> listDeviceNotices(String ipAddress) async {
    try {
      final url = Uri.parse('http://$ipAddress/list-notices');
      final response = await http.get(url).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      developer.log('Error listing notices from $ipAddress: $e');
      return [];
    }
  }
}
