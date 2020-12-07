/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: widget for displaying travel stat for 
 * account profile page.
 */
import 'package:flutter/material.dart';

class TravelStatCard extends StatelessWidget {

  final String statistic;
  final stat;

  TravelStatCard(this.statistic, this.stat);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 85,
        width: 110,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$stat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '$statistic',
              style: TextStyle(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      elevation: 3,
      color: Colors.blue,
    );
  }
}
