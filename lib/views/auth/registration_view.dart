import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_signup_auth/core/app_navigator.dart';
import 'package:login_signup_auth/core/functions.dart';
import 'package:login_signup_auth/core/snack_bar.dart';
import 'package:login_signup_auth/views/home/home_screen.dart';

class RegistrationView extends StatefulWidget {
  const RegistrationView({super.key});

  @override
  State<RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  final addressController = TextEditingController();
  final nameController = TextEditingController();

  bool isBusy = false;

  final formKey = GlobalKey<FormState>();

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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: formKey,
          child: Stack(
            children: [
              Column(
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
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      label: Text('Name'),
                    ),
                    validator: (String? v) {
                      if (v == null || v.isEmpty) {
                        return "Please enter Name";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      label: Text('Address'),
                    ),
                    validator: (String? v) {
                      if (v == null || v.isEmpty) {
                        return "Please enter Address";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        if (formKey.currentState!.validate()) {
                          if (image == null) {
                            appSnackBar(
                                context, "Please select Profile Picture");
                            return;
                          }

                          setState(() {
                            isBusy = true;
                          });

                          String path = await appUploadImage(image!);

                          String userId =
                              FirebaseAuth.instance.currentUser!.uid;
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .set({
                            'address': addressController.text,
                            'name': nameController.text,
                            'image': path,
                          });
                          setState(() {
                            isBusy = false;
                          });
                          appNavPopAndPush(context, HomeScreen());
                        }
                      } catch (e) {
                        appSnackBar(context, e.toString());
                      }
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
              Visibility(
                visible: isBusy,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                    ),
                    child: const CircularProgressIndicator(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
