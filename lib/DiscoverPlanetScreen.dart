import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stellaris/model/spacemodel.dart';
import 'package:stellaris/SpaceWebView.dart'; // WebView wali file import karein

class DiscoverPlanets extends StatefulWidget {
  const DiscoverPlanets({super.key});

  @override
  State<DiscoverPlanets> createState() => _DiscoverPlanetsState();
}

class _DiscoverPlanetsState extends State<DiscoverPlanets> {
  List<Spacemodel> planetList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlanets();
  }

  Future<void> fetchPlanets() async {
    const String apiKey = "alIWrCiEGKUM77YGHqLWZFvoy7OUSx4qpEbvzbGq";
    const String url = "https://api.nasa.gov/planetary/apod?api_key=$apiKey&count=10";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          // Model mapping check kar lein (Image, Title, Desc, Date fields honi chahiye)
          planetList = data.map((e) => Spacemodel.fromMap(e)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white.withAlpha(30)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.white.withAlpha(12),
                  child: Column(
                    children: [
                      _buildAppBar(),
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
                            : _buildPlanetGrid(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const Text(
            'DISCOVER',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(15),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 0.75,
      ),
      itemCount: planetList.length,
      itemBuilder: (context, index) {
        return _planetGlassCard(planetList[index]);
      },
    );
  }

  Widget _planetGlassCard(Spacemodel planet) {
    return InkWell( // Navigation click handle karne ke liye
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpaceWebView(
              url: planet.Image,        // Web URL ya Image URL
              title: planet.Title,      // Title
              description: planet.Desc, // Full detailed description
              date: planet.Date,        // Date
              image: planet.Image,      // Top Header Image
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white10),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white.withAlpha(20), Colors.white.withAlpha(5)],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  planet.Image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => 
                    const Center(child: Icon(Icons.broken_image, color: Colors.white24)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planet.Title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      planet.Date,
                      style: const TextStyle(color: Colors.cyanAccent, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}