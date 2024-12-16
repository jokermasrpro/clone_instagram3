import 'package:clone_instagram/screens/add_post.dart';
import 'package:clone_instagram/screens/home_screen.dart';
import 'package:clone_instagram/screens/profile_screen.dart';
import 'package:clone_instagram/screens/provider.dart';
import 'package:clone_instagram/screens/search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ButtonNav extends StatefulWidget {
  const ButtonNav({super.key});

  @override
  State<ButtonNav> createState() => _ButtonNavState();
}

class _ButtonNavState extends State<ButtonNav> {
  int selected = 0;

  void selectpage(int index) {
    setState(() {
      selected = index;
    });
  }

  final List pageList = [
    const HomeScreen(),
    const SearchScreen(),
    const AddPost(),
     ProfileScreen(userUID: FirebaseAuth.instance.currentUser!.uid,)
  ];

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final userprovider = Provider.of<UserProvider>(context);
    return Scaffold(
      body: pageList[selected],
      bottomNavigationBar: BottomNavigationBar(
          enableFeedback: false,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.white,
          selectedFontSize: 16,
          unselectedFontSize: 11,
          backgroundColor: Colors.black,
          currentIndex: selected,
          type: BottomNavigationBarType.fixed,
          onTap: selectpage,
          items: [
            const BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  size: 26,
                ),
                label: 'Home'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.search, size: 26),
                label: 'Search',
                backgroundColor: Colors.black),
            const BottomNavigationBarItem(
                icon: Icon(Icons.add, size: 26), label: 'Add Post'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_3), label: 'Profile'),
          ]),
    );
  }
}
