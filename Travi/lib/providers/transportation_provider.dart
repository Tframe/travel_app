import 'package:flutter/foundation.dart';

import 'country_provider.dart';

enum TransportationType {
  Flight,
  Train,
  Boat,
  CarRental,
  CarPickup,
}

class Transportation extends ChangeNotifier{
  final String id;
  final String company;
  final String reservationID;
  String startingLocation;
  DateTime startingDateTime;
  String endingLocation;
  DateTime endingDateTime;
  TransportationType transportationType;
  
  Transportation({
    @required this.id,
    @required this.company,
    @required this.reservationID,
    @required this.startingLocation,
    @required this.startingDateTime,
    @required this.endingLocation,
    @required this.endingDateTime,
    @required this.transportationType,
  });

}