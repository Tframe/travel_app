/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: widget for displaying the filter
 * on the discover page. includs buttons and search fields
 */
import 'package:flutter/material.dart';
import './keyword_search.dart';
import './place_search.dart';

class DiscoverFilter extends StatefulWidget {
  @override
  _DiscoverFilterState createState() => _DiscoverFilterState();
}

class _DiscoverFilterState extends State<DiscoverFilter> {
  List<bool> _buttonSelected = [false, false, false, false, false, false];

  Widget scrollButtons(String buttonText, int isSelectedIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      child: FlatButton(
        color: _buttonSelected[isSelectedIndex]
            ? Theme.of(context).buttonColor
            : null,
        onPressed: () {
          setState(() {
            _buttonSelected[isSelectedIndex] =
                !_buttonSelected[isSelectedIndex];
            for (int i = 0; i < _buttonSelected.length; i++) {
              if (i != isSelectedIndex) {
                _buttonSelected[i] = false;
              }
            }
          });
        },
        child: Text(
          buttonText,
          style: TextStyle(
            color:
                _buttonSelected[isSelectedIndex] ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PlaceSearch(),
            KeywordSearch(),
          ],
        ),
        Container(
          height: 60,
          padding: const EdgeInsets.only(
            top: 18.0,
            bottom: 10.0,
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              scrollButtons('People', 0),
              scrollButtons('Trip', 1),
              scrollButtons('Lodging', 2),
              scrollButtons('Activity', 3),
              scrollButtons('Restaurant', 4),
              scrollButtons('Flight', 5),
            ],
          ),
        ),
        Divider(
          thickness: 10,
        ),
      ],
    );
  }
}
