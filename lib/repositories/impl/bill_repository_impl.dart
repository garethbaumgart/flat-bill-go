import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../entities/bill.dart';
import '../bill_repository.dart';

class BillRepositoryImpl implements BillRepository {
  static const String _billsKey = 'bills';

  Future<List<Bill>> _loadAllBills() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_billsKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => Bill.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAllBills(List<Bill> bills) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(bills.map((e) => e.toJson()).toList());
    await prefs.setString(_billsKey, jsonString);
  }

  @override
  Future<void> saveBill(Bill bill) async {
    final List<Bill> bills = await _loadAllBills();
    final int index = bills.indexWhere((b) => b.id == bill.id);
    if (index >= 0) {
      bills[index] = bill;
    } else {
      bills.add(bill);
    }
    await _saveAllBills(bills);
  }

  @override
  Future<Bill?> loadBill(String id) async {
    final List<Bill> bills = await _loadAllBills();
    return bills.firstWhere((b) => b.id == id, orElse: () => null);
  }

  @override
  Future<List<Bill>> listBills() async {
    return await _loadAllBills();
  }

  @override
  Future<void> deleteBill(String id) async {
    final List<Bill> bills = await _loadAllBills();
    bills.removeWhere((b) => b.id == id);
    await _saveAllBills(bills);
  }
}