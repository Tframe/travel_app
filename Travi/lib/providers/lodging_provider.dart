import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Lodging extends ChangeNotifier {
  String id;
  String name;
  String address;
  String country;
  String city;
  String reservationID;
  DateTime checkInDate;
  TimeOfDay checkInTime;
  DateTime checkOutDate;
  TimeOfDay checkOutTime;

  Lodging({
    @required this.id,
    @required this.name,
    @required this.address,
    @required this.country,
    @required this.city,
    @required this.reservationID,
    @required this.checkInDate,
    @required this.checkInTime,
    @required this.checkOutDate,
    @required this.checkOutTime,
  });
}
