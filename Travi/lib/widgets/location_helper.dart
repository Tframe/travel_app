import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class LocationHelper {
  Future<String> getAddress(
    double latitude,
    double longitude,
  ) async {
    String apiKey = DotEnv().env['GOOGLE_PLACES_API_KEY'];
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';
    final response = await http.get(url);
    return json.decode(response.body)['results'][4]['formatted_address'];
  }
}
