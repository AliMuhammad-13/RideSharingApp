import 'package:flutter/material.dart';
import 'package:riders/auth/booking_service.dart';

class HistoryRides extends StatefulWidget {
  const HistoryRides({super.key});

  @override
  State<HistoryRides> createState() => _HistoryRidesState();
}

class _HistoryRidesState extends State<HistoryRides> {
  final bookingService = BookingService();
  List historyRides = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistoryRides();
  }

  Future loadHistoryRides() async {
    try {
      final data = await bookingService.getRideHistory();
      if (mounted) {
        setState(() {
          historyRides = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const Text(
          "Ride History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyRides.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: loadHistoryRides,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: historyRides.length,
                    itemBuilder: (context, index) {
                      final booking = historyRides[index];
                      final ride = booking['rides'] ?? {};

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      ride['name'] ?? "Captain",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "Completed",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.directions_car, size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    ride['car'] ?? "Car details",
                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  const Icon(Icons.circle, color: Colors.green, size: 10),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "From: ${ride['from'] ?? 'Pickup'}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.circle, color: Colors.red, size: 10),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "To: ${ride['to'] ?? 'Destination'}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Fare Paid",
                                    style: TextStyle(color: Colors.grey, fontSize: 14),
                                  ),
                                  Text(
                                    "Rs ${ride['fare'] ?? '0'}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "No History Found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Completed rides will be displayed here.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
