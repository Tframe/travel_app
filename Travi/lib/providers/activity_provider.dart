import 'package:flutter/foundation.dart';

import 'country_provider.dart';

class Activity extends ChangeNotifier{
  final String id;
  final String title;
  final String reservationID;
  final List<String> locationIDs;
  final DateTime startingDateTime;
  final DateTime endingDateTime;

  Activity({
    @required this.id,
    @required this.title,
    @required this.reservationID,
    @required this.locationIDs,
    @required this.startingDateTime,
    this.endingDateTime,
  });

}