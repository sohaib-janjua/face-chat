import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_signup_auth/core/functions.dart';
import 'package:login_signup_auth/core/snack_bar.dart';
import 'package:login_signup_auth/models/post.dart';

class AddPostView extends StatefulWidget {
  const AddPostView({Key? key}) : super(key: key);

  @override
  State<AddPostView> createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  final formKey = GlobalKey<FormState>();

  final bodyController = TextEditingController();

  File? image;

  void selectImage(ImageSource source) async {
    var picker = ImagePicker();
    XFile? pickedImage = await picker.pickImage(source: source);
    if (pickedImage != null) {
      image = File(pickedImage.path);
      setState(() {});
    }
  }

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
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(color: Colors.grey.shade200),
                child: image == null
                    ? const Center(child: Text("Select Image"))
                    : Image.file(image!),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      selectImage(ImageSource.gallery);
                    },
                    icon: const Icon(Icons.image),
                  ),
                  IconButton(
                    onPressed: () {
                      selectImage(ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera),
                  )
                ],
              ),
              const SizedBox(
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
                    return "Please enter Something!";
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
                      //Image must be selected
                      //Firebase Storage(create a new file)
                      //Data Upload
                      //When Upload done
                      //Get the public link

                      if (image == null) {
                        appSnackBar(context, "Please Select Image");
                        return;
                      }
                      String link = await appUploadImage(image!);

                      Post post = Post.create(
                        body: bodyController.text,
                        userId: FirebaseAuth.instance.currentUser!.uid,
                        image: link,
                      );

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
