import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stellaris/CategoryScreen.dart';
import 'package:stellaris/DiscoverPlanetScreen.dart';
import 'package:stellaris/SpaceWebView.dart';
import 'package:stellaris/model/spacemodel.dart';
import 'package:http/http.dart' as http;
import 'package:stellaris/searchscreen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  // Search Controller add kiya gaya hai
  final TextEditingController _searchController = TextEditingController();

  // Variables for Data
  List<Spacemodel> discoverPlanets = [];
  List<Spacemodel> exploreGalaxies = [];
  bool isLoadingPlanets = true;
  bool isLoadingGalaxies = true;

  @override
  void initState() {
    super.initState();
    fetchDiscoverPlanets();
    fetchExploreGalaxies();
  }

  // Memory leak se bachne ke liye dispose
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // NASA APOD API for Discover Section
  Future<void> fetchDiscoverPlanets() async {
    String url = "https://api.nasa.gov/planetary/apod?api_key=alIWrCiEGKUM77YGHqLWZFvoy7OUSx4qpEbvzbGq&count=10";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          discoverPlanets = data.map((e) => Spacemodel.fromMap(e)).toList();
          isLoadingPlanets = false;
        });
      }
    } catch (e) {
      debugPrint("Error Planets: $e");
      setState(() => isLoadingPlanets = false);
    }
  }

  // NASA Image Library API for Galaxies Section
  Future<void> fetchExploreGalaxies() async {
    String url = "https://images-api.nasa.gov/search?q=galaxy&media_type=image";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var items = data['collection']['items'] as List;
        setState(() {
          exploreGalaxies = items.take(10).map((e) => Spacemodel.fromMap({
            'title': e['data'][0]['title'],
            'hdurl': e['links'][0]['href'],
            'explanation': e['data'][0]['description'],
            'date': e['data'][0]['date_created']
          })).toList();
          isLoadingGalaxies = false;
        });
      }
    } catch (e) {
      debugPrint("Error Galaxies: $e");
      setState(() => isLoadingGalaxies = false);
    }
  }

  final List categoriesList = [
    {'icon': FontAwesomeIcons.earthOceania, 'name': 'Planet'},
    {'icon': FontAwesomeIcons.atom, 'name': 'Galaxy'},
    {'icon': FontAwesomeIcons.circleNotch, 'name': 'Black Holes'},
    {'icon': FontAwesomeIcons.shuttleSpace, 'name': 'Missions'},
    {'icon': FontAwesomeIcons.star, 'name': 'Star'},
    {'icon': FontAwesomeIcons.rss, 'name': 'News'},
  ];

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
            margin: const EdgeInsets.fromLTRB(8, 8, 8, 75),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white.withAlpha(30)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(12),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: _buildScrollableContent(),
                        ),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(color: Color(0xFFFDBE75), blurRadius: 30, spreadRadius: 2),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    right: 0,
                    child: Text('S', style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              const Text('TELLARIS', style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              const Icon(Icons.rocket_launch_outlined, size: 36, color: Color(0xFFD08CFF)),
            ],
          ),
          const Text('Cosmic Guide', style: TextStyle(color: Colors.white70)),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
            child: _buildSearchBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(60),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(12),
            borderRadius: BorderRadius.circular(60),
            border: Border.all(color: Colors.cyan.withOpacity(0.3)),
          ),
          child: TextField(
            controller: _searchController, // Controller link kiya
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.search, // Keyboard pe search icon
            onSubmitted: (value) {
              // Khali search pe kuch nahi hoga
              if (value.trim().isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(),
                  ),
                );
              }
            },
            decoration: const InputDecoration(
              hintText: 'Explore galaxies...',
              hintStyle: TextStyle(color: Colors.white38),
              prefixIcon: Icon(Icons.search, color: Color(0xFF00D2FF)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CATEGORIES
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categoriesList.length,
            itemBuilder: (context, index) {
              final item = categoriesList[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Categoryscreen(query: item['name']))),
                  child: _glassCircle(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item['icon'], color: Colors.white70, size: 18),
                        const SizedBox(height: 4),
                        Text(item['name'], style: const TextStyle(color: Colors.white70, fontSize: 8)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const Padding(
          padding: EdgeInsets.fromLTRB(20, 30, 0, 10),
          child: Text('DISCOVER PLANETS', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
        ),

        // DISCOVER PLANETS (DYNAMIC)
        SizedBox(
          height: 160,
          child: isLoadingPlanets
              ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: discoverPlanets.length,
                  itemBuilder: (context, index) {
                    final planet = discoverPlanets[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DiscoverPlanets())),
                        child: Column(
                          children: [
                            _glassCircle(size: 100, isNetwork: true, imagePath: planet.Image),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 100,
                              child: Text(planet.Title.toUpperCase(), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 0, 10),
          child: Text('EXPLORE GALAXIES', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
        ),

        // EXPLORE GALAXIES (DYNAMIC GRID)
        isLoadingGalaxies
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: exploreGalaxies.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return _glassCard(exploreGalaxies[index]);
                },
              ),
      ],
    );
  }

  Widget _glassCircle({Widget? child, double size = 50, String? imagePath, bool isNetwork = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withAlpha(12),
            border: Border.all(color: Colors.cyan.withOpacity(0.3)),
            image: imagePath != null
                ? DecorationImage(
                    image: isNetwork ? NetworkImage(imagePath) : AssetImage(imagePath) as ImageProvider,
                    fit: BoxFit.cover)
                : null,
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _glassCard(Spacemodel galaxy) {
    return InkWell(
      onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpaceWebView(
            url: galaxy.Image,        
            title: galaxy.Title,      
            description: galaxy.Desc, 
            date: galaxy.Date,        
            image: galaxy.Image,      
          ),
        ),
      );
    },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(galaxy.Title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12)),
                const SizedBox(height: 6),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    child: Image.network(
                      galaxy.Image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white24),
                    ),
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