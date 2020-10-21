import 'package:flutter/foundation.dart';

class Activity extends ChangeNotifier {
  String id;
  String title;
  String phoneNumber;
  String website;
  String reservationID;
  String address;
  double latitude;
  double longitude;
  DateTime startingDateTime;
  DateTime endingDateTime;
  String activityImageUrl;

  Activity({
    this.id,
    this.title,
    this.phoneNumber,
    this.website,
    this.reservationID,
    this.address,
    this.latitude,
    this.longitude,
    this.startingDateTime,
    this.endingDateTime,
    this.activityImageUrl,
  });
}
