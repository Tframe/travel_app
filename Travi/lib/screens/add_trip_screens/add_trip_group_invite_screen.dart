import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/trip_provider.dart';
import '../../providers/trips_provider.dart';
import '../../providers/country_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/city_provider.dart';
import '../../screens/tab_bar_screen.dart';

class AddTripGroupInviteScreen extends StatefulWidget {
  static const routeName = '/group-invite-screen';

  @override
  _AddTripGroupInviteScreenState createState() =>
      _AddTripGroupInviteScreenState();
}

class _AddTripGroupInviteScreenState extends State<AddTripGroupInviteScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _listViewController = ScrollController();
  var _numberCompanions = List<Widget>();
  var _companionsIndex = 0;

  List<String> tempGroup = [];
  //Map<int, String> grouptracker = {};
  List<String> grouptracker = [];
  List<bool> _searchUserEmail = [];

  var tripValues = TripProvider(
    id: null,
    title: null,
    startDate: null,
    endDate: null,
    group: [
      UserProvider(
        id: null,
        firstName: null,
        lastName: null,
        email: null,
        phone: null,
        location: null,
        invitationStatus: null,
      ),
    ],
    isPrivate: true,
    tripImageUrl: null,
    description: null,
  );

  //Function to add companions to trip values.
  Future<void> _addCompanions() async {
    User user = FirebaseAuth.instance.currentUser;
    final List<UserProvider> tempCompanion = [];
    final isValid = _formKey.currentState.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState.save();
    try {
      tempCompanion
          .add(Provider.of<UserProvider>(context, listen: false).loggedInUser);
      for (int i = 0; i < tempGroup.length; i++) {
        //Verify email or phone # is in firestore
        await Provider.of<UserProvider>(context, listen: false)
            .findUserByContactInfo(tempGroup[i], _searchUserEmail[i]);

        tempCompanion
            .add(Provider.of<UserProvider>(context, listen: false).users[0]);
      }
      for (int j = 1; j < tempCompanion.length; j++) {
        if (tempCompanion[j].id == user.uid) {
          await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text(
                'Can\'t invite youself',
              ),
              content: const Text(
                'You cannot invite yourself. Remove yourself before proceeding',
              ),
              actions: <Widget>[
                FlatButton(
                  child: const Text('Okay'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
          return;
        }
        for (int k = 0; k < tempCompanion.length; k++) {
          if (j != k) {
            if (tempCompanion[j].id == tempCompanion[k].id) {
              tempCompanion.removeAt(k);
              break;
            }
          }
        }
      }
    } catch (error) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            'Please verify',
          ),
          content: const Text(
            'Verify the contact information is correct.',
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text(
                'Okay',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }

    tripValues.group = tempCompanion;

    //Adds data to firestore
    try {
      await Provider.of<TripsProvider>(context, listen: false)
          .addTrip(tripValues, user.uid);
      Navigator.of(context).pushNamed(TabBarScreen.routeName);
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

    Navigator.of(context).pushNamed(TabBarScreen.routeName);

    tempGroup = [];
  }

  //adds a field for the country
  void _addGroupField() {
    grouptracker.add('');
    int index = _companionsIndex;
    setState(() {
      _searchUserEmail.add(true);
    });
    _numberCompanions = List.from(_numberCompanions)
      ..add(ListTile(
        title: TextFormField(
          decoration: InputDecoration(
            labelText: _searchUserEmail[index] ? 'Email' : 'Moible #',
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).buttonColor,
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
            return null;
          },
          keyboardType: _searchUserEmail[index]
              ? TextInputType.emailAddress
              : TextInputType.phone,
          onSaved: (value) {
            tempGroup.add(value);
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.email),
              onPressed: () => _switchSeachBy(index),
              color: _searchUserEmail[index]
                  ? Theme.of(context).buttonColor
                  : Colors.black,
            ),
            IconButton(
              icon: Icon(Icons.phone_android),
              onPressed: () => _switchSeachBy(index),
              color: !_searchUserEmail[index]
                  ? Theme.of(context).buttonColor
                  : Colors.black,
            ),
          ],
        ),
      ));
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

  //Pop back a page and clear out provider
  void _backPage() async {
    // final removed = await Provider.of<UserProvider>(context, listen: false)
    //     .removeAllUsers();
    Navigator.of(context).pop();
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
            // margin: EdgeInsets.symmetric(
            //   horizontal: screenWidth * 0.05,
            // ),
            width: screenWidth,
            decoration: BoxDecoration(
                // color: Theme.of(context).accentColor,
                ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 200.0,
                      bottom: 12.0,
                      top: 5.0,
                    ),
                    child: Text(
                      'Send invites to...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    height: screenHeight * 0.50,
                    width: screenWidth,
                    margin: EdgeInsets.only(
                      bottom: 25,
                      top: 15,
                    ),
                    child: Form(
                      key: _formKey,
                      child: ListView.builder(
                        itemCount: _searchUserEmail.length,
                        controller: _listViewController,
                        itemBuilder: (BuildContext ctx, int index) {
                          return Dismissible(
                            key: ValueKey(_numberCompanions),
                            child: ListTile(
                              title: TextFormField(
                                decoration: InputDecoration(
                                  labelText: _searchUserEmail[index]
                                      ? 'Email'
                                      : 'Moible #',
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).buttonColor,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).buttonColor,
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
                                initialValue: grouptracker[index] != ''
                                    ? grouptracker[index]
                                    : '',
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
                                  return null;
                                },
                                keyboardType: _searchUserEmail[index]
                                    ? TextInputType.emailAddress
                                    : TextInputType.phone,
                                onSaved: (value) {
                                  tempGroup.add(value);
                                },
                                onChanged: (value) {
                                  grouptracker[index] = value;
                                },
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.email),
                                    onPressed: () => _switchSeachBy(index),
                                    color: _searchUserEmail[index]
                                        ? Theme.of(context).buttonColor
                                        : Colors.black,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.phone_android),
                                    onPressed: () => _switchSeachBy(index),
                                    color: !_searchUserEmail[index]
                                        ? Theme.of(context).buttonColor
                                        : Colors.black,
                                  ),
                                  Transform.rotate(
                                    angle: 90 * math.pi / 180,
                                    child: Icon(
                                      Icons.drag_handle,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            background: Container(
                              color: Colors.red,
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) {
                              setState(() {
                                grouptracker.removeAt(index);
                                _numberCompanions = List.from(_numberCompanions)
                                  ..removeAt(index);
                                _companionsIndex--;
                                _searchUserEmail.removeAt(index);
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    width: screenWidth * 0.85,
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
                      color: Theme.of(context).buttonColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    width: screenWidth * 0.85,
                    child: FlatButton(
                      child: Text(
                        'Create Trip',
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
                      color: Theme.of(context).buttonColor,
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
