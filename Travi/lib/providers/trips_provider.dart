/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: Add, update, and remove operations
 * for storing Trips data into Firebase Firestore.
 */
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './trip_provider.dart';
import './user_provider.dart';
import './country_provider.dart';

class TripsProvider extends ChangeNotifier {
  List<TripProvider> _trips = [];

  TripsProvider();

  //getter function to return list of trips
  List<TripProvider> get trips {
    return [..._trips];
  }

  //find trip by id
  TripProvider findById(String id) {
    print(id);
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
        'organizerId': userId,
        'startDate': tripValues.startDate,
        'endDate': tripValues.endDate,
        'transportationsComplete': false,
        'lodgingsComplete': false,
        'activitiesComplete': false,
        'tripImageUrl': '',
        'description': tripValues.description,
        'companionsId': tripValues.companionsId,
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
                      'invitationStatus': group.invitationStatus,
                    })
                .toList()
            : [],
        'isPrivate': true,
      }).then((docRef) async {
        tripValues.id = docRef.id;
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc('$userId')
              .collection('trips')
              .doc('${docRef.id}')
              .update({
            'id': docRef.id,
          }).then(
            (value) => print('Trip added'),
          );
        } catch (error) {
          throw error;
        }
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
        description: tripValues.description,
        group: tripValues.group,
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
    List<String> companions = [];
    _trips = [];
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('${user.uid}')
          .collection('trips')
          .get()
          .then(
        (trip) {
          trip.docs.asMap().forEach(
            (index, data) {
              tempTrip = null;
              tempTrip = TripProvider(
                id: trip.docs[index].id,
                organizerId: trip.docs[index].data()['organizerId'],
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
                          invitationStatus: groupData['invitationStatus'],
                        ));
                      })
                    : [],
                isPrivate: trip.docs[index].data()['isPrivate'],
              );
              loadedTrips.add(tempTrip);
              loadedTrips[index].group = loadedUsers;
              loadedTrips[index].companionsId = companions;
              companions = [];
              loadedUsers = [];
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
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  //Fetch and add invited trips to trips list
  Future<void> fetchAndSetInvitedTrip(String userId, String tripId) async {
    final List<TripProvider> loadedTrips = [..._trips];
    TripProvider tempTrip;
    List<UserProvider> loadedUsers = [];
    List<String> companions = [];
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('trips')
          .doc('$tripId')
          .get()
          .then(
        (DocumentSnapshot doc) {
          tempTrip = TripProvider(
            id: doc.id,
            organizerId: doc.data()['organizerId'],
            title: doc.data()['title'],
            startDate: doc.data()['startDate'].toDate(),
            endDate: doc.data()['endDate'].toDate(),
            description: doc.data()['description'],
            tripImageUrl: doc.data()['tripImageUrl'],
            transportationsComplete: doc.data()['transportationsComplete'],
            lodgingsComplete: doc.data()['lodgingsComplete'],
            activitiesComplete: doc.data()['activitiesComplete'],
            group: doc.data()['group'] != null
                ? doc.data()['group'].asMap().forEach((groupIndex, groupData) {
                    loadedUsers.add(UserProvider(
                      id: groupData['id'],
                      firstName: groupData['firstName'],
                      lastName: groupData['lastName'],
                      email: groupData['email'],
                      phone: groupData['phone'],
                      profilePicUrl: groupData['profilePicUrl'],
                      invitationStatus: groupData['invitationStatus'],
                    ));
                  })
                : [],
            isPrivate: doc.data()['isPrivate'],
          );
          loadedTrips.add(tempTrip);
          loadedTrips[loadedTrips.length - 1].group = loadedUsers;
          loadedTrips[loadedTrips.length - 1].companionsId = companions;
          companions = [];
          loadedUsers = [];
        },
      ).then((value) async {
        print('Trip found');
      }).catchError((onError) {
        print('Failed to find Trip');
        throw onError;
      });
    } catch (error) {
      throw error;
    }
    await setTripsList(loadedTrips);
    notifyListeners();
  }

  //take in list of countries with their cities and their cities' activities, lodgings,
  //transportations, flights, and restaurants.
  void setCountriesCities(String tripId, List<Country> countryList) {
    final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
    _trips[tripIndex].countries = countryList;
    notifyListeners();
  }

  //receiving new list of trips with their countries list
  Future<void> setCountriesToTrip(List<TripProvider> trips) {
    _trips = trips;
    return null;
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

  //Updates the companions list for trip
  Future<void> updateCompanions(
    TripProvider currentTrip,
    String userId,
    String organizerFirstName,
    String organizerLastName,
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
                    'invitationStatus': companion.invitationStatus,
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

  //removes a companion from the list of companion ids
  Future<void> removeFromCompanionsList(
    String currentTripId,
    String userId,
    int tripIndex,
    int companionsIndex,
  ) async {
    _trips[tripIndex].companionsId.removeAt(companionsIndex);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('trips')
          .doc('$currentTripId')
          .update({
        'companionsId': _trips[tripIndex].companionsId,
      }).then((value) {
        print('removed from companionslist');
      });
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  //Removes chosen companion
  Future<void> removeCompanion(
    TripProvider currentTrip,
    int groupIndex,
  ) async {
    final tripIndex = _trips.indexWhere((trip) => trip.id == currentTrip.id);

    print(_trips[tripIndex].group[groupIndex].id);

    final companionsIndex = _trips[tripIndex].companionsId.indexWhere(
        (companion) => companion == _trips[tripIndex].group[groupIndex].id);

    _trips[tripIndex].group.removeAt(groupIndex);

    if (tripIndex >= 0) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc('${currentTrip.organizerId}')
            .collection('trips')
            .doc('${currentTrip.id}')
            .update({
          'group': _trips[tripIndex]
              .group
              .map((companion) => {
                    'id': companion.id,
                    'firstName': companion.firstName,
                    'lastName': companion.lastName,
                    'invitationStatus': companion.invitationStatus,
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
    //If companions index is 0 or greater, means companion was found in list,
    //so remove from list. Otherwise, skip it.
    if (companionsIndex >= 0) {
      print('found companion in list');
      //remove fromo list of companions on trip collection
      await removeFromCompanionsList(
          currentTrip.id, currentTrip.organizerId, tripIndex, companionsIndex);
    }

    notifyListeners();
  }

  //Checks if user is already invited to trip. Returns true if is,
  //false if not.
  Future<bool> checkIfInvited(
    String userId,
    String tripId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('invited-trips')
          .get()
          .then((invitedTrips) {
        invitedTrips.docs.asMap().forEach((index, data) {
          if (invitedTrips.docs[index].data()['tripId'] == tripId) {
            print('User is already invited to trip');
            return true;
          }
        });
      });
    } catch (error) {
      throw (error);
    }
    return false;
  }

  //Adds tripid to list of trips user is invited to
  Future<void> addTripToCompanion(
    String userId,
    String organizerUserId,
    String organizerFirstName,
    String organizerLastName,
    String inviterId,
    String inviterFirstName,
    String inviterLastName,
    String tripId,
    String tripTitle,
  ) async {
    //Add trip information to list of trip invitations.
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('invited-trips')
          .add({
        'organizerUserId': organizerUserId,
        'organizerFirstName': organizerFirstName,
        'organizerLastName': organizerLastName,
        'inviterId': inviterId,
        'inviterFirstName': inviterFirstName,
        'inviterLastName': inviterLastName,
        'tripId': tripId,
        'tripTitle': tripTitle,
        'status': 'pending',
        'unread': true,
      }).then((value) {
        print('Trip added');
      });
    } catch (error) {
      throw error;
    }
  }

  //Update trip details group invitation status, if new status
  //is 'Accepted', add current user id to companionsId list.
  Future<void> updateGroupInvitationStatus(
    String tripId,
    String organizerId,
    String userId,
    List<UserProvider> users,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('trips')
          .doc('$tripId')
          .update({
        'group': users
            .map((companion) => {
                  'id': companion.id,
                  'firstName': companion.firstName,
                  'lastName': companion.lastName,
                  'invitationStatus': companion.invitationStatus,
                  'location': companion.location,
                  'about': companion.about,
                  'email': companion.email,
                  'phone': companion.phone,
                  'profilePicUrl': companion.profilePicUrl,
                })
            .toList()
      });
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  //Update companionsIds list on trip when use accepts invitation
  Future<void> addToCompanions(
    String tripId,
    String organizerId,
    String userId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('trips')
          .doc('$tripId')
          .update({
        'companionsId': FieldValue.arrayUnion([userId]),
      });
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }
}
