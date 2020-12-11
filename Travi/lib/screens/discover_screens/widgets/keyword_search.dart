/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: widget for keyword search bar
 */
import 'package:flutter/material.dart';

class KeywordSearch extends StatefulWidget {
  @override
  _KeywordSearchState createState() => _KeywordSearchState();
}

class _KeywordSearchState extends State<KeywordSearch> {
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
          labelText: 'Keywords',
          hintText: 'Keywords',
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
