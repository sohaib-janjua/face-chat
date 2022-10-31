import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_signup_auth/core/snack_bar.dart';
import 'package:login_signup_auth/models/post.dart';

class AddPostView extends StatefulWidget {
  AddPostView({Key? key}) : super(key: key);

  @override
  State<AddPostView> createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  final formKey = GlobalKey<FormState>();

  final bodyController = TextEditingController();

  File? image;

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
              GestureDetector(
                onTap: () async {
                  var picker = ImagePicker();
                  XFile? pickedImage =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    image = File(pickedImage.path);
                    setState(() {});
                  }
                },
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: image == null
                      ? Center(child: Text("Select Image"))
                      : Image.file(image!),
                ),
              ),
              SizedBox(
                height: 10,
              ),
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
