import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/view/userreviewandrating.dart';

class Hospitaldetail extends StatelessWidget {
  final String hospitalId;

  const Hospitaldetail({super.key, required this.hospitalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Hospital Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hospitals')
            .doc(hospitalId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Hospital not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final double rating = (data['rating'] ?? 0).toDouble();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ================= IMAGE =================
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.blue.shade50),
                  child: data['image'] != null && data['image'] != ''
                      ? Image.network(data['image'], fit: BoxFit.cover)
                      : const Center(
                          child: Icon(
                            Icons.local_hospital,
                            size: 80,
                            color: Colors.blue,
                          ),
                        ),
                ),

                /// ================= CONTENT =================
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Hospital Name + Rating Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data['hospitalName'] ?? '',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data['location'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// Write Review Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Reviewandrating(hospitalId: hospitalId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.rate_review),
                        label: const Text("Write a Review"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// ================= CATEGORIES =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _categoryCard(
                            icon: Icons.medical_services,
                            title: "Medicine",
                            color: Colors.indigo,
                            onTap: () {},
                          ),
                          _categoryCard(
                            icon: Icons.person,
                            title: "Doctors",
                            color: Colors.teal,
                            onTap: () {},
                          ),
                          _categoryCard(
                            icon: Icons.local_hospital,
                            title: "Emergency",
                            color: Colors.redAccent,
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// ABOUT TITLE
                      const Text(
                        "About Hospital",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// ABOUT DESCRIPTION
                      Text(
                        data['description'] ?? "No description available.",
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// ================= USER REVIEWS =================
                      const Text(
                        "User Reviews",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('hospitals')
                            .doc(hospitalId)
                            .collection('reviews')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, reviewSnapshot) {
                          if (reviewSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (!reviewSnapshot.hasData ||
                              reviewSnapshot.data!.docs.isEmpty) {
                            return const Text("No reviews yet.");
                          }

                          final reviews = reviewSnapshot.data!.docs;

                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              final reviewData =
                                  reviews[index].data() as Map<String, dynamic>;
                              final double userRating =
                                  (reviewData['rating'] ?? 0).toDouble();
                              final String userReview =
                                  reviewData['review'] ?? '';

                             final String userEmail = reviewData['email'] ?? "Anonymous";

return Card(
  margin: const EdgeInsets.symmetric(vertical: 6),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// User Email
        Text(
          userEmail,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 4),

        /// Rating stars
        Row(
          children: List.generate(
            5,
            (i) => Icon(
              Icons.star,
              size: 16,
              color: i < userRating
                  ? Colors.amber
                  : Colors.grey.shade400,
            ),
          ),
        ),

        const SizedBox(height: 6),

        /// Review text
        Text(
          userReview,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    ),
  ),
);

                            },
                          );
                        },
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ================= CATEGORY CARD =================
  Widget _categoryCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
