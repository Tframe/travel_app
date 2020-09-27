import 'package:flutter/material.dart';
import '../screens/add_trip_screens/add_trip_intro_screen.dart';
import 'package:groupy/screens/current_trips_screen.dart';
import 'package:groupy/screens/discover_screen.dart';
import 'package:groupy/screens/past_trips_screen.dart';
import 'package:groupy/widgets/app_drawer.dart';

class TabBarScreen extends StatefulWidget {
  static const routeName = '/tab-bar-screen';

  @override
  _TabBarScreenState createState() => _TabBarScreenState();
}

class _TabBarScreenState extends State<TabBarScreen> {
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 1;

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

    super.initState();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  Widget _builderAppBar(BuildContext ctx) {
    if (_selectedPageIndex == 0) {
      return AppBar(
        title: Text(_pages[_selectedPageIndex]['title'],
            style: TextStyle(
              color: Theme.of(context).secondaryHeaderColor,
            )),
        iconTheme: new IconThemeData(
          color: Theme.of(context).secondaryHeaderColor,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).secondaryHeaderColor,
            ),
            onPressed: () => Navigator.of(context).pushNamed(AddTripIntroScreen.routeName)
          ),
        ],
      );
    } else {
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
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _builderAppBar(context),
      drawer: AppDrawer(),
      body: _pages[_selectedPageIndex]['page'],
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
