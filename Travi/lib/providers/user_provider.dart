import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'country_provider.dart';

class UserProvider extends ChangeNotifier {
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

  List<UserProvider> _users = [];

  //getter function to return list of trips
  List<UserProvider> get users {
    return [..._users];
  }

  //used to set companions once users are loaded from firebase
  Future<void> setCompanionsList(List<UserProvider> loadedUser) async {
    _users = loadedUser;
  }

  //Get users list by email
  Future<void> findUserByContactInfo(String contactInfo, bool email) async {
    final List<UserProvider> loadedUsers = [];
    _users = [];
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .where(email ? 'email' : 'phone', isEqualTo: contactInfo)
          .get()
          .then((QuerySnapshot querySnapshot) => {
                querySnapshot.docs.forEach((doc) {
                  
                  //If user already exists on list
                  loadedUsers.forEach((user) {
                    if(user.id == doc.reference.id){
                      print('User is already being added');
                      return;
                    }
                    //Check if user already on trip for once trip is already made
                  });


                  loadedUsers.add(UserProvider(
                    id: doc.reference.id,
                    firstName: doc.data()['firstName'],
                    lastName: doc.data()['lastName'],
                    email: doc.data()['email'],
                    phone: doc.data()['phone'],
                    profilePicUrl: doc.data()['profilePicUrl'],
                  ));
                })
              })
          .catchError((error) {
        print('Error $error');
      });
      await setCompanionsList(loadedUsers);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
