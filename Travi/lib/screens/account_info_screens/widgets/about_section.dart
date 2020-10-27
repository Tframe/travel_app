import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../providers/user_provider.dart';
import '../edit_about_screen.dart';

class AboutSection extends StatelessWidget {
  final UserProvider _loadedUser;
  final User user;

  AboutSection(this._loadedUser, this.user);

  //routes to edit contact info screen, sends the loadeduser current info 
  //and user info for firestore
  void _editAbout(BuildContext context) {
    Navigator.of(context).pushNamed(
      EditAboutScreen.routeName,
      arguments: {'loadedUser': _loadedUser, 'user': user},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 15.0,
            left: 18.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _editAbout(context),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 18.0,
            bottom: 18.0,
          ),
          child: Text(
            _loadedUser.about != null
                ? _loadedUser.about
                : 'Add some information about yourself',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
