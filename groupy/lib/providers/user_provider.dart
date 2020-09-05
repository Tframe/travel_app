import 'package:flutter/foundation.dart';

import 'country_provider.dart';

class UserProvider extends ChangeNotifier{
  String id;
  String email;
  String phone;
  String password;
  String firstName;
  String lastName;
  List<Country> location;
  String profilePicUrl;

  UserProvider({
    this.id,
    this.email,
    this.phone,
    this.password,
    this.firstName,
    this.lastName,
    this.location,
    this.profilePicUrl,
  });

}