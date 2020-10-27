import 'package:flutter/foundation.dart';
import 'package:groupy/providers/user_provider.dart';

class Activity extends ChangeNotifier {
  String id;
  String organizerId;
  List<UserProvider> participants;
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
  bool chosen;

  Activity({
    this.id,
    this.organizerId,
    this.participants,
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
    this.chosen,
  });

}
