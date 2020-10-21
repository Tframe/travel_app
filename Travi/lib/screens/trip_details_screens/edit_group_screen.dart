import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/trips_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/trip_provider.dart';
import './add_companion_screen.dart';

class EditGroupScreen extends StatefulWidget {
  static const routeName = '/edit-group-screen';
  @override
  _EditGroupScreenState createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  TripProvider loadedTrip;

  void addCompanion() async {
    Navigator.of(context).pushNamed(
      AddCompanionScreen.routeName,
      arguments: {'loadedTrip': loadedTrip},
    ).then((value) {
      setState(() {
        print('popped and updated');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    loadedTrip = arguments['loadedTrip'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Group'),
      ),
      body: loadedTrip.group.length == 0
          ? Center(
              child: Text('No Companions Added'),
            )
          : SingleChildScrollView(
              child: Container(
                width: screenWidth,
                child: Column(
                  children: [
                    Container(
                      height: screenHeight * 0.8,
                      width: screenWidth * 0.8,
                      padding: const EdgeInsets.only(
                        top: 35,
                      ),
                      child: ListView.builder(
                        itemCount: loadedTrip.group.length,
                        itemBuilder: (BuildContext ctx, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            child: Dismissible(
                              key: ValueKey(loadedTrip.group),
                              child: ListTile(
                                leading: loadedTrip
                                        .group[index].profilePicUrl.isEmpty
                                    ? CircleAvatar(
                                        radius: 30,
                                        child: Icon(
                                          Icons.person,
                                        ),
                                      )
                                    : CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(
                                          loadedTrip.group[index].profilePicUrl,
                                        ),
                                      ),
                                title: Text(
                                  '${loadedTrip.group[index].firstName} ${loadedTrip.group[index].lastName[0]}.',
                                ),
                                //Display trip acception status
                                trailing: loadedTrip.group[index].invitationStatus ==
                                        'accepted'
                                    ? Text('Accepted')
                                    : loadedTrip.group[index].invitationStatus ==
                                            'pending'
                                        ? Text('Pending...')
                                        : loadedTrip.group[index].invitationStatus ==
                                                'declined'
                                            ? Text('Declined')
                                            : Text(''),
                                //TODO Navigate to the user profile page
                                onTap: () {},
                              ),
                              background: Container(
                                color: Colors.red,
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                User user = await Provider.of<UserProvider>(
                                        context,
                                        listen: false)
                                    .getCurrentUser();
                                return await showDialog<Null>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text(
                                      'Confirm',
                                    ),
                                    content: Text(
                                      'Are you sure you want to remove ${loadedTrip.group[index].firstName} ${loadedTrip.group[index].lastName[0]}.?',
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: const Text('Yes'),
                                        onPressed: () {
                                          setState(() {
                                            Provider.of<TripsProvider>(context,
                                                    listen: false)
                                                .removeCompanion(loadedTrip,
                                                    user.uid, index);
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      FlatButton(
                                        child: const Text('No'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: addCompanion,
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}
