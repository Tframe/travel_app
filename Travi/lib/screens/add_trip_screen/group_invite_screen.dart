import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/places.dart';
import '../../providers/trip_provider.dart';
import '../../providers/country_provider.dart';
import '../../providers/countries_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/cities_provider.dart';
import '../../providers/city_provider.dart';

class GroupInviteScreen extends StatefulWidget {
  static const routeName = '/group-invite-screen';

  @override
  _GroupInviteScreenState createState() => _GroupInviteScreenState();
}

class _GroupInviteScreenState extends State<GroupInviteScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _listViewController = ScrollController();
  var _numberCompanions = List<Container>();
  var _companionsIndex = 0;

  List<String> tempGroup = [];

  List<bool> _searchUserEmail = [];

  var tripValues = TripProvider(
    id: null,
    title: null,
    startDate: null,
    endDate: null,
    countries: [
      Country(
        id: null,
        country: null,
        latitude: null,
        longitude: null,
        cities: [
          City(
            id: null,
            city: null,
            longitude: null,
            latitude: null,
            places: null,
          ),
        ],
      ),
    ],
    group: [
      UserProvider(
        id: null,
        firstName: null,
        lastName: null,
        email: null,
        phone: null,
        location: null,
      ),
    ],
    description: null,
  );

  //Function to add companions to trip values.
  Future<void> _addCompanions() async {
    print('in add');
    final isValid = _formKey.currentState.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState.save();
    print('in add 2');
    try {
      print(tempGroup.length);
      for (int i = 0; i < tempGroup.length; i++) {
        print(tempGroup[i]);
      }
    } catch (error) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occured'),
          content: Text('Something went wrong'),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }

    // final newGroup = Provider.of<UserProvider>(context, listen: false).users;
    // tripValues.group = newGroup;

    // Navigator.of(context)
    //       .pushNamed(SignUpLocationScreen.routeName, arguments: tripValues);
  }

  //adds a field for the country
  void _addGroupField() {
    int index = _companionsIndex;
    setState(() {
      _searchUserEmail.add(true);
    });

    _numberCompanions = List.from(_numberCompanions)
      ..add(
        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          margin: EdgeInsets.only(right: 5, left: 5, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.63,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email or moible #',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black54,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter an email or mobile #';
                    }
                    if (_searchUserEmail[index] && !value.contains('@')) {
                      return 'You must enter a valid email address';
                    }
                    if (!_searchUserEmail[index] && value.length != 10) {
                      return 'You must enter a valid mobile #';
                    }
                  },
                  keyboardType: _searchUserEmail[index]
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  onSaved: (value) {
                    tempGroup[index] = value;
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.email),
                onPressed: () => _switchSeachBy(index),
                color: _searchUserEmail[index]
                    ? Theme.of(context).primaryColor
                    : Colors.black,
              ),
              IconButton(
                icon: Icon(Icons.phone_android),
                onPressed: () => _switchSeachBy(index),
                color: !_searchUserEmail[index]
                    ? Theme.of(context).primaryColor
                    : Colors.black,
              ),
            ],
          ),
        ),
      );
    setState(() {
      _companionsIndex++;
    });
    Timer(Duration(milliseconds: 50), () => _scrollToBottom());
  }

  //Function to search for users by email
  void _switchSeachBy(int index) {
    setState(() {
      _searchUserEmail[index] = !_searchUserEmail[index];
    });
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  //Function to scroll ListView of Places text fields to automatically scroll
  //to the bottom with an animation
  void _scrollToBottom() {
    _listViewController.animateTo(
      _listViewController.position.maxScrollExtent + 50,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  //Removes the last city field
  void _removeCompanionField() {
    // if (_companionsIndex == _numberCompanions.length) {
    //   Provider.of<Cities>(context, listen: false)
    //       .removeCity(_numberCompanions.length - 1);
    // }
    setState(() {
      _numberCompanions = List.from(_numberCompanions)..removeLast();
      _companionsIndex--;
      _searchUserEmail.removeLast();
    });
  }

  //Pop back a page and clear out provider
  void _backPage() async {
    // final removed = await Provider.of<UserProvider>(context, listen: false)
    //     .removeAllUsers();
    Navigator.of(context).pop();
  }

  //Skip button feature if user doesn't know any cities to stop.
  void _skipButton() {
    // Navigator.of(context)
    //     .pushNamed(SignUpLocationScreen.routeName, arguments: tripValues);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    tripValues = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Group Invites',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: _backPage,
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
            ),
            width: screenWidth,
            decoration: BoxDecoration(
                // color: Theme.of(context).accentColor,
                ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: screenHeight * 0.015,
                  ),
                  Text(
                    'Send invites to...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Divider(
                    thickness: 3,
                    color: Theme.of(context).primaryColor,
                  ),
                  Container(
                    height: screenHeight * 0.50,
                    width: screenWidth * 0.9,
                    margin: EdgeInsets.only(
                      bottom: 25,
                    ),
                    child: Form(
                      key: _formKey,
                      child: ListView.builder(
                        itemCount: _searchUserEmail.length,
                        controller: _listViewController,
                        itemBuilder: (BuildContext ctx, int index) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            margin: EdgeInsets.only(right: 5, left: 5, top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.63,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Email or moible #',
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black54,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Enter an email or mobile #';
                                      }
                                      if (_searchUserEmail[index] &&
                                          !value.contains('@')) {
                                        return 'You must enter a valid email address';
                                      }
                                      if (!_searchUserEmail[index] &&
                                          value.length != 10) {
                                        return 'You must enter a valid mobile #';
                                      }
                                    },
                                    keyboardType: _searchUserEmail[index]
                                        ? TextInputType.emailAddress
                                        : TextInputType.phone,
                                    onSaved: (value) {
                                      tempGroup[index] = value;
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.email),
                                  onPressed: () => _switchSeachBy(index),
                                  color: _searchUserEmail[index]
                                      ? Theme.of(context).primaryColor
                                      : Colors.black,
                                ),
                                IconButton(
                                  icon: Icon(Icons.phone_android),
                                  onPressed: () => _switchSeachBy(index),
                                  color: !_searchUserEmail[index]
                                      ? Theme.of(context).primaryColor
                                      : Colors.black,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 3,
                    color: Theme.of(context).primaryColor,
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    width: screenWidth,
                    child: FlatButton(
                      child: Text(
                        'Add Companion',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      onPressed: () => _addGroupField(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    width: screenWidth,
                    child: FlatButton(
                      child: Text(
                        'Remove Last Companion',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      onPressed: _removeCompanionField,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    width: screenWidth,
                    child: FlatButton(
                      child: Text(
                        'Next',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      onPressed: _addCompanions,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      color: Theme.of(context).primaryColor,
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
