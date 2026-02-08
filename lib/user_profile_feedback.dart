import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileFeedback extends StatefulWidget {
  @override
  _UserProfileFeedbackState createState() =>
      _UserProfileFeedbackState();
}

class _UserProfileFeedbackState extends State<UserProfileFeedback> {
  final TextEditingController nameController = TextEditingController();
  final emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  bool isEditing = false;
  final TextEditingController placeController = TextEditingController();
  final TextEditingController feedbackController = TextEditingController();

  Future<void> fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    setState(() {
      nameController.text = data['name'] ?? '';
      emailController.text = data['email'] ?? '';
      phoneController.text = data['phone'] ?? '';
      dobController.text = data['dob'] ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'dob': dobController.text.trim(),
    });

    setState(() {
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }


  void submitFeedback(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    String place = placeController.text.trim();
    String feedback = feedbackController.text.trim();

    if (place.isEmpty || feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'userEmail': user?.email ?? 'Anonymous',
        'place': place,
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Feedback submitted successfully")),
      );

      placeController.clear();
      feedbackController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting feedback: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text("User Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text(
                  "User Profile",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text(
                  user?.email ?? "Email not available",
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (route) => false);
                  },
                ),
              ),
            ),


            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              readOnly: !isEditing,
              decoration: InputDecoration(labelText: "Name"),
            ),

            TextField(
              controller: emailController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            TextField(
              controller: phoneController,
              readOnly: !isEditing,
              decoration: InputDecoration(labelText: "Phone"),
            ),

            TextField(
              controller: dobController,
              readOnly: !isEditing,
              decoration: InputDecoration(labelText: "DOB"),
            ),
            const SizedBox(height: 16),


            ElevatedButton(
              onPressed: () async {
                if (!isEditing) {
                  setState(() => isEditing = true);
                } else {
                  final user = FirebaseAuth.instance.currentUser;
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .update({
                    'name': nameController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'dob': dobController.text.trim(),
                  });

                  setState(() => isEditing = false);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Profile updated")),
                  );
                }
              },
              child: Text(isEditing ? "Save Profile" : "Edit Profile"),
            ),
            const SizedBox(height: 10),
            const Text("Submit Feedback", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: placeController,
              decoration: InputDecoration(
                labelText: "Place Name",
                hintText: "Enter place name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Your Feedback",
                hintText: "Share your detailed feedback about this place",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => submitFeedback(context),
              child: const Text("Submit Feedback"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
