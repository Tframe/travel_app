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