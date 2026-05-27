import 'package:flutter/material.dart';
import 'package:riders/auth/rides_service.dart';
import 'package:riders/auth/booking_service.dart';

class AvailableRides extends StatefulWidget {
  const AvailableRides({super.key});

  @override
  State<AvailableRides> createState() => _AvailableRidesState();
}

class _AvailableRidesState extends State<AvailableRides> {
  final ridesService = RidesService();
  final bookingService = BookingService();

  List rides = [];
  List filteredRides = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRides();
  }

  Future loadRides() async {
    setState(() => isLoading = true);
    try {
      final data = await ridesService.getRides();
      setState(() {
        rides = data;
        filteredRides = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void searchRide(String keyword) {
    final results = rides.where((ride) {
      final from = ride['from'].toString().toLowerCase();
      final to = ride['to'].toString().toLowerCase();
      final name = ride['name'].toString().toLowerCase();
      final input = keyword.toLowerCase();
      return from.contains(input) || to.contains(input) || name.contains(input);
    }).toList();

    setState(() {
      filteredRides = results;
    });
  }

  Future<void> handleBookRide(Map ride) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await bookingService.bookRide(rideId: ride['id']);
      Navigator.pop(context); // Dismiss loading

      // Show a premium confirmation dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text("Request Sent"),
              ],
            ),
            content: Text(
              "Your request to join Captain ${ride['name']}'s ride has been sent.\n\nYou will be notified once they accept or decline.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  loadRides(); // Reload rides list
                },
                child: const Text("OK", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Dismiss loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Booking failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
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
          "Rides Available",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: searchRide,
              decoration: InputDecoration(
                hintText: "Search destinations or pickups...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRides.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: loadRides,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredRides.length,
                          itemBuilder: (context, index) {
                            final ride = filteredRides[index];

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
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.cyan.shade100,
                                          child: const Icon(Icons.person, color: Colors.cyan),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ride['name'] ?? "Captain",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                ride['car'] ?? "Car details",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.green.shade50,
                                          ),
                                          child: Text(
                                            "Rs ${ride['fare']}",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
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
                                            "From: ${ride['from']}",
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.circle, color: Colors.red, size: 10),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "To: ${ride['to']}",
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Seats Available: ${ride['seats'] ?? '0'}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () => handleBookRide(ride),
                                          child: const Text(
                                            "Book Ride",
                                            style: TextStyle(fontWeight: FontWeight.bold),
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_meals_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "No Rides Available",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Check back later or search with a different keyword.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
