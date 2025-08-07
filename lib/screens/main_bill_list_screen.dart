import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/property_controller.dart';
import '../controllers/bill_controller.dart';
import '../entities/bill.dart';
import 'property_details_screen.dart';
import 'new_bill_screen.dart';

class MainBillListScreen extends ConsumerWidget {
  const MainBillListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsync = ref.watch(propertyControllerProvider);
    final billsAsync = ref.watch(billControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: propertyAsync.when(
          data: (property) => Text(property?.name ?? 'My Flat'),
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
        ],
      ),
      body: billsAsync.when(
        data: (bills) => bills.isEmpty
            ? const Center(child: Text('(No bills yet)'))
            : ListView.builder(
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  final Bill bill = bills[index];
                  return ListTile(
                    title: Text('Bill: ${bill.periodStart} - ${bill.periodEnd}'),
                    subtitle: Text('ID: ${bill.id}'),
                    onTap: () {
                      // TODO: Navigate to Bill Summary screen
                    },
                  );
                },
              ),
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
