import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Post {
  final String? id;
  final String body;
  final int comments;
  final int likes;
  final DateTime createdAt;
  String? image;

  Post({
    this.id,
    required this.body,
    required this.comments,
    required this.likes,
    required this.createdAt,
    this.image,
  });

  factory Post.create({
    required body,
    String? image,
  }) {
    return Post(
      body: body,
      comments: 0,
      likes: 0,
      createdAt: DateTime.now(),
      image: image,
    );
  }

  factory Post.fromJson(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Post(
      id: snapshot.id,
      body: snapshot.data()['body'],
      comments: snapshot.data()['comments'],
      likes: snapshot.data()['likes'],
      createdAt: snapshot.data()['created_at'] == null
          ? DateTime.now()
          : snapshot.data()['created_at'].toDate(),
      image: snapshot.data()['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'body': body,
      'comments': comments,
      'likes': likes,
      'created_at': FieldValue.serverTimestamp(),
      'image': image,
    };
  }
}
