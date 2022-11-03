import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:login_signup_auth/views/auth/login_screen.dart';
import 'package:login_signup_auth/views/home/add_post.dart';
import 'package:login_signup_auth/views/home/map_tab.dart';
import 'package:login_signup_auth/views/home/post_tab.dart';
import '../../core/app_navigator.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  int pageIndex = 0;

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
      body: IndexedStack(
        index: pageIndex,
        children: [
          PostTab(),
          MapTab(),
        ],
      ),
      floatingActionButton: pageIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                appNavPush(context, const AddPostView());
              },
              child: const Icon(Icons.add),
            )
          : SizedBox.shrink(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: (int newIndex) {
          setState(() {
            pageIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.map,
            ),
            label: "Map",
          ),
        ],
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
