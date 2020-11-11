import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_place/google_place.dart';

import '../providers/country_provider.dart';
import '../providers/city_provider.dart';

class Places extends StatefulWidget {
  final countryPicker;
  final cityPicker;
  final String currentCountry;
  final String currentCity;
  Places(
    this.countryPicker,
    this.cityPicker,
    this.currentCountry,
    this.currentCity,
  );

  @override
  _PlacesState createState() => _PlacesState();
}

class _PlacesState extends State<Places> {
  var _countryController = TextEditingController();
  var _cityController = TextEditingController();
  var _placeController = TextEditingController();
  final _listController = ScrollController();

  var country = Country(
    id: null,
    country: null,
    latitude: null,
    longitude: null,
  );
  var city = City(
    id: null,
    city: null,
    latitude: null,
    longitude: null,
  );

  DetailsResult detailsResult;
  List<Uint8List> images = [];

  List<AutocompletePrediction> predictions = [];
  List<AutocompletePrediction> predictionCountries = [];
  List<AutocompletePrediction> predictionCities = [];
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
    if (widget.countryPicker == true && widget.currentCountry != null) {
      _countryController.text = widget.currentCountry;
    }
    if (widget.cityPicker == true && widget.currentCity != null) {
      print(widget.currentCity);
      _cityController.text = widget.currentCity;
    }
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
        width: screenWidth,
        margin: EdgeInsets.only(
          right: 5,
          left: 5,
          top: 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: widget.countryPicker
                  ? _countryController
                  : (widget.cityPicker ? _cityController : _placeController),
              decoration: InputDecoration(
                labelText: widget.countryPicker
                    ? 'Country'
                    : (widget.cityPicker ? 'City' : 'Place'),
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
                  if (widget.countryPicker == true) {
                    autoCompleteSearchCountries(value);
                  } else if (widget.cityPicker == true) {
                    autoCompleteSearchCities(value);
                  } else {
                    autoCompleteSearch(value);
                  }
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
                      if (widget.countryPicker) {
                        setCountry(predictions[index].placeId);
                      } else if (widget.cityPicker) {
                        setCity(predictions[index].placeId);
                      } else {
                        //setPlace(predictions[index].placeId);
                      }
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

  //Find list of countires to provide to user.
  void autoCompleteSearchCities(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      result.predictions.forEach((prediction) {
        var countryCheck = '';
        if (widget.currentCountry == 'United States') {
          countryCheck = 'USA';
        } else {
          countryCheck = widget.currentCountry;
        }
        if (prediction.description.contains(countryCheck)) {
          prediction.types
              .where((types) => types == 'locality')
              .forEach((found) {
            predictionCities.add(prediction);
          });
        }
      });
      setState(() {
        //predictions = result.predictions;
        predictions = predictionCities;
      });
      predictionCities = [];
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

  //set country for provider
  void setCountry(String placeId) async {
    await getDetails(placeId);
    setState(() {
      _countryController.text = detailsResult.formattedAddress;
    });
    var tempCountry = Country(
      id: placeId,
      country: detailsResult.formattedAddress,
      latitude: detailsResult.geometry.location.lat,
      longitude: detailsResult.geometry.location.lng,
      cities: null,
    );

    country = tempCountry;

    await Provider.of<Country>(context, listen: false).addCountry(country);

    setState(() {
      predictions = [];
    });
    FocusScope.of(context).unfocus();
  }

  //set city for provider
  void setCity(String placeId) async {
    await getDetails(placeId);

    var tempCity = City(
      id: null,
      city: detailsResult.formattedAddress,
      latitude: detailsResult.geometry.location.lat,
      longitude: detailsResult.geometry.location.lng,
    );

    city = tempCity;
    await Provider.of<City>(context, listen: false).addCity(city);

    setState(() {
      _cityController.text = detailsResult.formattedAddress;
      predictions = [];
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> getDetails(String placeId) async {
    var details = await this.googlePlace.details.get(placeId);
    if (details != null && details.result != null && mounted) {
      setState(() {
        detailsResult = details.result;
        images = [];
      });
      //number of photos we want from google
    //   int numPhotos = 1;
    //   if (details.result.photos != null) {
    //     for (var photo in details.result.photos) {
    //       if(numPhotos == 0){
    //         return;
    //       }
    //       await getPhoto(photo.photoReference);
    //       numPhotos--;
    //     }
    //   }
    }
  }

  // Future<void> getPhoto(String photoReference) async {
  //   var photos = await this.googlePlace.photos.get(photoReference, null, 400);
  //   if (photos != null && mounted) {
  //     setState(() {
  //       images.add(photos);
  //     });
  //   }
  // }



}
