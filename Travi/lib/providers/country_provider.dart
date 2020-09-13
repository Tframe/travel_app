import 'package:flutter/material.dart';
import './city_provider.dart';

class Country extends ChangeNotifier {
  String id;
  String country;
  double latitude;
  double longitude;
  List<City> cities;
  Country({
    @required this.id,
    @required this.country,
    @required this.latitude,
    @required this.longitude,
    this.cities,
  });

}
