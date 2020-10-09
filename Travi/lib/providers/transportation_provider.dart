import 'package:flutter/foundation.dart';

enum TransportationType {
  Train,
  Boat,
  CarRental,
  CarPickup, //Like Uber or Lyft
}

class Transportation extends ChangeNotifier {
  String id;
  String company;
  String reservationID;
  String startingAddress;
  DateTime startingDateTime;
  String endingAddress;
  DateTime endingDateTime;
  String transportationType;
  String transportationImageUrl;

  Transportation({
    @required this.id,
    @required this.company,
    @required this.reservationID,
    @required this.startingAddress,
    @required this.startingDateTime,
    @required this.endingAddress,
    @required this.endingDateTime,
    @required this.transportationType,
    this.transportationImageUrl,
  });
}
