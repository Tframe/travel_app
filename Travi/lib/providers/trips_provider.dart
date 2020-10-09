import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groupy/providers/restaurant_provider.dart';
import '../providers/address_provider.dart';

import './trip_provider.dart';
import './user_provider.dart';
import './lodging_provider.dart';
import './activity_provider.dart';
import './transportation_provider.dart';
import './city_provider.dart';
import './country_provider.dart';
import './flight_provider.dart';
import './restaurant_provider.dart';

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
        'transportationsComplete': false,
        'lodgingsComplete': false,
        'activitiesComplete': false,
        'tripImageUrl': '',
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
                                    'cityImageUrl': cities.cityImageUrl,
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
                      'countryImageUrl': countries.countryImageUrl,
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
                      'activityImageUrl': '',
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
                      'lodgingImageUrl': '',
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
                      'transportationImageUrl': '',
                    })
                .toList()
            : [],
        'flights': tripValues.flights != null
            ? tripValues.flights
                .map((flight) => {
                      'id': '',
                      'airline': '',
                      'flightNumber': '',
                      'confirmationNumber': '',
                      'departureAirport': '',
                      'departureDateTime': null,
                      'departureTerminal': '',
                      'departureGate': '',
                      'arrivalAirport': '',
                      'arrivalDateTime': null,
                      'arrivalTerminal': '',
                      'arrivalGate': '',
                    })
                .toList()
            : [],
        'restaurants': tripValues.restaurants != null
            ? tripValues.restaurants
                .map((restaurant) => {
                      'id': '',
                      'name': '',
                      'reservationID': '',
                      'address': '',
                      'startingDateTime': null,
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
        tripImageUrl: null,
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
    List<Flight> loadedFlights = [];
    List<Restaurant> loadedRestaurants = [];

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
                tripImageUrl: trip.docs[index].data()['tripImageUrl'],
                transportationsComplete:
                    trip.docs[index].data()['transportationsComplete'],
                lodgingsComplete: trip.docs[index].data()['lodgingsComplete'],
                activitiesComplete:
                    trip.docs[index].data()['activitiesComplete'],
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
                          countryImageUrl: countryData['countryImageUrl'],
                          cities: countryData['cities'] != null
                              ? countryData['cities']
                                  .asMap()
                                  .forEach((cityIndex, cityData) {
                                  loadedCities.add(City(
                                    id: cityData['id'],
                                    city: cityData['city'],
                                    latitude: cityData['latitude'],
                                    longitude: cityData['longitude'],
                                    cityImageUrl: cityData['cityImageUrl'],
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
                          address: activitiesData['address'],
                          startingDateTime:
                              activitiesData['startingDateTime'].toDate(),
                          endingDateTime:
                              activitiesData['endingDateTime'].toDate(),
                          activityImageUrl: activitiesData['activityImageUrl'],
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
                          checkInDateTime:
                              lodgingsData['checkInDateTime'].toDate(),
                          checkOutDateTime:
                              lodgingsData['checkOutDateTime'].toDate(),
                          lodgingImageUrl: lodgingsData['lodgingImageUrl'],
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
                              transportationsData['startingAddress'],
                          startingDateTime:
                              transportationsData['startingDateTime'].toDate(),
                          endingAddress: transportationsData['endingAddress'],
                          endingDateTime:
                              transportationsData['endingDateTime'].toDate(),
                          transportationType:
                              transportationsData['transportationType'],
                        ));
                      })
                    : [],
                flights: trip.docs[index].data()['flights'] != null
                    ? trip.docs[index]
                        .data()['flights']
                        .asMap()
                        .forEach((flightsIndex, flightData) {
                        loadedFlights.add(Flight(
                          id: flightData['id'],
                          airline: flightData['airline'],
                          flightNumber: flightData['flightNumber'],
                          confirmationNumber: flightData['confirmationNumber'],
                          departureAirport: flightData['departureAirport'],
                          departureDateTime:
                              flightData['departureDateTime'].toDate(),
                          departureTerminal: flightData['departureTerminal'],
                          departureGate: flightData['departureGate'],
                          arrivalAirport: flightData['arrivalAirport'],
                          arrivalDateTime:
                              flightData['arrivalDateTime'].toDate(),
                          arrivalTerminal: flightData['arrivalTerminal'],
                          arrivalGate: flightData['arrivalGate'],
                        ));
                      })
                    : [],
                restaurants: trip.docs[index].data()['restaurants'] != null
                    ? trip.docs[index]
                        .data()['restaurants']
                        .asMap()
                        .forEach((restaurantIndex, restaurantsData) {
                        loadedRestaurants.add(Restaurant(
                          id: restaurantsData['id'],
                          name: restaurantsData['name'],
                          reservationID: restaurantsData['reservationID'],
                          startingDateTime:
                              restaurantsData['startingDateTime'].toDate(),
                          address: restaurantsData['address'],
                        ));
                      })
                    : [],
                isPrivate: trip.docs[index].data()['isPrivate'],
              );
              loadedTrips.add(tempTrip);
              loadedTrips[index].group = loadedUsers;
              loadedTrips[index].countries = loadedCountries;
              loadedTrips[index].activities = loadedActivities;
              loadedTrips[index].lodgings = loadedLodgings;
              loadedTrips[index].transportations = loadedTransportations;
              loadedTrips[index].flights = loadedFlights;
              loadedTrips[index].restaurants = loadedRestaurants;
              loadedUsers = [];
              loadedCountries = [];
              loadedActivities = [];
              loadedLodgings = [];
              loadedTransportations = [];
              loadedFlights = [];
              loadedRestaurants = [];
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
  Future<void> updateTripDetails(TripProvider updatedTrip, User userId) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == updatedTrip.id);
    if (tripIndex >= 0) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc('${userId.uid}')
            .collection('trips')
            .doc('${updatedTrip.id}')
            .update({
          'title': updatedTrip.title,
          'description': updatedTrip.description,
          'startDate': updatedTrip.startDate,
          'endDate': updatedTrip.endDate,
        }).then(
          (value) {
            print('Trip updated');
          },
        );
      } catch (error) {
        throw error;
      }
    }
    notifyListeners();
  }

  //Update user specified trip in Firebase Firestore
  Future<void> updateTripCompleted(
      String tripId, String taskCompleted, bool mark, User user) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
    if (tripIndex >= 0) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc('${user.uid}')
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

  //Add lodging to a trip
  //If editLodgingIndex is -1, then adding lodging to trip,
  //else if editLodgingIndex > -1, then editing that lodging
  Future<void> addOrEditLodging(
    TripProvider currentTrip,
    String userId,
    Lodging newLodging,
    int editLodgingIndex,
  ) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == currentTrip.id);
    List<Lodging> tempLodge = [];
    if (editLodgingIndex == -1) {
      currentTrip.lodgings.add(newLodging);
      tempLodge = currentTrip.lodgings;
    } else if (editLodgingIndex > -1) {
      currentTrip.lodgings[editLodgingIndex] = newLodging;
      tempLodge = currentTrip.lodgings;
    }

    tempLodge.sort((a, b) => a.checkInDateTime.compareTo(b.checkInDateTime));

    if (tripIndex >= 0) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc('$userId')
            .collection('trips')
            .doc('${currentTrip.id}')
            .update({
          'lodgings': tempLodge
              .map((lodging) => {
                    'name': lodging.name,
                    'address': lodging.address,
                    'checkInDateTime': lodging.checkInDateTime,
                    'checkOutDateTime': lodging.checkOutDateTime,
                    'reservationID': lodging.reservationID,
                    'lodgingImageUrl': lodging.lodgingImageUrl,
                  })
              .toList()
        }).then(
          (value) {
            print('Lodging updated');
          },
        );
      } catch (error) {
        throw error;
      }
    }
    _trips[tripIndex].lodgings = tempLodge;
    notifyListeners();
  }

  //Removes chosen transportation
  Future<void> removeLodging(
    TripProvider currentTrip,
    String userId,
    int lodgingIndex,
  ) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == currentTrip.id);

    _trips[tripIndex].lodgings.removeAt(lodgingIndex);
    if (tripIndex >= 0) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc('$userId')
            .collection('trips')
            .doc('${currentTrip.id}')
            .update({
          'lodgings': _trips[tripIndex]
              .lodgings
              .map((lodging) => {
                    'name': lodging.name,
                    'address': lodging.address,
                    'checkInDateTime': lodging.checkInDateTime,
                    'checkOutDateTime': lodging.checkOutDateTime,
                    'reservationID': lodging.reservationID,
                    'lodgingImageUrl': lodging.lodgingImageUrl,
                  })
              .toList()
        }).then(
          (value) {
            print('lodging updated');
          },
        );
      } catch (error) {
        throw error;
      }
    }
    notifyListeners();
  }

  //Add lodging to a trip
  //If editLodgingIndex is -1, then adding lodging to trip,
  //else if editLodgingIndex > -1, then editing that lodging
  Future<void> addOrEditRestaurant(
    TripProvider currentTrip,
    String userId,
    Restaurant newRestaurant,
    int editRestaurantIndex,
  ) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == currentTrip.id);
    List<Restaurant> tempRestaurant = [];
    if (editRestaurantIndex == -1) {
      currentTrip.restaurants.add(newRestaurant);
      tempRestaurant = currentTrip.restaurants;
    } else if (editRestaurantIndex > -1) {
      currentTrip.restaurants[editRestaurantIndex] = newRestaurant;
      tempRestaurant = currentTrip.restaurants;
    }

    tempRestaurant
        .sort((a, b) => a.startingDateTime.compareTo(b.startingDateTime));

    if (tripIndex >= 0) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc('$userId')
            .collection('trips')
            .doc('${currentTrip.id}')
            .update({
          'restaurants': tempRestaurant
              .map((restaurant) => {
                    'name': restaurant.name,
                    'address': restaurant.address,
                    'startingDateTime': restaurant.startingDateTime,
                    'reservationID': restaurant.reservationID,
                  })
              .toList()
        }).then(
          (value) {
            print('Restaurant updated');
          },
        );
      } catch (error) {
        throw error;
      }
    }
    _trips[tripIndex].restaurants = tempRestaurant;
    notifyListeners();
  }

  //Removes chosen transportation
  Future<void> removeRestaurant(
    TripProvider currentTrip,
    String userId,
    int restaurantIndex,
  ) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == currentTrip.id);

    _trips[tripIndex].restaurants.removeAt(restaurantIndex);
    if (tripIndex >= 0) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc('$userId')
            .collection('trips')
            .doc('${currentTrip.id}')
            .update({
          'restaurants': _trips[tripIndex]
              .restaurants
              .map((restaurant) => {
                    'name': restaurant.name,
                    'address': restaurant.address,
                    'startingDateTime': restaurant.startingDateTime,
                    'reservationID': restaurant.reservationID,
                  })
              .toList()
        }).then(
          (value) {
            print('lodging updated');
          },
        );
      } catch (error) {
        throw error;
      }
    }
    notifyListeners();
  }

  //Updates the companions list for trip
  Future<void> updateCompanions(
    TripProvider currentTrip,
    String userId,
    List<UserProvider> newCompanionList,
  ) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == currentTrip.id);

    if (tripIndex >= 0) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc('$userId')
            .collection('trips')
            .doc('${currentTrip.id}')
            .update({
          'group': newCompanionList
              .map((companion) => {
                    'id': companion.id,
                    'firstName': companion.firstName,
                    'lastName': companion.lastName,
                    'location': companion.location,
                    'about': companion.about,
                    'email': companion.email,
                    'phone': companion.phone,
                    'profilePicUrl': companion.profilePicUrl,
                  })
              .toList()
        }).then(
          (value) {
            print('users updated');
          },
        );
      } catch (error) {
        throw error;
      }
    }
    _trips[tripIndex].group = newCompanionList;
    notifyListeners();
  }

  //Removes chosen companion
  Future<void> removeCompanion(
    TripProvider currentTrip,
    String userId,
    int groupIndex,
  ) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == currentTrip.id);

    _trips[tripIndex].group.removeAt(groupIndex);
    if (tripIndex >= 0) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc('$userId')
            .collection('trips')
            .doc('${currentTrip.id}')
            .update({
          'group': _trips[tripIndex]
              .group
              .map((companion) => {
                    'id': companion.id,
                    'firstName': companion.firstName,
                    'lastName': companion.lastName,
                    'location': companion.location,
                    'about': companion.about,
                    'email': companion.email,
                    'phone': companion.phone,
                    'profilePicUrl': companion.profilePicUrl,
                  })
              .toList()
        }).then(
          (value) {
            print('group updated');
          },
        );
      } catch (error) {
        throw error;
      }
    }
    notifyListeners();
  }

  //Updates current Trip list of Transportations, sorts by startDateTime
  Future<void> addOrEditTransportation(
    TripProvider currentTrip,
    String userId,
    Transportation newTransportations,
    int editTransportationIndex,
  ) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == currentTrip.id);

    if (editTransportationIndex == -1) {
      _trips[tripIndex].transportations.add(newTransportations);
    } else if (editTransportationIndex > -1) {
      _trips[tripIndex].transportations[editTransportationIndex] =
          newTransportations;
    }

    _trips[tripIndex]
        .transportations
        .sort((a, b) => a.startingDateTime.compareTo(b.startingDateTime));

    if (tripIndex >= 0) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc('$userId')
            .collection('trips')
            .doc('${currentTrip.id}')
            .update({
          'transportations': _trips[tripIndex]
              .transportations
              .map((transportation) => {
                    'transportationType': transportation.transportationType,
                    'company': transportation.company,
                    'startingDateTime': transportation.startingDateTime,
                    'endingDateTime': transportation.endingDateTime,
                    'startingAddress': transportation.startingAddress,
                    'endingAddress': transportation.endingAddress,
                    'reservationID': transportation.reservationID,
                    'transportationImageUrl':
                        transportation.transportationImageUrl,
                  })
              .toList()
        }).then(
          (value) {
            print('transportations updated');
          },
        );
      } catch (error) {
        throw error;
      }
    }
    notifyListeners();
  }

  //Removes chosen transportation
  Future<void> removeTransportation(
    TripProvider currentTrip,
    String userId,
    int transportationIndex,
  ) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == currentTrip.id);

    _trips[tripIndex].transportations.removeAt(transportationIndex);
    if (tripIndex >= 0) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc('$userId')
            .collection('trips')
            .doc('${currentTrip.id}')
            .update({
          'transportations': _trips[tripIndex]
              .transportations
              .map((transportation) => {
                    'transportationType': transportation.transportationType,
                    'company': transportation.company,
                    'startingDateTime': transportation.startingDateTime,
                    'endingDateTime': transportation.endingDateTime,
                    'startingAddress': transportation.startingAddress,
                    'endingAddress': transportation.endingAddress,
                    'reservationID': transportation.reservationID,
                    'transportationImageUrl':
                        transportation.transportationImageUrl,
                  })
              .toList()
        }).then(
          (value) {
            print('transportation updated');
          },
        );
      } catch (error) {
        throw error;
      }
    }
    notifyListeners();
  }

  //adds or edit flight information
  Future<void> addOrEditFlight(
    TripProvider currentTrip,
    String userId,
    Flight newflight,
    int editFlightIndex,
  ) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == currentTrip.id);
    //adds new flight if edit index is < 0,
    //otherwise updates the flight
    if (editFlightIndex == -1) {
      _trips[tripIndex].flights.add(newflight);
    } else if (editFlightIndex > -1) {
      _trips[tripIndex].flights[editFlightIndex] = newflight;
    }
    //sorts the flights by departureDateTime
    _trips[tripIndex]
        .flights
        .sort((a, b) => a.departureDateTime.compareTo(b.departureDateTime));

    if (tripIndex >= 0) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc('$userId')
            .collection('trips')
            .doc('${currentTrip.id}')
            .update({
          'flights': _trips[tripIndex]
              .flights
              .map((flight) => {
                    'id': flight.id,
                    'airline': flight.airline,
                    'flightNumber': flight.flightNumber,
                    'confirmationNumber': flight.confirmationNumber,
                    'departureAirport': flight.departureAirport,
                    'departureDateTime': flight.departureDateTime,
                    'departureTerminal': flight.departureTerminal,
                    'departureGate': flight.departureGate,
                    'arrivalAirport': flight.arrivalAirport,
                    'arrivalDateTime': flight.arrivalDateTime,
                    'arrivalTerminal': flight.arrivalTerminal,
                    'arrivalGate': flight.arrivalGate,
                  })
              .toList()
        }).then(
          (value) {
            print('flight updated');
          },
        );
      } catch (error) {
        throw error;
      }
    }
    notifyListeners();
  }

  Future<void> removeFlight(
    TripProvider currentTrip,
    String userId,
    int flightIndex,
  ) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == currentTrip.id);

    _trips[tripIndex].flights.removeAt(flightIndex);

    if (tripIndex >= 0) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc('$userId')
            .collection('trips')
            .doc('${currentTrip.id}')
            .update({
          'flights': _trips[tripIndex]
              .flights
              .map((flight) => {
                    'id': flight.id,
                    'airline': flight.airline,
                    'flightNumber': flight.flightNumber,
                    'confirmationNumber': flight.confirmationNumber,
                    'departureAirport': flight.departureAirport,
                    'departureDateTime': flight.departureDateTime,
                    'departureTerminal': flight.departureTerminal,
                    'departureGate': flight.departureGate,
                    'arrivalAirport': flight.arrivalAirport,
                    'arrivalDateTime': flight.arrivalDateTime,
                    'arrivalTerminal': flight.arrivalTerminal,
                    'arrivalGate': flight.arrivalGate,
                  })
              .toList()
        }).then(
          (value) {
            print('flight updated');
          },
        );
      } catch (error) {
        throw error;
      }
    }
    notifyListeners();
  }

  //Updates current Trip list of Transportations
  Future<void> addOrEditActivity(
    TripProvider currentTrip,
    String userId,
    Activity newactivity,
    int editActivityIndex,
  ) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == currentTrip.id);

    //adds new activity if edit index is < 0,
    //otherwise updates the activity
    if (editActivityIndex == -1) {
      _trips[tripIndex].activities.add(newactivity);
    } else if (editActivityIndex > -1) {
      _trips[tripIndex].activities[editActivityIndex] = newactivity;
    }

    //sorts the activities by startDateTime
    _trips[tripIndex]
        .activities
        .sort((a, b) => a.startingDateTime.compareTo(b.startingDateTime));

    if (tripIndex >= 0) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc('$userId')
            .collection('trips')
            .doc('${currentTrip.id}')
            .update({
          'activities': _trips[tripIndex]
              .activities
              .map((activity) => {
                    'title': activity.title,
                    'address': activity.address,
                    'startingDateTime': activity.startingDateTime,
                    'endingDateTime': activity.endingDateTime,
                    'reservationID': activity.reservationID,
                    'activityImageUrl': activity.activityImageUrl,
                  })
              .toList()
        }).then(
          (value) {
            print('activity updated');
          },
        );
      } catch (error) {
        throw error;
      }
    }
    notifyListeners();
  }

  //Removes chosen activity
  Future<void> removeActivity(
    TripProvider currentTrip,
    String userId,
    int activityIndex,
  ) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == currentTrip.id);

    _trips[tripIndex].activities.removeAt(activityIndex);
    if (tripIndex >= 0) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc('$userId')
            .collection('trips')
            .doc('${currentTrip.id}')
            .update({
          'activities': _trips[tripIndex]
              .activities
              .map((activity) => {
                    'title': activity.title,
                    'address': activity.address,
                    'startingDateTime': activity.startingDateTime,
                    'endingDateTime': activity.endingDateTime,
                    'reservationID': activity.reservationID,
                    'activityImageUrl': activity.activityImageUrl,
                  })
              .toList()
        }).then(
          (value) {
            print('activity updated');
          },
        );
      } catch (error) {
        throw error;
      }
    }
    notifyListeners();
  }
}
