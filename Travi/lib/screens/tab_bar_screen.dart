import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/current_trips_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/past_trips_screen.dart';
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

  Future<void> setUserData() async {
    try {
      await Provider.of<UserProvider>(context, listen: false).setCurrentUser();
      await Provider.of<UserProvider>(context, listen: false)
          .setCurrentUserId();
      currentUserId = await Provider.of<UserProvider>(context, listen: false)
          .getCurrentUserId();
      await Provider.of<UserProvider>(context, listen: false)
          .setLoggedInUser(currentUserId);
      getListOfInvitations();
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

  Widget _builderAppBar(BuildContext ctx) {
    return AppBar(
      title: Text(_pages[_selectedPageIndex]['title'],
          style: TextStyle(
            color: Theme.of(context).secondaryHeaderColor,
          )),
      iconTheme: new IconThemeData(
        color: Theme.of(context).secondaryHeaderColor,
      ),
      actions: <Widget>[
        Stack(
          fit: StackFit.loose,
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: Icon(
                Icons.announcement,
                size: 30,
              ),
              onPressed: () {
                _scaffoldKey.currentState.openEndDrawer();
              },
            ),
            currentLoggedInUser != null
                ? currentLoggedInUser.tripInvites != null
                    ? currentLoggedInUser.tripInvites.length > 0
                        ? Container(
                            height: 25,
                            width: 25,
                            child: Card(
                              elevation: 5,
                              color: Colors.red,
                              child: Text(
                                '${currentLoggedInUser.tripInvites.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : Container()
                    : Container()
                : Container(),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    int value = 0;
    return Scaffold(
      key: _scaffoldKey,
      appBar: _builderAppBar(context),
      drawer: AppDrawer(),
      body: _pages[_selectedPageIndex]['page'],
      endDrawer: Container(
        width: screenWidth * 0.9,
        child: NotificationEndDrawer(currentLoggedInUser),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).accentColor,
        selectedItemColor: Theme.of(context).secondaryHeaderColor,
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
    );
  }
}
