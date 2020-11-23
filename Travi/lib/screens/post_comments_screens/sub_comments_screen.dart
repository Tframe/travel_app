import 'package:flutter/material.dart';

class SubCommentsScreen extends StatefulWidget {
  static const routeName = '/sub-comments-screen';
  @override
  _SubCommentsScreenState createState() => _SubCommentsScreenState();
}

class _SubCommentsScreenState extends State<SubCommentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
        bottom: PreferredSize(
          child: Container(
            color: Colors.grey[400],
            height: 1,
          ),
          preferredSize: Size.fromHeight(1.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: new IconThemeData(
          color: Theme.of(context).secondaryHeaderColor,
        ),
      ),
      body: Center(
        child: Text('hi'),
      ),
    );
  }
}
