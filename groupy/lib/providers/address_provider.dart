import 'package:flutter/material.dart';

class Address extends ChangeNotifier {
  String id;
  String address;
  double latitude;
  double longitude;

  Address({
    @required this.id,
    @required this.address,
    @required this.latitude,
    @required this.longitude,
  });

}
