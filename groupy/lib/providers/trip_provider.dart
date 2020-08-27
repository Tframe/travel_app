import 'package:flutter/foundation.dart';
import 'package:groupy/providers/activity_provider.dart';
import 'package:groupy/providers/lodging_provider.dart';
import 'package:groupy/providers/transportation_provider.dart';
import './destination_provider.dart';
import './user_provider.dart';

class TripProvider extends ChangeNotifier{
  String id;
  String title;
  DateTime startDate;
  DateTime endDate;
  List<Destination> destinations; //Do I want them as destination ID's?
  String image;
  String description;
  List<User> group;
  List<Lodging> lodgings;
  List<Activity> activities;
  List<Transportation> transportations;

  TripProvider({
    @required this.id,
    @required this.title,
    @required this.startDate,
    @required this.endDate,
    @required this.destinations,
    this.image,
    this.description,
    this.group,
    this.lodgings,
    this.activities,
    this.transportations,
  });

}