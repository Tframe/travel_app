import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_place/google_place.dart';

import '../providers/country_provider.dart';
import '../providers/countries_provider.dart';

class Places extends StatefulWidget {
  final countryPicker;
  Places(this.countryPicker);

  @override
  _PlacesState createState() => _PlacesState();
}

class _PlacesState extends State<Places> {
  var _countryController = TextEditingController();
  final _listController = ScrollController();
  var country = Country(
    id: null,
    country: null,
    latitude: null,
    longitude: null,
  );

  DetailsResult detailsResult;
  List<Uint8List> images = [];

  List<AutocompletePrediction> predictions = [];
  List<AutocompletePrediction> predictionCountries = [];
  GooglePlace googlePlace;

  void _scrollToBottom() {
    _listController.animateTo(
      _listController.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void initState() {
    String apiKey = DotEnv().env['GOOGLE_PLACES_API_KEY'];
    googlePlace = GooglePlace(apiKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        height: screenHeight * 0.1 * (predictions.length + 1),
        width: screenWidth * 0.8,
        margin: EdgeInsets.only(right: 5, left: 5, top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _countryController,
              decoration: InputDecoration(
                labelText: widget.countryPicker ? 'Countries' : 'Cities',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black54,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  autoCompleteSearchCountries(value);
                } else {
                  if (predictions.length > 0 && mounted) {
                    setState(() {
                      predictions = [];
                    });
                  }
                }
              },
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                controller: _listController,
                itemCount: predictions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        Icons.pin_drop,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(predictions[index].description),
                    onTap: () {
                      debugPrint(predictions[index].placeId);
                      setCountry(predictions[index].placeId);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Find list of countires to provide to user.
  void autoCompleteSearchCountries(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      result.predictions.forEach((prediction) {
        prediction.types.where((types) => types == 'country').forEach((found) {
          predictionCountries.add(prediction);
        });
      });

      setState(() {
        //predictions = result.predictions;
        predictions = predictionCountries;
      });
      predictionCountries = [];
    }
    Timer(Duration(milliseconds: 100), () => _scrollToBottom());
  }

  //Find list possible places provide to user.
  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions;
      });
      predictionCountries = [];
    }
  }

  //set destination for provider
  void setCountry(String placeId) async {
    await getDetails(placeId);
    setState(() {
      _countryController.text = detailsResult.formattedAddress;
    });
    // print('${detailsResult.types}');
    // print('${detailsResult.formattedAddress}');
    // print('${detailsResult.geometry.location.lat.toString()}');
    // print('${detailsResult.geometry.location.lng.toString()}');
    // print('${detailsResult.rating.toString()}');
    // print('${detailsResult.priceLevel.toString()}');
    var tempCountry = Country(
      id: null,
      country: detailsResult.formattedAddress,
      latitude: detailsResult.geometry.location.lat,
      longitude: detailsResult.geometry.location.lng,
    );

    country = tempCountry;
    await Provider.of<Countries>(context, listen: false)
        .addCountry(country);
    FocusScope.of(context).unfocus();
    setState(() {
      //predictions = result.predictions;
      predictions = [];
    });
  }

  Future<void> getDetails(String placeId) async {
    var details = await this.googlePlace.details.get(placeId);
    if (details != null && details.result != null && mounted) {
      setState(() {
        detailsResult = details.result;
        images = [];
      });

      if (details.result.photos != null) {
        for (var photo in details.result.photos) {
          getPhoto(photo.photoReference);
        }
      }
    }
  }

  void getPhoto(String photoReference) async {
    var photos = await this.googlePlace.photos.get(photoReference, null, 400);
    if (photos != null && mounted) {
      setState(() {
        images.add(photos);
      });
    }
  }
}

// class DetailsPage extends StatefulWidget {
//   final String placeId;
//   final GooglePlace googlePlace;

//   DetailsPage({Key key, this.placeId, this.googlePlace}) : super(key: key);

//   @override
//   _DetailsPageState createState() =>
//       _DetailsPageState(this.placeId, this.googlePlace);
// }

// class _DetailsPageState extends State<DetailsPage> {
//   final String placeId;
//   final GooglePlace googlePlace;

//   _DetailsPageState(this.placeId, this.googlePlace);

//   DetailsResult detailsResult;
//   List<Uint8List> images = [];

//   @override
//   void initState() {
//     getDetails(this.placeId);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Details"),
//         backgroundColor: Colors.blueAccent,
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.blueAccent,
//         onPressed: () {
//           getDetails(this.placeId);
//         },
//         child: Icon(Icons.refresh),
//       ),
//       body: SafeArea(
//         child: Container(
//           margin: EdgeInsets.only(right: 20, left: 20, top: 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Container(
//                 height: 200,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: images.length,
//                   itemBuilder: (context, index) {
//                     return Container(
//                       width: 250,
//                       child: Card(
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(10.0),
//                           child: Image.memory(
//                             images[index],
//                             fit: BoxFit.fill,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Expanded(
//                 child: Card(
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   child: ListView(
//                     children: <Widget>[
//                       Container(
//                         margin: EdgeInsets.only(left: 15, top: 10),
//                         child: Text(
//                           "Details",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       detailsResult != null && detailsResult.types != null
//                           ? Container(
//                               margin: EdgeInsets.only(left: 15, top: 10),
//                               height: 50,
//                               child: ListView.builder(
//                                 scrollDirection: Axis.horizontal,
//                                 itemCount: detailsResult.types.length,
//                                 itemBuilder: (context, index) {
//                                   return Container(
//                                     margin: EdgeInsets.only(right: 10),
//                                     child: Chip(
//                                       label: Text(
//                                         detailsResult.types[index],
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                       backgroundColor: Colors.blueAccent,
//                                     ),
//                                   );
//                                 },
//                               ),
//                             )
//                           : Container(),
//                       Container(
//                         margin: EdgeInsets.only(left: 15, top: 10),
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             child: Icon(Icons.location_on),
//                           ),
//                           title: Text(
//                             detailsResult != null &&
//                                     detailsResult.formattedAddress != null
//                                 ? 'Address: ${detailsResult.formattedAddress}'
//                                 : "Address: null",
//                           ),
//                         ),
//                       ),
//                       Container(
//                         margin: EdgeInsets.only(left: 15, top: 10),
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             child: Icon(Icons.location_searching),
//                           ),
//                           title: Text(
//                             detailsResult != null &&
//                                     detailsResult.geometry != null &&
//                                     detailsResult.geometry.location != null
//                                 ? 'Geometry: ${detailsResult.geometry.location.lat.toString()},${detailsResult.geometry.location.lng.toString()}'
//                                 : "Geometry: null",
//                           ),
//                         ),
//                       ),
//                       Container(
//                         margin: EdgeInsets.only(left: 15, top: 10),
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             child: Icon(Icons.timelapse),
//                           ),
//                           title: Text(
//                             detailsResult != null &&
//                                     detailsResult.utcOffset != null
//                                 ? 'UTC offset: ${detailsResult.utcOffset.toString()} min'
//                                 : "UTC offset: null",
//                           ),
//                         ),
//                       ),
//                       Container(
//                         margin: EdgeInsets.only(left: 15, top: 10),
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             child: Icon(Icons.rate_review),
//                           ),
//                           title: Text(
//                             detailsResult != null &&
//                                     detailsResult.rating != null
//                                 ? 'Rating: ${detailsResult.rating.toString()}'
//                                 : "Rating: null",
//                           ),
//                         ),
//                       ),
//                       Container(
//                         margin: EdgeInsets.only(left: 15, top: 10),
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             child: Icon(Icons.attach_money),
//                           ),
//                           title: Text(
//                             detailsResult != null &&
//                                     detailsResult.priceLevel != null
//                                 ? 'Price level: ${detailsResult.priceLevel.toString()}'
//                                 : "Price level: null",
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
