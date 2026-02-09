import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:livefy/models/recentEvent/RecentEvent.dart';

class ApiService {
  static const String baseUrl =
      'https://api.fota.connectx-pioneer.com/api/mobile/dashboard';

  static Future<List<dynamic>> getPosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts'),
    );
    // TODO: Handle response
    return [];
  }

  static Future<List<RecentEvent>> fetchRecentEvents({
    required String deviceId,
    required String tenantId,
  }) async {
    final url = '$baseUrl/getAllEventsForDevice/$deviceId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'tenant-id': tenantId,
        'Content-Type': 'application/json',
      },
    );

    print('API Response Status: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final dynamic decodedBody = jsonDecode(response.body);
        
        // Handle null response
        if (decodedBody == null) {
          print('API returned null response');
          return [];
        }
        
        // Handle if response is not a list
        if (decodedBody is! List) {
          print('API response is not a list: ${decodedBody.runtimeType}');
          return [];
        }
        
        final List<dynamic> jsonList = decodedBody as List<dynamic>;
        
        // Filter out null items and safely parse
        final List<RecentEvent> events = [];
        for (var item in jsonList) {
          if (item != null) {
            try {
              // Ensure item is a Map before parsing
              Map<String, dynamic>? eventMap;
              if (item is Map) {
                eventMap = Map<String, dynamic>.from(item);
              } else {
                print('Skipping non-map item: $item (type: ${item.runtimeType})');
                continue;
              }
              
              if (eventMap != null) {
                events.add(RecentEvent.fromJson(eventMap));
              }
            } catch (e) {
              print('Error parsing event item: $e');
              print('Item data: $item');
            }
          }
        }
        
        return events;
      } catch (e) {
        print('Error decoding JSON: $e');
        throw Exception('Failed to parse API response: $e');
      }
    } else {
      throw Exception(
        'API failed: ${response.statusCode} - ${response.body}',
      );
    }
  }
}