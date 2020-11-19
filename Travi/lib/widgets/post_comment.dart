import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../screens/post_comments_screens/post_comment_screen.dart';

class PostComment extends StatefulWidget {
  @override
  _PostCommentState createState() => _PostCommentState();
}

class _PostCommentState extends State<PostComment> {
  double screenHeight = 0;
  double screenWidth = 0;
  UserProvider loggedInUser;

  Future<void> getUserInfo() async {
    setState(() {
      loggedInUser =
          Provider.of<UserProvider>(context, listen: false).loggedInUser;
    });
  }

  @override
  void initState() {
    getUserInfo();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            thickness: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  top: 8,
                ),
                child: Text(
                  'Post',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 12.0,
              bottom: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                loggedInUser.profilePicUrl == null
                    ? CircleAvatar(
                        radius: 20,
                        child: Icon(
                          Icons.person,
                        ),
                      )
                    : ClipOval(
                        child: Image.network(
                          loggedInUser.profilePicUrl,
                          fit: BoxFit.cover,
                          height: 40,
                          width: 40,
                        ),
                      ),
                Container(
                  width: screenWidth * 0.65,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      primaryColor: Theme.of(context).buttonColor,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Share your thoughts...',
                      ),
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(PostCommentScreen.routeName);
                        FocusScope.of(context).unfocus();
                      },
                      showCursor: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
