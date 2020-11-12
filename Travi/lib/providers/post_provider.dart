import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './comment_provider.dart';

class PostProvider extends ChangeNotifier {
  String id;
  DateTime dateTime;
  String authorId;
  String tripId;
  String activityId;
  String lodgingId;
  String flightId;
  String transportationId;
  String restaurantId;
  String message;
  double locationLatitude;
  double locationLongitude;
  String location;
  List<String> tagIds;
  String photosURL;
  String videosURL;
  int likes;
  List<CommentProvider> comments;

  PostProvider({
    this.id,
    this.dateTime,
    this.authorId,
    this.tripId,
    this.activityId,
    this.lodgingId,
    this.flightId,
    this.transportationId,
    this.restaurantId,
    this.message,
    this.locationLatitude,
    this.locationLongitude,
    this.location,
    this.tagIds,
    this.photosURL,
    this.videosURL,
    this.likes,
    this.comments,
  });

  PostProvider _currentPost;

  PostProvider get currentPost {
    return _currentPost;
  }

  Future<void> addPostToTrip(
    String organizerId,
    String tripId,
    PostProvider post,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('trips')
          .doc('$tripId')
          .collection('posts')
          .add({
        'authorId': post.authorId,
        'message': post.message,
        'dateTime': post.dateTime,
        'tripId': post.tripId,
        'activityId': post.activityId,
        'lodgingId': post.lodgingId,
        'flightId': post.flightId,
        'transportationId': post.transportationId,
        'restaurantId': post.restaurantId,
        'locationLatitude': post.locationLatitude,
        'locationLongitude': post.locationLatitude,
        'location': post.location,
        'photosURL': post.photosURL,
        'videosURL': post.videosURL,
        'likes': 0,
        'tagIds': [],
      }).then((docRef) {
        post.id = docRef.id;
        print('post added to trip');
      });
    } catch (error) {
      throw error;
    }
    _currentPost = post;
    notifyListeners();
  }

  Future<void> updateTagId(
    String organizerId,
    String tripId,
    String postId,
    String tagId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('trips')
          .doc('$tripId')
          .collection('posts')
          .doc('$postId')
          .update({
        'tagIds': FieldValue.arrayUnion([tagId]),
      }).then((docRef) {
        print('Added tag ids');
      });
    } catch (error) {
      throw error;
    }
  }

  Future<void> addPhotoUrl(
    String organizerId,
    String tripId,
    PostProvider post,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('trips')
          .doc('$tripId')
          .collection('posts')
          .doc('${post.id}')
          .update({
        'photosURL': post.photosURL,
      }).then((docRef) {
        print('Added photo url');
      });
    } catch (error) {
      throw error;
    }
  }

  Future<void> addVideoUrl(
    String organizerId,
    String tripId,
    PostProvider post,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('trips')
          .doc('$tripId')
          .collection('posts')
          .doc('${post.id}')
          .update({
        'videosURL': post.videosURL,
      }).then((docRef) {
        print('Added video url');
      });
    } catch (error) {
      throw error;
    }
  }
}
