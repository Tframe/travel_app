/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: Provider to creat an invitation object
 */
import 'package:flutter/foundation.dart';

class Invites extends ChangeNotifier {
  String invitationId;
  String organizerUserId;
  String organizerFirstName;
  String organizerLastName;
  String status;
  String tripId;
  String tripTitle;
  bool unread;

  Invites({
    this.invitationId,
    this.organizerUserId,
    this.organizerFirstName,
    this.organizerLastName,
    this.status,
    this.tripId,
    this.tripTitle,
    this.unread,
  });
}