import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './comment_provider.dart';

class PostProvider extends ChangeNotifier {
  String id;
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
  List<String> tagIds;
  List<String> photosURL;
  int likes;
  List<CommentProvider> comments;

  PostProvider({
    this.id,
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
    this.tagIds,
    this.photosURL,
    this.likes,
    this.comments,
  });

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
        'tripId': post.tripId,
        'activityId': post.activityId,
        'lodgingId': post.lodgingId,
        'flightId': post.flightId,
        'transportationId': post.transportationId,
        'restaurantId': post.restaurantId,
        'locationLatitude': post.locationLatitude,
        'locationLongitude': post.locationLatitude,
        'photosURL': post.photosURL.toList(),
        'likes': 0,
      }).then((docRef) {
        post.id = docRef.id;
        print('post added to trip');
      });
    } catch (error) {
      throw error;
    }
  }
}
