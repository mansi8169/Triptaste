import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavedPlacesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Places"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('SavedPlaces').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No saved places yet."));
          }

          var savedPlaces = snapshot.data!.docs;

          return ListView.builder(
            itemCount: savedPlaces.length,
            itemBuilder: (context, index) {
              var place = savedPlaces[index];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      place['photo_url'],
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image_not_supported),
                    ),
                  ),
                  title: Text(place['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(place['location']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      FirebaseFirestore.instance.collection('SavedPlaces').doc(place.id).delete();
                    },
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
