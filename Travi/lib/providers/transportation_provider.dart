/* Author: Trevor Frame
 * Date: 10/27/2020
 * Description: Add, update, and remove operations
 * for storing transportation data into Firebase Firestore.
 * Transportation is a collection under a specific trip
 */

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './user_provider.dart';

enum TransportationType {
  Train,
  Boat,
  CarRental,
  CarPickup, //Like Uber or Lyft
}

class Transportation extends ChangeNotifier {
  String id;
  String organizerId;
  List<UserProvider> participants;
  String company;
  String phoneNumber;
  String website;
  String reservationID;
  String startingAddress;
  double startingLatitude;
  double startingLongitude;
  DateTime startingDateTime;
  String endingAddress;
  double endingLatitude;
  double endingLongitude;
  DateTime endingDateTime;
  String transportationType;
  String transportationImageUrl;
  bool chosen;

  Transportation({
    this.id,
    this.organizerId,
    this.participants,
    this.company,
    this.phoneNumber,
    this.website,
    this.reservationID,
    this.startingAddress,
    this.startingLatitude,
    this.startingLongitude,
    this.startingDateTime,
    this.endingAddress,
    this.endingLatitude,
    this.endingLongitude,
    this.endingDateTime,
    this.transportationType,
    this.transportationImageUrl,
    this.chosen,
  });

  List<Transportation> _transportations = [];

  List<Transportation> get transportations {
    return [..._transportations];
  }

  //verify if list of restaurants is empty
  bool assertTransportationList() {
    if(_transportations.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  //add transportation
  Future<void> addTransportation(
    String tripId,
    String userId,
    String countryId,
    String cityId,
    Transportation transportation,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('trips')
          .doc('$tripId')
          .collection('countries')
          .doc('$countryId')
          .collection('cities')
          .doc('$cityId')
          .collection('transportations')
          .add({
        'chosen': transportation.chosen,
        'organizerId': transportation.organizerId,
        'transportationType': transportation.transportationType,
        'company': transportation.company,
        'phoneNumber': transportation.phoneNumber,
        'website': transportation.website,
        'startingDateTime': transportation.startingDateTime,
        'endingDateTime': transportation.endingDateTime,
        'startingAddress': transportation.startingAddress,
        'startingLatitude': transportation.startingLatitude,
        'startingLongitude': transportation.startingLongitude,
        'endingAddress': transportation.endingAddress,
        'endingLatitude': transportation.endingLatitude,
        'endingLongitude': transportation.endingLongitude,
        'reservationID': transportation.reservationID,
        'transportationImageUrl': transportation.transportationImageUrl,
        'participants': transportation.participants
            .map((participants) => {
                  'id': participants.id,
                  'firstName': participants.firstName,
                  'lastName': participants.lastName,
                })
            .toList()
      }).then(
        (value) {
          print('transportations added');
        },
      );
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  //edit transportation
  Future<void> editTransportation(
    String tripId,
    String userId,
    String countryId,
    String cityId,
    Transportation transportation,
    String transportationId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('trips')
          .doc('$tripId')
          .collection('countries')
          .doc('$countryId')
          .collection('cities')
          .doc('$cityId')
          .collection('transportations')
          .doc('$transportationId')
          .update({
        'chosen': transportation.chosen,
        'organizerId': transportation.organizerId,
        'transportationType': transportation.transportationType,
        'company': transportation.company,
        'phoneNumber': transportation.phoneNumber,
        'website': transportation.website,
        'startingDateTime': transportation.startingDateTime,
        'endingDateTime': transportation.endingDateTime,
        'startingAddress': transportation.startingAddress,
        'startingLatitude': transportation.startingLatitude,
        'startingLongitude': transportation.startingLongitude,
        'endingAddress': transportation.endingAddress,
        'endingLatitude': transportation.endingLatitude,
        'endingLongitude': transportation.endingLongitude,
        'reservationID': transportation.reservationID,
        'transportationImageUrl': transportation.transportationImageUrl,
        'participants': transportation.participants
            .map((participants) => {
                  'id': participants.id,
                  'firstName': participants.firstName,
                  'lastName': participants.lastName,
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
    notifyListeners();
  }

  Future<void> setTransportation(
      List<Transportation> transportationList) async {
    _transportations = transportationList;
  }

  Future<void> fetchAndSetTransportations(
    String tripId,
    String userId,
    String countryId,
    String cityId,
  ) async {
    List<Transportation> transportationList = [];
    List<UserProvider> participantsList = [];
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('trips')
          .doc('$tripId')
          .collection('countries')
          .doc('$countryId')
          .collection('cities')
          .doc('$cityId')
          .collection('transportations')
          .get()
          .then((transportation) => {
                transportation.docs
                    .asMap()
                    .forEach((transportationIndex, transportationData) {
                  transportationList.add(
                    Transportation(
                      id: transportationData.id,
                      organizerId: transportationData.data()['organizerId'],
                      company: transportationData.data()['company'],
                      phoneNumber: transportationData.data()['phoneNumber'],
                      website: transportationData.data()['website'],
                      chosen: transportationData.data()['chosen'],
                      reservationID: transportationData.data()['reservationID'],
                      startingAddress:
                          transportationData.data()['startingAddress'],
                      startingLatitude:
                          transportationData.data()['startingLatitude'],
                      startingLongitude:
                          transportationData.data()['startingLongitude'],
                      startingDateTime:
                          transportationData.data()['startingDateTime'].toDate(),
                      endingAddress: transportationData.data()['endingAddress'],
                      endingLatitude:
                          transportationData.data()['endingLatitude'],
                      endingLongitude:
                          transportationData.data()['endingLongitude'],
                      endingDateTime:
                          transportationData.data()['endingDateTime'].toDate(),
                      transportationType:
                          transportationData.data()['transportationType'],
                      transportationImageUrl:
                          transportationData.data()['transportationImageUrl'],
                      participants:
                          transportationData.data()['participants'] != null
                              ? transportationData
                                  .data()['participants']
                                  .asMap()
                                  .forEach(
                                  (participantIndex, participantData) {
                                    participantsList.add(
                                      UserProvider(
                                        id: participantData['id'],
                                        firstName: participantData['firstName'],
                                        lastName: participantData['lastName'],
                                        email: participantData['email'],
                                        phone: participantData['phone'],
                                        profilePicUrl:
                                            participantData['profilePicUrl'],
                                        invitationStatus:
                                            participantData['invitationStatus'],
                                      ),
                                    );
                                  },
                                )
                              : [],
                    ),
                  );
                  transportationList[transportationIndex].participants =
                      participantsList;
                  participantsList = [];
                }),
              });
    } catch (error) {
      throw error;
    }
    await setTransportation(transportationList);
    notifyListeners();
  }

  //Removes chosen transportation
  Future<void> removeTransportation(
    String tripId,
    String userId,
    String countryId,
    String cityId,
    String transportationId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('trips')
          .doc('$tripId')
          .collection('countries')
          .doc('$countryId')
          .collection('cities')
          .doc('$cityId')
          .collection('transportations')
          .doc('$transportationId')
          .delete()
          .then(
        (value) {
          print('transportation updated');
        },
      );
    } catch (error) {
      throw error;
    }

    notifyListeners();
  }
}
