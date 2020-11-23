import 'package:flutter/material.dart';

import '../../../providers/user_provider.dart';

class AboutSection extends StatelessWidget {
  final UserProvider _loadedUser;

  AboutSection(this._loadedUser);

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
            children: [
              const Text(
                'About',
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
