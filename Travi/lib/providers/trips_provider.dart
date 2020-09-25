import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groupy/providers/address_provider.dart';

import './trip_provider.dart';
import './user_provider.dart';
import './lodging_provider.dart';
import './activity_provider.dart';
import './transportation_provider.dart';
import './city_provider.dart';
import './country_provider.dart';

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
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('trips')
          .add({
        'title': tripValues.title,
        'creator': userId,
        'startDate': tripValues.startDate,
        'endDate': tripValues.endDate,
        'destinationsComplete': tripValues.destinationsComplete,
        'transportationsComplete': tripValues.transportationsComplete,
        'lodgingsComplete': tripValues.lodgingsComplete,
        'activitiesComplete': tripValues.activitiesComplete,
        'countries': tripValues.countries != null
            ? tripValues.countries
                .map((countries) => {
                      'id': countries.id,
                      'country': countries.country,
                      'cities': countries.cities != null
                          ? countries.cities
                              .map((cities) => {
                                    'id': cities.id != null ? cities.id : '',
                                    'city': cities.city,
                                    'latitude': cities.latitude,
                                    'longitude': cities.longitude,
                                    'places': cities.places != null
                                        ? cities.places
                                            .map((places) => {
                                                  'title': '',
                                                  'address': '',
                                                  'latitude': 0.00,
                                                  'longitude': 0.00,
                                                })
                                            .toList()
                                        : [],
                                  })
                              .toList()
                          : [],
                      'latitude': countries.latitude,
                      'longitude': countries.longitude,
                    })
                .toList()
            : [],
        'description': tripValues.description,
        'group': tripValues.group != null
            ? tripValues.group
                .map((group) => {
                      'id': group.id,
                      'firstName': group.firstName,
                      'lastName': group.lastName,
                      'email': group.email,
                      'phone': group.phone,
                      'profilePicUrl': group.profilePicUrl == null
                          ? null
                          : group.profilePicUrl,
                      'requestAccepted': false,
                    })
                .toList()
            : [],
        'activities': tripValues.activities != null
            ? tripValues.activities
                .map((activity) => {
                      'id': '',
                      'title': '',
                      'reservationID': '',
                      'startingDateTime': null,
                      'endingDateTime': null,
                      'address': '',
                    })
                .toList()
            : [],
        'lodgings': tripValues.lodgings != null
            ? tripValues.lodgings
                .map((lodging) => {
                      'id': '',
                      'name': '',
                      'checkInDateTime': null,
                      'checkOutDateTime': null,
                      'address': '',
                      'reservationID': '',
                    })
                .toList()
            : [],
        'tranportations': tripValues.transportations != null
            ? tripValues.transportations
                .map((transportation) => {
                      'id': '',
                      'company': '',
                      'reservationID': '',
                      'startingAddress': '',
                      'endingAddress': '',
                      'startingDateTime': null,
                      'endingDateTime': null,
                    })
                .toList()
            : [],
        'isPrivate': true,
      }).then((value) {
        print('Trip added');
      }).catchError((onError) {
        print('Failed to add Trip');
        throw onError;
      });

      //Create a TripProvider object with newly aquired autogenerated id.
      //This will be used to add to list of trips in the state
      final newTrip = TripProvider(
        id: tripValues.id, //ADD CODE TO GET ID
        title: tripValues.title,
        startDate: tripValues.startDate,
        endDate: tripValues.endDate,
        countries: tripValues.countries,
        description: tripValues.description,
        group: tripValues.group,
        activities: null,
        lodgings: null,
        transportations: null,
        isPrivate: true,
        image: null,
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
    TripProvider tempTrip;
    List<UserProvider> loadedUsers = [];
    List<Country> loadedCountries = [];
    List<City> loadedCities = [];
    List<Address> loadedAddresses = [];
    List<Activity> loadedActivities = [];
    List<Lodging> loadedLodgings = [];
    List<Transportation> loadedTransportations = [];

    _trips = [];
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('${user.uid}')
          .collection('trips')
          .get()
          .then(
        //.forEach(
        (trip) {
          trip.docs.asMap().forEach(
            (index, data) {
              tempTrip = null;
              tempTrip = TripProvider(
                id: trip.docs[index].id,
                title: trip.docs[index].data()['title'],
                startDate: trip.docs[index].data()['startDate'].toDate(),
                endDate: trip.docs[index].data()['endDate'].toDate(),
                description: trip.docs[index].data()['description'],
                transportationsComplete: trip.docs[index].data()['transportationsComplete'],
                lodgingsComplete: trip.docs[index].data()['lodgingsComplete'],
                activitiesComplete: trip.docs[index].data()['activitiesComplete'],
                group: trip.docs[index].data()['group'] != null
                    ? trip.docs[index]
                        .data()['group']
                        .asMap()
                        .forEach((groupIndex, groupData) {
                        loadedUsers.add(UserProvider(
                          id: groupData['id'],
                          firstName: groupData['firstName'],
                          lastName: groupData['lastName'],
                          email: groupData['email'],
                          phone: groupData['phone'],
                          profilePicUrl: groupData['profilePicUrl'],
                        ));
                      })
                    : [],
                countries: trip.docs[index].data()['countries'] != null
                    ? trip.docs[index]
                        .data()['countries']
                        .asMap()
                        .forEach((countryIndex, countryData) {
                        loadedCountries.add(Country(
                          id: countryData['id'],
                          country: countryData['country'],
                          latitude: countryData['latitude'],
                          longitude: countryData['longitude'],
                          cities: countryData['cities'] != null
                              ? countryData['cities']
                                  .asMap()
                                  .forEach((cityIndex, cityData) {
                                  loadedCities.add(City(
                                    id: cityData['id'],
                                    city: cityData['city'],
                                    latitude: cityData['latitude'],
                                    longitude: cityData['longitude'],
                                    places: cityData['places'] != null
                                        ? cityData['places']
                                            .asMap()
                                            .forEach((placeIndex, placeData) {
                                            loadedAddresses.add(Address(
                                              id: null,
                                              title: placeData['title'],
                                              address: placeData['address'],
                                              latitude: placeData['latitude'],
                                              longitude: placeData['longitude'],
                                            ));
                                          })
                                        : [],
                                  ));
                                  loadedCities[cityIndex].places =
                                      loadedAddresses;
                                  loadedAddresses = [];
                                })
                              : [],
                        ));
                        loadedCountries[countryIndex].cities = loadedCities;
                        loadedCities = [];
                      })
                    : [],
                activities: trip.docs[index].data()['activities'] != null
                    ? trip.docs[index]
                        .data()['activities']
                        .asMap()
                        .forEach((activitiesIndex, activitiesData) {
                        loadedActivities.add(Activity(
                          id: null,
                          title: activitiesData['title'],
                          reservationID: activitiesData['reservationID'],
                          address: activitiesData['locationIDs'],
                          startingDateTime: activitiesData['startingDateTime'],
                          endingDateTime: activitiesData['endingDateTime'],
                        ));
                      })
                    : [],
                lodgings: trip.docs[index].data()['lodgings'] != null
                    ? trip.docs[index]
                        .data()['lodgings']
                        .asMap()
                        .forEach((lodgingsIndex, lodgingsData) {
                        loadedLodgings.add(Lodging(
                          id: null,
                          name: lodgingsData['name'],
                          address: lodgingsData['address'],
                          reservationID: lodgingsData['reservationID'],
                          checkInDateTime: lodgingsData['checkInDateTime'],
                          checkOutDateTime: lodgingsData['checkOutDateTime'],
                        ));
                      })
                    : [],
                transportations: trip.docs[index].data()['transportations'] !=
                        null
                    ? trip.docs[index]
                        .data()['transportations']
                        .asMap()
                        .forEach((transportationsIndex, transportationsData) {
                        loadedTransportations.add(Transportation(
                          id: transportationsData['id'],
                          company: transportationsData['company'],
                          reservationID: transportationsData['reservationID'],
                          startingAddress:
                              transportationsData['startingLocation'],
                          startingDateTime:
                              transportationsData['startingDateTime'],
                          endingAddress: transportationsData['endingLocation'],
                          endingDateTime: transportationsData['endingDateTime'],
                          transportationType:
                              transportationsData['transportationType'],
                        ));
                      })
                    : [],
                isPrivate: trip.docs[index].data()['isPrivate'],
                image: trip.docs[index].data()['imageUrl'],
              );
              loadedTrips.add(tempTrip);
              loadedTrips[index].group = loadedUsers;
              loadedTrips[index].countries = loadedCountries;
              loadedTrips[index].activities = loadedActivities;
              loadedTrips[index].lodgings = loadedLodgings;
              loadedTrips[index].transportations = loadedTransportations;
              loadedUsers = [];
              loadedCountries = [];
              loadedActivities = [];
              loadedLodgings = [];
              loadedTransportations = [];
            },
          );
        },
      ).then((value) {
        print('Trip found');
      }).catchError((onError) {
        print('Failed to find Trip');
        throw onError;
      });

      await setTripsList(loadedTrips);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  //Update user specified trip in Firebase Firestore
  Future<void> updateTripCompleted(
      String tripId, String taskCompleted, bool mark, User userId) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
    if (tripIndex >= 0) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc('${userId.uid}')
            .collection('trips')
            .doc('$tripId')
            .update({'$taskCompleted': mark}).then(
          (value) {
            print('Trip updated');
          },
        );
      } catch (error) {
        throw error;
      }
    }
    if (taskCompleted == 'activitiesComplete') {
      _trips[tripIndex].activitiesComplete = mark;
    } else if (taskCompleted == 'lodgingsComplete') {
      _trips[tripIndex].lodgingsComplete = mark;
    } else if (taskCompleted == 'transportationsComplete') {
      _trips[tripIndex].transportationsComplete = mark;
    }
    notifyListeners();
  }
}
