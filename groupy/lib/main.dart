import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import './screens/discover_screen.dart';
import 'screens/current_trips_screen.dart';
import './screens/past_trips_screen.dart';
import './screens/tab_bar_screen.dart';
import './screens/edit_trip_screen.dart';
import './screens/login_signup_screen.dart';
import './screens/trip_detail_screen.dart';
import './screens/splash_screen.dart';
import './screens/contact_screen.dart';
import './screens/login_screen.dart';
import './screens/signup_screens/signup_screen.dart';
import './screens/signup_screens/signup_intro_screen.dart';
import './screens/signup_screens/signup_name_screen.dart';
import './screens/signup_screens/signup_location_screen.dart';
import './screens/signup_screens/signup_email_screen.dart';
import './screens/signup_screens/signup_phone_screen.dart';
import './screens/signup_screens/signup_password_screen.dart';

import './providers/auth.dart';
import './providers/user_provider.dart';
import './providers/trips_provider.dart';

void main() {
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
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, TripsProvider>(
          // create: (_) => TripsProvider(),
          update: (ctx, authData, previousTrips) => TripsProvider(
            authData.token,
            previousTrips == null ? [] : previousTrips.trips,
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => User(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, authData, _) => MaterialApp(
          theme: ThemeData(
            //scaffoldBackgroundColor: lemonMeringue,
            primarySwatch: sandyBrown,
            secondaryHeaderColor: indigoDye,
            accentColor: lemonMeringue,
            buttonColor: lemonMeringue,
            fontFamily: 'OpenSans',
          ),
          home: authData.isAuth
              ? TabBarScreen()
              : FutureBuilder(
                  future: authData.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : LoginSignupScreen(),
                ),
          routes: {
            DiscoverScreen.routeName: (ctx) => DiscoverScreen(),
            CurrentTripsScreen.routeName: (ctx) => CurrentTripsScreen(),
            PastTripsScreen.routeName: (ctx) => PastTripsScreen(),
            TripDetailsScreen.routeName: (ctx) => TripDetailsScreen(),
            EditTripScreen.routeName: (ctx) => EditTripScreen(),
            LoginScreen.routeName: (ctx) => LoginScreen(),
            SignUpScreen.routeName: (ctx) => SignUpScreen(),
            SignUpIntroScreen.routeName: (ctx) => SignUpIntroScreen(),
            SignUpNameScreen.routeName: (ctx) => SignUpNameScreen(),
            SignUpLocationScreen.routeName: (ctx) => SignUpLocationScreen(),
            SignUpPhoneScreen.routeName: (ctx) => SignUpPhoneScreen(),
            SignUpEmailScreen.routeName: (ctx) => SignUpEmailScreen(),
            SignUpPasswordScreen.routeName: (ctx) => SignUpPasswordScreen(),
          },
        ),
      ),
    );
  }
}
