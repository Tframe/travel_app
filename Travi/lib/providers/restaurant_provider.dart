/* Author: Trevor Frame
 * Date: 10/27/2020
 * Description: Add, update, and remove operations
 * for storing restaurant data into Firebase Firestore.
 * Restaurant is a collection under a specific trip
 */

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './user_provider.dart';

class Restaurant extends ChangeNotifier {
  String id;
  String organizerId;
  List<UserProvider> participants;
  String name;
  String phoneNumber;
  String website;
  String reservationID;
  DateTime startingDateTime;
  String address;
  double latitude;
  double longitude;
  String restaurantImageUrl;
  bool chosen;

  Restaurant({
    this.id,
    this.organizerId,
    this.participants,
    this.name,
    this.phoneNumber,
    this.website,
    this.reservationID,
    this.startingDateTime,
    this.address,
    this.latitude,
    this.longitude,
    this.restaurantImageUrl,
    this.chosen,
  });

  List<Restaurant> _restaurants = [];

  List<Restaurant> get restaurants {
    return [..._restaurants];
  }

  //verify if list of restaurants is empty
  bool assertRestaurantList() {
    if(_restaurants.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  //add restaurant
  Future<void> addRestaurant(
    String tripId,
    String userId,
    String countryId,
    String cityId,
    Restaurant restaurant,
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
          .collection('restaurants')
          .add({
        'chosen': restaurant.chosen,
        'organizerId': restaurant.organizerId,
        'name': restaurant.name,
        'phoneNumber': restaurant.phoneNumber,
        'website': restaurant.website,
        'address': restaurant.address,
        'latitude': restaurant.latitude,
        'longitude': restaurant.longitude,
        'startingDateTime': restaurant.startingDateTime,
        'reservationID': restaurant.reservationID,
        'participants': restaurant.participants
            .map((participant) => {
                  'id': participant.id,
                  'firstName': participant.firstName,
                  'lastName': participant.lastName,
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
    notifyListeners();
  }

  //edit restuarant
  Future<void> editRestaurant(
    String tripId,
    String userId,
    String countryId,
    String cityId,
    Restaurant restaurant,
    String restaurantId,
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
          .collection('restaurants')
          .doc('$restaurantId')
          .update({
        'chosen': restaurant.chosen,
        'organizerId': restaurant.organizerId,
        'name': restaurant.name,
        'phoneNumber': restaurant.phoneNumber,
        'website': restaurant.website,
        'address': restaurant.address,
        'latitude': restaurant.latitude,
        'longitude': restaurant.longitude,
        'startingDateTime': restaurant.startingDateTime,
        'reservationID': restaurant.reservationID,
        'participants': restaurant.participants
            .map((participant) => {
                  'id': participant.id,
                  'firstName': participant.firstName,
                  'lastName': participant.lastName,
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
    notifyListeners();
  }

  Future<void> setRestaurant(List<Restaurant> restaurantList) async {
    _restaurants = restaurantList;
  }

  //Get all restaurants for city
  Future<void> fetchAndSetRestaurants(
    String tripId,
    String userId,
    String countryId,
    String cityId,
  ) async {
    List<Restaurant> restaurantList = [];
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
          .collection('restaurants')
          .get()
          .then((restaurant) => {
                restaurant.docs
                    .asMap()
                    .forEach((restaurantIndex, restaurantData) {
                  restaurantList.add(
                    Restaurant(
                      id: restaurantData.id,
                      organizerId: restaurantData.data()['organizerId'],
                      name: restaurantData.data()['name'],
                      latitude: restaurantData.data()['latitude'],
                      longitude: restaurantData.data()['longitude'],
                      address: restaurantData.data()['address'],
                      phoneNumber: restaurantData.data()['phoneNumber'],
                      website: restaurantData.data()['website'],
                      reservationID: restaurantData.data()['reservationID'],
                      startingDateTime:
                          restaurantData.data()['startingDateTime'].toDate(),
                      restaurantImageUrl:
                          restaurantData.data()['restaurantImageUrl'],
                      chosen: restaurantData.data()['chosen'],
                      participants:
                          restaurantData.data()['participants'] != null
                              ? restaurantData
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
                  restaurantList[restaurantIndex].participants = participantsList;
                  participantsList = [];
                }),
              });
    } catch (error) {
      throw error;
    }
    await setRestaurant(restaurantList);
    notifyListeners();
  }

  //Removes chosen restaurant
  Future<void> removeRestaurant(
    String tripId,
    String userId,
    String countryId,
    String cityId,
    String restaurantId,
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
          .collection('restaurants')
          .doc('$restaurantId')
          .delete()
          .then(
        (value) {
          print('restaurant deleted');
        },
      );
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }
}
