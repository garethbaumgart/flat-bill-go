import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../entities/property.dart';
import '../property_repository.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  static const String _propertyKey = 'property';

  @override
  Future<void> saveProperty(Property property) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(property.toJson());
    await prefs.setString(_propertyKey, jsonString);
  }

  @override
  Future<Property?> loadProperty() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_propertyKey);
    if (jsonString == null) return null;
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return Property.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteProperty() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_propertyKey);
  }
}