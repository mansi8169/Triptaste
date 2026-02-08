import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagePlacesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Places")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("places").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final place = docs[index];
              return ListTile(
                title: Text(place["name"]),
                subtitle: Text(place["location"]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    place.reference.delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
