import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:login_signup_auth/core/snack_bar.dart';
import 'package:login_signup_auth/models/post.dart';

class AddPostView extends StatelessWidget {
  AddPostView({Key? key}) : super(key: key);

  final formKey = GlobalKey<FormState>();
  final bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Post"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: bodyController,
                decoration: InputDecoration(
                    labelText: "What's on your mind?",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                maxLines: 5,
                validator: (String? v) {
                  if (v == null || v.isEmpty) {
                    return "Please nter Something!";
                  } else if (v.length < 5) {
                    return "Please enter atleast 5 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      Post post = Post.create(body: bodyController.text);

                      await FirebaseFirestore.instance
                          .collection("posts")
                          .doc()
                          .set(post.toJson());
                      Navigator.pop(context);
                      appSnackBar(
                          context, "Your Post Have Been Created Successfully!");
                    }
                  },
                  child: const Text("Save Post"))
            ],
          ),
        ),
      ),
    );
  }
}
