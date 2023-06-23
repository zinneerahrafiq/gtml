import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
// const double geofenceCenterLatitude = 37.7749;
// const double geofenceCenterLongitude = -122.4194;
const double geofenceCenterLatitude = 24.8721135;
const double geofenceCenterLongitude = 67.0892254;
const double geofenceRadius = 1.0;


class _HomeScreenState extends State<HomeScreen> {
  String _currentLocation = 'Unknown';

  bool isWithinGeofence = false;

  Timer? geofenceTimer;

  @override
  void initState() {
    super.initState();
    fetchLocation();
    _verifyGeofence();
    startGeofenceTimer();
  }

  void dispose() {
    geofenceTimer?.cancel();
    super.dispose();
  }

  void startGeofenceTimer() {
    const duration = Duration(seconds: 10);
    geofenceTimer = Timer.periodic(duration, (_) {
      _verifyGeofence();
    });
  }
  void _verifyGeofence() async {

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );


    _currentLocation =
    'Latitude: ${position.latitude}\nLongitude: ${position.longitude}';

    double? longitude = position.longitude;
    double? latitude = position.latitude;

    if (latitude != null && longitude != null) {
      print('Current Location: Latitude $latitude, Longitude $longitude');

      double distance = calculateDistance(
        latitude,
        longitude,
        geofenceCenterLatitude,
        geofenceCenterLongitude,
      );

      if (distance <= geofenceRadius) {
        setState(() {
          isWithinGeofence = true;
        });
      } else {
        setState(() {
          isWithinGeofence = false;
        });
      }
    } else {
      print('Failed to retrieve location coordinates');
    }
  }

  double calculateDistance(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    const int radiusOfEarth = 6371;

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * asin(sqrt(a));

    return radiusOfEarth * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }


  Future<void> fetchLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation =
        'Latitude: ${position.latitude}\nLongitude: ${position.longitude}';
      });
    } catch (e) {
      setState(() {
        _currentLocation = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gadoon Textiles'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isWithinGeofence ? (){} : null,
              child: const Text(
                'Mark your attendance',
              ),

            ),
            SizedBox(height:20),

            Text(
              'Current Location:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              _currentLocation,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}