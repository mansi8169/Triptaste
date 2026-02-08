import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPlaceScreen extends StatefulWidget {
  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final ratingCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final photoCtrl = TextEditingController();
  final infoCtrl = TextEditingController();
  final mapCtrl = TextEditingController();
  final reserveCtrl = TextEditingController();
  final contactCtrl = TextEditingController();

  String category = "food";
  bool isLoading = false;

  void savePlace() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection("places").add({
        "name": nameCtrl.text.trim(),
        "location": locationCtrl.text.trim(),
        "category": category,
        "rating": double.parse(ratingCtrl.text),
        "price": int.parse(priceCtrl.text),
        "photo_url": photoCtrl.text.trim(),
        "info": infoCtrl.text.trim(),
        "maplink": mapCtrl.text.trim(),
        "reserve": reserveCtrl.text.trim(),
        "contact": contactCtrl.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Place added successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  Widget buildField(String label, TextEditingController c,
      {bool number = false, bool multi = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        maxLines: multi ? 3 : 1,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        validator: (v) => v!.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add New Place")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildField("Place Name", nameCtrl),
              buildField("Location", locationCtrl),

              DropdownButtonFormField(
                value: category,
                items: [
                  DropdownMenuItem(value: "food", child: Text("Restaurant")),
                  DropdownMenuItem(value: "travel", child: Text("Destination")),
                  DropdownMenuItem(value: "hotel", child: Text("Hotel")),
                ],
                onChanged: (v) => setState(() => category = v!),
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(height: 14),

              buildField("Rating (0–5)", ratingCtrl, number: true),
              buildField("Price", priceCtrl, number: true),
              buildField("Photo URL", photoCtrl),
              buildField("Info / Overview", infoCtrl, multi: true),
              buildField("Map Link", mapCtrl),
              buildField("Reserve Link", reserveCtrl),
              buildField("Contact Number", contactCtrl),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: isLoading ? null : savePlace,
                child: Text(isLoading ? "Saving..." : "Add Place"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
