// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import 'package:flutter/material.dart';
import 'package:ultralytics_yolo_example/presentation/screens/camera_inference_screen.dart';
import 'package:ultralytics_yolo_example/presentation/cropping_example_screen.dart';
import 'package:ultralytics_yolo_example/presentation/screens/license_plate_screen.dart';
import 'package:ultralytics_yolo_example/presentation/screens/license_plate_cropping_screen.dart';
import 'package:ultralytics_yolo_example/presentation/screens/simple_ocr_test_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YOLO Examples', 
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YOLO Examples'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExampleCard(
            context,
            icon: Icons.camera_alt,
            title: 'Camera Inference',
            description: 'Real-time object detection with camera',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CameraInferenceScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context,
            icon: Icons.directions_car,
            title: '🚗 License Plate Recognition',
            description: 'Deteksi plat nomor kendaraan secara real-time',
            color: Colors.green,
            badge: 'NEW',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LicensePlateScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context,
            icon: Icons.content_cut,
            title: '🔥 Advanced Plate Cropping',
            description: 'Enhanced license plate cropping with OCR support',
            color: Colors.indigo,
            badge: 'ENHANCED',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LicensePlateCroppingScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context,
            icon: Icons.science,
            title: '🧪 Simple OCR Test',
            description: 'Test OCR tanpa pause logic - untuk debugging',
            color: Colors.purple,
            badge: 'DEBUG',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SimpleOCRTestScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context,
            icon: Icons.crop,
            title: '🔥 Basic Cropping Feature',
            description: 'Automatic object cropping demo',
            color: Colors.purple,
            badge: 'DEMO',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CroppingExampleScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
