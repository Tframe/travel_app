import 'package:flutter/material.dart';

class Flight extends ChangeNotifier {
  String id;
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

  Flight({
    this.id,
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
  });
}
