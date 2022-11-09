import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:login_signup_auth/models/message.dart';
import 'package:http/http.dart' as http;

class ChatView extends StatelessWidget {
  ChatView({super.key, required this.chatId, required this.userId});

  final String chatId;

  final formKey = GlobalKey<FormState>();
  final msgTextController = TextEditingController();

  final authId = FirebaseAuth.instance.currentUser!.uid;

  final String userId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .doc("inbox/$chatId")
                .collection("msgs")
                .orderBy(
                  'created_at',
                  descending: true,
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var msg =
                        Message.fromJson(snapshot.data!.docs[index].data());
                    bool isMineMsg = msg.sendBy == authId;
                    return Row(
                      mainAxisAlignment: isMineMsg
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: isMineMsg
                                  ? Colors.blue.shade100
                                  : Colors.green.shade100),
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Column(
                            crossAxisAlignment: isMineMsg
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(msg.message),
                              SizedBox(
                                height: 2,
                              ),
                              Text(
                                msg.createdAt.toString().substring(10, 16),
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  },
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          )),
          Row(
            children: [
              Expanded(
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: msgTextController,
                    validator: (String? msg) {
                      if (msg == null || msg.isEmpty) {
                        return "Please enter Message";
                      }
                      return null;
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("inbox")
                      .doc(chatId)
                      .collection("msgs")
                      .doc()
                      .set({
                    "message": msgTextController.text,
                    "created_at": FieldValue.serverTimestamp(),
                    "send_by": authId,
                  });

                  await FirebaseFirestore.instance
                      .collection("inbox")
                      .doc(chatId)
                      .update({
                    "last_message": msgTextController.text,
                    "last_message_time": FieldValue.serverTimestamp(),
                  });

                  String? token;
                  var user = await FirebaseFirestore.instance
                      .doc("users/$userId")
                      .get();
                  if (user.exists) {
                    token = user.data()!['fcm_token'];
                  }
                  if (token != null) {
                    Response res = await http.post(
                        Uri.parse(
                            'https://fcm.googleapis.com/v1/projects/emailpasswordauth-8b4bf/messages:send'),
                        headers: {
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: jsonEncode({
                          'token': token,
                          'data': {'screen': 'chat', 'user': authId},
                          'notification': {
                            'title': 'New Message',
                            'body': msgTextController.text,
                          },
                        }));

                    print(res.statusCode);
                  }

                  msgTextController.clear();
                },
                icon: Icon(Icons.send),
              ),
            ],
          )
        ],
      ),
    );
  }
}
