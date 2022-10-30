import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:login_signup_auth/core/snack_bar.dart';
import 'package:login_signup_auth/models/post.dart';

class EditPost extends StatelessWidget {
  EditPost({Key? key, required this.post}) : super(key: key);

  final Post post;

  final formKey = GlobalKey<FormState>();
  late TextEditingController bodyController;

  @override
  Widget build(BuildContext context) {
    bodyController = TextEditingController(text: post.body);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Post"),
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
                      await FirebaseFirestore.instance
                          .collection("posts")
                          .doc(post.id)
                          .update({
                        'body': bodyController.text,
                        'updated_at': FieldValue.serverTimestamp()
                      });
                      Navigator.pop(context);
                      appSnackBar(
                          context, "Your Post Have Been Updated Successfully!");
                    }
                  },
                  child: const Text("Update Post"))
            ],
          ),
        ),
      ),
    );
  }
}
