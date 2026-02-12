import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stellaris/model/spacemodel.dart'; 
import 'package:stellaris/SpaceWebView.dart'; // WebView file import karein

class Categoryscreen extends StatefulWidget {
  final String query;
  const Categoryscreen({super.key, required this.query});

  @override
  State<Categoryscreen> createState() => _CategoryscreenState();
}

class _CategoryscreenState extends State<Categoryscreen> {
  List<Spacemodel> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCategory(widget.query);
  }

  Future<void> getCategory(String query) async {
    String url = "";
    String apiKey = "alIWrCiEGKUM77YGHqLWZFvoy7OUSx4qpEbvzbGq";
    
    DateTime tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
    String formattedDate = "${tenDaysAgo.year}-${tenDaysAgo.month.toString().padLeft(2, '0')}-${tenDaysAgo.day.toString().padLeft(2, '0')}";

    switch (query) {
      case 'Planet':
        url = "https://api.nasa.gov/planetary/apod?api_key=$apiKey&start_date=$formattedDate";
        break;
      case 'Galaxy':
        url = "https://images-api.nasa.gov/search?q=galaxy&media_type=image";
        break;
      case 'Black Holes':
        url = "https://images-api.nasa.gov/search?q=black%20hole&media_type=image";
        break;
      case 'Missions':
        url = "https://images-api.nasa.gov/search?q=mars%20rover&media_type=image";
        break;
      case 'Star':
        url = "https://images-api.nasa.gov/search?q=nebula&media_type=image";
        break;
      case 'News':
        url = "https://api.spaceflightnewsapi.net/v4/articles/?limit=10";
        break;
      default:
        url = "https://api.nasa.gov/planetary/apod?api_key=$apiKey&count=10";
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var rawData = jsonDecode(response.body);
        List<Spacemodel> tempList = [];

        if (query == 'Planet') {
          for (var e in rawData) {
            tempList.add(Spacemodel.fromMap({
              'title': e['title'],
              'hdurl': e['url'], // variable name model ke mutabiq
              'explanation': e['explanation'],
              'date': e['date'],
            }));
          }
        } else if (query == 'News') {
          for (var e in rawData['results']) {
            tempList.add(Spacemodel.fromMap({
              'title': e['title'],
              'hdurl': e['image_url'],
              'explanation': e['summary'],
              'date': e['published_at'].toString().substring(0, 10),
            }));
          }
        } else {
          for (var e in rawData['collection']['items']) {
            tempList.add(Spacemodel.fromMap({
              'title': e['data'][0]['title'],
              'hdurl': e['links'][0]['href'],
              'explanation': e['data'][0]['description'],
              'date': e['data'][0]['date_created'].toString().substring(0, 10),
            }));
          }
        }

        setState(() {
          categories = tempList;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      widget.query.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                    : ListView.builder(
                        itemCount: categories.length,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemBuilder: (context, index) {
                          return _buildSpaceCard(categories[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpaceCard(Spacemodel item) {
    return InkWell( // WebView Navigation ke liye wrap kiya
     onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SpaceWebView(
        url: item.Image,        // Web URL
        title: item.Title,      // Title
        description: item.Desc, // Full detailed description
        date: item.Date,        // Publication Date
        image: item.Image,      // Header Image
      ),
    ),
  );
},
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 380,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(item.Image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.Title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                item.Date,
                                style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.Desc,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.4),
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              "READ MORE →",
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}