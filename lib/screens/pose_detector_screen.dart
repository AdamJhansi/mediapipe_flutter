import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/pose_utils.dart';

class PoseDetectorView extends StatefulWidget {
  final CameraDescription camera;

  const PoseDetectorView({super.key, required this.camera});

  @override
  State<PoseDetectorView> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  PoseDetector? _poseDetector;
  bool _canProcess = false;
  bool _isBusy = false;
  String? _text;
  List<CameraDescription>? cameras;
  int _cameraIndex = 0;
  
  // Optimized smoothing parameters
  Map<PoseLandmarkType, List<PoseLandmark>> _landmarkHistory = {};
  final int _historySize = 5;
  final double _confidenceThreshold = 0.7;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializePoseDetector();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      debugPrint('Camera permission denied');
    }
  }
  
  Future<void> _initializeCamera() async {
    await _requestCameraPermission();
    
    try {
      cameras = await availableCameras();
      if (cameras == null || cameras!.isEmpty) {
        debugPrint('No cameras available');
        return;
      }

      _cameraController = CameraController(
        cameras![_cameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _cameraController!.initialize().then((_) {
        if (!mounted) return;
        _cameraController!.startImageStream(_processCameraImage);
        setState(() {});
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }
  
  Future<void> _switchCamera() async {
    if (cameras == null || cameras!.isEmpty) return;
    
    _cameraIndex = (_cameraIndex + 1) % cameras!.length;
    await _cameraController?.stopImageStream();
    await _cameraController?.dispose();
    
    setState(() {
      _text = null;
      _initializeCamera();
    });
  }

  void _initializePoseDetector() async {
    final options = PoseDetectorOptions(
      model: PoseDetectionModel.accurate,
      mode: PoseDetectionMode.stream,
    );
    _poseDetector = PoseDetector(options: options);
    await Future.delayed(const Duration(milliseconds: 300));
    _canProcess = true;
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (!_canProcess || _isBusy || _cameraController == null) return;
    _isBusy = true;

    final InputImage inputImage;
    final int imageRotation = cameras![_cameraIndex].sensorOrientation;
    final InputImageRotation rotation = InputImageRotation.values.firstWhere(
      (element) => element.rawValue == imageRotation,
      orElse: () => InputImageRotation.rotation0deg,
    );
    
    try {
      if (Platform.isAndroid) {
        final WriteBuffer allBytes = WriteBuffer();
        for (Plane plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();
        
        inputImage = InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.yuv420,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );
      } else {
        inputImage = InputImage.fromBytes(
          bytes: image.planes[0].bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.bgra8888,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );
      }
    
      final poses = await _poseDetector?.processImage(inputImage);
      final imageSize = Size(image.width.toDouble(), image.height.toDouble());
      
      if (poses != null && poses.isNotEmpty) {
        final pose = poses.first;
        final Map<PoseLandmarkType, PoseLandmark> filteredLandmarks = {};
        
        pose.landmarks.forEach((type, landmark) {
          if (landmark.likelihood >= _confidenceThreshold) {
            filteredLandmarks[type] = landmark;
          }
        });
        
        final filteredPose = Pose(landmarks: filteredLandmarks);
        final smoothedPose = PoseUtils.applySmoothing(
          filteredPose, 
          _landmarkHistory,
          _historySize
        );
        
        if (mounted) {
          setState(() {
            if (filteredLandmarks.length >= 4) {
              final statusList = PoseUtils.analyzePose(smoothedPose, imageSize);
              _text = statusList.join('\n');
            } else {
              _text = 'Bergeraklah agar terdeteksi lebih baik';
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _text = 'Tidak ada pose terdeteksi';
          });
        }
      }
    } catch (e) {
      debugPrint('Error pada deteksi pose: $e');
      if (mounted) {
        setState(() {
          _text = 'Error: ${e.toString().substring(0, e.toString().length > 50 ? 50 : e.toString().length)}';
        });
      }
    }

    _isBusy = false;
  }

  @override
  void dispose() {
    _canProcess = false;
    _poseDetector?.close();
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Menginisialisasi kamera...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MediaPipe Pose Detector'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: _switchCamera,
            tooltip: 'Ganti kamera',
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CameraPreview(_cameraController!),
          // Container(
          //   color: Colors.red,
          //   // color: Colors.black.withOpacity(0.1),
          // ),
          if (_text != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _text!.split('\n').map((line) {
                      final parts = line.split(': ');
                      if (parts.length == 2) {
                        final label = parts[0];
                        final value = parts[1];
                        Color valueColor = Colors.white;
                        
                        if (value.contains('normal') || value == 'Berdiri') {
                          valueColor = Colors.green;
                        } else {
                          valueColor = Colors.orange;
                        }
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                value,
                                style: TextStyle(
                                  color: valueColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Text(
                          line,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        );
                      }
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 