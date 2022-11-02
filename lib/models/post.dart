import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Post {
  final String? id;
  final String userId;
  final String body;
  final int comments;
  final List<String> likes;
  final DateTime createdAt;
  String? image;

  Post({
    this.id,
    required this.body,
    required this.userId,
    required this.comments,
    required this.likes,
    required this.createdAt,
    this.image,
  });

  factory Post.create({
    required body,
    String? image,
    required String userId,
  }) {
    return Post(
      body: body,
      userId: userId,
      comments: 0,
      likes: [],
      createdAt: DateTime.now(),
      image: image,
    );
  }

  factory Post.fromJson(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Post(
      id: snapshot.id,
      userId: snapshot.data()['user_id'],
      body: snapshot.data()['body'],
      comments: snapshot.data()['comments'],
      likes: List.from(snapshot.data()['likes']),
      createdAt: snapshot.data()['created_at'] == null
          ? DateTime.now()
          : snapshot.data()['created_at'].toDate(),
      image: snapshot.data()['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'body': body,
      'user_id': userId,
      'comments': comments,
      'likes': likes,
      'created_at': FieldValue.serverTimestamp(),
      'image': image,
    };
  }

  bool get isLiked => likes.contains(FirebaseAuth.instance.currentUser!.uid);
}
