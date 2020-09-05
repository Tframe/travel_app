import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/trip_provider.dart';
import '../screens/trip_detail_screen.dart';


class PastTripItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final foundTrip = Provider.of<TripProvider>(context, listen: false);

    void selectTrip(BuildContext ctx) {
      Navigator.of(ctx).pushNamed(
        TripDetailsScreen.routeName,
        arguments: foundTrip.id,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      //Create a card that will display trip data
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 5,
        ),
        child: Card(
          color: Theme.of(context).accentColor,
          elevation: 5,
          child: InkWell(
            //navigate to trip detail screen
            onTap: () => selectTrip(context),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.015,
                  ),
                  height: screenHeight * 0.20,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: foundTrip.image == null
                      ? ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                          child: Container(
                            child: IconButton(
                              icon: Icon(Icons.photo_camera),
                              //TODO
                              onPressed: () {},
                            ),
                            color: Colors.grey,
                            height: double.infinity,
                            width: double.infinity,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                          child: Image.network(
                            foundTrip.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10.0,
                  ),
                  child: Container(
                    padding: EdgeInsets.only(left: screenWidth * .02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(bottom: 5),
                              width: screenWidth * 0.85,
                              child: Text(
                                '${foundTrip.title}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: 2.5),
                              width: screenWidth * 0.85,
                              child: Text(
                                'hi',//'${foundTrip.destinations[0].city + ', '}${foundTrip.destinations[0].state != null ? foundTrip.destinations[0].state + ', ' : ''}${foundTrip.destinations[0].country}',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: 10),
                              width: screenWidth * 0.85,
                              child: Text(
                                '${DateFormat.yMMMd().format(foundTrip.startDate)} - ${' ' + DateFormat.yMMMd().format(foundTrip.endDate)}',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
