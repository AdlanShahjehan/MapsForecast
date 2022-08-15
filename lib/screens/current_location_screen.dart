import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:weather/weather.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CurrentLocationScreen extends StatefulWidget {
  const CurrentLocationScreen({Key? key}) : super(key: key);

  @override
  _CurrentLocationScreenState createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  late GoogleMapController googleMapController;

  static const CameraPosition initialCameraPosition = CameraPosition(target: LatLng(3.1407046,101.6822229), zoom: 12);

  Set<Marker> markers = {};

  WeatherFactory wf = new WeatherFactory("YOUR API KEY");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
      ),
      floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
          FloatingActionButton.extended(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            label: const Text("Sign Out"),
            icon: const Icon(Icons.power_settings_new_outlined),
          ),
          const SizedBox(
            width: 70,
          ),
          FloatingActionButton(
          onPressed: () async {

          Position position = await _determinePosition();

          googleMapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 15)));

          Weather w = await wf.currentWeatherByLocation(position.latitude, position.longitude);
          var weather1 = w.weatherMain;
          var weather2 = w.temperature;
          var weather3 = w.humidity;

          String weather = 'Weather: ' + weather1.toString() +', '+ weather2.toString() + ', '+ weather3.toString() + '% Humidity';

          final coordinates = Coordinates(position.latitude, position.longitude);
          var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
          var first = addresses.first;

          markers.clear();

          markers.add(Marker(markerId: const MarkerId('1'),position: LatLng(position.latitude, position.longitude), infoWindow: InfoWindow(
              title: first.addressLine, snippet: weather
          )));

          Future.delayed(const Duration(milliseconds: 1500), () {
            googleMapController.showMarkerInfoWindow(const MarkerId("1"));
            setState(() {});
          });

          setState(() {});
        },
        child: const Icon(Icons.location_searching_rounded),
      ),]
    ));
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }
}
