/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: User Profile personal info
 * widget.
 */
import 'package:flutter/material.dart';
import '../../../providers/user_provider.dart';

class PersonalInfo extends StatelessWidget {
  final UserProvider _loadedUser;

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        _paddingText('${_loadedUser.firstName} ${_loadedUser.lastName}',
            screenHeight, screenWidth, 20),
        _paddingText('${_loadedUser.location}', screenHeight, screenWidth, 15),
        _loadedUser.sites != null
            ? _paddingText('www.webite.com', screenHeight, screenWidth, 15)
            : new Container(),
        _loadedUser.followers != null
            ? _paddingText('Number Followers', screenHeight, screenWidth, 15)
            : new Container(),
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
              child: Text('Timeline'),
              color: Colors.blue,
            ),
            
          ],
        ),
      ],
    );
  }
}
