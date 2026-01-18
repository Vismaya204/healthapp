import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthapp/view/userpayment.dart';

class Medicinedetailuserscr extends StatelessWidget {
  final String hospitalId;
  final String medicineId;

  const Medicinedetailuserscr({
    super.key,
    required this.hospitalId,
    required this.medicineId,
  });

  @override
  Widget build(BuildContext context) {
    final medicines = FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalId)
        .collection('medicines');

    final userEmail =
        FirebaseAuth.instance.currentUser?.email ?? 'Anonymous';

    /// ⭐ ADD REVIEW
    void showReviewDialog() {
      final reviewController = TextEditingController();
      double rating = 4;

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Add Rating & Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () =>
                            setState(() => rating = index + 1.0),
                      );
                    }),
                  ),
                  TextField(
                    controller: reviewController,
                    decoration:
                        const InputDecoration(labelText: 'Review'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor:const Color.fromARGB(255, 106, 186, 252),),
                  onPressed: () async {
                    await medicines
                        .doc(medicineId)
                        .collection('reviews')
                        .add({
                      'userEmail': userEmail,
                      'rating': rating,
                      'review': reviewController.text,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        ),
      );
    }

    /// 🛒 BUY NOW
    void showBuyNowDialog(BuildContext context, int price) {
      final nameController = TextEditingController();
      int quantity = 1;

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            int total = price * quantity;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Confirm Order'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Your Name'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Price'),
                      Text('₹ $price',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Quantity'),
                      Row(
                        children: [
                          IconButton(
                              onPressed: quantity > 1
                                  ? () => setState(() => quantity--)
                                  : null,
                              icon: const Icon(Icons.remove)),
                          Text(quantity.toString()),
                          IconButton(
                              onPressed: () =>
                                  setState(() => quantity++),
                              icon: const Icon(Icons.add)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style:
                              TextStyle(fontWeight: FontWeight.bold)),
                      Text('₹ $total',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color:const Color.fromARGB(255, 106, 186, 252),)),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor:const Color.fromARGB(255, 106, 186, 252),),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentOptionScreen(hospitalId:hospitalId ,medicineId: medicineId,price: price,
                          userName: nameController.text,
                          totalAmount: total,
                          quantity: quantity,
                        ),
                      ),
                    );
                  },
                  child: const Text('PAY'),
                ),
              ],
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Medicine Details'),
        backgroundColor: const Color.fromARGB(255, 106, 186, 252),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: medicines.doc(medicineId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final int price =
              int.tryParse(data['price'].toString()) ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    data['imageUrl'],
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 16),

                Text(data['name'],
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),

                const SizedBox(height: 12),

                /// PRICE + AVG RATING
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Price'),
                          Text('₹ $price',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        ],
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: medicines
                            .doc(medicineId)
                            .collection('reviews')
                            .snapshots(),
                        builder: (context, snap) {
                          double avg = 0;
                          if (snap.hasData &&
                              snap.data!.docs.isNotEmpty) {
                            double sum = 0;
                            for (var d in snap.data!.docs) {
                              sum += (d['rating'] as num).toDouble();
                            }
                            avg = sum / snap.data!.docs.length;
                          }
                          return Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber),
                              Text(avg.toStringAsFixed(1)),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// DESCRIPTION ✅
                const Text('Description',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  child: Text(
                      data['description'] ?? 'No description available'),
                ),

                const SizedBox(height: 20),

                OutlinedButton.icon(
                  onPressed: showReviewDialog,
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Add Rating & Review'),
                ),

                const SizedBox(height: 20),

                /// USER REVIEWS ✅
                const Text('User Reviews',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                StreamBuilder<QuerySnapshot>(
                  stream: medicines
                      .doc(medicineId)
                      .collection('reviews')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData || snap.data!.docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('No reviews yet'),
                      );
                    }

                    return Column(
                      children: snap.data!.docs.map((doc) {
                        final r = doc.data() as Map<String, dynamic>;
                        return Card(
                          child: ListTile(
                            title: Text(r['userEmail']),
                            subtitle: Text(r['review']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 18),
                                Text(r['rating'].toString()),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 30),

                /// BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30)),
                        ),
                        onPressed: () {},
                        child: const Text('ADD TO CART'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            showBuyNowDialog(context, price),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [const Color.fromARGB(255, 106, 186, 252), Colors.green],
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'BUY NOW',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
