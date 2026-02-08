import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'firebase_options.dart';
import 'saved_places_screen.dart';
import 'place_details_page.dart';
import 'user_profile_feedback.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'become_admin.dart';
import 'admin_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'become_admin.dart';
import 'become_admin.dart';
import 'admin_dashboard.dart';


import 'package:cloud_firestore/cloud_firestore.dart';





class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "food";
  TextEditingController locationController = TextEditingController();
  String selectedFilter = "All";
  Set<String> savedPlaceIds = {};
  String userRole = "user";

  void fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        userRole = doc["role"] ?? "user";
      });
    }
  }
  @override
  void initState() {
    super.initState();
    fetchSavedPlaces();
    fetchUserRole();
  }

  void fetchSavedPlaces() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('SavedPlaces').get();

    setState(() {
      savedPlaceIds = snapshot.docs.map((doc) => doc.id).toSet();
    });
  }


  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Filter", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildFilterTile("All"),
              _buildFilterTile("Top Rated"),
              _buildFilterTile("Budget Friendly"),

            ],
          ),
        );
      },
    );
  }
  Widget _buildFilterTile(String value) {
    return ListTile(
      title: Text(
        value,
        style: TextStyle(
          fontWeight: selectedFilter == value
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
      trailing: selectedFilter == value
          ? Icon(Icons.check, color: Color(0xFF0B1C2D))
          : null,
      onTap: () {
        setState(() => selectedFilter = value);
        Navigator.pop(context);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),


      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF0B1C2D),
            borderRadius: BorderRadius.circular(20),
          ),

          child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logo.png', height: 40),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.bookmark_border, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SavedPlacesScreen()),
                          );
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          if (userRole == "admin") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AdminDashboard()),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => BecomeAdminScreen()),
                            );
                          }
                        },
                        child: Text(
                          userRole == "admin" ? "You are Admin" : "Become Admin",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),



                      IconButton(
                        icon: const Icon(Icons.person_outline, color: Colors.white),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => UserProfileFeedback()));
                        },
                      ),

                    ],
                  ),

                  SizedBox(height: 12),

                  Text(
                    "Discover places you'll love",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: locationController,
                            decoration: InputDecoration(
                              hintText: "Enter location...",
                              border: InputBorder.none,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.filter_list),
                          onPressed: () => _showFilterOptions(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),),



            SizedBox(height: 20),
            Row(
              children: [
                CategoryButton(
                  title: "Restaurants",
                  icon: Icons.restaurant,
                  isSelected: selectedCategory == "food",
                  onTap: () => setState(() => selectedCategory = "food"),
                ),
                CategoryButton(
                  title: "Destinations",
                  icon: Icons.beach_access,
                  isSelected: selectedCategory == "travel",
                  onTap: () => setState(() => selectedCategory = "travel"),
                ),
                CategoryButton(
                  title: "Hotels",
                  icon: Icons.apartment,
                  isSelected: selectedCategory == "hotel",
                  onTap: () => setState(() => selectedCategory = "hotel"),
                ),
              ],
            ),

            SizedBox(height: 1),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: PlacesList(
                    category: selectedCategory,
                    location: locationController.text.trim(),
                    filter: selectedFilter,
                    savedPlaceIds: savedPlaceIds,
                    onSaved: fetchSavedPlaces,
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),

        ],
        ),
    );
  }
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1C2D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: const [
          Text(
            "TripTaste",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Discover • Eat • Travel",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          SizedBox(height: 4),
          Text(
            "© 2026 TripTaste",
            style: TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }

}

class PlacesList extends StatelessWidget {
  final String category;
  final String location;
  final String filter;
  final Set<String> savedPlaceIds;
  final VoidCallback onSaved;

  PlacesList({required this.category, required this.location, required this.filter, required this.savedPlaceIds, required this.onSaved});

  void toggleSavePlace(DocumentSnapshot place) async {
    final docRef = FirebaseFirestore.instance
        .collection('SavedPlaces')
        .doc(place.id);

    final doc = await docRef.get();

    if (doc.exists) {
      // UNSAVE
      await docRef.delete();
    } else {
      // SAVE
      await docRef.set({
        'name': place['name'],
        'location': place['location'],
        'category': place['category'],
        'photo_url': place['photo_url'],
      });
    }

    onSaved(); // refresh UI
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('places').where('category', isEqualTo: category).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        var places = snapshot.data!.docs;

        if (location.isNotEmpty) {
          places = places.where((doc) => doc['location'].toString().toLowerCase().contains(location.toLowerCase())).toList();
        }

        if (filter == "Top Rated") {
          places.sort((a, b) =>
              ((b['avgrating'] ?? b['rating'] ?? 0))
                  .compareTo(a['avgrating'] ?? a['rating'] ?? 0));
        } else if (filter == "Budget Friendly") {
          places.sort((a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0));
        }

        return ListView.builder(
          itemCount: places.length,
          itemBuilder: (context, index) {
            var place = places[index];
            bool isSaved = savedPlaceIds.contains(place.id);

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceDetailsPage(placeId: place.id),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: place['photo_url'],
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          errorWidget: (context, url, error) =>
                          const Icon(Icons.image_not_supported),
                        ),

                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              place['location'],
                              maxLines: 2,                     // 👈 only 2 lines
                              overflow: TextOverflow.ellipsis, // 👈 adds ...
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),

                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: const Color(0xFF0B1C2D),
                        ),
                        onPressed: () => toggleSavePlace(place),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: isSelected ? 1.0 : 0.95,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            height: 90,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0B1C2D) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF0B1C2D)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF0B1C2D),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF0B1C2D),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


