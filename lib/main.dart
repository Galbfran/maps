import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

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
  final places = GoogleMapsPlaces(
      apiKey:
          "AIzaSyAA6KXYXkm6KJ84V1apLQguQKXBoKx0NtE"); // Reemplaza con tu clave API

  Future<void> _buscarDireccion() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey:
          "AIzaSyAA6KXYXkm6KJ84V1apLQguQKXBoKx0NtE", // Tu clave API de Google Cloud
      mode: Mode.overlay, // Modo de búsqueda
      language: "es", // Idioma
      components: [
        Component(Component.country, "pe")
      ], // Configura según necesidad
    );

    if (p != null) {
      PlacesDetailsResponse detail =
          await places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;

      setState(() {
        selectedLocation = LatLng(lat, lng);
        // Actualizar el mapa si es necesario
      });
    }
  }

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
            ElevatedButton(
              onPressed: _buscarDireccion,
              child: const Text('Buscar Dirección'),
            ),
            if (selectedLocation != null)
              Text(
                  'Ubicación Seleccionada: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}'),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.of(context).push<LatLng>(
                  MaterialPageRoute(
                      builder: (context) =>
                          MapSample(initialLocation: selectedLocation)),
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
  final LatLng? initialLocation;

  const MapSample({super.key, this.initialLocation});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Marker> _markers = {};
  LatLng? selectedLocation;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      selectedLocation = widget.initialLocation;
      _addMarker(selectedLocation!);
    }
  }

  void _addMarker(LatLng latLng) {
    _markers.add(Marker(
      markerId: MarkerId(latLng.toString()),
      position: latLng,
      infoWindow: InfoWindow(
          title: 'Ubicación Seleccionada',
          snippet: '${latLng.latitude}, ${latLng.longitude}'),
    ));
  }

  void _handleTap(LatLng latLng) {
    setState(() {
      selectedLocation = latLng;
      _markers.clear();
      _addMarker(latLng);
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
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: CameraPosition(
          target: widget.initialLocation ??
              LatLng(-12.04967738829701, -77.09668506723912),
          zoom: 14.4746,
        ),
        onTap: _handleTap,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
