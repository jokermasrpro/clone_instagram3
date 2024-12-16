import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AllChatsScreen extends StatelessWidget {
  AllChatsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // custom app bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () {
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'option2') {}
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<String>(
                            value: 'option1',
                            child: Text('hide story'),
                          ),
                          PopupMenuItem<String>(
                            value: 'option2',
                            child: Text('delete story'),
                          ),
                        ];
                      },
                    );
                  },
                  child: Text(
                    "Chats",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              TextField(
                decoration: InputDecoration(
                    hintText: "search...",
                    hintStyle: TextStyle(color: Colors.grey),
                    suffixIcon:
                        IconButton(onPressed: () {}, icon: Icon(Icons.search)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey))),
              ),
              SizedBox(
                height: 10,
              ),
              StreamBuilder(
                  // FirebaseFirestore.instance
                  //           .collection("users")
                  //           .where('stories', isNotEqualTo: [])
                  //           .where('followers',
                  //               arrayContains:
                  //                   FirebaseAuth.instance.currentUser!.uid)
                  //           .snapshots(),
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('chats',
                          arrayContains: FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return ScaffoldMessenger(
                          child: SnackBar(
                              content: Text("${snapshot.error.toString()}")));
                    }

                    if (snapshot.hasData) {
                      final getUser = snapshot.data!.docs;
                      return Expanded(
                        child: ListView.builder(
                          itemCount: getUser.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> userMap =
                                snapshot.data!.docs[index].data();
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 10, right: 0, bottom: 10),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        'https://i.pinimg.com/736x/f4/05/a8/f405a89b972ef01be59c662757590dd5.jpg'),
                                    radius: 30,
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    // mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userMap[index]['userName'],
                                        style: TextStyle(
                                            fontSize: 17, color: Colors.white),
                                      ),
                                      Text(
                                        'last message',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  IconButton(
                                      onPressed: () {
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'option1') {}
                                            if (value == 'option2') {}
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return [
                                              PopupMenuItem<String>(
                                                value: 'option1',
                                                child: Text('hide story'),
                                              ),
                                              PopupMenuItem<String>(
                                                value: 'option2',
                                                child: Text('delete story'),
                                              ),
                                            ];
                                          },
                                        );
                                      },
                                      icon: Icon(Icons.more_vert)),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return Center(
                        child: Text("null"),
                      );
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
