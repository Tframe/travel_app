import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  String id;
  String email;
  String phone;
  String password;
  String firstName;
  String lastName;
  String address;
  String profilePicUrl;
  String about;
  List<String> sites;
  List<String> followers;

  UserProvider({
    this.id,
    this.email,
    this.phone,
    this.password,
    this.firstName,
    this.lastName,
    this.address,
    this.profilePicUrl,
    this.about,
    this.sites,
    this.followers,
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

  //Add user info to Firestore
  Future<void> addUser(UserProvider userInfo, String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({
          'id': userId,
          'firstName': userInfo.firstName,
          'lastName': userInfo.lastName,
          'email': userInfo.email,
          'phone': userInfo.phone,
          'address': userInfo.address,
          'profilePicUrl': userInfo.profilePicUrl,
        })
        .then((value) => print('User added'))
        .catchError((error) => print('Failed to add user: $error'));
  }

  //Get single user info by ID
  Future<UserProvider> findUserById(String userId) async {
    print(userId);
    UserProvider loadedUser;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((doc) => {
                loadedUser = UserProvider(
                    id: doc.reference.id,
                    firstName: doc.data()['firstName'],
                    lastName: doc.data()['lastName'],
                    address: doc.data()['address'],
                    email: doc.data()['email'],
                    phone: doc.data()['phone'],
                    profilePicUrl: doc.data()['profilePicUrl'])
              });
    } catch (error) {
      throw error;
    }
    return loadedUser;
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
                  loadedUsers.add(UserProvider(
                    id: doc.reference.id,
                    firstName: doc.data()['firstName'],
                    lastName: doc.data()['lastName'],
                    address: doc.data()['address'],
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

  //Update user name and address
  Future<void> updateUserNameAddress(
      UserProvider userValues, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'firstName': userValues.firstName,
        'lastName': userValues.lastName,
        'address': userValues.address,
      }).then((value) => print('User updated'));
    } catch (error) {
      throw error;
    }
    _users = [];
    _users.add(userValues);
    notifyListeners();
  }


  //Update user name and address
  Future<void> updateUserContact(
      UserProvider userValues, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'phone': userValues.phone,
        'email': userValues.email,
      }).then((value) => print('User updated'));
    } catch (error) {
      throw error;
    }
    _users = [];
    _users.add(userValues);
    notifyListeners();
  }

}
