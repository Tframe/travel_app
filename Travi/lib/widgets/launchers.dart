import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';

class Launchers {
  //Gets and returns list of available map applications
  Future<List<AvailableMap>> getAvailableMaps() async {
    final availableMaps = await MapLauncher.installedMaps;
    print(availableMaps);
    return availableMaps;
  }

  //Launches chosen maptype map by coordinates and title
  mapLauncher(
      MapType mapType, String title, double latitude, double longitude) async {
    if (await MapLauncher.isMapAvailable(mapType)) {
      await MapLauncher.showMarker(
        mapType: mapType,
        coords: Coords(
          latitude,
          longitude,
        ),
        title: title,
      );
    }
  }

  phoneLauncher(String phone) async {
    if (await canLaunch(phone)) {
      await launch(phone);
    } else {
      throw 'Could not launch $phone';
    }
  }

  //launch url to open in browser
  urlLauncher(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

}
