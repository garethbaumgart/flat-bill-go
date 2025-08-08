import 'package:shared_preferences/shared_preferences.dart';

class InvoiceNumberGenerator {
  static const String _key = 'last_invoice_number';
  
  /// Generates the next invoice number in the format INV-0001, INV-0002, etc.
  static Future<String> generateNextInvoiceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final lastNumber = prefs.getInt(_key) ?? 0;
    final nextNumber = lastNumber + 1;
    
    // Save the next number
    await prefs.setInt(_key, nextNumber);
    
    // Format as INV-0001, INV-0002, etc.
    return 'INV-${nextNumber.toString().padLeft(4, '0')}';
  }
  
  /// Gets the current invoice number without incrementing
  static Future<String> getCurrentInvoiceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final currentNumber = prefs.getInt(_key) ?? 0;
    return 'INV-${currentNumber.toString().padLeft(4, '0')}';
  }
  
  /// Resets the invoice number counter (useful for testing)
  static Future<void> resetInvoiceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

