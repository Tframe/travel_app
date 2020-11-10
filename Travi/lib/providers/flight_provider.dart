/* Author: Trevor Frame
 * Date: 10/27/2020
 * Description: Add, update, and remove operations
 * for storing flight data into Firebase Firestore.
 * Flight is a collection under a specific trip
 */

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './user_provider.dart';

class Flight extends ChangeNotifier {
  String id;
  String organizerId;
  List<UserProvider> participants;
  String airline;
  String airlinePhoneNumber;
  String airlineWebsite;
  String flightNumber;
  String confirmationNumber;
  String departureAirport;
  double departureAirportLatitude;
  double departureAirportLongitude;
  DateTime departureDateTime;
  String departureTerminal;
  String departureGate;
  String arrivalAirport;
  double arrivalAirportLatitude;
  double arrivalAirportLongitude;
  DateTime arrivalDateTime;
  String arrivalTerminal;
  String arrivalGate;
  bool chosen;

  Flight({
    this.id,
    this.organizerId,
    this.participants,
    this.airline,
    this.airlinePhoneNumber,
    this.airlineWebsite,
    this.flightNumber,
    this.confirmationNumber,
    this.departureAirport,
    this.departureAirportLatitude,
    this.departureAirportLongitude,
    this.departureDateTime,
    this.departureTerminal,
    this.departureGate,
    this.arrivalAirport,
    this.arrivalAirportLatitude,
    this.arrivalAirportLongitude,
    this.arrivalDateTime,
    this.arrivalTerminal,
    this.arrivalGate,
    this.chosen,
  });

  List<Flight> _flights = [];

  List<Flight> get flights {
    return [..._flights];
  }

  //verify if list of restaurants is empty
  bool assertFlightList() {
    if(_flights.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  //add flight
  Future<void> addFlight(
    String tripId,
    String userId,
    String countryId,
    Flight flight,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('trips')
          .doc('$tripId')
          .collection('countries')
          .doc('$countryId')
          .collection('flights')
          .add({
        'chosen': flight.chosen,
        'id': flight.id,
        'organizerId': flight.organizerId,
        'airline': flight.airline,
        'airlinePhoneNumber': flight.airlinePhoneNumber,
        'airlineWebsite': flight.airlineWebsite,
        'flightNumber': flight.flightNumber,
        'confirmationNumber': flight.confirmationNumber,
        'departureAirport': flight.departureAirport,
        'departureLatitude': flight.departureAirportLatitude,
        'departureAirportLongitude': flight.departureAirportLongitude,
        'departureDateTime': flight.departureDateTime,
        'departureTerminal': flight.departureTerminal,
        'departureGate': flight.departureGate,
        'arrivalAirport': flight.arrivalAirport,
        'arrivalAirportLatitude': flight.arrivalAirportLatitude,
        'arrivalAirportLongitude': flight.arrivalAirportLongitude,
        'arrivalDateTime': flight.arrivalDateTime,
        'arrivalTerminal': flight.arrivalTerminal,
        'arrivalGate': flight.arrivalGate,
        'participants': flight.participants
            .map((participant) => {
                  'id': participant.id,
                  'firstName': participant.firstName,
                  'lastName': participant.lastName,
                })
            .toList()
      }).then(
        (value) {
          print('flight added');
        },
      );
    } catch (error) {
      throw error;
    }

    notifyListeners();
  }

  //adds or edit flight information
  Future<void> editFlight(
    String tripId,
    String userId,
    String countryId,
    Flight flight,
    String flightId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('trips')
          .doc('$tripId')
          .collection('countries')
          .doc('$countryId')
          .collection('flights')
          .doc('$flightId')
          .update({
        'chosen': flight.chosen,
        'id': flight.id,
        'organizerId': flight.organizerId,
        'airline': flight.airline,
        'airlinePhoneNumber': flight.airlinePhoneNumber,
        'airlineWebsite': flight.airlineWebsite,
        'flightNumber': flight.flightNumber,
        'confirmationNumber': flight.confirmationNumber,
        'departureAirport': flight.departureAirport,
        'departureLatitude': flight.departureAirportLatitude,
        'departureAirportLongitude': flight.departureAirportLongitude,
        'departureDateTime': flight.departureDateTime,
        'departureTerminal': flight.departureTerminal,
        'departureGate': flight.departureGate,
        'arrivalAirport': flight.arrivalAirport,
        'arrivalAirportLatitude': flight.arrivalAirportLatitude,
        'arrivalAirportLongitude': flight.arrivalAirportLongitude,
        'arrivalDateTime': flight.arrivalDateTime,
        'arrivalTerminal': flight.arrivalTerminal,
        'arrivalGate': flight.arrivalGate,
        'participants': flight.participants
            .map((participant) => {
                  'id': participant.id,
                  'firstName': participant.firstName,
                  'lastName': participant.lastName,
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

    notifyListeners();
  }

  Future<void> setFlights(List<Flight> flightList) async {
    _flights = flightList;
  }

  Future<void> fetchAndSetFlights(
    String tripId,
    String userId,
    String countryId,
  ) async {
    List<Flight> flightList = [];
    List<UserProvider> participantsList = [];
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('trips')
          .doc('$tripId')
          .collection('countries')
          .doc('$countryId')
          .collection('flights')
          .get()
          .then((flight) {
        if (flight.docs.length > 0) {
          flight.docs.asMap().forEach(
            (flightIndex, flightData) {
              if (flightData.data() != null && flightData.data().length > 0) {
                flightList.add(
                  Flight(
                    id: flightData.id,
                    organizerId: flightData.data()['organizerId'],
                    airline: flightData.data()['airline'],
                    airlinePhoneNumber: flightData.data()['airlinePhoneNumber'],
                    airlineWebsite: flightData.data()['airlineWebsite'],
                    flightNumber: flightData.data()['flightNumber'],
                    confirmationNumber: flightData.data()['confirmationNumber'],
                    departureAirport: flightData.data()['departureAirport'],
                    departureAirportLatitude:
                        flightData.data()['departureAirportLatitude'],
                    departureAirportLongitude:
                        flightData.data()['departureAirportLongitude'],
                    departureDateTime:
                        flightData.data()['departureDateTime'].toDate(),
                    departureGate: flightData.data()['departureGate'],
                    departureTerminal: flightData.data()['departureTerminal'],
                    arrivalAirport: flightData.data()['arrivalAirport'],
                    arrivalAirportLatitude:
                        flightData.data()['arrivalAirportLatitude'],
                    arrivalAirportLongitude:
                        flightData.data()['arrivalAirportLongitude'],
                    arrivalDateTime:
                        flightData.data()['arrivalDateTime'].toDate(),
                    arrivalGate: flightData.data()['arrivalGate'],
                    arrivalTerminal: flightData.data()['arrivalTerminal'],
                    chosen: flightData.data()['chosen'],
                    participants: flightData.data()['participants'] != null
                        ? flightData.data()['participants'].asMap().forEach(
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
              flightList[flightIndex].participants = participantsList;
              participantsList = [];
            },
          );
        } else {
          print('No flights found');
          return;
        }
      }).then(
        (value) => print('Fetched flights'),
      );
    } catch (error) {
      throw error;
    }
    await setFlights(flightList);
    notifyListeners();
  }

  Future<void> removeFlight(
    String tripId,
    String userId,
    String countryId,
    String flightId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('trips')
          .doc('$tripId')
          .collection('countries')
          .doc('$countryId')
          .collection('flights')
          .doc('$flightId')
          .delete()
          .then(
        (value) {
          print('flight deleted');
        },
      );
    } catch (error) {
      throw error;
    }
    
    notifyListeners();
  }
}
