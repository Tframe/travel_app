/* Author: Trevor Frame
 * Date: 10/27/2020
 * Description: Add, update, and remove operations
 * for storing loddging data into Firebase Firestore.
 * Lodging is a collection under a specific trip
 */

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './user_provider.dart';

class Lodging extends ChangeNotifier {
  String id;
  String organizerId;
  List<UserProvider> participants;
  String name;
  String phoneNumber;
  String website;
  String address;
  double latitude;
  double longitude;
  String reservationID;
  DateTime checkInDateTime;
  DateTime checkOutDateTime;
  String lodgingImageUrl;
  bool chosen;

  Lodging({
    this.id,
    this.organizerId,
    this.participants,
    this.name,
    this.phoneNumber,
    this.website,
    this.address,
    this.latitude,
    this.longitude,
    this.reservationID,
    this.checkInDateTime,
    this.checkOutDateTime,
    this.lodgingImageUrl,
    this.chosen,
  });

  List<Lodging> _lodgings = [];

  List<Lodging> get lodgings {
    return [..._lodgings];
  }

  //verify if list of restaurants is empty
  bool assertLodgingList() {
    if(_lodgings.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  //Add lodging
  Future<void> addLodging(
    String tripId,
    String userId,
    String countryId,
    String cityId,
    Lodging lodging,
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
          .collection('lodgings')
          .add({
        'chosen': lodging.chosen,
        'organizerId': lodging.organizerId,
        'name': lodging.name,
        'address': lodging.address,
        'latitude': lodging.latitude,
        'longitude': lodging.longitude,
        'phoneNumber': lodging.phoneNumber,
        'website': lodging.website,
        'checkInDateTime': lodging.checkInDateTime,
        'checkOutDateTime': lodging.checkOutDateTime,
        'reservationID': lodging.reservationID,
        'lodgingImageUrl': lodging.lodgingImageUrl,
        'participants': lodging.participants
            .map((participant) => {
                  'id': participant.id,
                  'firstName': participant.firstName,
                  'lastName': participant.lastName,
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

    _lodgings.add(lodging);
    notifyListeners();
  }

  //Edit lodging
  Future<void> editLodging(
    String tripId,
    String userId,
    String countryId,
    String cityId,
    Lodging lodging,
    String lodgingId,
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
          .collection('lodgings')
          .doc('$lodgingId')
          .update({
        'chosen': lodging.chosen,
        'organizerId': lodging.organizerId,
        'name': lodging.name,
        'address': lodging.address,
        'latitude': lodging.latitude,
        'longitude': lodging.longitude,
        'phoneNumber': lodging.phoneNumber,
        'website': lodging.website,
        'checkInDateTime': lodging.checkInDateTime,
        'checkOutDateTime': lodging.checkOutDateTime,
        'reservationID': lodging.reservationID,
        'lodgingImageUrl': lodging.lodgingImageUrl,
        'participants': lodging.participants
            .map((participant) => {
                  'id': participant.id,
                  'firstName': participant.firstName,
                  'lastName': participant.lastName,
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
    notifyListeners();
  }

  Future<void> setLodging(List<Lodging> lodgingList) async {
    _lodgings = lodgingList;
  }

  Future<void> fetchAndSetLodging(
    String tripId,
    String userId,
    String countryId,
    String cityId,
  ) async {
    List<Lodging> lodgeList = [];
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
          .collection('lodgings')
          .get()
          .then((lodging) {
        lodging.docs.asMap().forEach((lodgingIndex, lodgingData) {
          lodgeList.add(
            Lodging(
              id: lodgingData.id,
              organizerId: lodgingData.data()['organizerId'],
              name: lodgingData.data()['name'],
              latitude: lodgingData.data()['latitude'],
              longitude: lodgingData.data()['longitude'],
              address: lodgingData.data()['address'],
              phoneNumber: lodgingData.data()['phoneNumber'],
              website: lodgingData.data()['website'],
              reservationID: lodgingData.data()['reservationID'],
              lodgingImageUrl: lodgingData.data()['lodgingImageUrl'],
              checkInDateTime: lodgingData.data()['checkInDateTime'].toDate(),
              checkOutDateTime: lodgingData.data()['checkOutDateTime'].toDate(),
              chosen: lodgingData.data()['chosen'],
              participants: lodgingData.data()['participants'] != null
                  ? lodgingData.data()['participants'].asMap().forEach(
                      (participantIndex, participantData) {
                        participantsList.add(
                          UserProvider(
                            id: participantData['id'],
                            firstName: participantData['firstName'],
                            lastName: participantData['lastName'],
                            email: participantData['email'],
                            phone: participantData['phone'],
                            profilePicUrl: participantData['profilePicUrl'],
                            invitationStatus:
                                participantData['invitationStatus'],
                          ),
                        );
                      },
                    )
                  : [],
            ),
          );
          lodgeList[lodgingIndex].participants = participantsList;
          participantsList = [];
        });
      });
    } catch (error) {
      throw error;
    }
    await setLodging(lodgeList);
    notifyListeners();
  }

  //Removes chosen lodging
  Future<void> removeLodging(
    String tripId,
    String userId,
    String countryId,
    String cityId,
    String lodgingId,
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
          .collection('lodgings')
          .doc('$lodgingId')
          .delete()
          .then(
        (value) {
          print('lodging deleted');
        },
      );
    } catch (error) {
      throw error;
    }
  }

  notifyListeners();
}
