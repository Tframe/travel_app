import 'package:flutter/material.dart';

import './widgets/discover_filter.dart';
import './widgets/most_popular.dart';

class DiscoverScreen extends StatefulWidget {
  static const routeName = '/discover';

  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            DiscoverFilter(),
            MostPopular(),
          ],
        ),
      ),
    );
  }
}
