import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRequestsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Requests")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("adminRequest", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No admin requests found",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['email']),
                  subtitle: Text("Status: ${data['status']}"),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final uid = data.id;

                      // Update user role
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(uid)
                          .update({"role": "admin"});

                      // Mark request as approved
                      await FirebaseFirestore.instance
                          .collection("admin_requests")
                          .doc(uid)
                          .update({"status": "approved"});

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Admin approved")),
                      );
                    },
                    child: const Text("Approve"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
