import 'package:flutter/foundation.dart';

import './destination_provider.dart';

class Activity extends ChangeNotifier{
  final String id;
  final String title;
  final Destination location;
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