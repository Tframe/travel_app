import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class TagProvider extends ChangeNotifier {
  String id;
  String tagWord;
  List<String> authorId;
  List<String> postId;

  TagProvider({
    this.id,
    this.tagWord,
    this.authorId,
    this.postId,
  });

  //Add tag to firestore
  Future<void> addNewTag(TagProvider tag) async {
    try {
      await FirebaseFirestore.instance.collection('tags').add({
        'tagWord': tag.tagWord,
        'authorId': tag.authorId.toList(),
        'postId': tag.postId.toList(),
      });
    } catch (error) {
      throw error;
    }
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
            authorId: tagData.data()['authorId'],
            postId: tagData.data()['postId'],
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
}
