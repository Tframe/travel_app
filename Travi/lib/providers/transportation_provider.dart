import 'package:flutter/foundation.dart';
import 'package:groupy/providers/user_provider.dart';

enum TransportationType {
  Train,
  Boat,
  CarRental,
  CarPickup, //Like Uber or Lyft
}

class Transportation extends ChangeNotifier {
  String id;
  String organizerId;
  List<UserProvider> participants;
  String company;
  String phoneNumber;
  String website;
  String reservationID;
  String startingAddress;
  double startingLatitude;
  double startingLongitude;
  DateTime startingDateTime;
  String endingAddress;
  double endingLatitude;
  double endingLongitude;
  DateTime endingDateTime;
  String transportationType;
  String transportationImageUrl;
  bool chosen;

  Transportation({
    this.id,
    this.organizerId,
    this.participants,
    this.company,
    this.phoneNumber,
    this.website,
    this.reservationID,
    this.startingAddress,
    this.startingLatitude,
    this.startingLongitude,
    this.startingDateTime,
    this.endingAddress,
    this.endingLatitude,
    this.endingLongitude,
    this.endingDateTime,
    this.transportationType,
    this.transportationImageUrl,
    this.chosen,
  });
}
