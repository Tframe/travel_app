import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/current_trips_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/past_trips_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/notification_end_drawer.dart';
import '../providers/user_provider.dart';
import '../providers/notification_provider.dart';

class TabBarScreen extends StatefulWidget {
  static const routeName = '/tab-bar-screen';

  @override
  _TabBarScreenState createState() => _TabBarScreenState();
}

class _TabBarScreenState extends State<TabBarScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 1;
  String currentUserId;
  UserProvider currentLoggedInUser;
  List<NotificationProvider> notifications;

  @override
  void initState() {
    _pages = [
      {
        'page': CurrentTripsScreen(),
        'title': 'Current Trips',
      },
      {
        'page': DiscoverScreen(),
        'title': 'Discover',
      },
      {
        'page': PastTripsScreen(),
        'title': 'Past Trips',
      }
    ];
    setUserData();
    super.initState();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  Future<void> setUserData() async {
    try {
      await Provider.of<UserProvider>(context, listen: false).setCurrentUser();
      await Provider.of<UserProvider>(context, listen: false)
          .setCurrentUserId();
      currentUserId = await Provider.of<UserProvider>(context, listen: false)
          .getCurrentUserId();
      await Provider.of<UserProvider>(context, listen: false)
          .setLoggedInUser(currentUserId);

      await getListOfInvitations();
      await getNotifications();
    } catch (error) {
      print(error);
      return;
    }
  }

  //Gets list of pending invitations for current loggedin user.
  Future<void> getListOfInvitations() async {
    await Provider.of<UserProvider>(context, listen: false)
        .getInvites(currentUserId);
    setState(() {
      currentLoggedInUser =
          Provider.of<UserProvider>(context, listen: false).currentLoggedInUser;
    });
  }

  //after loading user, get all notifications for user.
  Future<void> getNotifications() async {
    await Provider.of<NotificationProvider>(context, listen: false)
        .getNotifications(currentUserId);
    notifications =
        Provider.of<NotificationProvider>(context, listen: false).notifications;
    setState(() {
      notifications.sort(
          (a, b) => b.notificationDateTime.compareTo(a.notificationDateTime));
    });
  }

  Widget _builderAppBar(BuildContext ctx) {
    return AppBar(
      title: Text(
        _pages[_selectedPageIndex]['title'],
        style: TextStyle(
          color: Theme.of(context).secondaryHeaderColor,
        ),
      ),
      iconTheme: new IconThemeData(
        color: Theme.of(context).secondaryHeaderColor,
      ),
      bottom: PreferredSize(
        child: Container(
          color: Colors.grey[400],
          height: 1,
        ),
        preferredSize: Size.fromHeight(1.0),
      ),
      backgroundColor: Colors.grey[50],
      actions: <Widget>[
        Stack(
          fit: StackFit.loose,
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications,
                size: 30,
              ),
              onPressed: () {
                _scaffoldKey.currentState.openEndDrawer();
                if (_scaffoldKey.currentState.isEndDrawerOpen) {
                  setState(() {
                    Provider.of<NotificationProvider>(context, listen: false)
                        .clearNotificationsList();
                    // //After viewing, update all unread notifications to be read.
                    for (int i = 0; i < notifications.length; i++) {
                      if (notifications[i].unread) {
                        Provider.of<NotificationProvider>(context,
                                listen: false)
                            .updatedNotificationUnread(
                          currentLoggedInUser.id,
                          notifications[i].id,
                          false,
                        );
                      }
                    }
                  });
                }
              },
            ),
            notifications != null
                ? notifications
                            .where(
                                (notification) => notification.unread == true)
                            .length >
                        0
                    ? Container(
                        height: 25,
                        width: 25,
                        child: Card(
                          elevation: 5,
                          color: Colors.red,
                          child: Text(
                            '${notifications.where((notification) => notification.unread).length}',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Container(
                        width: 1,
                      )
                : Container(
                    width: 1,
                  ),
          ],
        ),
      ],
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: _builderAppBar(context),
      drawer: AppDrawer(),
      body:  _pages[_selectedPageIndex]['page'],
      endDrawer: Container(
          width: screenWidth * 0.9,
          child: NotificationEndDrawer(currentLoggedInUser)),
      endDrawerEnableOpenDragGesture: false,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey[500],
            ),
          ],
        ),
        child: BottomNavigationBar(
          elevation: 0,
          //backgroundColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[500],
          selectedItemColor: Theme.of(context).buttonColor,
          selectedFontSize: 17,
          selectedIconTheme: IconThemeData(
            size: 35,
          ),
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          onTap: _selectPage,
          currentIndex: _selectedPageIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.beach_access),
              title: Text('Current Trips'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              title: Text('Discover'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              title: Text('Past Trips'),
            ),
          ],
        ),
      ),
    );
  }
}
