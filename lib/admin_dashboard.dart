import 'package:flutter/material.dart';
import 'add_place_screen.dart';
import 'manage_places_screen.dart';
import 'admin_requests_screen.dart';


class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => AddPlaceScreen()));
              },
              child: const Text("Add New Place"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ManagePlacesScreen()));
              },
              child: const Text("Edit / Delete Places"),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => AdminRequestsScreen()));
              },
              child: const Text("Approve Admin Requests"),
            ),
          ],
        ),
      ),
    );
  }
}
