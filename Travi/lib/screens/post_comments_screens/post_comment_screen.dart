import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../providers/tag_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/pickers/image_video_pickers.dart';
import '../../widgets/pickers/image_video.dart';

class PostCommentScreen extends StatefulWidget {
  static const routeName = '/post-comment';
  @override
  _PostCommentScreenState createState() => _PostCommentScreenState();
}

class _PostCommentScreenState extends State<PostCommentScreen> {
  double screenWidth = 0;
  double screenHeight = 0;
  String message = '';
  List<String> tags = [];

  TripProvider currentTrip;

  PostProvider newPost = PostProvider(
    id: null,
    authorId: null,
    message: null,
    tripId: null,
    flightId: null,
    lodgingId: null,
    activityId: null,
    transportationId: null,
    restaurantId: null,
    locationLatitude: null,
    locationLongitude: null,
    tagIds: [],
    photosURL: [],
  );

  final GlobalKey<FormState> _formKey = GlobalKey();
  final _eventFocusNode = FocusNode();
  final _eventTypeFocusNode = FocusNode();

  int _selectedEventType = 0;
  int _selectedSpecifiedEventType = 0;
  //List of dropdowns for selecting what type of event to comment on
  List<DropdownMenuItem<int>> commentOnEventType = [];
  //List of actual events for the specified event type
  List<DropdownMenuItem<int>> commentOnSpecifiedEvent = [];

  UserProvider loggedInUser;

  File _imageFile;

  @override
  void initState() {
    getTripInfo();
    commentOnEventType.add(
      new DropdownMenuItem(
        child: new Text('Trip'),
        value: 0,
      ),
    );
    commentOnEventType.add(
      new DropdownMenuItem(
        child: new Text('Flight'),
        value: 1,
      ),
    );
    commentOnEventType.add(
      new DropdownMenuItem(
        child: new Text('Lodging'),
        value: 2,
      ),
    );
    commentOnEventType.add(
      new DropdownMenuItem(
        child: new Text('Activity'),
        value: 3,
      ),
    );
    commentOnEventType.add(
      new DropdownMenuItem(
        child: new Text('Restaurant'),
        value: 4,
      ),
    );
    commentOnEventType.add(
      new DropdownMenuItem(
        child: new Text('Transportation'),
        value: 5,
      ),
    );
    getUserInfo();
    super.initState();
  }

  void updateSpecificEventDropDown() {
    commentOnSpecifiedEvent = [];
    if (_selectedEventType == 1) {
      updateFlightDropDown();
    } else if (_selectedEventType == 2) {
      updateLodgingDropDown();
    } else if (_selectedEventType == 3) {
      updateActivityDropDown();
    } else if (_selectedEventType == 4) {
      updateRestaurantDropDown();
    } else if (_selectedEventType == 5) {
      updateTransportationDropDown();
    }
  }

  void updateFlightDropDown() {
    print('Flight');
    for (int i = 0; i < currentTrip.countries.length; i++) {
      for (int j = 0; j < currentTrip.countries[i].flights.length; j++) {
        commentOnSpecifiedEvent.add(
          new DropdownMenuItem(
            child: new Text(
                '${currentTrip.countries[i].flights[j].airline} ${currentTrip.countries[i].flights[j].flightNumber}'),
            value: i + j,
          ),
        );
      }
    }
  }

  void updateLodgingDropDown() {
    print('Lodging');
    for (int i = 0; i < currentTrip.countries.length; i++) {
      for (int j = 0; j < currentTrip.countries[i].cities.length; j++) {
        for (int k = 0;
            k < currentTrip.countries[i].cities[j].lodgings.length;
            k++) {
          commentOnSpecifiedEvent.add(
            new DropdownMenuItem(
              child: new Text(
                  '${currentTrip.countries[i].cities[j].lodgings[k].name}'),
              value: i + j + k,
            ),
          );
        }
      }
    }
  }

  void updateActivityDropDown() {
    print('Activity');
    for (int i = 0; i < currentTrip.countries.length; i++) {
      for (int j = 0; j < currentTrip.countries[i].cities.length; j++) {
        for (int k = 0;
            k < currentTrip.countries[i].cities[j].activities.length;
            k++) {
          commentOnSpecifiedEvent.add(
            new DropdownMenuItem(
              child: new Text(
                  '${currentTrip.countries[i].cities[j].activities[k].title}'),
              value: i + j + k,
            ),
          );
        }
      }
    }
  }

  void updateRestaurantDropDown() {
    print('Restaurant');
    for (int i = 0; i < currentTrip.countries.length; i++) {
      for (int j = 0; j < currentTrip.countries[i].cities.length; j++) {
        for (int k = 0;
            k < currentTrip.countries[i].cities[j].restaurants.length;
            k++) {
          commentOnSpecifiedEvent.add(
            new DropdownMenuItem(
              child: new Text(
                  '${currentTrip.countries[i].cities[j].restaurants[k].name}'),
              value: i + j + k,
            ),
          );
        }
      }
    }
  }

  void updateTransportationDropDown() {
    print('Transportation');
    for (int i = 0; i < currentTrip.countries.length; i++) {
      for (int j = 0; j < currentTrip.countries[i].cities.length; j++) {
        for (int k = 0;
            k < currentTrip.countries[i].cities[j].transportations.length;
            k++) {
          commentOnSpecifiedEvent.add(
            new DropdownMenuItem(
              child: new Text(
                  '${currentTrip.countries[i].cities[j].transportations[k].company}'),
              value: i + j + k,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _eventTypeFocusNode.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> getUserInfo() async {
    setState(() {
      loggedInUser =
          Provider.of<UserProvider>(context, listen: false).loggedInUser;
    });
  }

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
              onPressed: () => submitPost(),
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

  //Parses message looking for any '#' for adding word as a tag.
  void parseMessage() async {
    List<String> parsedMessage = message.split(' ');
    const hashTag = '#';

    //Go through array of words in message and search for
    //words that start with '#' to add to list of tags
    for (int i = 0; i < parsedMessage.length; i++) {
      if (parsedMessage[i].startsWith(hashTag)) {
        parsedMessage[i] =
            parsedMessage[i].substring(1, parsedMessage[i].length - 1);
        parsedMessage[i] =
            parsedMessage[i].replaceAll(new RegExp(r"[^\s\w]"), '');
        tags.add(parsedMessage[i]);
      }
    }

    newPost.message = message;
  }

  //Set tripId to currentTrips' id;
  //Set the id for selected event; ie activityId,
  //lodgingId, etc.
  void getPostLocation() {
    newPost.tripId = currentTrip.id;
  }

  //Look for existing tags that contain tag word.
  void checkThenAddTags() async {
    //For each tag, check if exists in firestore
    for (int j = 0; j < tags.length; j++) {
      String tagId = await Provider.of<TagProvider>(context, listen: false)
          .checkForExistingTag(tags[j]);
      List<String> authors = [];
      authors.add(loggedInUser.id);
      List<String> posts = [];

      //Create the tag
      TagProvider tag = TagProvider(
        authorId: authors,
        tagWord: tags[j],
        postId: posts,
      );

      //If receive a tagId, then add to existing tag
      //otherwise add a new tag collection
      if (tagId != null) {
        print('exist');
        await Provider.of<TagProvider>(context).addNewTag(tag);
      } else {
        print('doesnt exist');
        //Provider.of<TagProvider>(context).addToExistingTag(tag);
      }
    }
  }

  //Set user info
  Future<void> setUserInfo() async {
    String userId = await Provider.of<UserProvider>(context, listen: false)
        .getCurrentUserId();
    newPost.authorId = userId;
  }

  //Get trip info
  void getTripInfo() {
    currentTrip = Provider.of<TripProvider>(context, listen: false).currentTrip;
  }

  //Function called once post is tapped
  void submitPost() async {
    if (!_formKey.currentState.validate()) {
      return;
    } else {
      _formKey.currentState.save();
      try {
        parseMessage();
        getPostLocation();
        await Provider.of<PostProvider>(context, listen: false)
            .addPostToTrip(currentTrip.organizerId, currentTrip.id, newPost);
        checkThenAddTags();
      } catch (error) {
        throw error;
      }
    }
  }

  void setImage(File image) {
    setState(() {
      _imageFile = image;
    });
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
                          onTap: () {},
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
                            _imageFile = await ImageVideo()
                                .getVideo(ImageSource.gallery);
                            setImage(_imageFile);
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

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
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
                            flex: 2,
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
                                          : ClipOval(
                                              child: Image.network(
                                                loggedInUser.profilePicUrl,
                                                fit: BoxFit.cover,
                                                height: 60,
                                                width: 60,
                                              ),
                                            ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.only(
                                              left: 18.0,
                                              bottom: 10.0,
                                            ),
                                            child: Text(
                                              '${loggedInUser.firstName} ${loggedInUser.lastName}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(
                                              left: 18.0,
                                            ),
                                            width: screenWidth * 0.73,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: screenWidth * 0.3,
                                                  child:
                                                      DropdownButtonFormField(
                                                    isExpanded: true,
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 0,
                                                      ),
                                                      labelText: 'Post to...',
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          10,
                                                        ),
                                                      ),
                                                    ),
                                                    items: commentOnEventType,
                                                    value: _selectedEventType,
                                                    onChanged: (selectedValue) {
                                                      setState(() {
                                                        _selectedEventType =
                                                            selectedValue;
                                                        updateSpecificEventDropDown();
                                                      });
                                                    },
                                                    focusNode:
                                                        _eventTypeFocusNode,
                                                  ),
                                                ),
                                                Container(
                                                  width: screenWidth * 0.3,
                                                  child:
                                                      DropdownButtonFormField(
                                                    isExpanded: true,
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 0,
                                                      ),
                                                      labelText: 'Post to...',
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          10,
                                                        ),
                                                      ),
                                                    ),
                                                    items:
                                                        commentOnSpecifiedEvent,
                                                    value:
                                                        _selectedSpecifiedEventType,
                                                    onChanged: (selectedValue) {
                                                      setState(() {
                                                        _selectedSpecifiedEventType =
                                                            selectedValue;
                                                      });
                                                    },
                                                    focusNode:
                                                        _eventTypeFocusNode,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Divider(
                                            thickness: 1.5,
                                          ),
                                        ],
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
