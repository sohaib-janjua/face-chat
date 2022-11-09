import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:login_signup_auth/core/app_navigator.dart';
import 'package:login_signup_auth/views/video_rooms/video_room_view.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoRoomTab extends StatelessWidget {
  const VideoRoomTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    ...snapshot.data!.docs
                        .map((e) => InkWell(
                              onTap: () async {
                                await Permission.camera.request();
                                await Permission.microphone.request();
                                appNavPush(context, VideoRoomView(room: e));
                              },
                              child: Material(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                color: Colors.blue.shade100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      child:
                                          Text(e.data()['name'][0].toString()),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(e.data()['name']),
                                  ],
                                ),
                              ),
                            ))
                        .toList()
                  ],
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }
}
