import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import '../providers/destination_provider.dart';
import '../providers/trips_provider.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  //check if user is authenticated
  bool get isAuth {
    return token != null;
  }

  //get the token
  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  //get the userId
  String get userId {
    return _userId;
  }

  //Add user
  Future<void> addUser(String userId, String email, String firstName,
      String lastName, List<Destination> location, String phone) async {
    final url =
        'https://the-travel-app-0920.firebaseio.com/user/$userId.json?auth=$_token';
    try {
      //send post request to url with a json formatted trip document.
      var response = await http.post(
        url,
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'location': {
            'country': location[0].country,
            'city': location[0].city,
            'state': location[0].state,
          },
        }),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  //Sign up using Firebase Authentication using email and password
  Future<void> signup(String email, String password, List<Destination> location,
      String firstName, String lastName, String phone) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyBl-AsESzqoRB94fU3LAk4XYm6FfbSaN88';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);

      //send http exception error message
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      //store token, userid, and token expire date
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autoLogout();
      addUser(userId, email, firstName, lastName, location, phone);
      notifyListeners();
      //Stores userdata on device storage to be used for autologin
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String()
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  //Sign in using Firebase Authentication using email and password
  Future<void> signin(String email, String password) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBl-AsESzqoRB94fU3LAk4XYm6FfbSaN88';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);

      //send http exception error message
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      //store token, userid, and token expire date
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autoLogout();
      notifyListeners();
      //Stores userdata on device storage to be used for autologin
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String()
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  //attempt to auto login if valid token found on device storage
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    //if there is no user data stored found
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;

    //BELOW IS USED IF WE WANT TOKEN TO EXPIRE
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    //if expiryDate is past, return false
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _expiryDate = expiryDate;
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    print(_userId);
    notifyListeners();
    _autoLogout();
    return true;
  }

  //logout resets auth data
  Future<void> logout() async {
    print('user id is $userId');
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();

    //Clears userData info from device storage
    // prefs.remove('userData');
    //Clears all data from app stored on device
    prefs.clear();
  }

  //auto logout using timers
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    var timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
