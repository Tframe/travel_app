import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/current_trips_screen.dart';
import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text(
              'MENU',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            automaticallyImplyLeading: false,
            iconTheme: new IconThemeData(
              color: Colors.white,
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              color: Theme.of(context).secondaryHeaderColor,
            ),
            title: Text(
              'Account Information',
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
            //NAVIGATION TO NEW SCREEN
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(CurrentTripsScreen.routeName);
            },
          ),
          Divider(
            thickness: 2,
          ),
          ListTile(
            leading: Icon(
              Icons.email,
              color: Theme.of(context).secondaryHeaderColor,
            ),
            title: Text(
              'Contact Us',
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
            //NAVIGATION TO NEW SCREEN
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(CurrentTripsScreen.routeName);
            },
          ),
          Divider(
            thickness: 2,
          ),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).secondaryHeaderColor,
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
            //NAVIGATION TO NEW SCREEN
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
