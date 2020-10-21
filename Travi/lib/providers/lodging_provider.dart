import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Lodging extends ChangeNotifier {
  String id;
  String name;
  String phoneNumber;
  String website;
  String address;
  double latitude;
  double longitude;
  String reservationID;
  DateTime checkInDateTime;
  DateTime checkOutDateTime;
  String lodgingImageUrl;

  Lodging({
    this.id,
    this.name,
    this.phoneNumber,
    this.website,
    this.address,
    this.latitude,
    this.longitude,
    this.reservationID,
    this.checkInDateTime,
    this.checkOutDateTime,
    this.lodgingImageUrl,
  });
}
