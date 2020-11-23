/* Author: Trevor Frame
 * Date: 11/18/2020
 * Description: AccountProfileScreen will display other user's
 * account profile pages that display their personal information,
 * post history, photoes, and trip history.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../account_info_screens/widgets/personal_info.dart';
import '../account_info_screens/widgets/about_section.dart';
import './widgets/post_comment_profile.dart';
import '../../widgets/travel_stats.dart';
import './widgets/display_account_profile_posts.dart';

class AccountProfileScreen extends StatefulWidget {
  static const routeName = '/account-profile-screen';

  @override
  _AccountProfileScreenState createState() => _AccountProfileScreenState();
}

class _AccountProfileScreenState extends State<AccountProfileScreen> {
  UserProvider userProfileInfo = UserProvider();

  Future<bool> getUserData(String userId) async {
    UserProvider tempUser =
        await Provider.of<UserProvider>(context).findUserById(userId);
    userProfileInfo = tempUser;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    final userId = arguments['userId'];
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          child: Container(
            color: Colors.grey[400],
            height: 1,
          ),
          preferredSize: Size.fromHeight(1.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: new IconThemeData(
          color: Theme.of(context).secondaryHeaderColor,
        ),
      ),
      body: SingleChildScrollView(
              child: FutureBuilder(
          future: getUserData(userId),
          builder: (context, snapshot) {
            List<Widget> children;
            if (snapshot.hasData) {
              children = [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          height: screenHeight * 0.18,
                          width: double.infinity,
                          color: Colors.grey[400],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: screenWidth * (0.5 - 0.17),
                                bottom: screenHeight * 0.0125,
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: screenHeight * 0.075,
                                ),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: screenWidth * 0.17,
                                  child: userProfileInfo.profilePicUrl == null
                                      ? CircleAvatar(
                                          radius: 30,
                                          child: Icon(
                                            Icons.person,
                                          ),
                                        )
                                      : ClipOval(
                                          child: Image.network(
                                            userProfileInfo.profilePicUrl,
                                            fit: BoxFit.cover,
                                            height: screenWidth * 0.32,
                                            width: screenWidth * 0.32,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    PersonalInfo(userProfileInfo),
                    Divider(
                      thickness: 10,
                    ),
                    AboutSection(userProfileInfo),
                    Divider(
                      thickness: 10,
                    ),
                    TravelStats(),
                    PostCommentProfile(userId),
                    Divider(
                      thickness: 10,
                    ),
                    DisplayAccountProfilePosts(userId),
                  ],
                ),
              ];
            } else if (snapshot.hasError) {
              children = [
                Center(
                  child: Text('ERROR'),
                ),
              ];
            } else {
              children = [
                CircularProgressIndicator(),
              ];
            }
            return Center(
              child: Column(
                children: children,
              ),
            );
          },
        ),
      ),
    );
  }
}
