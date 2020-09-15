import 'package:flutter/foundation.dart';

import 'country_provider.dart';

class Lodging extends ChangeNotifier{
  final String id;
  final String name;
  final String address;
  final String reservationID;
  final DateTime checkInDateTime;
  final DateTime checkOutDateTime;

  Lodging({
    @required this.id,
    @required this.name,
    @required this.address,
    @required this.reservationID,
    @required this.checkInDateTime,
    @required this.checkOutDateTime,
  });

}