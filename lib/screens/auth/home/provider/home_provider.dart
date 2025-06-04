import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../model/video_model.dart';

class HomeProvider extends ChangeNotifier {
  List<VideoModel> _videos = [];
  bool isLoading = true;

  List<VideoModel> get videos => _videos;

  HomeProvider() {
    fetchVideos();
  }

  // Fetch videos from Firestore
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

  // Pick video, upload to storage, save metadata to Firestore
  Future<void> pickAndUploadVideo(String caption) async {
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

        // Save to Firestore
        var docRef = await FirebaseFirestore.instance.collection('videos').add({
          'videoUrl': videoUrl,
          'caption': caption,
          'likes': 0,
        });

        // Add to local list
        // _videos.insert(
        //   0,
        //   VideoModel(
        //     id: docRef.id,
        //     videoUrl: videoUrl,
        //     caption: caption,
        //   ),
        // );

        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error uploading video: $e");
    }
  }

  // Like/Unlike video
  void toggleLike(VideoModel video) async {
    video.isLiked = !video.isLiked;
    //video.likes += video.isLiked ? 1 : -1;

    await FirebaseFirestore.instance
        .collection('videos')
        .doc(video.id)
        .update({'likes': video.likes});

    notifyListeners();
  }

  // Save/Unsave video locally (not in database)
  void toggleSave(VideoModel video) {
    video.isSaved = !video.isSaved;
    notifyListeners();
  }
}
