import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/trip_provider.dart';
import '../providers/country_provider.dart';
import '../screens/trip_detail_screen.dart';
import './places_images.dart';

class CurrentTripItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final foundTrip = Provider.of<TripProvider>(context);

    void selectTrip(BuildContext ctx) {
      Navigator.of(ctx).pushNamed(
        TripDetailsScreen.routeName,
        arguments: foundTrip.id,
      );
    }

    List<Widget> listCountries() {
      List<Widget> textList = [];
      for (int i = 0; i < foundTrip.countries.length; i++) {
        textList.add(
          Text(
            '${foundTrip.countries[i].country}${foundTrip.countries.length > 1 && foundTrip.countries.length != i + 1 ? ', ' : ''}',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Theme.of(context).secondaryHeaderColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
      return textList;
    }

    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          //Create a card that will display trip data
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 5,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              child: InkWell(
                //navigate to trip detail screen
                onTap: () => selectTrip(context),
                child: Column(
                  children: <Widget>[
                    Container(
                        height: screenHeight * 0.30,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: foundTrip.image == null
                            ? ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  topRight: Radius.circular(8.0),
                                ),
                                child: Hero(
                                  tag: foundTrip.id,
                                  child:
                                      PlacesImages(foundTrip.countries[0].id),
                                ),
                              )
                            : (foundTrip.countries[0].id != ''
                                ? ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8.0),
                                      topRight: Radius.circular(8.0),
                                    ),
                                    child: Hero(
                                      tag: foundTrip.id,
                                      child: Image.network(
                                        foundTrip.image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : Container(
                                    child: IconButton(
                                      icon: Icon(Icons.photo_camera),
                                      //TODO
                                      onPressed: () {},
                                    ),
                                    color: Colors.grey,
                                    height: double.infinity,
                                    width: double.infinity,
                                  ))),
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
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(bottom: 2.5),
                                  width: screenWidth * 0.85,
                                  child: Row(
                                    children: listCountries(),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(bottom: 2.5),
                                  width: screenWidth * 0.85,
                                  child: Text(
                                    '${DateFormat.yMMMd().format(foundTrip.startDate)} - ${' ' + DateFormat.yMMMd().format(foundTrip.endDate)}',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.timer,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                    ),
                                    Text(
                                      'Days Left: ${foundTrip.startDate.difference(DateTime.now()).inDays + 1}',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: screenHeight * 0.015,
                        bottom: 10,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                              left: screenWidth * 0.015,
                            ),
                            alignment: Alignment.centerLeft,
                            child: Column(
                              children: <Widget>[
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                                Text(
                                  'Transportation',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Column(
                              children: <Widget>[
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                                Text(
                                  'Lodging',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              right: screenWidth * 0.015,
                            ),
                            alignment: Alignment.centerRight,
                            child: Column(
                              children: <Widget>[
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                                Text(
                                  'Activities',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Divider(
          color: Colors.grey[250],
          thickness: 10,
          height: 10,
        ),
      ],
    );
  }
}
