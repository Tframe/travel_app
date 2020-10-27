import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:groupy/providers/user_provider.dart';

class Lodging extends ChangeNotifier {
  String id;
  String organizerId;
  List<UserProvider> participants;
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
  bool chosen;

  Lodging({
    this.id,
    this.organizerId,
    this.participants,
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
    this.chosen,
  });
}
