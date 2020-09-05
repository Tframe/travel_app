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
  final String title;
  Country startingLocation;
  DateTime startingDateTime;
  Country endingLocation;
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