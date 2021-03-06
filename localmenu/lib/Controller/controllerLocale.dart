
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:localmenu/Beans/LocalsListSerializableBean.dart';
import 'package:localmenu/Utils/Geolocalizzazione.dart';
import 'package:localmenu/Utils/SharedPreferencesManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Beans/Locale.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ControllerLocale{

  // Init firestore and geoFlutterFire

  static Future<Stream> initLocaliFromCategory(String Category, double radius) async{
    List<LocalePreview> localList = new List();
    var geo = Geoflutterfire();
    var firestore = FirebaseFirestore.instance;
    // Create a geoFirePoint
    var pos = await Geolocalizzazione.determinePosition();
    GeoFirePoint center = geo.point(latitude: pos.latitude, longitude:pos.longitude);
    // get the collection reference or query
    var collectionReference = firestore.collection(Category);

    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: "position");

    return stream;
  }

  static void saveLocalsPreviewList(String category, List<LocalePreview> locali) async{
    LocalsList l = await LocalsList.initLocalsList(category, locali);
    SharedPreferencesManager spm = new SharedPreferencesManager();
    await spm.initPreferences();
    spm.SaveSerializable(category, LocalsList.createJsonFromLocalePreview(l));
  }

  static Future<LocalsList> getLocalsPreviewList(String category) async{
    SharedPreferencesManager spm = new SharedPreferencesManager();
    await spm.initPreferences();
    Map<String, dynamic> json = spm.GetSerializable(category);
    print("JSON RETRIEVED FROM SHARED PREFERENCES: " + json.toString());
    if(json==null) return null;
    String jsonCoordinate = json["cordinate"];
    var jsonTranslated = jsonDecode(jsonCoordinate);
    LocalsList l = LocalsList.convertFromJson(json, double.parse(jsonTranslated["latitude"]), double.parse(jsonTranslated["longitude"]));
    print("metodo interno: " +  l.locali.toString());
    return l;
  }

  static Future<Locale> getLocaleFromPreview(LocalePreview l, String Category) async {
    String url = "https://local-menu-1527c-default-rtdb.firebaseio.com/dettagli/categoria/" +
        Category.toLowerCase().replaceAll(" ", "") + "/" +
        l.getName().toLowerCase().replaceAll(" ", "") + "_" +
        l.city.toLowerCase().replaceAll(" ", "") + ".json";
    http.Response response = await http.get(url);
    if (response != null && response.statusCode == 200) {
        print(response.body);
        Locale l = Locale.convertFromJson(json.decode(response.body));
        return l;
    }
    return null;
  }


}
