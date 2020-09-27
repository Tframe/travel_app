import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';


import '../../../providers/user_provider.dart';
import '../edit_contact_info_screen.dart';

class ContactInfo extends StatelessWidget {
  final UserProvider _loadedUser;
  final User user;
  ContactInfo(this._loadedUser, this.user);

  //routes to edit contact info screen, sends the loadeduser current info 
  //and user info for firestore
  void _editContactInfo(BuildContext context) {
    Navigator.of(context).pushNamed(
      EditContactInfoScreen.routeName,
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
                'Contact',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _editContactInfo(context),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 18.0,
            bottom: 8.0,
          ),
          child: Text(
            _loadedUser.email == null && _loadedUser.phone == null
                ? 'Add some contact information'
                : _loadedUser.email != null
                    ? _loadedUser.email
                    : _loadedUser.phone,
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 18.0,
            bottom: 18.0,
          ),
          child: Text(
            _loadedUser.email == null ? Container() : _loadedUser.phone,
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
