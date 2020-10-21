import 'package:flutter/material.dart';

import '../screens/current_trips_screen.dart';
import '../screens/account_info_screens/account_profile_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';

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
            actions: [
              Container(),
            ],
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              color: Theme.of(context).secondaryHeaderColor,
            ),
            title: Text(
              'Account Profile',
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
            //NAVIGATION TO NEW SCREEN
            onTap: () {
              Navigator.of(context)
                  .pushNamed(AccountProfileScreen.routeName);
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
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
