import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  //get list of notifications and add to notification list.
  Future<void> getNotifications() async {
    _loggedInUser =
        Provider.of<UserProvider>(context, listen: false).loggedInUser;

    await Provider.of<NotificationProvider>(context, listen: false)
        .getNotifications(_loggedInUser.id);
    setState(() {
      notifications = Provider.of<NotificationProvider>(context, listen: false)
          .notifications;
      notifications.sort(
          (a, b) => b.notificationDateTime.compareTo(a.notificationDateTime));
    });
  }

  Future<void> displayNotificationInvitationResponse(
    BuildContext context,
    int index,
  ) async {
    await showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Trip invitation',
        ),
        content: Text(
          '${widget.currentLoggedInUser.tripInvites[index].organizerFirstName} ${widget.currentLoggedInUser.tripInvites[index].organizerLastName[0]}. has invited you on their ${widget.currentLoggedInUser.tripInvites[index].tripTitle} trip.',
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Accept'),
            onPressed: () {
              invitationResponse(
                context,
                index,
                'accepted',
              );
            },
          ),
          FlatButton(
            child: const Text('Decline'),
            onPressed: () {
              invitationResponse(
                context,
                index,
                'declined',
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> invitationResponse(
    BuildContext context,
    int index,
    String invitationStatusResponse,
  ) async {
    await Provider.of<UserProvider>(context, listen: false)
        .updateTripInvitationStatus(
      widget.currentLoggedInUser.id,
      widget.currentLoggedInUser.tripInvites[index].invitationId,
      widget.currentLoggedInUser.tripInvites[index].tripId,
      invitationStatusResponse,
    );
    await Provider.of<NotificationProvider>(context, listen: false)
        .updateNotificationStatus(widget.currentLoggedInUser.id,
            notifications[index].id, invitationStatusResponse);
    await Provider.of<NotificationProvider>(context, listen: false)
        .updatedNotificationUnread(
          widget.currentLoggedInUser.id,
          notifications[index].id,
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

  @override
  void initState() {
    getNotifications();
    super.initState();
  }

  Widget getIcon(int index) {
    if (notifications[index].notificationType == 'trip-invite') {
      return Icon(
        Icons.group,
      );
    }
    if (notifications[index].notificationType == 'edit-flight' ||
        notifications[index].notificationType == 'add-flight') {
      return Icon(
        Icons.flight,
      );
    }
    if (notifications[index].notificationType == 'edit-lodging' ||
        notifications[index].notificationType == 'add-lodging') {
      return Icon(
        Icons.hotel,
      );
    }
    if (notifications[index].notificationType == 'edit-activity' ||
        notifications[index].notificationType == 'add-activity') {
      return Icon(
        Icons.local_activity,
      );
    }
    if (notifications[index].notificationType == 'edit-restaurant' ||
        notifications[index].notificationType == 'add-restaurant') {
      return Icon(
        Icons.restaurant,
      );
    }
    if (notifications[index].notificationType == 'edit-transportation' ||
        notifications[index].notificationType == 'add-transportation') {
      return Icon(
        Icons.directions_car,
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
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
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (BuildContext ctx, int index) {
                    return Container(
                      color: notifications[index].unread
                          ? Colors.grey[300]
                          : Colors.grey[50],
                      child: ListTile(
                        leading: Container(
                          width: 30,
                          child: getIcon(index),
                        ),
                        title: Text(
                          '${notifications[index].notificationMessage}',
                        ),
                        trailing: notifications[index].status == 'na'
                            ? Container(
                                width: 1,
                              )
                            : notifications[index].status == 'pending'
                                ? Container(
                                    width: 100,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.check),
                                          onPressed: () => invitationResponse(
                                              context, index, 'Accepted'),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.clear),
                                          onPressed: () => invitationResponse(
                                              context, index, 'Declined'),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    width: 65,
                                    child: Text(
                                      '${notifications[index].status}',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                        onTap: () => notifications[index].status == 'pending'
                            ? displayNotificationInvitationResponse(
                                context,
                                index,
                              )
                            : null,
                        dense: true,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
