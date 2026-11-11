import 'package:attendance_app/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraButton extends StatelessWidget {
  final Function(String imagePath) onImageCaptured;
  final String buttonText;
  final Color? color;
  final bool isLoading;

  const CameraButton({
    super.key,
    required this.onImageCaptured,
    required this.buttonText,
    this.color,
    this.isLoading = false,
  });

  Future<void> _takePhoto(BuildContext context) async {
    try {
      // Validasi izin kamera melalui PermissionService (modular)
      final hasPermission = await PermissionService().ensureCameraPermission(context);
      if (!hasPermission) return;

      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 70, // Kompresi awal gambar
      );

      if (photo != null) {
        onImageCaptured(photo.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Colors.blue[600]!;

    return OutlinedButton.icon(
      onPressed: isLoading ? null : () => _takePhoto(context),
      icon: const Icon(Icons.camera_alt_rounded, size: 20),
      label: Text(
        buttonText,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: themeColor,
        side: BorderSide(color: themeColor, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
