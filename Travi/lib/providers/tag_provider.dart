import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import './post_provider.dart';

class TagProvider extends ChangeNotifier {
  String id;
  String tagWord;
  List<PostProvider> postInfo;

  TagProvider({
    this.id,
    this.tagWord,
    this.postInfo,
  });

  TagProvider _currentTag;

  TagProvider get currentTag {
    return _currentTag;
  }

  //Add tag to firestore
  Future<String> addNewTag(TagProvider tag) async {
    try {
      await FirebaseFirestore.instance.collection('tags').add({
        'tagWord': tag.tagWord,
        'postInfo': tag.postInfo
            .map((post) => {
                  'id': post.id,
                  'dateTime': post.dateTime,
                  'authorId': post.authorId,
                  'authorFirstName': post.authorFirstName,
                  'authorLastName': post.authorLastName,
                  'authorImageURL': post.authorImageURL,
                  'eventName': post.eventName,
                  'tripId': post.tripId,
                  'lodgingId': post.lodgingId,
                  'flightId': post.flightId,
                  'transportationId': post.transportationId,
                  'restaurantId': post.restaurantId,
                  'activityId': post.activityId,
                  'message': post.message,
                  'photosURL': post.photosURL,
                  'videosURL': post.videosURL,
                  'location': post.location,
                  'locationLatitude': post.locationLatitude,
                  'locationLongitude': post.locationLongitude,
                })
            .toList()
      }).then((docRef) => tag.id = docRef.id);
    } catch (error) {
      throw error;
    }

    _currentTag = tag;
    notifyListeners();
    return tag.id;
  }

  //Check for existing tag. If it exists, return the tag id, otherwise
  //returns a does not exist message.
  Future<String> checkForExistingTag(String tag) async {
    TagProvider tempTag;
    try {
      await FirebaseFirestore.instance
          .collection('tags')
          .where('tagWord', isEqualTo: tag)
          .get()
          .then((tag) {
        tag.docs.asMap().forEach((tagIndex, tagData) {
          tempTag = TagProvider(
            id: tag.docs[tagIndex].id,
            tagWord: tagData.data()['tagWord'],
          );
        });
      });
    } catch (error) {
      throw error;
    }
    if (tempTag != null) {
      return tempTag.id;
    } else {
      return null;
    }
  }

  Future<void> addToExistingTag(
    TagProvider tag,
    String tagId,
  ) async {
    try {
      FirebaseFirestore.instance.collection('tags').doc(tagId).update({
        'postInfo': FieldValue.arrayUnion(tag.postInfo
            .map((post) => {
                  'id': post.id,
                  'dateTime': DateTime.now(),
                  'authorId': post.authorId,
                  'authorFirstName': post.authorFirstName,
                  'authorLastName': post.authorLastName,
                  'authorImageURL': post.authorImageURL,
                  'tripId': post.tripId,
                  'lodgingId': post.lodgingId,
                  'flightId': post.flightId,
                  'transportationId': post.transportationId,
                  'restaurantId': post.restaurantId,
                  'activityId': post.activityId,
                  'eventName': post.eventName,
                  'photosURL': post.photosURL,
                  'videosURL': post.videosURL,
                  'message': post.message,
                  'location': post.location,
                  'locationLatitude': post.locationLatitude,
                  'locationLongitude': post.locationLongitude,
                })
            .toList())
      }).then((docRef) => print('Tag updated'));
    } catch (error) {
      throw error;
    }
  }
}
