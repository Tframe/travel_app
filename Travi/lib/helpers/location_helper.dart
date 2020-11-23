/* Author: Trevor Frame
 * Date: 11/17/2020
 * Description: Helper functions that can be used
 * to get locations using latitude and longitude using
 * Google places API
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class LocationHelper {
  //returns a string of a formatted address that wil display cit, state, country, and zip code
  Future<String> getCityStateCountry(
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
