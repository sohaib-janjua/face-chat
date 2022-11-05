import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_signup_auth/core/app_navigator.dart';
import 'package:login_signup_auth/models/post.dart';
import 'package:login_signup_auth/views/auth/profile_view.dart';
import 'package:login_signup_auth/views/home/edit_post.dart';

class PostTab extends StatelessWidget {
  PostTab({Key? key}) : super(key: key);

  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection("posts")
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                Post post = Post.fromJson(snapshot.data!.docs[index]);

                return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future: FirebaseFirestore.instance
                        .doc(
                            "users/${snapshot.data!.docs[index].data()['user_id']}")
                        .get(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Material(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    appNavPush(
                                        context,
                                        ProfileView(
                                          user: userSnapshot.data!.data()!,
                                          uid: userSnapshot.data!.id,
                                        ));
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 35,
                                            width: 35,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: CachedNetworkImage(
                                                imageUrl: userSnapshot.data!
                                                    .data()!['image'],
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(userSnapshot.data!
                                              .data()!['name']),
                                        ],
                                      ),
                                      if (post.userId == uid)
                                        PopupMenuButton(
                                          tooltip: "User Menu",
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 0,
                                              child: Text("Edit"),
                                            ),
                                            const PopupMenuItem(
                                              value: 1,
                                              child: Text("Delete"),
                                            )
                                          ],
                                          onSelected: (int v) {
                                            if (v == 0) {
                                              appNavPush(
                                                  context,
                                                  EditPost(
                                                    post: post,
                                                  ));
                                            } else if (v == 1) {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Dialog(
                                                      child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Text(
                                                            "Are you sure you want to delete this post?"),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                  "No"),
                                                            ),
                                                            TextButton(
                                                              onPressed:
                                                                  () async {
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "posts")
                                                                    .doc(
                                                                        post.id)
                                                                    .delete();
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                  "Yes"),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ));
                                                },
                                              );
                                            }
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                                if (post.image != null)
                                  CachedNetworkImage(
                                    imageUrl: post.image!,
                                    height: 250,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(post.body),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          post.likes.length.toString(),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        IconButton(
                                            icon: Icon(
                                              Icons.thumb_up_alt,
                                              color: post.isLiked
                                                  ? Colors.blue
                                                  : Colors.black,
                                            ),
                                            onPressed: () {
                                              snapshot
                                                  .data!.docs[index].reference
                                                  .update({
                                                'likes': post.isLiked
                                                    ? FieldValue.arrayRemove(
                                                        [uid])
                                                    : FieldValue.arrayUnion(
                                                        [uid])
                                              });
                                            })
                                      ],
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          showComments(context, post);
                                        },
                                        child:
                                            Text("${post.comments} Comments")),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              });
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future showComments(BuildContext context, Post post) async {
    final commentFormKey = GlobalKey<FormState>();
    final commentController = TextEditingController();

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Form(
              key: commentFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('comments')
                        .where('post_id', isEqualTo: post.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const CircleAvatar(),
                                title: const Text("Username"),
                                subtitle: Text(
                                  snapshot.data!.docs[index].data()['comment'],
                                ),
                              );
                            });
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  )),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextFormField(
                          controller: commentController,
                          validator: (String? v) {
                            if (v == null || v.isEmpty) {
                              return "Please enter comment";
                            }
                            return null;
                          },
                        )),
                        const SizedBox(
                          width: 5,
                        ),
                        IconButton(
                            onPressed: () async {
                              if (commentFormKey.currentState!.validate()) {
                                await FirebaseFirestore.instance
                                    .collection("comments")
                                    .doc()
                                    .set({
                                  'post_id': post.id,
                                  'user_id': uid,
                                  'comment': commentController.text,
                                  'created_at': FieldValue.serverTimestamp()
                                });

                                await FirebaseFirestore.instance
                                    .collection("posts")
                                    .doc(post.id)
                                    .update(
                                  {
                                    'comments': FieldValue.increment(1),
                                  },
                                );
                                commentController.clear();
                              }
                            },
                            icon: const Icon(
                              Icons.send,
                            ))
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
