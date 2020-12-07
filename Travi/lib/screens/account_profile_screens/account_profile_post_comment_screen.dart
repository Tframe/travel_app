/* Author: Trevor Frame
 * Date: 11/19/2020
 * Description: Screen for adding a post comment to a 
 * profile. User can add photos/videos
 * and location.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import '../../providers/user_provider.dart';
import '../../providers/tag_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/pickers/image_video.dart';
import '../../helpers/location_helper.dart';
import '../../helpers/parse_strings.dart';

class AccountProfilePostCommentScreen extends StatefulWidget {
  static const routeName = '/account-profile-post-comment-screen';

  @override
  _AccountProfilePostCommentScreenState createState() =>
      _AccountProfilePostCommentScreenState();
}

class _AccountProfilePostCommentScreenState
    extends State<AccountProfilePostCommentScreen> {
  String userId;
  double screenWidth = 0;
  double screenHeight = 0;
  String message = '';
  List<String> tags = [];
  bool _video = false;
  bool _uploaded = false;

  PostProvider newPost = PostProvider(
    id: null,
    authorId: null,
    authorFirstName: null,
    authorImageURL: null,
    authorLastName: null,
    message: null,
    location: null,
    locationLatitude: null,
    locationLongitude: null,
    tagIds: [],
    photosURL: null,
  );

  final GlobalKey<FormState> _formKey = GlobalKey();
  final _audienceFocusNode = FocusNode();
  final _thoughtsFocusNode = FocusNode();

  UserProvider loggedInUser;

  File _imageFile;
  File _videoFile;

  //List of dropdowns for selecting what type of event to comment on
  List<DropdownMenuItem<int>> audience = [];
  int _selectdAudience = 0;

  @override
  void initState() {
    audience.add(
      new DropdownMenuItem(
        child: new Text('Public'),
        value: 0,
      ),
    );
    audience.add(
      new DropdownMenuItem(
        child: new Text('Friends'),
        value: 1,
      ),
    );
    audience.add(
      new DropdownMenuItem(
        child: new Text('Close Friends and Family'),
        value: 2,
      ),
    );
    audience.add(
      new DropdownMenuItem(
        child: new Text('Private'),
        value: 3,
      ),
    );
    getUserInfo();
    super.initState();
  }

  @override
  void dispose() {
    _audienceFocusNode.dispose();
    _thoughtsFocusNode.dispose();
    super.dispose();
  }

  Future<void> getUserInfo() async {
    setState(() {
      loggedInUser =
          Provider.of<UserProvider>(context, listen: false).loggedInUser;
    });
    newPost.authorId = loggedInUser.id;
    newPost.authorFirstName = loggedInUser.firstName;
    newPost.authorLastName = loggedInUser.lastName;
    newPost.authorImageURL = loggedInUser.profilePicUrl;
  }

  //App bar widget
  Widget appBar() {
    return AppBar(
      title: const Text('Add Post'),
      elevation: 0,
      backgroundColor: Colors.grey[50],
      bottom: PreferredSize(
        child: Container(
          color: Colors.grey[400],
          height: 1,
        ),
        preferredSize: Size.fromHeight(1.0),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 20.0,
          ),
          child: SizedBox(
            width: 75,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  10.0,
                ),
              ),
              onPressed: () => submitPost(context),
              child: Text(
                'POST',
              ),
              color: Theme.of(context).buttonColor,
              textColor: Theme.of(context).accentColor,
            ),
          ),
        ),
      ],
    );
  }

  //Look for existing tags that contain tag word.
  Future<void> checkThenAddTags(BuildContext context) async {
    //For each tag, check if exists in firestore
    for (int j = 0; j < tags.length; j++) {
      String tagId = await Provider.of<TagProvider>(context, listen: false)
          .checkForExistingTag(tags[j]);
      String authorId = loggedInUser.id;
      PostProvider postInfo = PostProvider(
        id: newPost.id,
        dateTime: newPost.dateTime,
        authorId: authorId,
        authorFirstName: newPost.authorFirstName,
        authorLastName: newPost.authorLastName,
        authorImageURL: newPost.authorImageURL,
        message: newPost.message,
        tripId: null,
        activityId: null,
        flightId: null,
        eventName: null,
        lodgingId: null,
        restaurantId: null,
        transportationId: null,
        photosURL: newPost.photosURL,
        videosURL: newPost.videosURL,
        location: newPost.location,
        locationLatitude: newPost.locationLatitude,
        locationLongitude: newPost.locationLongitude,
      );
      //Create the tag
      TagProvider tag = TagProvider(
        postInfo: [
          postInfo,
        ],
        tagWord: tags[j],
      );
      //If receive a tagId, then add to existing tag
      //otherwise add a new tag collection
      if (tagId != null) {
        Provider.of<TagProvider>(context, listen: false)
            .addToExistingTag(tag, tagId);
      } else {
        tagId = await Provider.of<TagProvider>(context, listen: false)
            .addNewTag(tag);
      }
      await Provider.of<PostProvider>(context, listen: false)
          .updateTagIdToPostUser(
        userId,
        newPost.id,
        tagId,
      );
    }
  }

  //Function called once post is tapped
  void submitPost(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      return;
    } else {
      _formKey.currentState.save();
      try {
        newPost.dateTime = DateTime.now();
        //get list of tags
        tags = ParseStrings().parseMessageForTags(message);
        //remove tags from message
        message = ParseStrings().removeTagsFromMessage(message);

        newPost.message = message;

        //add post to trip
        await Provider.of<PostProvider>(context, listen: false)
            .addPostToUser(userId, newPost, loggedInUser);
        newPost.id =
            Provider.of<PostProvider>(context, listen: false).currentPost.id;
        //store photo and set url
        if (_uploaded) {
          if (!_video) {
            await storePhotoAndSetUrl();
            //update photo url into post and tag
            await Provider.of<PostProvider>(context, listen: false)
                .addPhotoUrlToPostUser(userId, newPost);
          }
          if (_video) {
            await storeVideoAndSetUrl();
            //update photo url into post and tag
            await Provider.of<PostProvider>(context, listen: false)
                .addVideoUrlToPostUser(userId, newPost);
          }
        }
        //create or update tag
        await checkThenAddTags(context);
      } catch (error) {
        throw error;
      }
      Navigator.of(context).pop();
    }
  }

  //set current photo to store
  void setImage(File image) async {
    setState(() {
      _imageFile = image;
      _video = false;
      _uploaded = true;
    });
  }

  //set current video to store
  void setVideo(File image) async {
    setState(() {
      _videoFile = image;
      _video = true;
      _uploaded = true;
    });
  }

  //stores file as a jpg image file.
  Future<void> storePhotoAndSetUrl() async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_post_images')
        .child('${loggedInUser.id}')
        .child(newPost.id + '.jpg');

    await ref.putFile(_imageFile).onComplete;
    final url = await ref.getDownloadURL();

    newPost.photosURL = url;
  }

  //stores file as a mp4 video file
  Future<void> storeVideoAndSetUrl() async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_post_videos')
        .child('${loggedInUser.id}')
        .child(newPost.id + '.mp4');

    await ref
        .putFile(_videoFile, StorageMetadata(contentType: 'video/mp4'))
        .onComplete;
    final url = await ref.getDownloadURL();

    newPost.videosURL = url;
  }

  Future<Widget> showBottomModalSheet(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Align(
            alignment: FractionalOffset.bottomCenter,
            child: Container(
              height: 250,
              width: screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 50,
                    child: ListView(
                      children: [
                        ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.location_on,
                            color: Colors.red,
                          ),
                          title: Text('Check In'),
                          onTap: () {
                            getCurrentUserLocation();
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 1.5,
                  ),
                  Container(
                    height: 50,
                    child: ListView(
                      children: [
                        ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.photo_library,
                            color: Colors.blue,
                          ),
                          title: Text('Photo'),
                          onTap: () async {
                            _imageFile = await ImageVideo()
                                .getImage(ImageSource.gallery);
                            setImage(_imageFile);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 1.5,
                  ),
                  Container(
                    height: 50,
                    child: ListView(
                      children: [
                        ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.video_library,
                            color: Colors.orange,
                          ),
                          title: Text('Video'),
                          onTap: () async {
                            _videoFile = await ImageVideo()
                                .getVideo(ImageSource.gallery);
                            setVideo(_videoFile);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 1.5,
                  ),
                  Container(
                    height: 50,
                    child: ListView(
                      children: [
                        ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.camera_alt,
                            color: Colors.green,
                          ),
                          title: Text('Camera'),
                          onTap: () async {
                            _imageFile =
                                await ImageVideo().getImage(ImageSource.camera);
                            setImage(_imageFile);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //get Coordinates of current user location and the string location
  Future<void> getCurrentUserLocation() async {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final locData = await location.getLocation();
    newPost.locationLatitude = locData.latitude;
    newPost.locationLongitude = locData.longitude;

    String currentLocation = await LocationHelper()
        .getCityStateCountry(locData.latitude, locData.longitude);

    //rome italy test
    // String currentLocation =
    //     await LocationHelper().getCityStateCountry(41.902782, 12.496366);

    setState(() {
      newPost.location = currentLocation;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    userId = arguments['userId'];

    final appBarHeight = AppBar().preferredSize.height + 1;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final navigationBarHeight = MediaQuery.of(context).padding.bottom;
    return Container(
      color: Colors.grey[50],
      child: SafeArea(
        child: Scaffold(
          appBar: appBar(),
          resizeToAvoidBottomInset: false,
          resizeToAvoidBottomPadding: false,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    top: 18.0,
                  ),
                  alignment: Alignment.center,
                  width: screenWidth,
                  height: screenHeight -
                      appBarHeight -
                      statusBarHeight -
                      navigationBarHeight,
                  child: Container(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            fit: FlexFit.tight,
                            flex: newPost.location != null ? 3 : 2,
                            child: Container(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      loggedInUser.profilePicUrl == null
                                          ? CircleAvatar(
                                              radius: 30,
                                              child: Icon(
                                                Icons.person,
                                              ),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: ClipOval(
                                                child: Image.network(
                                                  loggedInUser.profilePicUrl,
                                                  fit: BoxFit.cover,
                                                  height: 60,
                                                  width: 60,
                                                ),
                                              ),
                                            ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.only(
                                              left: 10.0,
                                              bottom: 7.0,
                                            ),
                                            child: Text(
                                              '${loggedInUser.firstName} ${loggedInUser.lastName}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          newPost.location != null
                                              ? Container(
                                                  width: 250,
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 10.0,
                                                    bottom: 15.0,
                                                  ),
                                                  child: Text(
                                                    'in ${newPost.location}',
                                                  ),
                                                )
                                              : Container(),
                                          Container(
                                            padding: const EdgeInsets.only(
                                              left: 10.0,
                                            ),
                                            width: screenWidth * 0.73,
                                            child: DropdownButtonFormField(
                                              isExpanded: true,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                  vertical: 0,
                                                ),
                                                labelText: 'Audience',
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10,
                                                  ),
                                                ),
                                              ),
                                              items: audience,
                                              value: _selectdAudience,
                                              onChanged: (selectedValue) {
                                                setState(() {
                                                  _selectdAudience =
                                                      selectedValue;
                                                });
                                              },
                                              focusNode: _audienceFocusNode,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        thickness: 1.5,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            thickness: 1.5,
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 10,
                            child: Container(
                              child: SingleChildScrollView(
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          hintText: 'Share your thoughts...',
                                          hintStyle: TextStyle(
                                            fontSize: 25,
                                          ),
                                        ),
                                        maxLines: null,
                                        keyboardType: TextInputType.multiline,
                                        style: TextStyle(
                                          fontSize: 25,
                                        ),
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please enter a message';
                                          } else {
                                            return null;
                                          }
                                        },
                                        focusNode: _thoughtsFocusNode,
                                        onChanged: (value) {
                                          setState(() {
                                            message = value;
                                          });
                                        },
                                      ),
                                      Container(
                                        height: 700,
                                        width: screenWidth,
                                        decoration: _imageFile != null
                                            ? BoxDecoration(
                                                image: DecorationImage(
                                                  image: FileImage(_imageFile),
                                                  fit: BoxFit.fitHeight,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            thickness: 1.5,
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            child: Container(
                              height: 50,
                              width: screenWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                  ),
                                  Icon(
                                    Icons.photo_library,
                                    color: Colors.blue,
                                  ),
                                  Icon(
                                    Icons.video_library,
                                    color: Colors.orange,
                                  ),
                                  Icon(
                                    Icons.camera_alt,
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                            onTap: () => showBottomModalSheet(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
