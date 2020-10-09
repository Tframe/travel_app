import 'package:flutter/material.dart';

class Flight extends ChangeNotifier {
  String id;
  String airline;
  String flightNumber;
  String confirmationNumber;
  String departureAirport;
  DateTime departureDateTime;
  String departureTerminal;
  String departureGate;
  String arrivalAirport;
  DateTime arrivalDateTime;
  String arrivalTerminal;
  String arrivalGate;


  Flight({
    this.id,
    this.airline,
    this.flightNumber,
    this.confirmationNumber,
    this.departureAirport,
    this.departureDateTime,
    this.departureTerminal,
    this.departureGate,
    this.arrivalAirport,
    this.arrivalDateTime,
    this.arrivalTerminal,
    this.arrivalGate,
  });
}
