/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: Layout used for seeing the different
 * tabs used for navigating between the discover, current trips, and
 * past trips screens.
 */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './current_trip_screens/current_trips_screen.dart';
import '../screens/discover_screens/discover_screen.dart';
import '../screens/past_trips_screens/past_trips_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/notification_end_drawer.dart';
import '../providers/user_provider.dart';

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
                // if (_scaffoldKey.currentState.isEndDrawerOpen) {
                //   setState(() {
                //     Provider.of<NotificationProvider>(context, listen: false)
                //         .clearNotificationsList();
                //     // //After viewing, update all unread notifications to be read.
                //     for (int i = 0; i < notifications.length; i++) {
                //       if (notifications[i].unread) {
                //         Provider.of<NotificationProvider>(context,
                //                 listen: false)
                //             .updatedNotificationUnread(
                //           currentLoggedInUser.id,
                //           notifications[i].id,
                //           false,
                //         );
                //       }
                //     }
                //   });
                // }
              },
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
      body: _pages[_selectedPageIndex]['page'],
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
