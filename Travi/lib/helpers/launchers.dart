/* Author: Trevor Frame
 * Date: 11/17/2020
 * Description: Helper functions that can be used
 * for launching maps, phones, or web browser
 * 
 * URL LAUNCHER LICENCE AGREEMENT 
 * Copyright 2017 The Chromium Authors. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


 * 
 * 
 */

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
