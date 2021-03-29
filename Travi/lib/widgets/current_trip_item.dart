/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: widget for displaying each current trip item
 */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../providers/trip_provider.dart';
import '../providers/country_provider.dart';
import '../screens/trip_details_screens/trip_detail_screen.dart';

class CurrentTripItem extends StatefulWidget {
  final TripProvider foundTrip;
  CurrentTripItem(this.foundTrip);

  @override
  _CurrentTripItemState createState() => _CurrentTripItemState();
}

class _CurrentTripItemState extends State<CurrentTripItem> {
  UserProvider user;
  String userId;

  List<Country> countryList;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      user = Provider.of<UserProvider>(context, listen: false).loggedInUser;
      userId = user.id;
      //getCountryData();
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    void selectTrip(BuildContext ctx) {
      Navigator.of(ctx).pushNamed(
        TripDetailsScreen.routeName,
        arguments: widget.foundTrip.id,
      );
    }

    List<Widget> listCountries() {
      List<Widget> textList = [];
      if (widget.foundTrip.countries != null ) {
        for (int i = 0; i < widget.foundTrip.countries.length; i++) {
          textList.add(
            Text(
              '${widget.foundTrip.countries[i].country}${widget.foundTrip.countries.length > 1 && widget.foundTrip.countries.length != i + 1 ? ', ' : ''}',
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
                    //If no picture is laoded, do not display anything, else
                    //display picture above trip info.

                    Container(
                      height: widget.foundTrip.tripImageUrl == null ||
                              widget.foundTrip.tripImageUrl == ''
                          ? 0
                          : screenHeight * 0.22,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: widget.foundTrip.tripImageUrl == null ||
                              widget.foundTrip.tripImageUrl == ''
                          ? Container()
                          : (widget.foundTrip.countries[0].id != ''
                              ? ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8.0),
                                    topRight: Radius.circular(8.0),
                                  ),
                                  child: Hero(
                                    tag: widget.foundTrip.id,
                                    child: Image.network(
                                      widget.foundTrip.tripImageUrl,
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
                                )),
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
                                    '${widget.foundTrip.title}',
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
                                    '${DateFormat.yMMMd().format(widget.foundTrip.startDate)} - ${' ' + DateFormat.yMMMd().format(widget.foundTrip.endDate)}',
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
                                      'Days Left: ${widget.foundTrip.startDate.difference(DateTime.now()).inDays + 1}',
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
                                  widget.foundTrip.transportationsComplete
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
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
                                  widget.foundTrip.lodgingsComplete
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
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
                                  widget.foundTrip.activitiesComplete
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
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
