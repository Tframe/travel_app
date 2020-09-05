import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import './screens/discover_screen.dart';
import './screens/current_trips_screen.dart';
import './screens/past_trips_screen.dart';
import './screens/tab_bar_screen.dart';
import './screens/edit_trip_screen.dart';
import './screens/login_signup_screen.dart';
import './screens/trip_detail_screen.dart';
import './screens/login_screen.dart';

import './screens/signup_screens/signup_screen.dart';
import './screens/signup_screens/signup_intro_screen.dart';
import './screens/signup_screens/signup_name_screen.dart';
import './screens/signup_screens/signup_photo_screen.dart';
import './screens/signup_screens/signup_location_screen.dart';
import './screens/signup_screens/signup_email_screen.dart';
import './screens/signup_screens/signup_phone_screen.dart';
import './screens/signup_screens/signup_password_screen.dart';
import './screens/add_trip_screen/add_trip_intro_screen.dart';
import './screens/add_trip_screen/add_trip_title_screen.dart';
import './screens/add_trip_screen/add_trip_countries_screen.dart';
import './screens/add_trip_screen/add_trip_cities_screen.dart';

import './providers/user_provider.dart';
import './providers/trips_provider.dart';
import './providers/countries_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DotEnv().load('.env');
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  static Map<int, Color> indiDye = {
    50: Color.fromRGBO(13, 59, 102, .1),
    100: Color.fromRGBO(13, 59, 102, .2),
    200: Color.fromRGBO(13, 59, 102, .3),
    300: Color.fromRGBO(13, 59, 102, .4),
    400: Color.fromRGBO(13, 59, 102, .5),
    500: Color.fromRGBO(13, 59, 102, .6),
    600: Color.fromRGBO(13, 59, 102, .7),
    700: Color.fromRGBO(13, 59, 102, .8),
    800: Color.fromRGBO(13, 59, 102, .9),
    900: Color.fromRGBO(13, 59, 102, 1),
  };
  MaterialColor indigoDye = MaterialColor(0xFF0D3B66, indiDye);

  static Map<int, Color> lemonMeri = {
    50: Color.fromRGBO(250, 240, 202, .1),
    100: Color.fromRGBO(250, 240, 202, .2),
    200: Color.fromRGBO(250, 240, 202, .3),
    300: Color.fromRGBO(250, 240, 202, .4),
    400: Color.fromRGBO(250, 240, 202, .5),
    500: Color.fromRGBO(250, 240, 202, .6),
    600: Color.fromRGBO(250, 240, 202, .7),
    700: Color.fromRGBO(250, 240, 202, .8),
    800: Color.fromRGBO(250, 240, 202, .9),
    900: Color.fromRGBO(250, 240, 202, 1),
  };
  MaterialColor lemonMeringue = MaterialColor(0xFFFAF0CA, lemonMeri);

  static Map<int, Color> oraYell = {
    50: Color.fromRGBO(244, 211, 94, .1),
    100: Color.fromRGBO(244, 211, 94, .2),
    200: Color.fromRGBO(244, 211, 94, .3),
    300: Color.fromRGBO(244, 211, 94, .4),
    400: Color.fromRGBO(244, 211, 94, .5),
    500: Color.fromRGBO(244, 211, 94, .6),
    600: Color.fromRGBO(244, 211, 94, .7),
    700: Color.fromRGBO(244, 211, 94, .8),
    800: Color.fromRGBO(244, 211, 94, .9),
    900: Color.fromRGBO(244, 211, 94, 1),
  };
  MaterialColor orangeYellow = MaterialColor(0xFFF4D35E, oraYell);

  static Map<int, Color> sanBrow = {
    50: Color.fromRGBO(238, 150, 75, .1),
    100: Color.fromRGBO(238, 150, 75, .2),
    200: Color.fromRGBO(238, 150, 75, .3),
    300: Color.fromRGBO(238, 150, 75, .4),
    400: Color.fromRGBO(238, 150, 75, .5),
    500: Color.fromRGBO(238, 150, 75, .6),
    600: Color.fromRGBO(238, 150, 75, .7),
    700: Color.fromRGBO(238, 150, 75, .8),
    800: Color.fromRGBO(238, 150, 75, .9),
    900: Color.fromRGBO(238, 150, 75, 1),
  };
  MaterialColor sandyBrown = MaterialColor(0xFFEE964B, sanBrow);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => TripsProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Countries(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          //scaffoldBackgroundColor: lemonMeringue,
          primarySwatch: sandyBrown,
          secondaryHeaderColor: indigoDye,
          accentColor: lemonMeringue,
          buttonColor: lemonMeringue,
          fontFamily: 'OpenSans',
          buttonTheme: ButtonTheme.of(context).copyWith(
            buttonColor: sandyBrown,
            textTheme: ButtonTextTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                20.0,
              ),
            ),
          ),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.hasData) {
              //return Places();
              return TabBarScreen();
            }
            return LoginSignupScreen();
          },
        ),
        routes: {
          TabBarScreen.routeName: (ctx) => TabBarScreen(),
          DiscoverScreen.routeName: (ctx) => DiscoverScreen(),
          CurrentTripsScreen.routeName: (ctx) => CurrentTripsScreen(),
          PastTripsScreen.routeName: (ctx) => PastTripsScreen(),
          TripDetailsScreen.routeName: (ctx) => TripDetailsScreen(),
          EditTripScreen.routeName: (ctx) => EditTripScreen(),
          LoginScreen.routeName: (ctx) => LoginScreen(),
          SignUpScreen.routeName: (ctx) => SignUpScreen(),
          SignUpIntroScreen.routeName: (ctx) => SignUpIntroScreen(),
          SignUpNameScreen.routeName: (ctx) => SignUpNameScreen(),
          SignUpPhotoScreen.routeName: (ctx) => SignUpPhotoScreen(),
          SignUpLocationScreen.routeName: (ctx) => SignUpLocationScreen(),
          SignUpPhoneScreen.routeName: (ctx) => SignUpPhoneScreen(),
          SignUpEmailScreen.routeName: (ctx) => SignUpEmailScreen(),
          SignUpPasswordScreen.routeName: (ctx) => SignUpPasswordScreen(),
          AddTripIntroScreen.routeName: (ctx) => AddTripIntroScreen(),
          AddTripTitleScreen.routeName: (ctx) => AddTripTitleScreen(),
          AddTripCountriesScreen.routeName: (ctx) => AddTripCountriesScreen(),
          AddTripCitiesScreen.routeName: (ctx) => AddTripCitiesScreen(),
        },
      ),
    );
  }
}
