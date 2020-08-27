import 'package:flutter/foundation.dart';

import './destination_provider.dart';

enum Sex {
  Female, Male,
  }

class User extends ChangeNotifier{
  String id;
  String email;
  String phone;
  String password;
  String firstName;
  String lastName;
  List<Destination> location;
  String profilePic;

  User({
    this.id,
    this.email,
    this.phone,
    this.password,
    this.firstName,
    this.lastName,
    this.location,
    this.profilePic,
  });

}