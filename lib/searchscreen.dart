import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stellaris/SpaceWebView.dart';
import 'package:stellaris/model/spacemodel.dart';

class SearchScreen extends StatefulWidget {

  const SearchScreen({super.key,});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Spacemodel> searchResults = [];
  bool isLoading = false;
  bool hasSearched = false;

  // NASA Image Library API for Searching
  Future<void> performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    String url = "https://images-api.nasa.gov/search?q=$query&media_type=image";
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var items = data['collection']['items'] as List;
        
        setState(() {
          searchResults = items.take(20).map((e) => Spacemodel.fromMap({
            'title': e['data'][0]['title'] ?? "No Title",
            'hdurl': e['links'][0]['href'] ?? "",
            'explanation': e['data'][0]['description'] ?? "No description available.",
            'date': e['data'][0]['date_created'] ?? ""
          })).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Search Error: $e");
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
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Column(
                children: [
                  _buildTopBar(),
                  _buildSearchInput(),
                  Expanded(
                    child: _buildResultsArea(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const Text(
            'COSMIC SEARCH',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.cyan.withOpacity(0.5)),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) => performSearch(value),
          decoration: InputDecoration(
            hintText: 'Search stars, nebula, planets...',
            hintStyle: TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Colors.cyanAccent),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.white54),
              onPressed: () => _searchController.clear(),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsArea() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
    }

    if (!hasSearched) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rocket, size: 80, color: Colors.white24),
            SizedBox(height: 10),
            Text("Enter a keyword to explore", style: TextStyle(color: Colors.white38)),
          ],
        ),
      );
    }

    if (searchResults.isEmpty) {
      return const Center(
        child: Text("Not Found", style: TextStyle(color: Colors.white70, fontSize: 18)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final planet = searchResults[index];
        return _searchResultCard(planet);
      },
    );
  }

  Widget _searchResultCard(Spacemodel planet) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpaceWebView(
            url: planet.Image,
            title: planet.Title,
            description: planet.Desc,
            date: planet.Date,
            image: planet.Image,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.network(
                    planet.Image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white24),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    planet.Title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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