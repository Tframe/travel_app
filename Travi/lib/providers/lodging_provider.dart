import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Lodging extends ChangeNotifier {
  String id;
  String name;
  String address;
  String reservationID;
  DateTime checkInDateTime;
  DateTime checkOutDateTime;
  String lodgingImageUrl;

  Lodging({
    @required this.id,
    @required this.name,
    @required this.address,
    @required this.reservationID,
    @required this.checkInDateTime,
    @required this.checkOutDateTime,
    this.lodgingImageUrl,
  });
}
