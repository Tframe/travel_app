import 'package:flutter/foundation.dart';

import './country_provider.dart';
import './user_provider.dart';


class TripProvider extends ChangeNotifier {
  String id;
  String organizerId;
  String title;
  DateTime startDate;
  DateTime endDate;
  List<Country> countries;
  String tripImageUrl;
  String description;
  List<UserProvider> group;
  bool isPrivate;
  bool destinationsComplete;
  bool transportationsComplete;
  bool lodgingsComplete;
  bool activitiesComplete;

  TripProvider({
    this.id,
    this.organizerId,
    this.title,
    this.startDate,
    this.endDate,
    this.countries,
    this.tripImageUrl,
    this.description,
    this.group,
    this.isPrivate,
    this.destinationsComplete,
    this.activitiesComplete,
    this.lodgingsComplete,
    this.transportationsComplete,
  });
}
