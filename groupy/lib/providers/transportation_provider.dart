import 'package:flutter/foundation.dart';

import 'destination_provider.dart';

enum TransportationType {
  Flight,
  Train,
  Boat,
  CarRental,
  CarPickup,
}

class Transportation extends ChangeNotifier{
  final String id;
  final String title;
  Destination startingLocation;
  DateTime startingDateTime;
  Destination endingLocation;
  DateTime endingDateTime;
  TransportationType transportationType;
  
  Transportation({
    @required this.id,
    @required this.title,
    @required this.startingLocation,
    @required this.startingDateTime,
    @required this.endingLocation,
    @required this.endingDateTime,
    @required this.transportationType,
  });

}