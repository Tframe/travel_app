import 'dart:typed_data';
import 'package:flutter/material.dart';

class City extends ChangeNotifier {
  String id;
  String city;
  double latitude;
  double longitude;
  List<Uint8List> googleImages;
  String cityImageUrl;

  City({
    @required this.id,
    @required this.city,
    @required this.latitude,
    @required this.longitude,
    this.googleImages,
    this.cityImageUrl,
  });
}
