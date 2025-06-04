import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import '../model/video_model.dart';

class HomeProvider extends ChangeNotifier {
  List<VideoModel> _videos = [];
  bool isLoading = true;

  List<VideoModel> get videos => _videos;

  HomeProvider() {
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    try {
      isLoading = true;
      notifyListeners();

      var snapshot = await FirebaseFirestore.instance.collection('videos').get();
      _videos = snapshot.docs
          .map((doc) => VideoModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching videos: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickAndUploadVideo({
    required String caption,
    required String uploaderName,
    required String uploaderImage,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);

      if (result != null) {
        File videoFile = File(result.files.single.path!);

        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('videos/$fileName')
            .putFile(videoFile);

        TaskSnapshot snapshot = await uploadTask;
        String videoUrl = await snapshot.ref.getDownloadURL();

        var docRef = await FirebaseFirestore.instance.collection('videos').add({
          'videoUrl': videoUrl,
          'caption': caption,
          'likes': [],
          'saves': [],
          'uploaderName': uploaderName,
          'uploaderImage': uploaderImage,
        });

        _videos.insert(
          0,
          VideoModel(
            id: docRef.id,
            videoUrl: videoUrl,
            caption: caption,
            likes: [],
            saves: [],
            uploaderName: uploaderName,
            uploaderImage: uploaderImage,
          ),
        );

        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error uploading video: $e");
    }
  }

  void toggleLike(VideoModel video, String userId) async {
    if (video.likes.contains(userId)) {
      video.likes.remove(userId);
    } else {
      video.likes.add(userId);
    }

    await FirebaseFirestore.instance
        .collection('videos')
        .doc(video.id)
        .update({'likes': video.likes});

    notifyListeners();
  }

  void toggleSave(VideoModel video, String userId) async {
    if (video.saves.contains(userId)) {
      video.saves.remove(userId);
    } else {
      video.saves.add(userId);
    }

    await FirebaseFirestore.instance
        .collection('videos')
        .doc(video.id)
        .update({'saves': video.saves});

    notifyListeners();
  }
}
