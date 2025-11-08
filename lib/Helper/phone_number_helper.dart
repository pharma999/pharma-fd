import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class PhoneNumberHelper {
  static Future<String?> detectCountryCode() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return null;
    }

    Position position = await Geolocator.getCurrentPosition(
      // desiredAccuracy: LocationAccuracy.high,
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      return placemarks.first.isoCountryCode;
    }
    return null;
  }
}
