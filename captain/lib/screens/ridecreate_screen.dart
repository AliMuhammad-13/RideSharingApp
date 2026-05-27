import 'package:flutter/material.dart';
import 'package:captain/auth/rides_service.dart';

class CreateRide extends StatefulWidget {
  const CreateRide({super.key});

  @override
  State<CreateRide> createState() => _CreateRideState();
}

class _CreateRideState extends State<CreateRide> {
  final nameController = TextEditingController();
  final carController = TextEditingController();
  final toController = TextEditingController();
  final pickupController = TextEditingController();
  final fareController = TextEditingController();
  final seatsController = TextEditingController(text: "4");

  final ridesService = RidesService();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          "Create a Ride",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Offer a Ride",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Enter details to share your journey with riders",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        labelText: "Captain Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: carController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.directions_car),
                        labelText: "Car Details & Number",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: pickupController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.my_location, color: Colors.green),
                        labelText: "Pickup Location (From)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: toController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                        labelText: "Destination (To)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: fareController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.attach_money),
                              labelText: "Fare (Rs)",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: seatsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.event_seat),
                              labelText: "Seats Available",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (nameController.text.trim().isEmpty ||
                                    carController.text.trim().isEmpty ||
                                    pickupController.text.trim().isEmpty ||
                                    toController.text.trim().isEmpty ||
                                    fareController.text.trim().isEmpty ||
                                    seatsController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please fill all fields"),
                                    ),
                                  );
                                  return;
                                }

                                final fareVal = fareController.text.trim();
                                final seatsVal = int.tryParse(seatsController.text.trim()) ?? 4;

                                setState(() => isLoading = true);

                                try {
                                  await ridesService.createRide(
                                    name: nameController.text.trim(),
                                    car: carController.text.trim(),
                                    to: toController.text.trim(),
                                    pickup: pickupController.text.trim(),
                                    fare: fareVal,
                                    seats: seatsVal,
                                  );

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Ride Created Successfully!"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );

                                  Navigator.pop(context);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  if (mounted) setState(() => isLoading = false);
                                }
                              },
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              )
                            : const Text(
                                "Create Ride",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
