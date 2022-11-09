import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class VideoRoomView extends StatefulWidget {
  const VideoRoomView({super.key, required this.room});

  final QueryDocumentSnapshot<Map<String, dynamic>> room;

  @override
  State<VideoRoomView> createState() => _VideoRoomViewState();
}

class _VideoRoomViewState extends State<VideoRoomView> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  late String channelName;
  late String token;
  String appId = "40484308aee64ff084aa128772d2c7bb";

  @override
  void initState() {
    super.initState();

    channelName = widget.room.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: []),
    );
  }
}
