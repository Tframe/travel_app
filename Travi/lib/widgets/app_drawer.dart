/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: widget for displaying main app drawer contnts
 * Account profile, contact us, logout, etc.
 */
import 'package:flutter/material.dart';
import '../screens/current_trip_screens/current_trips_screen.dart';
import '../screens/account_info_screens/edit_account_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppBar(
            title: Text(
              'MENU',
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: new IconThemeData(
              color: Theme.of(context).secondaryHeaderColor,
            ),
            automaticallyImplyLeading: false,
            actions: [
              Container(),
            ],
          ),
          Divider(
            color: Colors.grey[400],
            thickness: 1,
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
              Navigator.of(context).pushNamed(EditAccountProfileScreen.routeName);
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
