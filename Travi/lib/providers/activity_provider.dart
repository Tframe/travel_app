/* Author: Trevor Frame
 * Date: 10/27/2020
 * Description: Add, update, and remove operations
 * for storing activity data into Firebase Firestore.
 * Activity is a collection under a specific trip
 */

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './user_provider.dart';

class Activity extends ChangeNotifier {
  String id;
  String organizerId;
  List<UserProvider> participants;
  String title;
  String phoneNumber;
  String website;
  String reservationID;
  String address;
  double latitude;
  double longitude;
  DateTime startingDateTime;
  DateTime endingDateTime;
  String activityImageUrl;
  bool chosen;

  Activity({
    this.id,
    this.organizerId,
    this.participants,
    this.title,
    this.phoneNumber,
    this.website,
    this.reservationID,
    this.address,
    this.latitude,
    this.longitude,
    this.startingDateTime,
    this.endingDateTime,
    this.activityImageUrl,
    this.chosen,
  });

  List<Activity> _activities = [];

  List<Activity> get activities {
    return [..._activities];
  }

  //add activity
  Future<void> addActivity(
    String tripId,
    String userId,
    String countryId,
    String cityId,
    Activity activity,
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
          .collection('activities')
          .add({
        'chosen': activity.chosen,
        'title': activity.title,
        'organizerId': activity.organizerId,
        'phoneNumber': activity.phoneNumber,
        'website': activity.website,
        'address': activity.address,
        'latitude': activity.latitude,
        'longitude': activity.longitude,
        'startingDateTime': activity.startingDateTime,
        'endingDateTime': activity.endingDateTime,
        'reservationID': activity.reservationID,
        'activityImageUrl': activity.activityImageUrl,
        'participants': activity.participants
            .map((participants) => {
                  'id': participants.id,
                  'firstName': participants.firstName,
                  'lastName': participants.lastName,
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
    notifyListeners();
  }

  //Updates current Trip list of Transportations
  Future<void> editActivity(
    String tripId,
    String userId,
    String countryId,
    String cityId,
    Activity activity,
    String activityId,
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
          .collection('activities')
          .doc('$activityId')
          .update({
        'chosen': activity.chosen,
        'title': activity.title,
        'organizerId': activity.organizerId,
        'phoneNumber': activity.phoneNumber,
        'website': activity.website,
        'address': activity.address,
        'latitude': activity.latitude,
        'longitude': activity.longitude,
        'startingDateTime': activity.startingDateTime,
        'endingDateTime': activity.endingDateTime,
        'reservationID': activity.reservationID,
        'activityImageUrl': activity.activityImageUrl,
        'participants': activity.participants
            .map((participants) => {
                  'id': participants.id,
                  'firstName': participants.firstName,
                  'lastName': participants.lastName,
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
    notifyListeners();
  }

  Future<void> setActivities(List<Activity> activityList) async {
    _activities = activityList;
  }

  Future<void> fetchAndSetActivity(
    String tripId,
    String userId,
    String countryId,
    String cityId,
  ) async {
    List<Activity> activityList = [];
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
          .collection('activities')
          .get()
          .then((activity) {
        if (activity.docs.length > 0) {
          activity.docs.asMap().forEach(
            (activityIndex, activityData) {
              if (activityData.data() != null &&
                  activityData.data().length > 0) {
                activityList.add(
                  Activity(
                    id: activityData.id,
                    organizerId: activityData.data()['organizerId'],
                    title: activityData.data()['title'],
                    phoneNumber: activityData.data()['phoneNumber'],
                    website: activityData.data()['website'],
                    address: activityData.data()['address'],
                    latitude: activityData.data()['latitude'],
                    longitude: activityData.data()['longitude'],
                    chosen: activityData.data()['chosen'],
                    reservationID: activityData.data()['reservationID'],
                    startingDateTime: activityData.data()['startingDateTime'],
                    endingDateTime: activityData.data()['endingDateTime'],
                    activityImageUrl: activityData.data()['activityImageUrl'],
                    participants: activityData.data()['participants'] != null
                        ? activityData.data()['participants'].asMap().forEach(
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
              }
              activityList[activityIndex].participants = participantsList;
              participantsList = [];
            },
          );
        } else {
          print('No activities found');
          return;
        }
      }).then(
        (value) => print('Fetched activities'),
      );
    } catch (error) {
      throw error;
    }
    await setActivities(activityList);
    notifyListeners();
  }

  //Removes chosen activity
  Future<void> removeActivity(
    String tripId,
    String userId,
    String countryId,
    String cityId,
    String activityId,
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
          .collection('activities')
          .doc('$activityId')
          .delete()
          .then(
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
