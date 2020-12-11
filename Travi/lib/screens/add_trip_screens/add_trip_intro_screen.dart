/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: Screen for displaying the intro to
 * the create trip process.
 */
import 'package:flutter/material.dart';
import './add_trip_title_screen.dart';

class AddTripIntroScreen extends StatelessWidget {
  static const routeName = '/add-trip-intro-screen';

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Trip',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          child: Container(
            color: Colors.grey[400],
            height: 1,
          ),
          preferredSize: Size.fromHeight(1.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: new IconThemeData(
          color: Theme.of(context).secondaryHeaderColor,
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                // color: Theme.of(context).accentColor,
                ),
            child: Container(
              width: screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: screenHeight * 0.15,
                  ),
                  Container(
                    width: screenWidth * 0.6,
                    //TODO image placeholder
                    child: Image.network(
                      'https://cdn.pixabay.com/photo/2013/07/13/12/18/airbus-159588_1280.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.035,
                  ),
                  Text(
                    'Create a trip!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.045,
                  ),
                  Container(
                    width: screenWidth * 0.8,
                    child: Text(
                      'Let\'s start organizing your next adventure with a few simple questions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.045,
                  ),
                  Container(
                    width: screenWidth * 0.8,
                    child: FlatButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(AddTripTitleScreen.routeName),
                      color: Theme.of(context).buttonColor,
                      child: Text(
                        'Next',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
