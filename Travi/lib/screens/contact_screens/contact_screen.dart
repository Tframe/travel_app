/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: Screen for contacting us with
 * message.
 */
import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class ContactUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
      ),
      drawer: AppDrawer(),
      body: Text('ON CONTACT PAGE'),
    );
  }
}