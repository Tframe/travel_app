import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/user_provider.dart';
import '../providers/notification_provider.dart';

class NotificationEndDrawer extends StatefulWidget {
  final UserProvider currentLoggedInUser;
  NotificationEndDrawer(this.currentLoggedInUser);

  @override
  _NotificationEndDrawerState createState() => _NotificationEndDrawerState();
}

class _NotificationEndDrawerState extends State<NotificationEndDrawer> {
  UserProvider _loggedInUser;
  List<NotificationProvider> notifications = [];

  @override
  void initState() {
    //getNotifications();
    getUserInfo();
    super.initState();
  }

  //get user information.
  Future<void> getUserInfo() async {
    _loggedInUser =
        Provider.of<UserProvider>(context, listen: false).loggedInUser;
  }

  //Display buttons for responses to invitation
  Future<void> displayNotificationInvitationResponse(
    BuildContext context,
    String inviteId,
    String organizerFirstName,
    String organizerLastName,
    String tripTitle,
    String tripId,
    String notificationId,
  ) async {
    await showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Trip invitation',
        ),
        content: Text(
          '$organizerFirstName $organizerLastName. has invited you on their $tripTitle trip.',
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Accept'),
            onPressed: () {
              invitationResponse(
                context,
                tripId,
                'accepted',
                notificationId,
              );
            },
          ),
          FlatButton(
            child: const Text('Decline'),
            onPressed: () {
              invitationResponse(
                context,
                tripId,
                'declined',
                notificationId,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> invitationResponse(
    BuildContext context,
    String tripId,
    String invitationStatusResponse,
    String notificationId,
  ) async {
    
    String inviteId;
    for(int i = 0; i < widget.currentLoggedInUser.tripInvites.length; i++){
      if(widget.currentLoggedInUser.tripInvites[i].tripId == tripId){
        print(widget.currentLoggedInUser.tripInvites[i].tripId);
        print(widget.currentLoggedInUser.tripInvites[i].invitationId);
        inviteId = widget.currentLoggedInUser.tripInvites[i].invitationId;
      }
    }
    await Provider.of<UserProvider>(context, listen: false)
        .updateTripInvitationStatus(
      _loggedInUser.id,
      inviteId,
      tripId,
      invitationStatusResponse,
    );
    await Provider.of<NotificationProvider>(context, listen: false)
        .updateNotificationStatus(
      _loggedInUser.id,
      notificationId,
      invitationStatusResponse,
    );
    await Provider.of<NotificationProvider>(context, listen: false)
        .updatedNotificationUnread(
          _loggedInUser.id,
          notificationId,
          false,
        )
        .then(
          (value) => setState(() {
            Navigator.of(context).pop();
          }),
        );
  }

  Future<void> displayConfirmationDialog(
    BuildContext context,
  ) async {
    await showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Confirm',
        ),
        content: Text(
          'Are you sure?',
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Yes'),
            onPressed: () {
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
  }

  //returns a type of icon based on notification type
  Widget getIcon(int index, String notificationType) {
    if (notificationType == 'trip-invite') {
      return Icon(
        Icons.group,
      );
    }
    if (notificationType == 'edit-flight' || notificationType == 'add-flight') {
      return Icon(
        Icons.flight,
      );
    }
    if (notificationType == 'edit-lodging' ||
        notificationType == 'add-lodging') {
      return Icon(
        Icons.hotel,
      );
    }
    if (notificationType == 'edit-activity' ||
        notificationType == 'add-activity') {
      return Icon(
        Icons.local_activity,
      );
    }
    if (notificationType == 'edit-restaurant' ||
        notificationType == 'add-restaurant') {
      return Icon(
        Icons.restaurant,
      );
    }
    if (notificationType == 'edit-transportation' ||
        notificationType == 'add-transportation') {
      return Icon(
        Icons.directions_car,
      );
    }
    return Container();
  }

  //returns true if already likes post, false if not.
  Future<void> checkIfRead(dynamic documents) async {}

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Drawer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppBar(
              title: Text(
                'Notifications',
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme: new IconThemeData(
                color: Theme.of(context).secondaryHeaderColor,
              ),
              toolbarHeight: screenHeight * 0.075,
              automaticallyImplyLeading: false,
              actions: [
                SizedBox(),
              ],
            ),
            Divider(
              thickness: 1,
              color: Colors.grey[400],
            ),
            SingleChildScrollView(
              child: Container(
                height: screenHeight * 0.87,
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc('${_loggedInUser.id}')
                        .collection('notifications')
                        .orderBy('notificationDateTime', descending: true)
                        .snapshots(),
                    builder: (ctx, streamSnapshot) {
                      if (streamSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final documents = streamSnapshot.data.documents;
                      return FutureBuilder(
                          future: checkIfRead(documents),
                          builder: (context, snapShot) {
                            if (snapShot.connectionState ==
                                ConnectionState.none) {
                              return Container();
                            }
                            return ListView.builder(
                              itemCount: documents.length,
                              itemBuilder: (BuildContext ctx, int index) {
                                return Container(
                                  color: !documents[index].data()['unread']
                                      ? Colors.grey[300]
                                      : Colors.grey[50],
                                  child: ListTile(
                                    leading: Container(
                                      width: 30,
                                      child: getIcon(
                                          index,
                                          documents[index]
                                              .data()['notificationType']),
                                    ),
                                    title: Text(
                                      '${documents[index].data()['notificationMessage']}',
                                    ),
                                    trailing: documents[index]
                                                .data()['status'] ==
                                            'na'
                                        ? Container(
                                            width: 1,
                                          )
                                        : documents[index].data()['status'] ==
                                                'pending'
                                            ? Container(
                                                width: 100,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(Icons.check),
                                                      onPressed: () =>
                                                          invitationResponse(
                                                        context,
                                                        documents[index]
                                                            .data()['tripId'],
                                                        'Accepted',
                                                        documents[index]
                                                            .data()['id'],
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons.clear),
                                                      onPressed: () =>
                                                          invitationResponse(
                                                        context,
                                                        documents[index]
                                                            .data()['tripId'],
                                                        'Declined',
                                                        documents[index]
                                                            .data()['id'],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(
                                                width: 65,
                                                child: Text(
                                                  '${documents[index].data()['status']}',
                                                  style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                    onTap: () => documents[index]
                                                .data()['status'] ==
                                            'pending'
                                        ? displayNotificationInvitationResponse(
                                            context,
                                            widget.currentLoggedInUser.tripInvites[0].invitationId,
                                            documents[index]
                                                .data()['organizerFirstName'],
                                            documents[index]
                                                .data()['organizerLastName'],
                                            documents[index]
                                                .data()['tripTitle'],
                                            documents[index].data()['tripId'],
                                            documents[index].data()['id'],
                                          )
                                        : null,
                                    dense: true,
                                  ),
                                );
                              },
                            );
                          });
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
