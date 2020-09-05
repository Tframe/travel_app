import 'package:flutter/foundation.dart';
import 'package:groupy/providers/country_provider.dart';

class TripProvider extends ChangeNotifier{
  String id;
  String title;
  DateTime startDate;
  DateTime endDate;
  List<Country> countries; //HOW DO WE FIX LIST<DESTINATION> INSTEAD OF LIST<STRING>
  String image;
  String description;
  List<String> group;
  List<String> lodgings;
  List<String> activities;
  List<String> transportations;

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
  });

}