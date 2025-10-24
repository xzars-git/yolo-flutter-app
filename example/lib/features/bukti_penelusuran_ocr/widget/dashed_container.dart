import 'dart:io';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:ultralytics_yolo_example/features/bukti_penelusuran_ocr/controller/bukti_penelusuran_ocr_controller.dart';
import 'package:ultralytics_yolo_example/state_util.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';

class DashedContainerTelusurMandiri extends StatelessWidget {
  final BuktiPenelusuranOcrController controller;

  const DashedContainerTelusurMandiri({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: blueGray50, width: 1.0)),
        width: double.infinity,
        child: InkWell(
          onTap: () async {
            showModalBottomSheet(
              context: context,
              builder: (ctx) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Ambil dari Kamera'),
                      onTap: () async {
                        Navigator.pop(ctx);
                        await controller.openCamera(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Ambil dari Galeri'),
                      onTap: () async {
                        Navigator.pop(ctx);
                        await controller.openGallery(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          child: _buildImageStackDashedContainer(context, controller),
        ),
      ),
    );
  }

  Widget _buildImageStackDashedContainer(
    BuildContext context,
    BuktiPenelusuranOcrController controller,
  ) {
    if (controller.pathPhoto.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, size: 32, color: Colors.grey[600]),
          const SizedBox(height: 8),
          Text(
            "Unggah Foto",
            style: myTextTheme.titleSmall?.copyWith(color: Colors.blue[900], height: 1.5),
          ),
        ],
      );
    } else {
      return Stack(
        children: [
          Image.file(
            File(controller.pathPhoto),
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
          // Tombol zoom/preview fullscreen
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  showImageViewer(
                    context,
                    Image.file(File(controller.pathPhoto)).image,
                    swipeDismissible: false,
                    doubleTapZoomable: true,
                  );
                },
                child: const SizedBox(
                  height: 50,
                  width: 50,
                  child: CircleAvatar(
                    backgroundColor: Color.fromRGBO(0, 0, 0, 0.45),
                    child: Icon(Icons.zoom_in, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ),
          // Tombol hapus di pojok kanan atas
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: () {
                controller.pathPhoto = '';
                controller.update();
              },
              child: const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      );
    }
  }
}
