import '../entities/property.dart';

abstract class PropertyRepository {
  Future<void> saveProperty(Property property);
  Future<Property?> loadProperty();
  Future<void> deleteProperty();
}