import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/property_controller.dart';
import '../controllers/bill_controller.dart';
import '../entities/bill.dart';
import '../utils/debug_data_seeder.dart';
import 'property_details_screen.dart';
import 'new_bill_screen.dart';
import 'bill_summary_screen.dart';

class MainBillListScreen extends ConsumerWidget {
  const MainBillListScreen({super.key});

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsync = ref.watch(propertyControllerProvider);
    final billsAsync = ref.watch(billControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: propertyAsync.when(
          data: (property) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property?.name ?? 'My Flat',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (property?.address != null && property!.address.isNotEmpty)
                Text(
                  property.address,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
          loading: () => const Text('Loading...'),
          error: (err, stack) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PropertyDetailsScreen(),
                ),
              );
            },
            tooltip: 'Edit Property Details',
          ),
          // Debug button for seeding test data
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              await DebugDataSeeder.seedTestData(ref);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Test data seeded successfully!')),
              );
            },
            tooltip: 'Seed Test Data (Debug)',
          ),
        ],
      ),
      body: billsAsync.when(
        data: (bills) {
          print('🔧 Debug: Main screen loaded ${bills.length} bills');
          return bills.isEmpty
              ? const Center(child: Text('(No bills yet)'))
              : ListView.builder(
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  final Bill bill = bills[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.receipt_long,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      title: Text(
                        'Bill Period',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '${_formatDate(bill.periodStart)} - ${_formatDate(bill.periodEnd)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID: ${bill.id.substring(bill.id.length - 6)}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey.shade400,
                        size: 16,
                      ),
                      onTap: () {
                        // Calculate the bill costs for display
                        final electricityUnits = bill.electricityReading.unitsUsed;
                        final waterUnits = bill.waterReading.unitsUsed;
                        final sanitationUnits = bill.sanitationReading.unitsUsed;
                        
                        // Get tariff rates from the bill
                        final electricityTariff = bill.electricityTariff.steps.first.rate;
                        final waterTariff0to6 = bill.waterTariff.steps[0].rate;
                        final waterTariff7to15 = bill.waterTariff.steps[1].rate;
                        final waterTariff16to30 = bill.waterTariff.steps[2].rate;
                        final sanitationTariff0to6 = bill.sanitationTariff.steps[0].rate;
                        final sanitationTariff7to15 = bill.sanitationTariff.steps[1].rate;
                        final sanitationTariff16to30 = bill.sanitationTariff.steps[2].rate;
                        
                        // Calculate costs
                        final double electricityCost = electricityUnits * electricityTariff;
                        
                        // Water sliding scale calculation
                        double waterCost = 0;
                        int remainingUnits = waterUnits;
                        if (remainingUnits > 0) {
                          final int firstTier = remainingUnits > 6 ? 6 : remainingUnits;
                          waterCost += firstTier * waterTariff0to6;
                          remainingUnits -= firstTier;
                        }
                        if (remainingUnits > 0) {
                          final int secondTier = remainingUnits > 9 ? 9 : remainingUnits;
                          waterCost += secondTier * waterTariff7to15;
                          remainingUnits -= secondTier;
                        }
                        if (remainingUnits > 0) {
                          waterCost += remainingUnits * waterTariff16to30;
                        }
                        
                        // Sanitation sliding scale calculation
                        double sanitationCost = 0;
                        remainingUnits = sanitationUnits;
                        if (remainingUnits > 0) {
                          final int firstTier = remainingUnits > 6 ? 6 : remainingUnits;
                          sanitationCost += firstTier * sanitationTariff0to6;
                          remainingUnits -= firstTier;
                        }
                        if (remainingUnits > 0) {
                          final int secondTier = remainingUnits > 9 ? 9 : remainingUnits;
                          sanitationCost += secondTier * sanitationTariff7to15;
                          remainingUnits -= secondTier;
                        }
                        if (remainingUnits > 0) {
                          sanitationCost += remainingUnits * sanitationTariff16to30;
                        }
                        
                        // Calculate totals
                        final double subtotal = electricityCost + waterCost + sanitationCost;
                        final double vat = subtotal * 0.15; // 15% VAT
                        final double total = subtotal + vat;
                        
                        // Navigate to Bill Summary screen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BillSummaryScreen(
                              bill: bill,
                              electricityCost: electricityCost,
                              waterCost: waterCost,
                              sanitationCost: sanitationCost,
                              subtotal: subtotal,
                              vat: vat,
                              total: total,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const NewBillScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Create New Bill',
      ),
    );
  }
}
