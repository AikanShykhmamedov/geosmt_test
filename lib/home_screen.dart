import 'dart:math';

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _zoom = TextEditingController();

  Point<int>? _tileCoordinate;
  String? _tileUrl;

  @override
  void dispose() {
    _latitude.dispose();
    _longitude.dispose();
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _latitude,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'latitude',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _longitude,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'longitude',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _zoom,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'zoom',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onCalculatePressed,
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 32),
            if (_tileCoordinate != null) //
              Text('$_tileCoordinate'),
            if (_tileUrl != null)
              Image.network(
                _tileUrl!,
                width: 128,
                height: 128,
              ),
          ],
        ),
      ),
    );
  }

  void _onCalculatePressed() async {
    final latitude = double.tryParse(_latitude.text);
    final longitude = double.tryParse(_longitude.text);
    final zoom = int.tryParse(_zoom.text);

    if (latitude == null || longitude == null || zoom == null) {
      return;
    }

    _tileCoordinate = _getTileCoordinate(latitude, longitude, zoom);
    _tileUrl = _getTileUrl(_tileCoordinate!, zoom);

    setState(() {});
  }

  // [https://yandex.ru/dev/maps/tiles/doc/dg/concepts/about-tiles.html#get-tile-number]
  Point<int> _getTileCoordinate(
    double latitude,
    double longitude,
    int zoom,
  ) {
    // Eccentricity of the earth's ellipsoid
    const epsilon = 0.0818191908426;

    final beta = pi * latitude / 180;
    final phi = (1 - epsilon * sin(beta)) / (1 + epsilon * sin(beta));
    final theta = tan(pi / 4 + beta / 2) * pow(phi, epsilon / 2);
    final rho = pow(2, zoom + 8) / 2;

    final x = rho * (1 + longitude / 180) ~/ 256;
    final y = rho * (1 - log(theta) / pi) ~/ 256;

    return Point<int>(x, y);
  }

  String _getTileUrl(Point<int> coordinate, int zoom) {
    return 'https://core-carparks-renderer-lots.maps.yandex.net/maps-rdr-carparks/tiles?l=carparks&x=${coordinate.x}&y=${coordinate.y}&z=$zoom&scale=1&lang=ru_RU';
  }
}
