/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: Widget for displaying the group
 * member's profile picture avatar.
 */
import 'package:flutter/material.dart';
import 'package:groupy/providers/trip_provider.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';

class GroupAvatars extends StatefulWidget {
  final TripProvider loadedTrip;
  final editIndex;
  final eventType;
  GroupAvatars(this.loadedTrip, this.editIndex, this.eventType);

  @override
  _GroupAvatarsState createState() => _GroupAvatarsState();
}

class _GroupAvatarsState extends State<GroupAvatars> {
  List<bool> _highlights = [];
  String loggedInUserid;

  //Highlights user and adds or removes user
  //from participant lists
  void highlightUser(int index) {
    setState(() {
      _highlights[index] = !_highlights[index];
    });
    if (_highlights[index]) {
      Provider.of<UserProvider>(context, listen: false)
          .addParticipant(widget.loadedTrip.group[index]);
    } else if (!_highlights[index]) {
      Provider.of<UserProvider>(context, listen: false)
          .removeParticipant(widget.loadedTrip.group[index].id);
    }
  }

  @override
  void initState() {
    loggedInUserid = Provider.of<UserProvider>(context, listen: false)
        .currentLoggedInUser
        .id;
    Provider.of<UserProvider>(context, listen: false).resetParticipantsList();
    //create an array the size of he group array and make them all false
    //minus the first of the group which is he organizer.
    for (int i = 0; i < widget.loadedTrip.group.length; i++) {
      if (widget.loadedTrip.group[i].id == loggedInUserid) {
        _highlights.add(true);
      } else {
        //If there is an edit index, then check for active participants
        if (widget.editIndex > -1 &&
            widget.eventType[widget.editIndex].participants.length > 0) {
          for (int j = 0;
              j < widget.eventType[widget.editIndex].participants.length;
              j++) {
            //if active participant, set it to be highlighted, otherwise not.
            if (widget.loadedTrip.group[i].id ==
                widget.eventType[widget.editIndex].participants[j].id) {
              _highlights.add(true);
              Provider.of<UserProvider>(context, listen: false)
                  .addParticipant(widget.loadedTrip.group[i]);
            } else {
              //If checking last group member and last participant and still no match,
              //add false to highlights list. 
              if (widget.eventType[widget.editIndex].participants.length ==
                      j + 1) {
                _highlights.add(false);
              }
            }
          }
        } else {
          _highlights.add(false);
        }
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Returns widget for creating avatar for group
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.loadedTrip.group.length,
      itemBuilder: (ctx, index) {
        if (widget.loadedTrip.group[index].id == loggedInUserid) {
          return Container();
        }
        return Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: 10,
          ),
          child: GestureDetector(
            onTap: () => highlightUser(index),
            child: Column(
              children: [
                widget.loadedTrip.group[index].profilePicUrl.isEmpty
                    ? CircleAvatar(
                        radius: 30,
                        child: Icon(
                          Icons.person,
                        ),
                      )
                    : ClipOval(
                        child: Image.network(
                          widget.loadedTrip.group[index].profilePicUrl,
                          fit: BoxFit.cover,
                          height: 60,
                          width: 60,
                          color: _highlights[index]
                              ? Color.fromRGBO(255, 255, 255, 1)
                              : Color.fromRGBO(255, 255, 255, 0.5),
                          colorBlendMode: BlendMode.modulate,
                        ),
                      ),
                Spacer(),
                Text(
                    '${widget.loadedTrip.group[index].firstName} ${widget.loadedTrip.group[index].lastName}.'),
              ],
            ),
          ),
        );
      },
    );
  }
}
