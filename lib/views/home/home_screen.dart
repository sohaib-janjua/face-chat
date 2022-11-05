import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:login_signup_auth/views/auth/login_screen.dart';
import 'package:login_signup_auth/views/home/add_post.dart';
import 'package:login_signup_auth/views/home/map_tab.dart';
import 'package:login_signup_auth/views/home/post_tab.dart';
import 'package:login_signup_auth/views/inbox/inbox_view.dart';
import '../../core/app_navigator.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  int pageIndex = 0;

  //local notifications variables
  AndroidInitializationSettings androidLNInit =
      const AndroidInitializationSettings('app_icon');

  final DarwinInitializationSettings iosLNInit = DarwinInitializationSettings(
    onDidReceiveLocalNotification: (id, title, body, payload) {},
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  late AndroidNotificationChannel channel;
  late NotificationDetails notificationDetails;
  @override
  void initState() {
    super.initState();

    channel = const AndroidNotificationChannel(
      'com.example.login_signup_auth',
      'notifications',
      description: 'This channel is used for important notifications',
      importance: Importance.high,
    );

    notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
      ),
    );

    flutterLocalNotificationsPlugin.initialize(InitializationSettings(
      android: androidLNInit,
      iOS: iosLNInit,
    ));

    FirebaseMessaging.instance.getToken().then((token) {
      FirebaseFirestore.instance.doc("users/$uid").update({
        'fcm_token': token,
      });
    });

    FirebaseMessaging.onMessage.listen((msg) {
      String title = msg.notification!.title!;
      String body = msg.notification!.body!;

      flutterLocalNotificationsPlugin.show(
        msg.hashCode,
        title,
        body,
        notificationDetails,
      );
      print("ONMESSAGE $title,$body,${msg.data.toString()}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      String title = msg.notification!.title!;
      String body = msg.notification!.body!;
      print("ONMESSAGEOPENEDAPP $title,$body,${msg.data.toString()}");
    });
  }

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
        children: [PostTab(), const MapTab(), InboxView()],
      ),
      floatingActionButton: pageIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                // appNavPush(context, const AddPostView());
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
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat,
            ),
            label: "Inbox",
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
