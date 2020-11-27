import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/post_provider.dart';
import '../providers/trip_provider.dart';
import '../providers/user_provider.dart';
import '../screens/post_comments_screens/sub_comments_screen.dart';
import '../screens/account_profile_screens/account_profile_screen.dart';

class DisplayPosts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth;
    String organizerId;
    String tripId;
    UserProvider currentLoggedInUser;
    List<bool> checked = [];

    //returns true if already likes post, false if not.
    Future<void> checkIfLiked(dynamic documents) async {
      for (int j = 0; j < documents.length; j++) {
        bool tempBool = await Provider.of<PostProvider>(context, listen: false)
            .checkIfLiked(
                organizerId, tripId, documents[j].id, currentLoggedInUser.id);
        checked[j] = tempBool;
      }
    }

    //Adds a like to the post
    Future<void> likePost(String postId, index) async {
      bool tempBool = false;
      //if already liked, remove like, otherwise add the like
      if (await Provider.of<PostProvider>(context, listen: false)
          .checkIfLiked(organizerId, tripId, postId, currentLoggedInUser.id)) {
        //remove the user information that likes the post
        await Provider.of<PostProvider>(context, listen: false)
            .removeLikePost(organizerId, tripId, postId, currentLoggedInUser)
            .then((value) => print('removed like'));
        //decrments number of likes
        await Provider.of<PostProvider>(context, listen: false)
            .decrementLikePost(
                organizerId, tripId, postId, currentLoggedInUser);
      } else {
        //add user information to likes of post
        await Provider.of<PostProvider>(context, listen: false)
            .likePost(organizerId, tripId, postId, currentLoggedInUser)
            .then((value) => print('liked post'));
        //increment number of likes for a post
        await Provider.of<PostProvider>(context, listen: false)
            .incrementLikePost(
                organizerId, tripId, postId, currentLoggedInUser);
      }
      checked[index] = tempBool;
    }

    Future<void> commentPost(String postId) async {
      Navigator.of(context).pushNamed(SubCommentsScreen.routeName);
    }

    screenWidth = MediaQuery.of(context).size.width;
    organizerId = Provider.of<TripProvider>(context, listen: false)
        .currentTrip
        .organizerId;
    tripId = Provider.of<TripProvider>(context, listen: false).currentTrip.id;
    currentLoggedInUser =
        Provider.of<UserProvider>(context, listen: false).loggedInUser;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('trips')
          .doc('$tripId')
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
        for (int i = 0; i < documents.length; i++) {
          checked.add(false);
        }
        return FutureBuilder(
          future: checkIfLiked(documents),
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
                                    Flexible(
                                      child: Container(
                                        child: Text(
                                          ' on ${documents[index].data()['eventName']}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          softWrap: false,
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
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
                                color:
                                    checked[index] ? Colors.blue : Colors.grey,
                              ),
                              onPressed: () async =>
                                  await likePost(documents[index].id, index),
                            ),
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
