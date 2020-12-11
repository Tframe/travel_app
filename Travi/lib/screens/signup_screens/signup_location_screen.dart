/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: screen for signup process - add your location
 */
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../../providers/user_provider.dart';
import '../../helpers/location_helper.dart';
import './signup_phone_screen.dart';

class SignUpLocationScreen extends StatefulWidget {
  static const routeName = '/signup-location-screen';
  @override
  _SignUpLocationScreenState createState() => _SignUpLocationScreenState();
}

class _SignUpLocationScreenState extends State<SignUpLocationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var userValues = UserProvider(
    id: null,
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    location: '',
    locationLatitude: 0,
    locationLongitude: 0,
  );

  //get Coordinates of current user location and the string location
  Future<void> getCurrentUserLocation() async {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final locData = await location.getLocation();
    userValues.locationLatitude = locData.latitude;
    userValues.locationLongitude = locData.longitude;

    String currentLocation = await LocationHelper()
        .getCityStateCountry(locData.latitude, locData.longitude);
    print('current location is $currentLocation');
    //rome italy test
    // String currentLocation =
    //     await LocationHelper().getCityStateCountry(41.902782, 12.496366);

    //Provider.of<UserProvider>(context, listen: false).setUserLocation(currentLocation);

    setState(() {
      userValues.location = currentLocation;
      print('userValues.location is ${userValues.location}');
    });
  }

  void _saveLocation() {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    Navigator.of(context)
        .pushNamed(SignUpPhoneScreen.routeName, arguments: userValues);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    setState(() {
      userValues = ModalRoute.of(context).settings.arguments;
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home Base Location',
        ),
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
      body: Stack(
        children: <Widget>[
          Container(
            width: screenWidth,
            decoration: BoxDecoration(
                // color: Theme.of(context).accentColor,
                ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: screenHeight * 0.055,
                  ),
                  Text(
                    'Where are you located?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.025,
                  ),
                  Container(
                    width: screenWidth * 0.8,
                    child: Text(
                      'Adding your homebase location helps us find the best travel deals from where you live.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.025,
                  ),
                  Container(
                    width: screenWidth * 0.85,
                    alignment: Alignment.center,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  cursorColor: Theme.of(context).buttonColor,
                                  decoration: InputDecoration(
                                    labelText: 'Location',
                                    labelStyle: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context).buttonColor,
                                      ),
                                    ),
                                  ),
                                  key: Key(userValues.location.toString()),
                                  initialValue: userValues.location,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter a location!';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    userValues.location = value;
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.location_searching),
                                color: Theme.of(context).buttonColor,
                                onPressed: getCurrentUserLocation,
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 40),
                            width: screenWidth,
                            child: FlatButton(
                              child: Text(
                                'Next',
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              onPressed: _saveLocation,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30.0, vertical: 8.0),
                              color: Theme.of(context).buttonColor,
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.025,
                          ),
                          Container(
                            alignment: Alignment.bottomCenter,
                            padding: EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: new InkWell(
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              //TODO NAVIGATE TO NEXT SCREEN
                              onTap: () => Navigator.of(context).pushNamed(
                                  SignUpPhoneScreen.routeName,
                                  arguments: userValues),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
