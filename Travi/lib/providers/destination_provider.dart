import 'package:flutter/material.dart';

class Destination extends ChangeNotifier {
  String id;
  String country;
  String state;
  String city;

  Destination({
    @required this.id,
    @required this.country,
    @required this.state,
    @required this.city,
  });
}
