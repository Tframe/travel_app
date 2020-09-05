import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './trip_provider.dart';
import './user_provider.dart';
import './lodging_provider.dart';
import './activity_provider.dart';
import './transportation_provider.dart';
import 'country_provider.dart';

class TripsProvider extends ChangeNotifier {
  List<TripProvider> _trips = [];

  TripsProvider();

  //getter function to return list of trips
  List<TripProvider> get trips {
    return [..._trips];
  }

  TripProvider findById(String id) {
    return _trips.firstWhere((trip) => trip.id == id);
  }

  //Adds a user created trip to their trips list in Firebase Firestore DB
  Future<void> addTrip(TripProvider tripValues, String userId) async {
    try {
      //Create a TripProvider object with newly aquired autogenerated id.
      //This will be used to add to list of trips in the state
      final newTrip = TripProvider(
        id: null, //ADD CODE TO GET ID
        title: tripValues.title,
        startDate: tripValues.startDate,
        endDate: tripValues.endDate,
        countries: tripValues.countries,
        description: tripValues.description,
      );
      _trips.add(newTrip);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  //used to set trips once trips are loaded from firebase
  Future<void> setTripsList(List<TripProvider> loadedTrip) async {
    _trips = loadedTrip;
  }

  //Get trips list of specific user from Firebase Firestore
  Future<void> fetchAndSetTrips(User user) async {
    final List<TripProvider> loadedTrips = [];
    _trips = [];
    try {
      FirebaseFirestore.instance
          .collection('/users/${user.uid}/trips')
          .snapshots()
          .forEach((trip) {
        trip.docs.asMap().forEach((index, data) {
          loadedTrips.add(TripProvider(
            id: trip.docs[index].id,
            title: trip.docs[index].data()['title'],
            startDate: trip.docs[index].data()['startDate'].toDate(),
            endDate: trip.docs[index].data()['endDate'].toDate(),
            description: trip.docs[index].data()['description'],
            group: List.from(trip.docs[index].data()['group']),
            countries: List.from(trip.docs[index].data()['destinations']),
            activities: List.from(trip.docs[index].data()['activities']),
            lodgings: List.from(trip.docs[index].data()['lodgings']),
            transportations:
                List.from(trip.docs[index].data()['transportations']),
            image: trip.docs[index].data()['imageUrl'],
          ));
        });
      });
      await setTripsList(loadedTrips);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  //Update user specified trip in Firebase Firestore
  Future<void> updateTrip(
      String id, TripProvider newTrip, String userId) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == id);
    if (tripIndex >= 0) {
      try {} catch (error) {
        throw error;
      }
    }
  }
}
