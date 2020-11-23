import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/post_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../screens/post_comments_screens/sub_comments_screen.dart';
import '../../../screens/account_profile_screens/account_profile_screen.dart';

class DisplayAccountProfilePosts extends StatefulWidget {
  final String userId;

  DisplayAccountProfilePosts(this.userId);

  @override
  _DisplayAccountProfilePostsState createState() =>
      _DisplayAccountProfilePostsState();
}

class _DisplayAccountProfilePostsState
    extends State<DisplayAccountProfilePosts> {
  List<bool> checked = [];
  UserProvider currentLoggedInUser;

//returns true if already likes post, false if not.
  Future<bool> checkIfLiked(dynamic documents) async {
    print('in check');
    for (int j = 0; j < documents.length; j++) {
      await Provider.of<PostProvider>(context, listen: false)
          .checkIfLikedForPostUser(
              widget.userId, documents[j].id, currentLoggedInUser.id)
          .then((value) {
        checked[j] = value;
        print(checked[j]);
      });
    }
    return true;
  }

  //Adds a like to the post
  Future<void> likePost(String postId, index) async {
    if (checked[index]) {
      await Provider.of<PostProvider>(context, listen: false)
          .removeLikePostUser(widget.userId, postId, currentLoggedInUser.id)
          .then((value) {
        print('unliked');
      });
      await Provider.of<PostProvider>(context, listen: false)
          .decrementLikePostUser(widget.userId, postId, currentLoggedInUser.id);
    } else {
      await Provider.of<PostProvider>(context, listen: false)
          .likePostUser(widget.userId, postId, currentLoggedInUser)
          .then((value) {
        print('liked');
      });
      await Provider.of<PostProvider>(context, listen: false).incrementLikePostUser(widget.userId, postId, currentLoggedInUser);
    }
  }

  Future<void> commentPost(String postId) async {
    Navigator.of(context).pushNamed(SubCommentsScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth;
    screenWidth = MediaQuery.of(context).size.width;
    currentLoggedInUser =
        Provider.of<UserProvider>(context, listen: false).loggedInUser;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc('${widget.userId}')
          .collection('posts')
          .orderBy('dateTime', descending: true)
          .snapshots(),
      builder: (ctx, streamSnapshot) {
        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final documents = streamSnapshot.data.documents;
        checked = [];
        for (int i = 0; i < documents.length; i++) {
          checked.add(false);
        }
        return FutureBuilder(
          future: checkIfLiked(documents).then((value) {
            print('Finished future');
          }),
          builder: (context, snapShot) {
            if (snapShot.connectionState == ConnectionState.none) {
              return Container();
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: documents.length,
              itemBuilder: (ctx, index) {
                //Add list of postId's
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 75,
                      width: screenWidth,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AccountProfileScreen.routeName,
                                arguments: {
                                  'userId': documents[index].data()['authorId']
                                },
                              );
                            },
                            child: documents[index].data()['authorImageURL'] ==
                                    null
                                ? CircleAvatar(
                                    radius: 20,
                                    child: Icon(
                                      Icons.person,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: ClipOval(
                                      child: Image.network(
                                        documents[index]
                                            .data()['authorImageURL'],
                                        fit: BoxFit.cover,
                                        height: 40,
                                        width: 40,
                                      ),
                                    ),
                                  ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18.0,
                            ),
                            width: screenWidth * .75,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${documents[index].data()['authorFirstName']} ${documents[index].data()['authorLastName']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${DateFormat.MMMd().format(documents[index].data()['dateTime'].toDate())}',
                                    ),
                                    documents[index].data()['location'] != null
                                        ? Text(
                                            '   -   ${documents[index].data()['location']}',
                                          )
                                        : Text(
                                            '',
                                          ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        bottom: 18.0,
                      ),
                      child: Container(
                        height: documents[index].data()['photosURL'] != null
                            ? 500
                            : 0,
                        width: screenWidth,
                        decoration: documents[index].data()['photosURL'] != null
                            ? BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    documents[index].data()['photosURL'],
                                  ),
                                  fit: BoxFit.fitHeight,
                                ),
                              )
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                      ),
                      child: Linkify(
                        options: LinkifyOptions(
                          humanize: false,
                        ),
                        text: documents[index].data()['message'],
                        onOpen: (link) async {
                          if (await canLaunch(link.url)) {
                            await launch(link.url);
                          } else {
                            throw 'Could not launch $link';
                          }
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        documents[index].data()['likes'] > 0
                            ? Padding(
                                padding: const EdgeInsets.only(left: 18.0),
                                child: Text(
                                    '${documents[index].data()['likes']} likes'),
                              )
                            : Text(''),
                        Row(
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.thumb_up,
                                  color: checked[index]
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                                onPressed: () async {
                                  await likePost(documents[index].id, index);
                                }),
                            IconButton(
                              icon: Icon(
                                Icons.chat_bubble,
                                color: Colors.grey,
                              ),
                              onPressed: () async =>
                                  await commentPost(documents[index].id),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(
                      thickness: 10,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
