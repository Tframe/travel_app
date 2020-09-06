import 'package:flutter/material.dart';
import 'city_provider.dart';

class Cities extends ChangeNotifier {
  List<City> _cities = [];
  Cities();

  //getter function to return list of trips
  List<City> get cities {
    return [..._cities];
  }

  //Function to add destination to Firebase Firestore
  Future<void> addCity(City cityValues) async {
    try {
      //Create a TripProvider object with newly aquired autogenerated id.
      //This will be used to add to list of trips in the state
      final newCity = City(
        id: null, //ADD CODE TO GET ID
        city: cityValues.city,
        latitude: cityValues.latitude,
        longitude: cityValues.longitude,
      );
      _cities.add(newCity);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  //Function to update desetination in Firebase Firestore

  //Function to remove a country from the list
  Future<void> removeCity(int index) async {
    try {
      if (index > _cities.length - 1 || index < 0) {
        return;
      }
      _cities.removeAt(index);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  //Function to remove all countries from list.
  Future<void> removeAllCities() async {
    try {
      if (_cities.length > 0) {
        _cities = [];
        notifyListeners();
      }
      return;
    } catch (error) {
      throw error;
    }
  }
}
