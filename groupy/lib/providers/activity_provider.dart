import 'package:flutter/foundation.dart';

import 'country_provider.dart';

class Activity extends ChangeNotifier{
  final String id;
  final String title;
  final Country location;
  final DateTime startingDateTime;
  final DateTime endingDateTime;

  Activity({
    @required this.id,
    @required this.title,
    @required this.location,
    @required this.startingDateTime,
    this.endingDateTime,
  });

}