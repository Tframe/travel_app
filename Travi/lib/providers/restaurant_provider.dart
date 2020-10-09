import 'package:flutter/material.dart';

class Restaurant extends ChangeNotifier {
  String id;
  String name;
  String reservationID;
  DateTime startingDateTime;
  String address;
  String restaurantImageUrl;

  Restaurant({
    this.id,
    this.name,
    this.reservationID,
    this.startingDateTime,
    this.address,
    this.restaurantImageUrl,
  });
}
