import 'package:flutter/foundation.dart';

enum TransportationType {
  Flight,
  Train,
  Boat,
  CarRental,
  CarPickup,  //Like Uber or Lyft
}

class Transportation extends ChangeNotifier{
  final String id;
  final String company;
  final String reservationID;
  String startingAddress;
  DateTime startingDateTime;
  String endingAddress;
  DateTime endingDateTime;
  TransportationType transportationType;
  
  Transportation({
    @required this.id,
    @required this.company,
    @required this.reservationID,
    @required this.startingAddress,
    @required this.startingDateTime,
    @required this.endingAddress,
    @required this.endingDateTime,
    @required this.transportationType,
  });

}