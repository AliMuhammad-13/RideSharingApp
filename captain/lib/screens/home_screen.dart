import 'package:flutter/material.dart';
import 'package:captain/screens/ridecreate_screen.dart';
import 'package:captain/screens/pending_requests.dart';
import 'package:captain/screens/active_rides.dart';
import 'package:captain/screens/history_rides.dart';
import 'package:captain/screens/notifications_screen.dart';
import 'package:captain/screens/settings_screen.dart';
import 'package:captain/auth/notifications_service.dart';
import 'package:captain/screens/login_screen.dart';
import 'package:captain/auth/auth_service.dart';

class CaptainHomeScreen extends StatefulWidget {
  const CaptainHomeScreen({super.key});

  @override
  State<CaptainHomeScreen> createState() => _CaptainHomeScreenState();
}

class _CaptainHomeScreenState extends State<CaptainHomeScreen> {
  final notificationService = NotificationsService();
  final authService = AuthService();
  int unreadNotifications = 0;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadNotificationCount();
  }

  Future<void> loadNotificationCount() async {
    try {
      final count = await notificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          unreadNotifications = count;
        });
      }
    } catch (_) {}
  }

  Widget _buildHomeBody() {
    return RefreshIndicator(
      onRefresh: loadNotificationCount,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: Text(
              "Welcome Captain",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          const Center(
            child: Text(
              "Manage your rides and requests below",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),

          /// CREATE A RIDE CARD
          _buildDashboardCard(
            title: "Create a Ride",
            subtitle: "Offer a new ride for passengers",
            icon: Icons.add_road,
            iconColor: Colors.indigo,
            backgroundColor: Colors.indigo.shade50,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateRide()),
              );
              loadNotificationCount();
            },
          ),
          const SizedBox(height: 16),

          /// PENDING REQUESTS CARD
          _buildDashboardCard(
            title: "Pending Requests",
            subtitle: "Manage ride requests from riders",
            icon: Icons.pending_actions,
            iconColor: Colors.orange,
            backgroundColor: Colors.orange.shade50,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PendingRequests()),
              );
              loadNotificationCount();
            },
          ),
          const SizedBox(height: 16),

          /// ACTIVE RIDES CARD
          _buildDashboardCard(
            title: "Active Rides",
            subtitle: "Track and complete your ongoing rides",
            icon: Icons.directions_car,
            iconColor: Colors.green,
            backgroundColor: Colors.green.shade50,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActiveRidesScreen()),
              );
              loadNotificationCount();
            },
          ),
          const SizedBox(height: 16),

          /// RIDE HISTORY CARD
          _buildDashboardCard(
            title: "Ride History",
            subtitle: "View details of your completed trips",
            icon: Icons.history,
            iconColor: Colors.grey.shade700,
            backgroundColor: Colors.grey.shade100,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryRidesScreen()),
              );
              loadNotificationCount();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeBody(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          currentIndex == 0 ? "Captain Portal" : "Settings",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (currentIndex == 0)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                    );
                    loadNotificationCount();
                  },
                ),
                if (unreadNotifications > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$unreadNotifications',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: pages[currentIndex],
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Center(
                child: Text(
                  "Captain Menu",
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  currentIndex = 0;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_road),
              title: const Text("Create Ride"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateRide()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text("Pending Requests"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PendingRequests()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text("Active Rides"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ActiveRidesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Ride History"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryRidesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  currentIndex = 1;
                });
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Log Out", style: TextStyle(color: Colors.red)),
              onTap: () async {
                await authService.signOut();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
          if (index == 0) {
            loadNotificationCount();
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(subtitle, style: const TextStyle(fontSize: 13)),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}
