import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Kelas untuk utilitas terkait pose detection
class PoseUtils {
  // Static list of required keypoints for different analyses
  static const List<PoseLandmarkType> handKeypoints = [
    PoseLandmarkType.leftWrist, 
    PoseLandmarkType.rightWrist,
    PoseLandmarkType.leftShoulder,
    PoseLandmarkType.rightShoulder
  ];
  
  static const List<PoseLandmarkType> squatKeypoints = [
    PoseLandmarkType.leftKnee, 
    PoseLandmarkType.rightKnee,
    PoseLandmarkType.leftHip,
    PoseLandmarkType.rightHip
  ];
  
  /// Memeriksa apakah semua keypoint yang diperlukan tersedia
  static bool hasKeypoints(Pose pose, List<PoseLandmarkType> types) {
    for (final type in types) {
      final landmark = pose.landmarks[type];
      if (landmark == null || landmark.likelihood < 0.5) {
        return false;
      }
    }
    return true;
  }

  /// Menganalisis pose dan mengembalikan daftar status
  static List<String> analyzePose(Pose pose, Size imageSize) {
    List<String> statusList = [];
    
    // Analyze hand positions
    if (hasKeypoints(pose, handKeypoints)) {
      final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist]!;
      final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist]!;
      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder]!;
      final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder]!;
      
      bool leftHandRaised = leftWrist.y < leftShoulder.y;
      bool rightHandRaised = rightWrist.y < rightShoulder.y;
      
      if (leftHandRaised && rightHandRaised) {
        statusList.add('Gerakan: Kedua tangan terangkat');
      } else if (leftHandRaised) {
        statusList.add('Gerakan: Tangan kiri terangkat');
      } else if (rightHandRaised) {
        statusList.add('Gerakan: Tangan kanan terangkat');
      } else {
        statusList.add('Gerakan: Tangan normal');
      }
    }
    
    // Analyze squat position
    if (hasKeypoints(pose, squatKeypoints)) {
      final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee]!;
      final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee]!;
      final leftHip = pose.landmarks[PoseLandmarkType.leftHip]!;
      final rightHip = pose.landmarks[PoseLandmarkType.rightHip]!;
      
      // Calculate knee-hip distance ratio for better squat detection
      double leftRatio = (leftKnee.y - leftHip.y) / imageSize.height;
      double rightRatio = (rightKnee.y - rightHip.y) / imageSize.height;
      double avgRatio = (leftRatio + rightRatio) / 2;
      
      if (avgRatio > 0.15) { // Adjusted threshold for better accuracy
        statusList.add('Posisi: Berdiri');
      } else {
        statusList.add('Posisi: Jongkok');
      }
    }
    
    if (statusList.isEmpty) {
      statusList.add('Bergeraklah agar terdeteksi lebih baik');
    }
    
    return statusList;
  }
  
  /// Menerapkan smoothing pada pose dengan algoritma yang dioptimalkan
  static Pose applySmoothing(
    Pose currentPose, 
    Map<PoseLandmarkType, List<PoseLandmark>> landmarkHistory,
    int historySize
  ) {
    if (currentPose.landmarks.isEmpty) {
      return currentPose;
    }
    
    final Map<PoseLandmarkType, PoseLandmark> smoothedLandmarks = {};
    final Map<PoseLandmarkType, List<PoseLandmark>> history = Map.from(landmarkHistory);
    
    currentPose.landmarks.forEach((type, landmark) {
      if (!history.containsKey(type)) {
        history[type] = [];
      }
      
      history[type]!.add(landmark);
      
      if (history[type]!.length > historySize) {
        history[type]!.removeAt(0);
      }
      
      if (history[type]!.isNotEmpty) {
        // Optimized weighted average calculation
        double sumX = 0, sumY = 0, sumZ = 0, totalWeight = 0;
        final length = history[type]!.length;
        
        for (int i = 0; i < length; i++) {
          final hist = history[type]![i];
          // Exponential weight decay for smoother transitions
          final weight = math.exp(-(length - i - 1) * 0.5) * hist.likelihood;
          
          sumX += hist.x * weight;
          sumY += hist.y * weight;
          sumZ += hist.z * weight;
          totalWeight += weight;
        }
        
        if (totalWeight > 0) {
          smoothedLandmarks[type] = PoseLandmark(
            type: type,
            x: sumX / totalWeight,
            y: sumY / totalWeight,
            z: sumZ / totalWeight,
            likelihood: landmark.likelihood,
          );
        } else {
          smoothedLandmarks[type] = landmark;
        }
      } else {
        smoothedLandmarks[type] = landmark;
      }
    });
    
    return Pose(landmarks: smoothedLandmarks);
  }
} 