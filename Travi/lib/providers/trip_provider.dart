import 'package:flutter/foundation.dart';
import './activity_provider.dart';
import './country_provider.dart';
import './lodging_provider.dart';
import './transportation_provider.dart';
import './user_provider.dart';

class TripProvider extends ChangeNotifier {
  String id;
  String title;
  DateTime startDate;
  DateTime endDate;
  List<Country> countries;
  String image;
  String description;
  List<UserProvider> group;
  List<Lodging> lodgings;
  List<Activity> activities;
  List<Transportation> transportations;
  bool isPrivate;
  bool destinationsComplete;
  bool transportationsComplete;
  bool lodgingsComplete;
  bool activitiesComplete;

  TripProvider({
    @required this.id,
    @required this.title,
    @required this.startDate,
    @required this.endDate,
    @required this.countries,
    this.image,
    @required this.description,
    this.group,
    this.lodgings,
    this.activities,
    this.transportations,
    this.isPrivate,
    this.destinationsComplete,
    this.activitiesComplete,
    this.lodgingsComplete,
    this.transportationsComplete,
  });
}
