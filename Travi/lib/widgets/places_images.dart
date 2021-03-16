/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: widget for using google places api to retrieve
 * place image. 
 * 
 * MIT License

    Copyright (c) 2020 bazrafkan

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
    
 * 
 */
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_place/google_place.dart';

class PlacesImages extends StatefulWidget {
  final String placeID;
  PlacesImages(this.placeID);
  @override
  _PlacesImagesState createState() => _PlacesImagesState();
}

class _PlacesImagesState extends State<PlacesImages> {
  DetailsResult detailsResult;
  List<Uint8List> images = [];
  GooglePlace googlePlace;
  File fileName;
  @override
  void initState() {
    String apiKey = DotEnv().env['GOOGLE_PLACES_API_KEY'];
    googlePlace = GooglePlace(apiKey);
    getDetails(widget.placeID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return images.length == 0
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Image.memory(
                  images[index],
                );
        });
  }

  void getDetails(String placeId) async {
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
      //Convert Unit8List bytes data to a file to be stored
      //onto Firebase storage
      //await fileName.writeAsBytes(photos);
    }
  }
}
