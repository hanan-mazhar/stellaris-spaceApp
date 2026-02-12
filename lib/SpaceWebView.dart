import 'package:flutter/material.dart';

class SpaceWebView extends StatelessWidget {
  final String url;
  final String title;
  final String description; 
  final String date;        
  final String image;       

  const SpaceWebView({
    super.key,
    required this.url,
    required this.title,
    this.description = "No description available.",
    this.date = "",
    this.image = "",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Header Image (Sirf ek baar top par)
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    image, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      const Center(child: Icon(Icons.broken_image, color: Colors.white24, size: 50)),
                  ),
                  // Fade effect for text visibility
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 2. Details Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Date Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        date,
                        style: const TextStyle(color: Colors.cyanAccent, fontSize: 13),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 25),
                  const Text(
                    "OVERVIEW",
                    style: TextStyle(
                      color: Colors.cyanAccent, 
                      fontSize: 12, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 2
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.6,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Footer info
                  Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.cyanAccent, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "OFFICIAL NASA SOURCE",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9), 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 40, thickness: 1),
                  
                  const SizedBox(height: 30), // Extra space at bottom
                ],
              ),
            ),
          ),
          
          // WebView Section "SliverFillRemaining" yahan se hata diya gaya hai.
        ],
      ),
    );
  }
}