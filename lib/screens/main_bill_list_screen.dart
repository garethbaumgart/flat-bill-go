import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/property_controller.dart';
import '../controllers/bill_controller.dart';
import '../entities/bill.dart';
import '../utils/debug_data_seeder.dart' as debug_seeder;
import 'package:flutter/foundation.dart' show kReleaseMode;
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

    return propertyAsync.when(
      data: (property) {
        // If no property exists, show property details screen
        if (property == null) {
          return const PropertyDetailsScreen();
        }
        
        // Property exists, show main screen
        return _buildMainScreen(context, ref, property, billsAsync);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildMainScreen(BuildContext context, WidgetRef ref, property, AsyncValue<List<Bill>> billsAsync) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
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
          if (!kReleaseMode)
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: () async {
                await debug_seeder.DebugDataSeeder.seedTestData(ref);
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
          // Sort bills so most recent periodEnd first
          bills.sort((a, b) => b.periodEnd.compareTo(a.periodEnd));
          return bills.isEmpty
              ? const Center(child: Text('(No bills yet)'))
              : ListView.builder(
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  final Bill bill = bills[index];
                  return Dismissible(
                    key: Key(bill.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Bill'),
                            content: Text('Are you sure you want to delete this bill for ${_formatDate(bill.periodStart)} - ${_formatDate(bill.periodEnd)}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) async {
                      await ref.read(billControllerProvider.notifier).deleteBill(bill.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bill deleted successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    child: Card(
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
                        bill.invoiceNumber.isNotEmpty ? bill.invoiceNumber : 'Bill Period',
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
                          // Removed ID from display to reduce clutter
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
                        double remainingUnits = waterUnits;
                        if (remainingUnits > 0) {
                          final double firstTier = remainingUnits > 6 ? 6 : remainingUnits;
                          waterCost += firstTier * waterTariff0to6;
                          remainingUnits -= firstTier;
                        }
                        if (remainingUnits > 0) {
                          final double secondTier = remainingUnits > 9 ? 9 : remainingUnits;
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
                          final double firstTier = remainingUnits > 6 ? 6 : remainingUnits;
                          sanitationCost += firstTier * sanitationTariff0to6;
                          remainingUnits -= firstTier;
                        }
                        if (remainingUnits > 0) {
                          final double secondTier = remainingUnits > 9 ? 9 : remainingUnits;
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
