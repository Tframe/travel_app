import 'package:flutter/material.dart';
import 'package:groupy/providers/user_provider.dart';

class Restaurant extends ChangeNotifier {
  String id;
  String organizerId;
  List<UserProvider> participants;
  String name;
  String phoneNumber;
  String website;
  String reservationID;
  DateTime startingDateTime;
  String address;
  double latitude;
  double longitude;
  String restaurantImageUrl;
  bool chosen;

  Restaurant({
    this.id,
    this.organizerId,
    this.participants,
    this.name,
    this.phoneNumber,
    this.website,
    this.reservationID,
    this.startingDateTime,
    this.address,
    this.latitude,
    this.longitude,
    this.restaurantImageUrl,
    this.chosen,
  });
}
