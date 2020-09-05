import 'package:flutter/material.dart';

import './address_provider.dart';

class City extends ChangeNotifier {
  String id;
  String city;
  double latitude;
  double longitude;
  List<Address> places;
  City({
    @required this.id,
    @required this.city,
    @required this.latitude,
    @required this.longitude,
    this.places,
  });

}
