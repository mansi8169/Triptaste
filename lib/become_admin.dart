import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BecomeAdminScreen extends StatefulWidget {
  @override
  _BecomeAdminScreenState createState() => _BecomeAdminScreenState();
}

class _BecomeAdminScreenState extends State<BecomeAdminScreen> {
  final TextEditingController reasonController = TextEditingController();
  bool agree = false;
  bool loading = false;

  Future<void> submitRequest() async {
    if (!agree || reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields and agree")),
      );
      return;
    }

    setState(() => loading = true);

    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection("admin_requests")
        .doc(user!.uid)
        .set({
      "email": user.email,
      "reason": reasonController.text.trim(),
      "status": "pending",
      "timestamp": FieldValue.serverTimestamp(),
    });

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Admin request sent")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Become Admin")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              enabled: false,
              controller: TextEditingController(
                text: FirebaseAuth.instance.currentUser?.email,
              ),
              decoration: const InputDecoration(labelText: "Your Email"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Why do you want to be admin?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: agree,
              onChanged: (v) => setState(() => agree = v!),
              title: const Text("I agree to manage TripTaste responsibly"),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : submitRequest,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Request"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
