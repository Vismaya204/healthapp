import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthapp/view/paysucc.dart';

class PaymentOptionScreen extends StatefulWidget {
  final String userName;
  final String hospitalId;
  final String medicineId;
  final int price;
  final int quantity;
  final int totalAmount;

  const PaymentOptionScreen({
    super.key,
    required this.userName,
    required this.hospitalId,
    required this.medicineId,
    required this.price,
    required this.quantity,
    required this.totalAmount,
  });

  @override
  State<PaymentOptionScreen> createState() => _PaymentOptionScreenState();
}

class _PaymentOptionScreenState extends State<PaymentOptionScreen> {
  String selectedMethod = '';
  bool isLoading = false;

  // Card controllers
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  bool get isCardPayment =>
    selectedMethod == 'GPAY' ||
    selectedMethod == 'VISA' ||
    selectedMethod == 'MASTERCARD';

  /// PAYMENT METHODS
  final List<Map<String, dynamic>> paymentMethods = [
    {
      'value': 'GPAY',
      'title': 'Google Pay',
      'image': 'gogl.jpg',
    },
    {
      'value': 'VISA',
      'title': 'Visa Card',
      'image': 'visalogo.png',
    },
    {
      'value': 'MASTERCARD',
      'title': 'MasterCard',
      'image': 'mastercard.png',
    },
  ];

  /// SAVE ORDER
  Future<void> saveOrder() async {
    setState(() => isLoading = true);

    await FirebaseFirestore.instance.collection('orders').add({
      'userName': widget.userName,
      'hospitalId': widget.hospitalId,
      'medicineId': widget.medicineId,
      'price': widget.price,
      'quantity': widget.quantity,
      'totalPrice': widget.totalAmount,
      'paymentMethod': selectedMethod,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const PaymentSuccessScreen(),
      ),
    );
  }

  /// PAYMENT CARD
  Widget paymentCard({
    required String value,
    required String title,
    required String imagePath,
  }) {
    final bool isSelected = selectedMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() => selectedMethod = value);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade300,
            width: 2,
          ),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              height: 32,
              width: 32,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.payment, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: Colors.teal, size: 22),
          ],
        ),
      ),
    );
  }

  /// CARD DETAILS FORM
  Widget cardDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        const Text('Card Holder Name',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: cardHolderController,
          decoration: InputDecoration(
            hintText: 'Your Name',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        const SizedBox(height: 14),

        const Text('Card Number',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: cardNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '**** **** **** ****',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Expiry Date',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: expiryController,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      hintText: 'MM/YY',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CVV',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: cvvController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '***',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// USER INFO
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(widget.userName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text('Quantity: ${widget.quantity}'),
              trailing: Text(
                '₹ ${widget.totalAmount}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ),

            const SizedBox(height: 20),

            /// PAYMENT OPTIONS
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                final method = paymentMethods[index];
                return paymentCard(
                  value: method['value'],
                  title: method['title'],
                  imagePath: method['image'],
                );
              },
            ),

            /// CARD FORM (ONLY FOR VISA / MASTERCARD)
            if (isCardPayment) cardDetailsForm(),

            const Spacer(),

            /// PAY NOW
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: selectedMethod.isEmpty || isLoading
                    ? null
                    : () {
                        if (isCardPayment &&
                            (cardHolderController.text.isEmpty ||
                                cardNumberController.text.length < 16 ||
                                expiryController.text.isEmpty ||
                                cvvController.text.length < 3)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please enter valid card details')),
                          );
                          return;
                        }
                        saveOrder();
                      },
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('PAY NOW',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
