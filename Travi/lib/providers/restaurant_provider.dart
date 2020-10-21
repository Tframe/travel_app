import 'package:flutter/material.dart';

class Restaurant extends ChangeNotifier {
  String id;
  String name;
  String phoneNumber;
  String website;
  String reservationID;
  DateTime startingDateTime;
  String address;
  double latitude;
  double longitude;
  String restaurantImageUrl;

  Restaurant({
    this.id,
    this.name,
    this.phoneNumber,
    this.website,
    this.reservationID,
    this.startingDateTime,
    this.address,
    this.latitude,
    this.longitude,
    this.restaurantImageUrl,
  });
}
