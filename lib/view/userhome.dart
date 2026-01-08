import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/controller/hospitalcontroller.dart';
import 'package:healthapp/model/model.dart';
import 'package:healthapp/view/userhospitaldetail.dart';
import 'package:provider/provider.dart';

/// ================= BANNER DATA =================
final List<Map<String, String>> bannerData = [
  {
    "title": "Take Measures\nTo Avoid Infection",
    "subtitle": "Wear a mask & keep distance\nStay safe and healthy",
    "image": "mask.jpg",
  },
  {
    "title": "Find Best\nDoctors Nearby",
    "subtitle": "Book appointments\nAnytime, Anywhere",
    "image": "appointment.jpg",
  },
  {
    "title": "Emergency\nMedical Support",
    "subtitle": "24/7 Ambulance & Care",
    "image": "emergencyimg.jpg",
  },
];


/// ================= HOME CATEGORY MODEL =================
class HomeCategory {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  HomeCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

/// ================= USER HOME =================
class Userhome extends StatefulWidget {
  const Userhome({super.key});

  @override
  State<Userhome> createState() => _UserhomeState();
}

class _UserhomeState extends State<Userhome> {
  final TextEditingController searchController = TextEditingController();

  String userName = "";
  String userLocation = "";
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    context.read<HospitalController>().fetchApprovedHospitals();
  }

  /// ================= FETCH USER =================
  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          userName = data['username'] ?? '';
          userLocation = data['location'] ?? '';
          isLoadingUser = false;
        });
      }
    } catch (_) {
      setState(() => isLoadingUser = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      HomeCategory(
        title: "Medicine",
        icon: Icons.medical_services,
        color: const Color(0xff5E60CE),
        onTap: () {},
      ),
      HomeCategory(
        title: "Doctors",
        icon: Icons.person,
        color: const Color(0xff4CC9F0),
        onTap: () {},
      ),
      HomeCategory(
        title: "Emergency",
        icon: Icons.local_hospital,
        color: const Color(0xffF72585),
        onTap: () {},
      ),
      HomeCategory(
        title: "More",
        icon: Icons.grid_view,
        color: const Color(0xffFCA311),
        onTap: () {},
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 106, 186, 252),
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.black),
        title: isLoadingUser
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName.isEmpty ? "Welcome" : userName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    userLocation.isEmpty ? "Select Location" : userLocation,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      /// ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// SEARCH
            TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search hospital",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// HEALTH BANNER
            const HealthBannerSlider(),

            const SizedBox(height: 18),

            /// CATEGORY ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: categories
                  .map(
                    (e) => Column(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: e.color,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child:
                              Icon(e.icon, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(e.title,
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 26),

            /// POPULAR HOSPITALS
            const Text(
              "Popular Hospitals",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Consumer<HospitalController>(
              builder: (context, controller, _) {
                final hospitals = controller.approvedHospitals
                    .where((h) => h.hospitalName
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase()))
                    .toList();

                if (hospitals.isEmpty) {
                  return const Center(child: Text("No hospitals found"));
                }

               return GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    childAspectRatio: 0.78,
  ),
  itemCount: hospitals.length,
  itemBuilder: (context, index) {
    final hospital = hospitals[index];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Hospitaldetail(
              hospitalId: hospital.uid, // ✅ FIXED
            ),
          ),
        );
      },
      child: HospitalGridCard(hospital: hospital),
    );
  },
);

              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= HEALTH BANNER =================

class HealthBannerSlider extends StatefulWidget {
  const HealthBannerSlider({super.key});

  @override
  State<HealthBannerSlider> createState() => _HealthBannerSliderState();
}

class _HealthBannerSliderState extends State<HealthBannerSlider> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    /// AUTO SLIDE
    Future.delayed(const Duration(seconds: 3), autoSlide);
  }

  void autoSlide() {
    if (!mounted) return;

    _currentIndex = (_currentIndex + 1) % bannerData.length;
    _controller.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(seconds: 3), autoSlide);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// ================= SLIDER =================
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            itemCount: bannerData.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final banner = bannerData[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: DecorationImage(
                    image: AssetImage(banner["image"]!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.65),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        banner["title"]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        banner["subtitle"]!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        /// ================= DOT INDICATOR =================
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerData.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? const Color(0xff4CC9F0)
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


/// ================= HOSPITAL GRID CARD =================
class HospitalGridCard extends StatelessWidget {
  final HospitalModel hospital;

  const HospitalGridCard({super.key, required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: hospital.image.isNotEmpty
                  ? Image.network(
                      hospital.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Container(
                      color: Colors.blue.shade50,
                      child: const Icon(Icons.local_hospital,
                          size: 40, color: Colors.blue),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hospital.hospitalName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(hospital.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
