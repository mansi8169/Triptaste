import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlaceDetailsPage extends StatefulWidget {
  final String placeId;

  const PlaceDetailsPage({Key? key, required this.placeId}) : super(key: key);

  @override
  State<PlaceDetailsPage> createState() => _PlaceDetailsPageState();
}

class _PlaceDetailsPageState extends State<PlaceDetailsPage> {

  // ✅ STATE VARIABLES (NOW CORRECT)
  double selectedRating = 0.0;
  final TextEditingController reviewController = TextEditingController();

  // ---------- HELPERS ----------
  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _makePhoneCall(String number) async {
    if (number.isEmpty) return;
    final uri = Uri.parse('tel:$number');
    await launchUrl(uri);
  }

  // ---------- SAVE REVIEW ----------
  Future<void> submitReview({
    required String placeId,
    required double rating,
    required String reviewText,
    required BuildContext context,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to submit review")),
      );
      return;
    }

    if (reviewText.trim().isEmpty || rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add rating and review")),
      );
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userName = userDoc.data()?['name'] ?? 'Anonymous';

      await FirebaseFirestore.instance
          .collection('places')
          .doc(placeId)
          .collection('reviews')
          .add({
        'userId': user.uid,
        'name': userName,        // ✅ THIS FIXES IT
        'rating': rating,
        'review': reviewText.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review submitted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Place Details"),
        backgroundColor: const Color(0xFF0B1C2D),
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('places')
            .doc(widget.placeId)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Place not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final name = data['name'] ?? '';
          final location = data['location'] ?? '';
          final category = data['category'] ?? '';
          final photoUrl = data['photo_url'] ?? '';
          final maplink = data['maplink'] ?? '';
          final price = data['price'] ?? '';
          final info = data['info'] ?? '';
          final reserve = data['reserve'] ?? '';
          final contact = data['contact']?.toString() ?? '';
          final moreDetails = data['moredetails'] ?? '';

          final rating =
          (data['avgrating'] ?? data['rating'] ?? 0).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ---------- IMAGE + AVG RATING ----------
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        photoUrl,
                        height: 280,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported, size: 80),
                      ),
                    ),

                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ---------- NAME ----------
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                // ---------- LOCATION ----------
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: Color(0xFF0B1C2D)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0B1C2D),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ---------- INFO / PRICE ----------
                Text(
                  category == 'travel'
                      ? "Overview:\n$info"
                      : "Price: $price",
                  style: const TextStyle(fontSize: 16),
                ),

                const Divider(height: 40),

                // ---------- WRITE REVIEW ----------
                const Text(
                  "Write a Review",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                RatingBar.builder(
                  initialRating: selectedRating,
                  minRating: 1,
                  itemCount: 5,
                  itemSize: 26,
                  itemBuilder: (_, __) =>
                  const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (value) {
                    setState(() => selectedRating = value);
                  },
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: reviewController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Share your experience...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      submitReview(
                        placeId: widget.placeId,
                        rating: selectedRating,
                        reviewText: reviewController.text,
                        context: context,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B1C2D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Submit Review"),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Reviews",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('places')
                      .doc(widget.placeId)
                      .collection('reviews')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return const Text(
                        "No reviews yet. Be the first one!",
                        style: TextStyle(color: Colors.grey),
                      );
                    }


                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final reviewData = doc.data() as Map<String, dynamic>;

                        final userName = reviewData['name'] ?? 'Anonymous';
                        final userId = reviewData['userId'];
                        final reviewText = reviewData['review'] ?? '';
                        final rating = (reviewData['rating'] ?? 0).toDouble();

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      userName,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),

                                    if (FirebaseAuth.instance.currentUser != null &&
                                        FirebaseAuth.instance.currentUser!.uid == userId)
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('places')
                                              .doc(widget.placeId)
                                              .collection('reviews')
                                              .doc(doc.id)
                                              .delete();
                                        },
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 4),
                                RatingBarIndicator(
                                  rating: (data['rating'] ?? 0).toDouble(),
                                  itemBuilder: (_, __) =>
                                  const Icon(Icons.star, color: Colors.amber),
                                  itemCount: 5,
                                  itemSize: 18,
                                ),
                                const SizedBox(height: 6),
                                Text(data['review'] ?? ''),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 16),




                // ---------- ACTION BUTTONS ----------
                if (maplink.isNotEmpty)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _openUrl(maplink),
                      icon: const Icon(Icons.map),
                      label: const Text("View in Maps"),
                    ),
                  ),

                if (reserve.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _openUrl(reserve),
                      icon: const Icon(Icons.event_seat),
                      label: const Text("Reserve"),
                    ),
                  ),
                ],

                if (contact.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _makePhoneCall(contact),
                      icon: const Icon(Icons.call),
                      label: const Text("Call Now"),
                    ),
                  ),
                ],

                if (moreDetails.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _openUrl(moreDetails),
                      icon: const Icon(Icons.info_outline),
                      label: const Text("More Details"),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
