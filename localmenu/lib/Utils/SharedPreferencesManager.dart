import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager{
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences prefs;

  SharedPreferencesManager();

  Future<void> initPreferences() async{
    prefs = await _prefs;
  }

  SaveSerializable(String key, Map<String, dynamic> value){
    prefs.setString(key, json.encode(value));
  }

  Map<String, dynamic> GetSerializable(String key){
    return json.decode(key);
  }
}