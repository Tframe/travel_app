// import 'dart:async';

// import 'package:google_maps_webservice/places.dart';
// import 'package:flutter_google_places/flutter_google_places.dart';
// import 'package:flutter/material.dart';

// const kGoogleApiKey = "AIzaSyCu9T1EYFgRVkWhtRrV0jCj-jK0pOh-A-M";

// class RoutesWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => MaterialApp();
// }

// class AutoComplete extends StatefulWidget {
//   @override
//   _AutoComplete createState() => _AutoComplete();
// }

// final homeScaffoldKey = GlobalKey<ScaffoldState>();
// final searchScaffoldKey = GlobalKey<ScaffoldState>();

// class _AutoComplete extends State<AutoComplete> {
//   Mode _mode = Mode.overlay;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: homeScaffoldKey,
//       appBar: AppBar(
//         title: Text("My App"),
//       ),
//       body: Center(
//           child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           RaisedButton(
//             onPressed: _handlePressButton,
//             child: Text("Search places"),
//           ),
//           PlacesAutocompleteField(apiKey: kGoogleApiKey, onError: onError, mode: _mode, language: "en",)
//         ],
//       )),
//     );
//   }

//   void onError(PlacesAutocompleteResponse response) {
//     homeScaffoldKey.currentState.showSnackBar(
//       SnackBar(content: Text(response.errorMessage)),
//     );
//   }

//   Future<void> _handlePressButton() async {
//     // show input autocomplete with selected mode
//     // then get the Prediction selected
//     /*Prediction p = await PlacesAutocompleteField.show(
//       context: context,
//       apiKey: kGoogleApiKey,
//       onError: onError,
//       mode: _mode,
//       language: "en",
//     );*/
//     PlacesAutocompleteField(apiKey: kGoogleApiKey, onError: onError, mode: _mode, language: "en",);

//     //displayPrediction(p, homeScaffoldKey.currentState);
//   }
// }

// Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
//   if (p != null) {
//     var termLength = p.terms.length;
//     var country = p.terms[termLength - 1].value;
//     var city = '';
//     var state = '';
//     if(termLength == 2){
//       city = p.terms[termLength - 2].value;
//     }
//     if(termLength > 2){
//       city = p.terms[termLength - 3].value;
//       state = p.terms[termLength - 2].value;
//     }

//     print('$city');
//     print('$state');
//     print('$country');

//     scaffold.showSnackBar(
//       SnackBar(content: Text("${p.description}")),
//     );
//   }
// }
