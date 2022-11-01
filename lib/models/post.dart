import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String? id;
  final String userId;
  final String body;
  final int comments;
  final int likes;
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
      likes: 0,
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
      'user_id': userId,
      'comments': comments,
      'likes': likes,
      'created_at': FieldValue.serverTimestamp(),
      'image': image,
    };
  }
}
