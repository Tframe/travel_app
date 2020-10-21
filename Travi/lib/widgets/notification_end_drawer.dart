import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:groupy/providers/user_provider.dart';

class NotificationEndDrawer extends StatefulWidget {
  final UserProvider currentLoggedInUser;
  NotificationEndDrawer(this.currentLoggedInUser);

  @override
  _NotificationEndDrawerState createState() => _NotificationEndDrawerState();
}

class _NotificationEndDrawerState extends State<NotificationEndDrawer> {
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
      BuildContext context, int index, String invitationStatusResponse) async {
    await Provider.of<UserProvider>(context, listen: false)
        .updateTripInvitationStatus(
          widget.currentLoggedInUser.id,
          widget.currentLoggedInUser.tripInvites[index].invitationId,
          widget.currentLoggedInUser.tripInvites[index].tripId,
          invitationStatusResponse,
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
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              toolbarHeight: screenHeight * 0.075,
              automaticallyImplyLeading: false,
              iconTheme: new IconThemeData(
                color: Colors.white,
              ),
              actions: [
                SizedBox(),
              ],
            ),
            SingleChildScrollView(
              child: Container(
                height: screenHeight * 0.1,
                child: ListView.builder(
                  itemExtent: screenHeight * 0.1,
                  itemCount: widget.currentLoggedInUser != null
                      ? widget.currentLoggedInUser.tripInvites.length > 0
                          ? widget.currentLoggedInUser.tripInvites.length
                          : 0
                      : 0,
                  itemBuilder: (BuildContext ctx, int index) {
                    return ListTile(
                      leading: Icon(
                        Icons.group,
                      ),
                      title: Text(
                        'Trip invitation:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${widget.currentLoggedInUser.tripInvites[index].organizerFirstName} ${widget.currentLoggedInUser.tripInvites[index].organizerLastName[0]}. has invited you on their ${widget.currentLoggedInUser.tripInvites[index].tripTitle} trip.',
                      ),
                      trailing: widget.currentLoggedInUser.tripInvites[index]
                                  .status ==
                              'pending'
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
                                '${widget.currentLoggedInUser.tripInvites[index].status}',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                      onTap: () => widget.currentLoggedInUser.tripInvites[index]
                                  .status ==
                              'pending'
                          ? displayNotificationInvitationResponse(
                              context, index)
                          : null,
                      dense: true,
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
