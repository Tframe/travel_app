import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_place/google_place.dart';

class PlacesImages extends StatefulWidget {
  final String placeID;
  PlacesImages(this.placeID);

  @override
  _PlacesImagesState createState() => _PlacesImagesState(placeID);
}

class _PlacesImagesState extends State<PlacesImages> {
  DetailsResult detailsResult;
  List<Uint8List> images = [];
  GooglePlace googlePlace;
  final String placeID;
  bool _isLoading = true;
  _PlacesImagesState(this.placeID);

  @override
  void initState() {
    String apiKey = DotEnv().env['GOOGLE_PLACES_API_KEY'];
    googlePlace = GooglePlace(apiKey);
    getDetails(this.placeID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return Image.memory(
            images[index],
          );
        });
  }

  void getDetails(String placeId) async {
    placeId = 'ChIJA9KNRIL-1BIRb15jJFz1LOI';
    print('in details $placeId');
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
