import 'package:flutter/foundation.dart';

import 'country_provider.dart';

class Lodging extends ChangeNotifier{
  final String id;
  final String name;
  final Country country;
  final DateTime checkInDateTime;
  final DateTime checkOutDateTime;

  Lodging({
    @required this.id,
    @required this.name,
    @required this.country,
    @required this.checkInDateTime,
    @required this.checkOutDateTime,
  });

}