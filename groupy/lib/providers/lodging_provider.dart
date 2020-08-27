import 'package:flutter/foundation.dart';

import './destination_provider.dart';

class Lodging extends ChangeNotifier{
  final String id;
  final String name;
  final Destination location;
  final DateTime checkInDateTime;
  final DateTime checkOutDateTime;

  Lodging({
    @required this.id,
    @required this.name,
    @required this.location,
    @required this.checkInDateTime,
    @required this.checkOutDateTime,
  });

}