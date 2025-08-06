import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';
import '../repositories/impl/property_repository_impl.dart';

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) => PropertyRepositoryImpl());

final propertyControllerProvider = AsyncNotifierProvider<PropertyController, Property?>(PropertyController.new);

class PropertyController extends AsyncNotifier<Property?> {
  late final PropertyRepository _repository;

  @override
  Future<Property?> build() async {
    _repository = ref.read(propertyRepositoryProvider);
    return await _repository.loadProperty();
  }

  Future<void> saveProperty(Property property) async {
    await _repository.saveProperty(property);
    state = AsyncValue.data(property);
  }

  Future<void> deleteProperty() async {
    await _repository.deleteProperty();
    state = const AsyncValue.data(null);
  }
}