/* Author: Trevor Frame
 * Date: 11/17/2020
 * Description: Helper functions that can be used
 * for parsing strings. Searching for special characters,
 * sub strings, etc.
 */

class ParseStrings {
  //Parses message looking for any '#' for adding word as a tag.
  //Returns list of tag words
  List<String> parseMessageForTags(String message) {
    List<String> tags = [];
    List<String> parsedMessage = message.split(' ');
    const hashTag = '#';

    //Go through array of words in message and search for
    //words that start with '#' to add to list of tags
    //Also removes the tag from the message itself
    for (int i = 0; i < parsedMessage.length; i++) {
      if (parsedMessage[i].startsWith(hashTag)) {
        //This is to remove any extra special characters from a tag
        parsedMessage[i] =
            parsedMessage[i].replaceAll(new RegExp(r"[^\s\w]"), '');
        tags.add(parsedMessage[i]);
      }
    }
    return tags;
  }

  //Removes all the tags from message and return new message.
  String removeTagsFromMessage(String message) {
    List<String> parsedMessage = message.split(' ');
    const hashTag = '#';
    //Go through array of words in message and search for
    //tags, removes them from current message.
    for (int i = 0; i < parsedMessage.length; i++) {
      if (parsedMessage[i].startsWith(hashTag)) {
        message = message.replaceAll(parsedMessage[i], '');
      }
    }
    return message;
  }

}
