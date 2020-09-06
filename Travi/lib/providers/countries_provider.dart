import 'package:flutter/material.dart';
import 'country_provider.dart';

class Countries extends ChangeNotifier {
  List<Country> _countries = [];
  Countries();

  //getter function to return list of trips
  List<Country> get countries {
    return [..._countries];
  }

  //Function to add destination to Firebase Firestore
  Future<void> addCountry(Country countryValues) async {
    try {
      //Create a TripProvider object with newly aquired autogenerated id.
      //This will be used to add to list of trips in the state
      final newDestination = Country(
        id: null, //ADD CODE TO GET ID
        country: countryValues.country,
        latitude: countryValues.latitude,
        longitude: countryValues.longitude,
      );
      _countries.add(newDestination);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  //Function to update desetination in Firebase Firestore

  //Function to remove a country from the list
  Future<void> removeCountry(int index) async {
    try {
      if (index > _countries.length - 1 || index < 0) {
        return;
      }
      _countries.removeAt(index);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  //Function to remove all countries from list.
  Future<void> removeAllCountries() async {
    try {
      if (_countries.length > 0) {
        _countries = [];
        notifyListeners();
      }
      return;
    } catch (error) {
      throw error;
    }
  }
}
