/* Author: Trevor Frame
 * Date: 11/17/2020
 * Description: Post provider creats the PostProvider object,
 * and methods used for CRUD commands for updating firestore.
 */
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groupy/providers/user_provider.dart';
// import './comment_provider.dart';

class PostProvider extends ChangeNotifier {
  String id;
  DateTime dateTime;
  String authorId;
  String authorFirstName;
  String authorLastName;
  String authorImageURL;
  String tripId;
  String activityId;
  String lodgingId;
  String flightId;
  String transportationId;
  String restaurantId;
  String eventName;
  String message;
  int likes;
  int comments;
  double locationLatitude;
  double locationLongitude;
  String location;
  List<String> tagIds;
  String photosURL;
  String videosURL;
  String audience;

  PostProvider({
    this.id,
    this.dateTime,
    this.authorId,
    this.authorFirstName,
    this.authorLastName,
    this.authorImageURL,
    this.tripId,
    this.activityId,
    this.lodgingId,
    this.flightId,
    this.transportationId,
    this.restaurantId,
    this.eventName,
    this.message,
    this.likes,
    this.locationLatitude,
    this.locationLongitude,
    this.location,
    this.tagIds,
    this.photosURL,
    this.videosURL,
    this.comments,
    this.audience,
  });

  PostProvider _currentPost;

  PostProvider get currentPost {
    return _currentPost;
  }

  //***************  Posts to trip ********************

  //adds a post to a trip
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
        'audience': post.audience,
        'authorId': post.authorId,
        'authorFirstName': post.authorFirstName,
        'authorLastName': post.authorLastName,
        'authorImageURL': post.authorImageURL,
        'message': post.message,
        'dateTime': post.dateTime,
        'tripId': post.tripId,
        'activityId': post.activityId,
        'lodgingId': post.lodgingId,
        'flightId': post.flightId,
        'transportationId': post.transportationId,
        'restaurantId': post.restaurantId,
        'eventName': post.eventName,
        'locationLatitude': post.locationLatitude,
        'locationLongitude': post.locationLatitude,
        'location': post.location,
        'photosURL': post.photosURL,
        'videosURL': post.videosURL,
        'likes': 0,
        'userLikes': [],
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

  //add tagId to post's array of tagIds
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

  //add url of photo to post
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

  //add url of video to post
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

  //Returns true if user liked the post already.
  Future<bool> checkIfLiked(
    String organizerId,
    String tripId,
    String postId,
    String userId,
  ) async {
    bool liked = false;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('trips')
          .doc('$tripId')
          .collection('posts')
          .doc('$postId')
          .collection('usersLike')
          .doc('$userId')
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          liked = true;
        } else {
          liked = false;
        }
      });
    } catch (error) {
      throw error;
    }
    return liked;
  }

  //Increments likes for a post
  Future<void> incrementLikePost(
    String organizerId,
    String tripId,
    String postId,
    UserProvider user,
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
        'likes': FieldValue.increment(1),
      }).then((docRef) {
        print('Incremented likes');
      });
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  //Adds a document with user information to post that shows like
  Future<void> likePost(
    String organizerId,
    String tripId,
    String postId,
    UserProvider user,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('trips')
          .doc('$tripId')
          .collection('posts')
          .doc('$postId')
          .collection('usersLike')
          .doc(user.id)
          .set({
        'firstName': user.firstName,
        'lastName': user.lastName,
      }).then((docRef) {
        print('Added like to post');
      });
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  //Decrements number of likes on post
  Future<void> decrementLikePost(
    String organizerId,
    String tripId,
    String postId,
    UserProvider user,
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
        'likes': FieldValue.increment(-1),
      }).then((docRef) {
        print('decremented likes');
      });
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  //Adds a document with user information to post that shows like
  Future<void> removeLikePost(
    String organizerId,
    String tripId,
    String postId,
    UserProvider user,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('trips')
          .doc('$tripId')
          .collection('posts')
          .doc('$postId')
          .collection('usersLike')
          .doc(user.id)
          .delete()
          .then((docRef) {
        print('Removed like from post');
      });
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  //add comments to post
  Future<void> addCommentPost(
    String organizerId,
    String tripId,
    String postId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('trips')
          .doc('$tripId')
          .collection('posts')
          .doc('$postId')
          .collection('comments')
          .add({}).then((value) => print('comment added to post'));
    } catch (error) {
      throw error;
    }
  }

  //remove comments from post
  Future<void> removeCommentPost(
    String organizerId,
    String tripId,
    String postId,
    String commentId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('trips')
          .doc('$tripId')
          .collection('posts')
          .doc('$postId')
          .collection('comments')
          .doc(commentId)
          .delete()
          .then((value) => print('comment deleted from post'));
    } catch (error) {
      throw error;
    }
  }

  //***************  Posts to user profile ********************
  Future<void> addPostToUser(
    String userId,
    PostProvider post,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('posts')
          .add({
        'audience': post.audience,
        'authorId': post.authorId,
        'authorFirstName': post.authorFirstName,
        'authorLastName': post.authorLastName,
        'authorImageURL': post.authorImageURL,
        'message': post.message,
        'dateTime': post.dateTime,
        'locationLatitude': post.locationLatitude,
        'locationLongitude': post.locationLatitude,
        'location': post.location,
        'photosURL': post.photosURL,
        'videosURL': post.videosURL,
        'likes': 0,
        'userLikes': [],
        'tagIds': [],
      }).then((docRef) {
        post.id = docRef.id;
        print('Added post to user');
      });
    } catch (error) {
      throw error;
    }
    _currentPost = post;
    notifyListeners();
  }

  //adds photo url to user profile posts
  Future<void> addPhotoUrlToPostUser(
    String userId,
    PostProvider post,
  ) async {
    print(userId);
    print(post.id);
    print(post.photosURL);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('posts')
          .doc('${post.id}')
          .update({
        'photosURL': post.photosURL,
      }).then((value) {
        print('Added photo url to user post');
      });
    } catch (error) {
      throw error;
    }
  }

  //adds video url to user profile post
  Future<void> addVideoUrlToPostUser(
    String userId,
    PostProvider post,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('posts')
          .doc('${post.id}')
          .update({
        'videosURL': post.videosURL,
      }).then((value) {
        print('Added video url to user post');
      });
    } catch (error) {
      throw error;
    }
  }

  //adds any tagids to the saved post
  Future<void> updateTagIdToPostUser(
    String userId,
    String postId,
    String tagId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('posts')
          .doc('$postId')
          .update({
        'tagIds': FieldValue.arrayUnion([tagId]),
      }).then((docRef) {
        print('Added tag ids to user post');
      });
    } catch (error) {
      throw error;
    }
  }

  //Returns true if user liked the post already.
  Future<bool> checkIfLikedForPostUser(
    String userId,
    String postId,
    String userLikeId,
  ) async {
    bool liked = false;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('posts')
          .doc('$postId')
          .collection('usersLike')
          .doc('$userLikeId')
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          liked = true;
        } else {
          liked = false;
        }
        return liked;
      });
    } catch (error) {
      throw error;
    }
    return liked;
  }

  //Adds a document with user information to post that shows like
  Future<void> incrementLikePostUser(
    String organizerId,
    String postId,
    UserProvider user,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('posts')
          .doc('$postId')
          .update({
        'likes': FieldValue.increment(1),
      }).then((docRef) {
        print('Incremented likes');
      });
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

//Adds a document with user information to post that shows like
  Future<void> likePostUser(
    String organizerId,
    String postId,
    UserProvider user,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('posts')
          .doc('$postId')
          .collection('usersLike')
          .doc('${user.id}')
          .set({
        'firstName': user.firstName,
        'lastName': user.lastName,
      }).then((docRef) {
        print('Added like to post');
      });
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  //decrement the like count for a user profile post
  Future<void> decrementLikePostUser(
    String organizerId,
    String postId,
    String userId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('posts')
          .doc('$postId')
          .update({
        'likes': FieldValue.increment(-1),
      }).then((docRef) {
        print('decremented likes');
      });
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  //Adds a document with user information to post that shows like
  Future<void> removeLikePostUser(
    String organizerId,
    String postId,
    String userId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('posts')
          .doc('$postId')
          .collection('usersLike')
          .doc('$userId')
          .delete()
          .then((docRef) {
        print('Removed like from post');
        notifyListeners();
      });
    } catch (error) {
      throw error;
    }
  }

  //add comments to post
  Future<void> addCommentPostUser(
    String organizerId,
    String postId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('posts')
          .doc('$postId')
          .collection('comments')
          .add({}).then((value) => print('comment added to post'));
    } catch (error) {
      throw error;
    }
  }

  //remove comments from post
  Future<void> removeCommentPostUser(
    String organizerId,
    String postId,
    String commentId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('posts')
          .doc('$postId')
          .collection('comments')
          .doc('$commentId')
          .delete()
          .then((value) => print('comment deleted from post'));
    } catch (error) {
      throw error;
    }
  }

  //***************  Create public post ********************

  //Adds post to public posts, but reuses same post id as trip or user post
  Future<void> addPublicPost(
    PostProvider post,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('public-posts')
          .doc(post.id)
          .set({
        'audience': post.audience,
        'authorId': post.authorId,
        'authorFirstName': post.authorFirstName,
        'authorLastName': post.authorLastName,
        'authorImageURL': post.authorImageURL,
        'message': post.message,
        'dateTime': post.dateTime,
        'tripId': post.tripId,
        'activityId': post.activityId,
        'lodgingId': post.lodgingId,
        'flightId': post.flightId,
        'transportationId': post.transportationId,
        'restaurantId': post.restaurantId,
        'eventName': post.eventName,
        'locationLatitude': post.locationLatitude,
        'locationLongitude': post.locationLatitude,
        'location': post.location,
        'photosURL': post.photosURL,
        'videosURL': post.videosURL,
        'likes': 0,
        'userLikes': [],
        'tagIds': [],
      }).then((docRef) {
        print('post added to trip');
      });
    } catch (error) {
      throw error;
    }
    _currentPost = post;
    notifyListeners();
  }

  //add tagId to post's array of tagIds
  Future<void> updatePublicPostTagId(
    String postId,
    String tagId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('public-posts')
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

//adds photo url to public posts
  Future<void> addPhotoUrlToPublicPost(
    PostProvider post,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('public-posts')
          .doc('${post.id}')
          .update({
        'photosURL': post.photosURL,
      }).then((value) {
        print('Added photo url to user post');
      });
    } catch (error) {
      throw error;
    }
  }

  //adds video url to public post
  Future<void> addVideoUrlToPublicPost(
    PostProvider post,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('public-posts')
          .doc('${post.id}')
          .update({
        'videosURL': post.videosURL,
      }).then((value) {
        print('Added video url to user post');
      });
    } catch (error) {
      throw error;
    }
  }
}
