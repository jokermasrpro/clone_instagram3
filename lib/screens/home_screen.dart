import 'package:clone_instagram/screens/chat_screen/chat_screen.dart';
import 'package:clone_instagram/screens/provider.dart';
import 'package:clone_instagram/screens/widgets/go_to_story.dart';
import 'package:clone_instagram/screens/widgets/post.dart';
import 'package:clone_instagram/screens/widgets/view_story.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void fetch_current_user() async {
    final String userUid = await FirebaseAuth.instance.currentUser!.uid;
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
  }

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.fetchuser(userid: FirebaseAuth.instance.currentUser!.uid);
    fetch_current_user();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          color: Colors.red,
          width: double.infinity,
          child: Container(
            color: Colors.black,
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Instagram",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24),
                    ),
                    // const Spacer(),
                    IconButton(
                      onPressed: () {
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (context) => ,
                        //   ),
                        // );
                      },
                      icon: Icon(
                        Icons.chat,
                        color: Colors.grey[50],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  height: 100,
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .where('stories', isNotEqualTo: [])
                          .where('followers',
                              arrayContains:
                                  FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(
                            color: Colors.pink,
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('${snapshot.error.toString()}'),
                          );
                        }
                        if (snapshot.hasData) {
                          final getData = snapshot.data!.docs;

                          return Row(
                            children: [
                              GoToStory(
                                click: () {
                                  userProvider.getuser!.stories.isNotEmpty
                                      ? Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => ViewStory(
                                              userStories:
                                                  userProvider.getuser!.stories,
                                              myUid: userProvider.getuser!.uid,
                                            ),
                                          ),
                                        )
                                      : null;
                                },
                                userImage: userProvider.getuser?.userImage,
                                userName: userProvider.getuser?.userName,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: getData.length,
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> userStories =
                                        getData[index].data();
                                    // delete story after 24 hours
                                    // FirebaseServices().deleteStoryAfter24H(
                                    //     story: userStories['stories'][index]);
                                    return GoToStory(
                                      click: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => ViewStory(
                                              userStories:
                                                  userStories['stories'],
                                              myUid: FirebaseAuth
                                                  .instance.currentUser!.uid,
                                            ),
                                          ),
                                        );
                                      },
                                      userImage:
                                          'https://i.pinimg.com/736x/f4/05/a8/f405a89b972ef01be59c662757590dd5.jpg',
                                      userName: 'Name',
                                      hideOpenStory: 'hide',
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Center(
                              child: Text(
                            "null",
                            style: TextStyle(color: Colors.red),
                          ));
                        }
                      }),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("posts")
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(
                        color: Colors.white,
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Erorr ${snapshot.error}",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    if (snapshot.hasData) {
                      return Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> postMap =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            return Post(
                              userMap: postMap,
                            );
                          },
                        ),
                      );
                    } else {
                      return Center(
                        child: Text(
                          "wating.....",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
