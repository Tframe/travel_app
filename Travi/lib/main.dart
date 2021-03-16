/* Author: Trevor Frame
 * Date: 10/27/2020
 * Description: Main that binds dot env, creates the 
 * app themes, creates notifiers, and establishes route names
 */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//screens
import './screens/discover_screens/discover_screen.dart';
import './screens/current_trip_screens/current_trips_screen.dart';
import './screens/past_trips_screens/past_trips_screen.dart';
import './screens/tab_bar_screen.dart';
import './screens/trip_details_screens/edit_trip_screen.dart';
import './screens/authentication_screens/login_signup_screen.dart';
import './screens/trip_details_screens/trip_detail_screen.dart';
import './screens/authentication_screens/login_screen.dart';
import './screens/signup_screens/signup_intro_screen.dart';
import './screens/signup_screens/signup_name_screen.dart';
import './screens/signup_screens/signup_photo_screen.dart';
import './screens/signup_screens/signup_location_screen.dart';
import './screens/signup_screens/signup_email_screen.dart';
import './screens/signup_screens/signup_phone_screen.dart';
import './screens/signup_screens/signup_password_screen.dart';
import './screens/add_trip_screens/add_trip_intro_screen.dart';
import './screens/add_trip_screens/add_trip_title_screen.dart';
import './screens/add_trip_screens/add_trip_countries_screen.dart';
import './screens/add_trip_screens/add_trip_cities_screen.dart';
import './screens/add_trip_screens/add_trip_group_invite_screen.dart';
import './screens/account_info_screens/edit_account_profile_screen.dart';
import './screens/account_info_screens/edit_personal_info_screen.dart';
import './screens/account_info_screens/edit_contact_info_screen.dart';
import './screens/account_info_screens/edit_about_screen.dart';
import './screens/trip_details_screens/edit_lodgings_screen.dart';
import './screens/trip_details_screens/add_or_edit_lodging_screen.dart';
import './screens/trip_details_screens/edit_transportations_screen.dart';
import './screens/trip_details_screens/edit_activities_screen.dart';
import './screens/trip_details_screens/edit_group_screen.dart';
import './screens/trip_details_screens/add_companion_screen.dart';
import './screens/trip_details_screens/add_or_edit_transportation_screen.dart';
import './screens/trip_details_screens/edit_flights_screen.dart';
import './screens/trip_details_screens/add_or_edit_flight_screen.dart';
import './screens/trip_details_screens/add_or_edit_activity_screen.dart';
import './screens/trip_details_screens/edit_restaurants_screen.dart';
import './screens/trip_details_screens/add_or_edit_restaurant_screen.dart';
import './screens/timeline_screens/timeline_screen.dart';
import './screens/post_comments_screens/post_comment_screen.dart';
import './screens/post_comments_screens/sub_comments_screen.dart';
import './screens/account_profile_screens/account_profile_screen.dart';
import './screens/account_profile_screens/account_profile_post_comment_screen.dart';
//providers
import './providers/user_provider.dart';
import './providers/trip_provider.dart';
import './providers/trips_provider.dart';
import './providers/country_provider.dart';
import './providers/city_provider.dart';
import './providers/notification_provider.dart';
import './providers/flight_provider.dart';
import './providers/activity_provider.dart';
import './providers/lodging_provider.dart';
import './providers/transportation_provider.dart';
import './providers/restaurant_provider.dart';
import './providers/post_provider.dart';
import './providers/tag_provider.dart';

import './helpers/size_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DotEnv().load('.env');
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const Map<int, Color> indiDye = {
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
  final MaterialColor indigoDye = MaterialColor(0xFF0D3B66, indiDye);

  static const Map<int, Color> lemonMeri = {
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
  final MaterialColor lemonMeringue = MaterialColor(0xFFFAF0CA, lemonMeri);

  static const Map<int, Color> oraYell = {
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
  final MaterialColor orangeYellow = MaterialColor(0xFFF4D35E, oraYell);

  static const Map<int, Color> sanBrow = {
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
  final MaterialColor sandyBrown = MaterialColor(0xFFEE964B, sanBrow);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => TripProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => TripsProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Country(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => City(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Flight(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Lodging(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Activity(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Restaurant(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Transportation(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => NotificationProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PostProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => TagProvider(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          //scaffoldBackgroundColor: lemonMeringue,
          primaryColor: Colors.white,
          primarySwatch: sandyBrown,
          secondaryHeaderColor: indigoDye,
          accentColor: lemonMeringue, //lemonMeringue,
          buttonColor: sandyBrown,
          fontFamily: 'OpenSans',
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: sandyBrown,
          ),
          highlightColor: sandyBrown,
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
          AddTripGroupInviteScreen.routeName: (ctx) =>
              AddTripGroupInviteScreen(),
          EditAccountProfileScreen.routeName: (ctx) =>
              EditAccountProfileScreen(),
          EditPersonalInfoScreen.routeName: (ctx) => EditPersonalInfoScreen(),
          EditContactInfoScreen.routeName: (ctx) => EditContactInfoScreen(),
          EditAboutScreen.routeName: (ctx) => EditAboutScreen(),
          EditGroupScreen.routeName: (ctx) => EditGroupScreen(),
          AddCompanionScreen.routeName: (ctx) => AddCompanionScreen(),
          EditLodgingsScreen.routeName: (ctx) => EditLodgingsScreen(),
          AddOrEditLodgingScreen.routeName: (ctx) => AddOrEditLodgingScreen(),
          EditTransportationsScreen.routeName: (ctx) =>
              EditTransportationsScreen(),
          AddOrEditTransportationScreen.routeName: (ctx) =>
              AddOrEditTransportationScreen(),
          EditFlightsScreen.routeName: (ctx) => EditFlightsScreen(),
          AddOrEditFlightScreen.routeName: (ctx) => AddOrEditFlightScreen(),
          EditActivitiesScreen.routeName: (ctx) => EditActivitiesScreen(),
          AddOrEditActivityScreen.routeName: (ctx) => AddOrEditActivityScreen(),
          EditRestaurantsScreen.routeName: (ctx) => EditRestaurantsScreen(),
          AddOrEditRestaurantScreen.routeName: (ctx) =>
              AddOrEditRestaurantScreen(),
          TimelineScreen.routeName: (ctx) => TimelineScreen(),
          PostCommentScreen.routeName: (ctx) => PostCommentScreen(),
          SubCommentsScreen.routeName: (ctx) => SubCommentsScreen(),
          AccountProfileScreen.routeName: (ctx) => AccountProfileScreen(),
          AccountProfilePostCommentScreen.routeName: (ctx) => AccountProfilePostCommentScreen(),
        },
      ),
    );
  }
}
