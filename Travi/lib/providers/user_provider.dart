import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './invitation_provider.dart';

class UserProvider extends ChangeNotifier {
  String id;
  String email;
  String phone;
  String password;
  String firstName;
  String lastName;
  String location;
  String profilePicUrl;
  String about;
  List<String> sites;
  List<String> followers;
  String invitationStatus;
  List<Invites> tripInvites;

  UserProvider({
    this.id,
    this.email,
    this.phone,
    this.password,
    this.firstName,
    this.lastName,
    this.location,
    this.profilePicUrl,
    this.about,
    this.sites,
    this.followers,
    this.invitationStatus,
    this.tripInvites,
  });

  List<UserProvider> _users = [];
  String _currentUserId = '';
  User _currentUser;
  UserProvider loggedInUser;

  //getter function to return list of users
  List<UserProvider> get users {
    return [..._users];
  }

  //Set's a provider variable Firebase User for currently logged
  //in user.
  Future<void> setCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  //Returned the Firebase User data
  Future<User> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    } else {
      return null;
    }
  }

  //Sets the current Firebase User ID
  Future<void> setCurrentUserId() async {
    _currentUserId = _currentUser.uid;
  }

  //Returned the current Firebase User ID
  Future<String> getCurrentUserId() async {
    if (_currentUserId != null || _currentUserId != '') {
      return _currentUserId;
    } else {
      return '';
    }
  }

  //used to set companions once users are loaded from firebase
  Future<void> setCompanionsList(List<UserProvider> loadedUser) async {
    _users = loadedUser;
  }

  //sets current logged in user
  Future<void> setLoggedInUser(String userId) async {
    List<Invites> tripInvites = [];
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then(
            (doc) => {
              loggedInUser = UserProvider(
                  id: doc.reference.id,
                  firstName: doc.data()['firstName'],
                  lastName: doc.data()['lastName'],
                  location: doc.data()['location'],
                  email: doc.data()['email'],
                  phone: doc.data()['phone'],
                  profilePicUrl: doc.data()['profilePicUrl'],
                  about: doc.data()['about'],
                  invitationStatus: 'Accepted',
                  tripInvites: doc.data()['tripInvites'] != null
                      ? doc
                          .data()['tripInvites']
                          .asMap()
                          .forEach((tripInviteIndex, tripInvite) {
                          tripInvites.add(Invites(
                            invitationId: tripInvite['id'],
                            organizerUserId: tripInvite['organizerUserId'],
                            organizerFirstName:
                                tripInvite['organizerFirstName'],
                            organizerLastName: tripInvite['organizerLastName'],
                            status: tripInvite['status'],
                            tripId: tripInvite['tripId'],
                            tripTitle: tripInvite['tripTitle'],
                          ));
                        })
                      : [])
            },
          );
    } catch (error) {
      throw error;
    }
  }

  //get currently logged in user
  UserProvider get currentLoggedInUser {
    return loggedInUser;
  }

  //Add user info to Firestore
  Future<void> addUser(UserProvider userInfo, String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({
          'id': userId,
          'firstName': userInfo.firstName,
          'lastName': userInfo.lastName,
          'email': userInfo.email,
          'phone': userInfo.phone,
          //CHANGE TO LOCATION INSTEAD OF location
          'location': userInfo.location,
          'profilePicUrl': '',
        })
        .then((value) => print('User added'))
        .catchError((error) => print('Failed to add user: $error'));
  }

  //Get single user info by ID
  Future<UserProvider> findUserById(String userId) async {
    UserProvider loadedUser;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((doc) => {
                loadedUser = UserProvider(
                  id: doc.reference.id,
                  firstName: doc.data()['firstName'],
                  lastName: doc.data()['lastName'],
                  location: doc.data()['location'],
                  email: doc.data()['email'],
                  phone: doc.data()['phone'],
                  profilePicUrl: doc.data()['profilePicUrl'],
                  about: doc.data()['about'],
                )
              });
    } catch (error) {
      throw error;
    }
    return loadedUser;
  }

  //Get users list by email
  Future<void> findUserByContactInfo(String contactInfo, bool email) async {
    final List<UserProvider> loadedUsers = [];
    _users = [];
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .where(email ? 'email' : 'phone', isEqualTo: contactInfo)
          .get()
          .then((QuerySnapshot querySnapshot) => {
                querySnapshot.docs.forEach((doc) {
                  loadedUsers.add(UserProvider(
                    id: doc.reference.id,
                    firstName: doc.data()['firstName'],
                    lastName: doc.data()['lastName'],
                    location: doc.data()['location'],
                    email: doc.data()['email'],
                    phone: doc.data()['phone'],
                    profilePicUrl: doc.data()['profilePicUrl'],
                    invitationStatus: 'pending',
                  ));
                })
              })
          .catchError((error) {
        print('Error $error');
      });
      await setCompanionsList(loadedUsers);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  //Update user name and location
  Future<void> updateUserNameLocation(
      UserProvider userValues, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'firstName': userValues.firstName,
        'lastName': userValues.lastName,
        'location': userValues.location,
      }).then((value) => print('User updated'));
    } catch (error) {
      throw error;
    }
    _users = [];
    _users.add(userValues);
    notifyListeners();
  }

  //Update user name and location
  Future<void> updateUserContact(UserProvider userValues, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'phone': userValues.phone,
        'email': userValues.email,
      }).then((value) => print('User updated'));
    } catch (error) {
      throw error;
    }
    _users = [];
    _users.add(userValues);
    notifyListeners();
  }

  //Update user name and location
  Future<void> updateAbout(UserProvider userValues, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'about': userValues.about,
      }).then((value) => print('User updated'));
    } catch (error) {
      throw error;
    }
    _users = [];
    _users.add(userValues);
    notifyListeners();
  }

  //Get trip invitation lists to see if anything is pending
  Future<void> getInvites(String userId) async {
    List<Invites> _newInvites = [];
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('invited-trips')
          .get()
          .then((invitedTrips) {
        invitedTrips.docs.asMap().forEach((index, data) {
          _newInvites.add(
            Invites(
                invitationId: invitedTrips.docs[index].id,
                organizerUserId:
                    invitedTrips.docs[index].data()['organizerUserId'],
                organizerFirstName:
                    invitedTrips.docs[index].data()['organizerFirstName'],
                organizerLastName:
                    invitedTrips.docs[index].data()['organizerLastName'],
                status: invitedTrips.docs[index].data()['status'],
                tripId: invitedTrips.docs[index].data()['tripId'],
                tripTitle: invitedTrips.docs[index].data()['tripTitle'],
                unread: invitedTrips.docs[index].data()['unread']),
          );
        });

        loggedInUser.tripInvites = _newInvites;
      });
    } catch (error) {
      loggedInUser.tripInvites = _newInvites;
      throw (error);
    }
  }

  //Update trip-invitations trip status
  Future<void> updateTripInvitationStatus(
    String userId,
    String invitationId,
    String tripId,
    String newStatus,
  ) async {
    final tripInviteIndex = loggedInUser.tripInvites
        .indexWhere((tripInvites) => tripInvites.tripId == tripId);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$userId')
          .collection('invited-trips')
          .doc('$invitationId')
          .update({
        'status': newStatus,
        'unread': false,
      }).then((value) {
        print('Invitation Status Updated');
      });
    } catch (error) {
      throw (error);
    }
    loggedInUser.tripInvites[tripInviteIndex].status = newStatus;
    updateOrganizerInvitationStatus(
      loggedInUser.tripInvites[tripInviteIndex].organizerUserId,
      tripId,
      newStatus,
      userId,
    );
    notifyListeners();
  }

  //Update organizer's trip with new invitation status
  Future<void> updateOrganizerInvitationStatus(
    String organizerId,
    String tripId,
    String newStatus,
    String userId,
  ) async {
    List<UserProvider> _tempGroup = [];

    //Get list of group in organizer's trip
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(organizerId)
          .collection('trips')
          .doc(tripId)
          .get()
          .then((DocumentSnapshot doc) {
        doc.data()['group'].asMap().forEach((groupIndex, groupData) {
          _tempGroup.add(UserProvider(
            id: groupData['id'],
            firstName: groupData['firstName'],
            lastName: groupData['lastName'],
            email: groupData['email'],
            phone: groupData['phone'],
            profilePicUrl: groupData['profilePicUrl'],
            invitationStatus: groupData['invitationStatus'],
          ));
        });
      });
    } catch (onError) {
      throw (onError);
    }
    //update status on organizer's trip
    final _groupIndex = _tempGroup.indexWhere((group) => group.id == userId);
    _tempGroup[_groupIndex].invitationStatus = newStatus;

    //update in firestore
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('$organizerId')
          .collection('trips')
          .doc('$tripId')
          .update({
        'group': _tempGroup
            .map((group) => {
                  'id': group.id,
                  'firstName': group.firstName,
                  'lastName': group.lastName,
                  'email': group.email,
                  'phone': group.phone,
                  'profilePicUrl': group.profilePicUrl,
                  'invitationStatus': group.invitationStatus,
                })
            .toList()
      }).then((value) {
        print('Invitation Status Updated on Organizer Trip');
      });
    } catch (error) {
      throw (error);
    }
    notifyListeners();
  }

  //set list of group members for events
  List<UserProvider> _participants = [];

  //add participant to list of participants
  void addParticipant(UserProvider newUser) {
    _participants.add(newUser);
  }

  //resets list of participants
  void resetParticipantsList() {
    _participants = [];
  }

  //return list of participants
  List<UserProvider> get getParticipants {
    return _participants;
  }

  //remove participant
  void removeParticipant(String userId) {
    final participantIndex =
        _participants.indexWhere((participant) => participant.id == userId);
    _participants.removeAt(participantIndex);
  }
}
