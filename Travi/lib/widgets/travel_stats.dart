import 'package:flutter/material.dart';

import './travel_stat_card.dart';

class TravelStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 15.0,
            left: 18.0,
            bottom: 15.0,
          ),
          child: Row(
            children: [
              const Text(
                'Travel Stats',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 18.0,
            bottom: 18.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TravelStatCard('Countries Traveled', 10),
              TravelStatCard('Experiences', 37),
              TravelStatCard('Vacations Taken', 5),
            ],
          ),
        ),
      ],
    );
  }
}
