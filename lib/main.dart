import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LatLng? selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedLocation != null)
              Text(
                  'Ubicación Seleccionada: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}'),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.of(context).push<LatLng>(
                  MaterialPageRoute(builder: (context) => const MapSample()),
                );
                if (result != null) {
                  setState(() {
                    selectedLocation = result;
                  });
                }
              },
              child: const Text('Ir al Mapa'),
            ),
          ],
        ),
      ),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};
  LatLng? selectedLocation;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-12.04967738829701, -77.09668506723912),
    zoom: 14.4746,
  );

  Future<void> _searchAndNavigate() async {
    String address = _searchController.text;
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=AIzaSyAA6KXYXkm6KJ84V1apLQguQKXBoKx0NtE'));

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      if (result['results'].length > 0) {
        double lat = result['results'][0]['geometry']['location']['lat'];
        double lng = result['results'][0]['geometry']['location']['lng'];
        LatLng searchedLocation = LatLng(lat, lng);

        _handleTap(searchedLocation);
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLng(searchedLocation));
      }
    }
  }

  void _handleTap(LatLng latLng) {
    setState(() {
      selectedLocation = latLng;
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId(latLng.toString()),
        position: latLng,
        infoWindow: InfoWindow(
            title: 'Ubicación Seleccionada',
            snippet: '${latLng.latitude}, ${latLng.longitude}'),
      ));
    });

    // Regresar automáticamente a HomePage con la ubicación seleccionada
    Navigator.of(context).pop(latLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(selectedLocation);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ingresa una dirección',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchAndNavigate,
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: _kGooglePlex,
              onTap: _handleTap,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
        ],
      ),
    );
  }
}
