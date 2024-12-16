import 'package:clone_instagram/screens/add_story.dart';
import 'package:clone_instagram/screens/chat_screen/chat_screen.dart';
import 'package:clone_instagram/screens/features/firebase_services.dart';
import 'package:clone_instagram/screens/provider.dart';
import 'package:clone_instagram/screens/widgets/view_image.dart';
import 'package:clone_instagram/screens/widgets/view_story.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.userUID});
  final String userUID;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late List following;
  bool isloading = false;
  late bool inFolloing = false;
  late int countPosts = 0;

  void fetch_current_user() async {
    setState(() {
      isloading = true;
    });
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    var snapPosts = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: widget.userUID)
        .get();

    countPosts = snapPosts.docs.length;
    following = snapshot.data()!['following'];

    setState(() {
      inFolloing = following.contains(widget.userUID);
    });
  }

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.getuser!.stories.forEach((element) {
      FirebaseServices().deleteStoryAfter24H(story: element);
    });
    userProvider.fetchuser(userid: widget.userUID);
    fetch_current_user();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.getuser == null) {
      return Scaffold(
        body: Center(
            child: CircularProgressIndicator(
          color: Colors.white,
        )),
      );
    }

    if (userProvider.getuser == null) {
      return Scaffold(
        body: Center(
            child: CircularProgressIndicator(
          color: Colors.grey,
        )),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${userProvider.getuser!.userName}",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        leading: FirebaseAuth.instance.currentUser!.uid == widget.userUID
            ? Text("")
            : BackButton(),
        actions: [
          Padding(
            padding: EdgeInsets.all(8),
            child: FirebaseAuth.instance.currentUser!.uid == widget.userUID
                ? null
                : IconButton(
                    onPressed: () {
                  
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => ChatScreen(uid: widget.userUID,),),);
                    },
                    icon: Icon(Icons.chat)),
          )
        ],
      ),
      body: isloading == false
          ? CircularProgressIndicator()
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ViewStory(
                                      userStories:
                                          userProvider.getuser!.stories,
                                      myUid: userProvider.getuser!.uid,
                                    ),
                                  ),
                                );
                              },
                              onLongPress: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          userProvider.getuser!.userImage),
                                      radius: 50,
                                    );
                                  },
                                );
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: userProvider
                                                  .getuser!.stories.isNotEmpty
                                              ? Colors.pink
                                              : Colors.transparent,
                                          width: 2),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                            userProvider.getuser!.userImage,
                                          )),
                                    ),
                                  ),
                                  Positioned(
                                    top: 40,
                                    left: 40,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => AddStory(),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              userProvider.getuser!.userName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              countPosts.toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Posts",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "${userProvider.getuser!.followers.length}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Followers",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "${userProvider.getuser!.following.length}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Following",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              FirebaseAuth.instance.currentUser!.uid ==
                                      userProvider.getuser!.uid
                                  ? Colors.grey[900]
                                  : inFolloing == true
                                      ? Colors.grey[900]
                                      : Colors.blue),
                        ),
                        onPressed: () async {
                          if (inFolloing == true) {
                            FirebaseServices().unfollow(userid: widget.userUID);
                            setState(() {
                              inFolloing = false;
                              userProvider.decrease_followers();
                            });

                            return;
                          } else {
                            setState(() {
                              inFolloing = true;
                              userProvider.increase_followers();
                            });
                            FirebaseServices().follow(userid: widget.userUID);
                          }
                        },
                        child: Text(
                          FirebaseAuth.instance.currentUser!.uid ==
                                  userProvider.getuser!.uid
                              ? "Edit Profile"
                              : inFolloing == true
                                  ? "unFollowe"
                                  : "Follow",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Expanded(
                      child: FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('posts')
                              .where('uid', isEqualTo: widget.userUID)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child:
                                    Text("Error: ${snapshot.error.toString()}"),
                              );
                            }
                            if (snapshot.hasData) {
                              return GridView.count(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                crossAxisCount: 3,
                                children: List.generate(
                                    snapshot.data!.docs.length, (index) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) => ViewImage(
                                                  image:
                                                      snapshot.data!.docs[index]
                                                          ['imagePost'])));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Image(
                                        image: NetworkImage(snapshot
                                            .data!.docs[index]['imagePost']),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }),
                              );
                            } else {
                              return const Center(
                                  child: Text("No posts available"));
                            }
                          }),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
