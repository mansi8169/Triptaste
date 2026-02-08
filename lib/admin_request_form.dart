import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRequestForm extends StatefulWidget {
  @override
  _AdminRequestFormState createState() => _AdminRequestFormState();
}

class _AdminRequestFormState extends State<AdminRequestForm> {
  final _nameController = TextEditingController();
  final _reasonController = TextEditingController();
  final _experienceController = TextEditingController();
  bool _agree = false;
  bool _loading = false;

  Future<void> submitRequest() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (_nameController.text.isEmpty ||
        _reasonController.text.isEmpty ||
        !_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => _loading = true);

    await FirebaseFirestore.instance
        .collection("admin_requests")
        .doc(user.uid)
        .set({
      "email": user.email,
      "name": _nameController.text.trim(),
      "reason": _reasonController.text.trim(),
      "experience": _experienceController.text.trim(),
      "status": "pending",
      "timestamp": FieldValue.serverTimestamp(),
    });

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Admin request submitted")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text("Request Admin Access")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: user?.email ?? "",
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration:
              InputDecoration(labelText: "Why do you want to be admin?"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _experienceController,
              decoration:
              InputDecoration(labelText: "Experience (optional)"),
            ),
            const SizedBox(height: 16),

            CheckboxListTile(
              value: _agree,
              onChanged: (v) => setState(() => _agree = v!),
              title: Text("I agree to responsibly manage data"),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _loading ? null : submitRequest,
              child: _loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Submit Request"),
            ),
          ],
        ),
      ),
    );
  }
}
