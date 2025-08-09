import 'package:shared_preferences/shared_preferences.dart';

class InvoiceNumberGenerator {
  static const String _key = 'last_invoice_number';
  static const String _prefix = 'INV-';
  
  /// Generates the next invoice number in the format INV-0001, INV-0002, etc.
  static Future<String> generateNextInvoiceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final lastNumber = prefs.getInt(_key) ?? 0;
    final nextNumber = lastNumber + 1;
    
    // Save the next number
    await prefs.setInt(_key, nextNumber);
    
    // Format as INV-0001, INV-0002, etc.
    return '${_prefix}${nextNumber.toString().padLeft(4, '0')}';
  }
  
  /// Gets the current invoice number without incrementing
  static Future<String> getCurrentInvoiceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final currentNumber = prefs.getInt(_key) ?? 0;
    return '${_prefix}${currentNumber.toString().padLeft(4, '0')}';
  }
  
  /// Resets the invoice number counter (useful for testing)
  static Future<void> resetInvoiceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Ensures the internal counter is at least [min]. Useful to sync with existing data.
  static Future<void> ensureCounterAtLeast(int min) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_key) ?? 0;
    if (min > current) {
      await prefs.setInt(_key, min);
    }
  }

  /// Parses an invoice number like INV-0123 into its numeric part (e.g., 123).
  /// Returns null if the format is invalid.
  static int? parseInvoiceNumber(String invoiceNumber) {
    if (!invoiceNumber.startsWith(_prefix)) return null;
    final digits = invoiceNumber.substring(_prefix.length);
    final value = int.tryParse(digits);
    return value;
  }
}

