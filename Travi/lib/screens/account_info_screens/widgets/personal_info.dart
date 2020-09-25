import 'package:flutter/material.dart';

import '../../../providers/user_provider.dart';

class PersonalInfo extends StatelessWidget {

  UserProvider _loadedUser;

  PersonalInfo(this._loadedUser);

  //padding for text widgets
  Widget _paddingText(
      String text, double screenHeight, double screenWidth, double fontSize) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.0055,
        horizontal: screenWidth * 0.05,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          height: screenHeight * 0.23,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _paddingText('${_loadedUser.firstName} ${_loadedUser.lastName}', screenHeight, screenWidth, 20),
              _paddingText('${_loadedUser.address}', screenHeight, screenWidth, 15),
              _paddingText('www.webite.com', screenHeight, screenWidth, 15),
              _paddingText('Number Followers', screenHeight, screenWidth, 15),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FlatButton(
                    onPressed: () {},
                    child: Text('Message'),
                    color: Colors.blue,
                  ),
                  FlatButton(
                    onPressed: () {},
                    child: Text('Photots'),
                    color: Colors.blue,
                  ),
                  FlatButton(
                    onPressed: () {},
                    child: Text('More'),
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {},
        ),
      ],
    );
  }
}
