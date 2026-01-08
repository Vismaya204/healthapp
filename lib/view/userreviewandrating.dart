import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Reviewandrating extends StatefulWidget {
  final String hospitalId;

  const Reviewandrating({super.key, required this.hospitalId});

  @override
  State<Reviewandrating> createState() => _ReviewandratingState();
}

class _ReviewandratingState extends State<Reviewandrating> {
  final TextEditingController reviewController = TextEditingController();
  int rating = 0; // 1-5 stars
  bool isLoading = false;

  void submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Make sure user is logged in

    if (rating == 0 || reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please provide rating and review")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final reviewData = {
        "rating": rating,
        "review": reviewController.text.trim(),
        "email": user.email ?? "Anonymous",
        "timestamp": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection("hospitals")
          .doc(widget.hospitalId)
          .collection("reviews")
          .add(reviewData);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Review submitted!")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget star(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          rating = index;
        });
      },
      child: Icon(
        Icons.star,
        size: 40,
        color: index <= rating ? Colors.amber : Colors.grey.shade400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Write a Review"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Rate the Hospital",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => star(index + 1)),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: reviewController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Write your review...",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit Review",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
