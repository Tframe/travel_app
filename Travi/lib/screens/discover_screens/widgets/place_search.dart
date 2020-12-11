/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: widget for displaying search by place bar
 */
import 'package:flutter/material.dart';

class PlaceSearch extends StatefulWidget {
  @override
  _PlaceSearchState createState() => _PlaceSearchState();
}

class _PlaceSearchState extends State<PlaceSearch> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 50,
      width: screenWidth * 0.85,
      child: TextField(
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).buttonColor,
            ),
          ),
          labelText: 'Place',
          hintText: 'Place',
          focusColor: Theme.of(context).buttonColor,
          contentPadding: EdgeInsets.symmetric(
            vertical: 5,
          ),
        ),
        cursorColor: Theme.of(context).buttonColor,
      ),
    );
  }
}
