/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: screen for adding companion
 * to a trip
 */
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/trip_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/trips_provider.dart';
import '../../providers/notification_provider.dart';

class AddCompanionScreen extends StatefulWidget {
  static const routeName = '/add-companion-screen';

  @override
  _AddCompanionScreenState createState() => _AddCompanionScreenState();
}

class _AddCompanionScreenState extends State<AddCompanionScreen> {
  TripProvider loadedTrip;

  final GlobalKey<FormState> _formKey = GlobalKey();
  final _listViewController = ScrollController();
  var _numberCompanions = List<Widget>();
  var _companionsIndex = 0;

  List<String> tempGroup = [];
  //Map<int, String> grouptracker = {};
  List<String> grouptracker = [];
  List<bool> _searchUserEmail = [];

  //Function to add companions to trip values.
  Future<void> _addCompanions() async {
    User user = await Provider.of<UserProvider>(context, listen: false)
        .getCurrentUser();
    UserProvider currentLoggedInUser =
        Provider.of<UserProvider>(context, listen: false).currentLoggedInUser;
    final List<UserProvider> tempCompanion = [];
    final List<String> tempCompanionIds = [];
    final isValid = _formKey.currentState.validate();
    bool _invited = false;
    if (!isValid) {
      return;
    }
    _formKey.currentState.save();
    try {
      for (int i = 0; i < tempGroup.length; i++) {
        //Verify email or phone # is in firestore
        await Provider.of<UserProvider>(context, listen: false)
            .findUserByContactInfo(tempGroup[i], _searchUserEmail[i]);
        tempCompanion
            .add(Provider.of<UserProvider>(context, listen: false).users[0]);
      }
      for (int j = 0; j < tempCompanion.length; j++) {
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
        //remove duplicates
        for (int k = 0; k < tempCompanion.length; k++) {
          if (j != k) {
            if (tempCompanion[j].id == tempCompanion[k].id) {
              tempCompanion.removeAt(k);
              break;
            }
          }
        }
        //Check is person already invited, if so, give alert
        for (int l = 1; l < loadedTrip.group.length; l++) {
          if (tempCompanion[j].id == loadedTrip.group[l].id) {
            await showDialog<Null>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text(
                  'Companion already invited',
                ),
                content: Text(
                  'You have already invited ${loadedTrip.group[l].firstName} ${loadedTrip.group[l].lastName[0]}.!',
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
        }
      }
      //add list of companionstrings
      for (int j = 0; j < tempCompanion.length; j++) {
        if (tempCompanion[j].id != user.uid) {
          tempCompanionIds.add(tempCompanion[j].id);
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
    loadedTrip.group.addAll(tempCompanion);
    loadedTrip.companionsId.addAll(tempCompanionIds);

    //add companions to trip
    await Provider.of<TripsProvider>(context, listen: false).updateCompanions(
        loadedTrip,
        loadedTrip.organizerId,
        currentLoggedInUser.firstName,
        currentLoggedInUser.lastName,
        loadedTrip.group);

    for (int a = 0; a < tempCompanionIds.length; a++) {
      //Add companion id to list of companions
      await Provider.of<TripsProvider>(context, listen: false).addToCompanions(
        loadedTrip.id,
        loadedTrip.organizerId,
        tempCompanionIds[a],
      );
    }

    for (int i = 0; i < tempCompanion.length; i++) {
      //check if user not already invited, if not invited, then
      //add notification and to trip invite list.
      _invited = await Provider.of<TripsProvider>(context, listen: false)
          .checkIfInvited(tempCompanion[i].id, loadedTrip.id);
      if (!_invited && tempCompanion[i].id != currentLoggedInUser.id) {
        //add trip info to new companion
        await Provider.of<TripsProvider>(context, listen: false)
            .addTripToCompanion(
          tempCompanion[i].id,
          loadedTrip.organizerId,
          //assumes first group member added is the organizer
          loadedTrip.group[0].firstName,
          loadedTrip.group[0].lastName,
          currentLoggedInUser.id,
          currentLoggedInUser.firstName,
          currentLoggedInUser.lastName,
          loadedTrip.id,
          loadedTrip.title,
        );

        //create the add trip notification
        NotificationProvider newNotification =
            Provider.of<NotificationProvider>(context, listen: false)
                .createTripInviteNotification(
          currentLoggedInUser.id,
          currentLoggedInUser.firstName,
          currentLoggedInUser.lastName,
          loadedTrip.id,
          loadedTrip.title,
        );

        //add notification to each companion added
        await Provider.of<NotificationProvider>(context, listen: false)
            .addNotification(tempCompanion[i].id, newNotification);
      }
    }

    Navigator.of(context).pop();

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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    loadedTrip = arguments['loadedTrip'];
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
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
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
                  Divider(
                    thickness: 5,
                    color: Theme.of(context).buttonColor,
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
                  Divider(
                    thickness: 5,
                    color: Theme.of(context).buttonColor,
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
                        'Submit',
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
