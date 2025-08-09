import 'package:shared_preferences/shared_preferences.dart';

class InvoiceNumberGenerator {
  static const String _key = 'last_invoice_number';
  static const String _prefix = 'UTIL-';
  
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
    // Accept legacy prefixes too so we keep monotonicity if data contains old invoices
    const prefixes = ['UTIL-', 'INV-'];
    for (final p in prefixes) {
      if (invoiceNumber.startsWith(p)) {
        final digits = invoiceNumber.substring(p.length);
        return int.tryParse(digits);
      }
    }
    return null;
  }
}

