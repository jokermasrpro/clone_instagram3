
import 'package:clone_instagram/screens/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clone_instagram/screens/features/firebase_services.dart';

class CommentScreen extends StatelessWidget {
  final String postId;
  CommentScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final commentController = TextEditingController();
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: const BackButton(
          color: Colors.white,
        ),
        title: const Text(
          "Comments",
          style: TextStyle(color: Colors.white, fontSize: 26),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postId)
                  .collection('comment')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final comments = snapshot.data?.docs ?? [];

                return Expanded(
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final commentMap =
                          comments[index].data() as Map<String, dynamic>;

                      return ListTile(
                        trailing: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                          ),
                        ),
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(commentMap['userImage']),
                        ),
                        title: Text(commentMap['userName']),
                        subtitle: Text(commentMap['comment']),
                      );
                    },
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage(userProvider.getuser!.userImage),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () async {
                            if (commentController.text.isNotEmpty) {
                              await FirebaseServices().addcomment(
                                comment: commentController.text,
                                userImage: userProvider.getuser!.userImage,
                                postId: postId,
                                uid: userProvider.getuser!.uid,
                                userName: userProvider.getuser!.userName,
                              );
                              commentController.clear();
                            }
                          },
                          icon: const Icon(
                            Icons.send,
                            size: 26,
                          ),
                        ),
                        hintText: "Enter comment",
                        hintStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
