import 'package:flutter/foundation.dart';

class Activity extends ChangeNotifier {
  String id;
  String title;
  String reservationID;
  String address;
  DateTime startingDateTime;
  DateTime endingDateTime;
  String activityImageUrl;

  Activity({
    @required this.id,
    @required this.title,
    @required this.reservationID,
    @required this.address,
    @required this.startingDateTime,
    @required this.endingDateTime,
    this.activityImageUrl,
  });
}
