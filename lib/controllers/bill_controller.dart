import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/bill.dart';
import '../repositories/bill_repository.dart';
import '../repositories/impl/bill_repository_impl.dart';
import '../utils/invoice_number_generator.dart';

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
    // Ensure invoice number uniqueness and monotonic increment
    Bill billToSave = bill;

    // If editing, keep the existing invoice number unchanged
    final isNew = await _repository.loadBill(bill.id) == null;

    if (isNew && bill.invoiceNumber.isEmpty) {
      // Sync counter to the highest existing invoice number
      final existing = await _repository.listBills();
      int maxExisting = 0;
      for (final b in existing) {
        final parsed = InvoiceNumberGenerator.parseInvoiceNumber(b.invoiceNumber);
        if (parsed != null && parsed > maxExisting) {
          maxExisting = parsed;
        }
      }
      await InvoiceNumberGenerator.ensureCounterAtLeast(maxExisting);

      // Generate next, guaranteed >= maxExisting + 1
      String candidate = await InvoiceNumberGenerator.generateNextInvoiceNumber();
      // Guard against race/duplication by rechecking list until unique
      final existingNumbers = existing.map((e) => e.invoiceNumber).toSet();
      while (existingNumbers.contains(candidate)) {
        candidate = await InvoiceNumberGenerator.generateNextInvoiceNumber();
      }

      billToSave = Bill(
        id: bill.id,
        invoiceNumber: candidate,
        periodStart: bill.periodStart,
        periodEnd: bill.periodEnd,
        electricityReading: bill.electricityReading,
        waterReading: bill.waterReading,
        sanitationReading: bill.sanitationReading,
        electricityTariff: bill.electricityTariff,
        waterTariff: bill.waterTariff,
        sanitationTariff: bill.sanitationTariff,
      );
    }
    
    await _repository.saveBill(billToSave);
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