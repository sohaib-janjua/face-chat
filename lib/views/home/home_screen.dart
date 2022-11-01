import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_signup_auth/models/post.dart';
import 'package:login_signup_auth/views/auth/login_screen.dart';
import 'package:login_signup_auth/views/home/add_post.dart';
import 'package:login_signup_auth/views/home/edit_post.dart';
import '../../core/app_navigator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
              onPressed: () {
                logout(context);
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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

                    return FutureBuilder<
                            DocumentSnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .doc(
                                "users/${snapshot.data!.docs[index].data()['user_id']}")
                            .get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return Center(
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
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            userSnapshot.data!.data()!['image'],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            userSnapshot.data!.data()!['name']),
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
                                                        Text(
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
                                                              child: Text("No"),
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
                                                              child:
                                                                  Text("Yes"),
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
                                    if (post.image != null)
                                      Image.network(post.image!),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(post.body),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(post.likes.toString()),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.thumb_up_alt),
                                              onPressed: () {
                                                snapshot
                                                    .data!.docs[index].reference
                                                    .update({
                                                  'likes':
                                                      FieldValue.increment(1)
                                                });
                                              },
                                            )
                                          ],
                                        ),
                                        Text("${post.comments} Comments"),
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
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          appNavPush(context, AddPostView());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    appNavReplace(context, LoginScreen());

    // Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
}
