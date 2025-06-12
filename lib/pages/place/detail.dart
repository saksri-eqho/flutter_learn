import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PalceDetailPage extends StatefulWidget {
  final int id;

  const PalceDetailPage({super.key, required this.id});

  @override
  State<StatefulWidget> createState() {
    return _PalceDetailPageState();
  }
}

class _PalceDetailPageState extends State<PalceDetailPage> {
  Map<String, dynamic>? _placeDetail;

  @override
  void initState() {
    super.initState();
    _fetchPlaceDetail();
  }

  Future<void> _fetchPlaceDetail() async {
    final response = await http.get(
      Uri.parse('https://www.melivecode.com/api/attractions/${widget.id}'),
    );

    setState(() {
      _placeDetail = jsonDecode(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Place Detail')),
      body: _placeDetail == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(_placeDetail!['attraction']['coverimage']),
                  const SizedBox(height: 16),
                  Text(
                    _placeDetail!['attraction']['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(_placeDetail!['attraction']['detail']),
                ],
              ),
            ),
    );
  }
}

//Text(_placeDetail!['attraction']['name'])
