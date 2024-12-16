import 'package:clone_instagram/screens/comment_screen.dart';
import 'package:clone_instagram/screens/features/firebase_services.dart';
import 'package:clone_instagram/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Post extends StatelessWidget {
  final Map<String, dynamic> userMap;
  Post({super.key, required this.userMap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // color: Colors.red,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    userUID: userMap['uid'],
                  ),
                ),
              );
            },
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(userMap['userImage']),
                  radius: 25,
                ),
                SizedBox(width: 15),
                Text(
                  userMap['userName'],
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Visibility(

                  visible: 
                      userMap['uid'] == FirebaseAuth.instance.currentUser!.uid
                          ? true
                          : false,
                  child: IconButton(
                    onPressed: () {
                      FirebaseServices().deletePost(postDelete: userMap);
                    },
                    icon: Icon(Icons.delete,color: Color(0xffff0000),),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Image.network(
            userMap['imagePost'],
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  FirebaseServices().addPost(postMap: userMap);
                },
                icon: Icon(
                  Icons.favorite,
                  color: userMap['likes']
                          .contains(FirebaseAuth.instance.currentUser!.uid)
                      ? Colors.red
                      : Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CommentScreen(
                            postId: userMap['postId'],
                          )));
                },
                icon: const Icon(
                  Icons.comment,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            "${userMap['likes'].length} likes",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          Text(
            userMap['des'],
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          TextButton(
              onPressed: () {},
              child: const Text(
                "Add comment",
                style: TextStyle(color: Colors.grey),
              )),
           Text(
            DateFormat.MMMEd().format(userMap['time'].toDate()),
            style: TextStyle(color: Colors.white, fontSize: 16),
          )
        ],
      ),
    );
  }
}
