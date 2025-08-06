import '../entities/bill.dart';

abstract class BillRepository {
  Future<void> saveBill(Bill bill);
  Future<Bill?> loadBill(String id);
  Future<List<Bill>> listBills();
  Future<void> deleteBill(String id);
}