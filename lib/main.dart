import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  Set<Marker> _markers = {};
  LatLng? selectedLocation;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-12.04967738829701, -77.09668506723912),
    zoom: 14.4746,
  );

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
      Navigator.of(context).pop(latLng);
    });
    
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
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onTap: _handleTap,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
