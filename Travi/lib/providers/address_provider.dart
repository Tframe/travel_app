import 'package:flutter/material.dart';

class Address extends ChangeNotifier {
  String id;
  String title;
  String address;
  double latitude;
  double longitude;

  Address({
    @required this.id,
    @required this.title,
    @required this.address,
    @required this.latitude,
    @required this.longitude,
  });

}
