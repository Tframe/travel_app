/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: Add, update, and remove operations
 * for storing comments data into Firebase Firestore.
 * Comments will be 'replies' to posts and therefore
 * be a sub collection of posts. 
 */
import 'package:flutter/material.dart';

class CommentProvider extends ChangeNotifier {
  String id;
  String commentorId;
  String comment;
  int likes;
  List<CommentProvider> replies;

  CommentProvider({
    this.id,
    this.commentorId,
    this.comment,
    this.likes,
    this.replies,
  });

}