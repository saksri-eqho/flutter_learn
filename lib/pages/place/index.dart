import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_learn/pages/place/detail.dart';

class PlacesScreen extends StatefulWidget {
const PlacesScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PlacesScreen();
  }
}

class _PlacesScreen extends State<PlacesScreen> {
  List<dynamic> _places = [];

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    final response =
      await http.get(Uri.parse('https://www.melivecode.com/api/attractions'));

    setState(() {
      _places = jsonDecode(response.body);
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(
        title: const Text('Places'),
      ),
      body: ListView.builder(
        itemCount: _places.length,
        itemBuilder: (context, index) {
          final place = _places[index];
          return ListTile(
              leading: SizedBox(width: MediaQuery.of(context).size.width * 0.2,
              child: Image.network(place['coverimage']),
            ),
            title: Row(children: [Text(place['name'])]),
            subtitle: Text(
              place['detail'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => PalceDetailScreen(id: place['id']))
            ),
          );
        },
      ),
    );
  }
}