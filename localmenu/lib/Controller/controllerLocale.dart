
import '../Beans/Locale.dart';
import '../Beans/Locale.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class ControllerLocale{

  // Init firestore and geoFlutterFire

  static Future<List<LocalePreview>> initLocaliFromCategory(String Category) async{

    double radius = 10000;
    var geo = Geoflutterfire();
    var firestore = FirebaseFirestore.instance;
    // Create a geoFirePoint
    var pos = await _determinePosition();
    GeoFirePoint center = geo.point(latitude: pos.latitude, longitude:pos.longitude);
    // get the collection reference or query
    var collectionReference = firestore.collection(Category);
    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: "position");
      
    stream.listen((event) {
      print("lauraaaaaaaaaaaaaaaaa " +  event.toString());
    });

  }

  static Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

}