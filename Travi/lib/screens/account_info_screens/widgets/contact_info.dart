import 'package:flutter/material.dart';

import '../../../providers/user_provider.dart';

class ContactInfo extends StatelessWidget {
  final UserProvider _loadedUser;
  ContactInfo(this._loadedUser);


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 15.0,
            left: 18.0,
            bottom: 15.0,
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
