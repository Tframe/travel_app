/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: Add, update, and remove operations
 * for storing notifications data into Firebase Firestore.
 * Notifications will be a sub collections for users
 */
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationProvider extends ChangeNotifier {
  String id;
  String organizerId;
  String organizerFirstName;
  String organizerLastName;
  String tripId;
  String tripTitle;
  DateTime notificationDateTime;
  bool unread;
  String notificationMessage;
  String notificationType;
  String status;

  NotificationProvider({
    this.id,
    this.organizerId,
    this.organizerFirstName,
    this.organizerLastName,
    this.tripId,
    this.tripTitle,
    this.notificationDateTime,
    this.unread,
    this.notificationMessage,
    this.notificationType,
    this.status,
  });

  List<NotificationProvider> _notifications = [];

  List<NotificationProvider> get notifications {
    _notifications.sort(
        (a, b) => a.notificationDateTime.compareTo(b.notificationDateTime));
    return _notifications;
  }

  //clears current provider list of notifications
  void clearNotificationsList() {
    _notifications = [];
  }

  //Create a notification message for trip invite and return it
  NotificationProvider createTripInviteNotification(
    String organizerId,
    String organizerFirstName,
    String organizerLastName,
    String tripId,
    String tripTitle,
  ) {
    NotificationProvider addTripNotification = NotificationProvider(
      organizerId: organizerId,
      organizerFirstName: organizerFirstName,
      organizerLastName: organizerLastName,
      tripId: tripId,
      tripTitle: tripTitle,
      notificationDateTime: DateTime.now(),
      unread: true,
      notificationMessage:
          '$organizerFirstName $organizerLastName invited you to their $tripTitle trip.',
      notificationType: 'trip-invite',
      status: 'pending',
    );
    return addTripNotification;
  }

  //Creates a add event notification message document
  NotificationProvider createAddEventNotification(
    String organizerId,
    String organizerFirstName,
    String organizerLastName,
    String tripId,
    String tripTitle,
    String event,
  ) {
    NotificationProvider addEventNotification = NotificationProvider(
      organizerId: organizerId,
      organizerFirstName: organizerFirstName,
      organizerLastName: organizerLastName,
      tripId: tripId,
      tripTitle: tripTitle,
      notificationDateTime: DateTime.now(),
      unread: true,
      notificationMessage:
          '$organizerFirstName $organizerLastName added a new $event',
      notificationType: 'add-$event',
      status: 'na',
    );
    return addEventNotification;
  }

  //Creates a edit event notification message document
  NotificationProvider createEditEventNotification(
    String organizerId,
    String organizerFirstName,
    String organizerLastName,
    String tripId,
    String tripTitle,
    String eventName,
    String eventType,
  ) {
    NotificationProvider editEventNotification = NotificationProvider(
      organizerId: organizerId,
      organizerFirstName: organizerFirstName,
      organizerLastName: organizerLastName,
      tripId: tripId,
      tripTitle: tripTitle,
      notificationDateTime: DateTime.now(),
      unread: true,
      notificationMessage:
          '$organizerFirstName $organizerLastName editted $eventName',
      notificationType: 'edit-$eventType',
      status: 'na',
    );
    return editEventNotification;
  }

  //add notification to user
  Future<void> addNotification(
    String userId,
    NotificationProvider newNotification,
  ) async {
    //Add trip information to list of trip invitations.
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('notifications')
          .add({
        'organizerUserId': newNotification.organizerId,
        'organizerFirstName': newNotification.organizerFirstName,
        'organizerLastName': newNotification.organizerLastName,
        'tripId': newNotification.tripId,
        'tripTitle': newNotification.tripTitle,
        'notificationDateTime': newNotification.notificationDateTime,
        'unread': true,
        'notificationMessage': newNotification.notificationMessage,
        'notificationType': newNotification.notificationType,
        'status': newNotification.status,
      }).then((docRef) async {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc('$userId')
              .collection('notifications')
              .doc('${docRef.id}')
              .update({
            'id': docRef.id,
          });
        } catch (error) {
          throw error;
        }
        print('Notification added');
      });
    } catch (error) {
      throw error;
    }
  }

  //Update notification unread status
  Future<void> updatedNotificationUnread(
    String userId,
    String notificationId,
    bool unread,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('notifications')
          .doc('$notificationId')
          .update({
        'unread': unread,
      }).then(
        (value) => print('unread updated'),
      );
    } catch (error) {
      throw error;
    }
  }

  //Update notification status
  Future<void> updateNotificationStatus(
    String userId,
    String notificationId,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('notifications')
          .doc('$notificationId')
          .update({
        'status': status,
      }).then(
        (value) => print('status updated'),
      );
    } catch (error) {
      throw error;
    }
  }

  //get notification
  Future<void> getNotifications(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('notifications')
          .get()
          .then((notification) => {
                notification.docs.asMap().forEach((index, data) {
                  _notifications.add(NotificationProvider(
                    id: data.data()['id'],
                    organizerId: data.data()['organizerId'],
                    organizerFirstName: data.data()['organizerFirstName'],
                    organizerLastName: data.data()['organizerLastName'],
                    notificationDateTime:
                        data.data()['notificationDateTime'].toDate(),
                    tripId: data.data()['tripId'],
                    tripTitle: data.data()['tripTitle'],
                    unread: data.data()['unread'],
                    notificationMessage: data.data()['notificationMessage'],
                    notificationType: data.data()['notificationType'],
                    status: data.data()['status'],
                  ));
                })
              })
          .then(
            (value) => print('Notifications received'),
          );
    } catch (error) {
      throw error;
    }
  }

  //get single notification
  Future<void> getSingleNotification(
      String userId, String notificationId) async {}
}
