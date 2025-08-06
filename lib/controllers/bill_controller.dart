import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/bill.dart';
import '../repositories/bill_repository.dart';
import '../repositories/impl/bill_repository_impl.dart';

final billRepositoryProvider = Provider<BillRepository>((ref) => BillRepositoryImpl());

final billControllerProvider = AsyncNotifierProvider<BillController, List<Bill>>(BillController.new);

class BillController extends AsyncNotifier<List<Bill>> {
  late final BillRepository _repository;

  @override
  Future<List<Bill>> build() async {
    _repository = ref.read(billRepositoryProvider);
    return await _repository.listBills();
  }

  Future<void> saveBill(Bill bill) async {
    await _repository.saveBill(bill);
    state = AsyncValue.data(await _repository.listBills());
  }

  Future<void> deleteBill(String id) async {
    await _repository.deleteBill(id);
    state = AsyncValue.data(await _repository.listBills());
  }

  Future<Bill?> loadBill(String id) async {
    return await _repository.loadBill(id);
  }
}