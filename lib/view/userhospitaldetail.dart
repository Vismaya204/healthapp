import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/view/userreviewandrating.dart';

class Hospitaldetail extends StatelessWidget {
  final String hospitalId;
  final String hospitalName;

  const Hospitaldetail({super.key, required this.hospitalId,required this.hospitalName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color.fromARGB(255, 106, 186, 252),
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

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ================= IMAGE =================
                Container(
                  height: 240,
                  width: double.infinity,
                  color: Colors.blue.shade50,
                  child: data['image'] != null && data['image'] != ''
                      ? Image.network(data['image'], fit: BoxFit.cover)
                      : const Center(
                          child: Icon(Icons.local_hospital,
                              size: 80, color: Colors.blue),
                        ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// NAME + RATING
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data['hospitalName'] ?? '',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),

                          /// ⭐ LIVE RATING (UNCHANGED)
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('hospitals')
                                .doc(hospitalId)
                                .collection('reviews')
                                .snapshots(),
                            builder: (context, ratingSnapshot) {
                              double avgRating = 0;

                              if (ratingSnapshot.hasData &&
                                  ratingSnapshot.data!.docs.isNotEmpty) {
                                final docs = ratingSnapshot.data!.docs;
                                double total = 0;

                                for (var doc in docs) {
                                  total +=
                                      (doc['rating'] ?? 0).toDouble();
                                }
                                avgRating = total / docs.length;
                              }

                              return Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    avgRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// LOCATION (UNCHANGED)
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            data['location'] ?? '',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// WRITE REVIEW (UNCHANGED)
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  Reviewandrating(hospitalId: hospitalId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.rate_review),
                        label: const Text("Write a Review"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
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
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/medicine',
                                arguments: hospitalId,
                              );
                            },
                          ),
                          _categoryCard(
                            icon: Icons.person,
                            title: "Doctors",
                            color: Colors.teal,
                            onTap: () {
                              Navigator.pushNamed(
  context,
  '/doctors',
  arguments: {
    'hospitalName': hospitalName,
    'hospitalId': hospitalId,
  },
);

                            },
                          ),
                          _categoryCard(
                            icon: Icons.local_hospital,
                            title: "Emergency",
                            color: Colors.redAccent,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/emergency',
                                arguments: hospitalId,
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// ABOUT (UNCHANGED)
                      const Text("About Hospital",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        data['description'] ??
                            "No description available.",
                        style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.black87),
                      ),

                      const SizedBox(height: 30),

                      /// USER REVIEWS (UNCHANGED)
                      const Text("User Reviews",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('hospitals')
                            .doc(hospitalId)
                            .collection('reviews')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, reviewSnapshot) {
                          if (!reviewSnapshot.hasData ||
                              reviewSnapshot.data!.docs.isEmpty) {
                            return const Text("No reviews yet.");
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount:
                                reviewSnapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final review =
                                  reviewSnapshot.data!.docs[index]
                                      .data() as Map<String, dynamic>;

                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review['email'] ??
                                            'Anonymous',
                                        style: const TextStyle(
                                            fontWeight:
                                                FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (i) => Icon(
                                            Icons.star,
                                            size: 16,
                                            color: i <
                                                    (review['rating'] ??
                                                        0)
                                                ? Colors.amber
                                                : Colors.grey
                                                    .shade400,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(review['review'] ?? ''),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
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

  /// CATEGORY CARD (UNCHANGED)
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
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
