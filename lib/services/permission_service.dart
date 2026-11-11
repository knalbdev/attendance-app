import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service modular untuk mengelola izin (permissions) aplikasi.
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Memeriksa status izin kamera saat ini.
  Future<PermissionStatus> getCameraStatus() async {
    return await Permission.camera.status;
  }

  /// Meminta izin kamera secara langsung.
  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  /// Meminta izin kamera di awal saat halaman dimuat (jika belum diizinkan).
  Future<void> requestCameraPermissionOnInit({BuildContext? context}) async {
    final status = await Permission.camera.status;

    // Jika belum pernah diminta atau statusnya denied, minta izin ke sistem
    if (!status.isGranted && !status.isPermanentlyDenied) {
      await Permission.camera.request();
    }
  }

  /// Memastikan izin kamera aktif sebelum mengambil foto.
  /// Menampilkan dialog/snackbar jika pengguna menolak atau blokir permanen.
  Future<bool> ensureCameraPermission(BuildContext context) async {
    var status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    // Jika belum diizinkan, minta izin
    if (status.isDenied) {
      status = await Permission.camera.request();
      if (status.isGranted) {
        return true;
      }
    }

    if (!context.mounted) return false;

    // Jika diblokir secara permanen oleh sistem
    if (status.isPermanentlyDenied) {
      showPermissionSettingsDialog(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin kamera diperlukan untuk mengambil foto absensi.'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    return false;
  }

  /// Menampilkan dialog edukatif untuk mengarahkan pengguna ke pengaturan perangkat.
  void showPermissionSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Izin Kamera Diperlukan'),
        content: const Text(
          'Aplikasi memerlukan izin kamera untuk mengambil foto absensi. '
          'Silakan aktifkan izin kamera melalui Pengaturan aplikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }
}

