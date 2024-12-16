// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class ChatScreen extends StatefulWidget {
//   final String uid;
//   ChatScreen({super.key, required this.uid});
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   void _sendMessage() async {
//     if (_messageController.text.isNotEmpty) {
//       final user = _auth.currentUser;
//       await FirebaseFirestore.instance
//           .collection('chatsUsers')
//           .doc(widget.uid)
//           .update({
//         'myId': user?.uid,
//         'frindId': widget.uid,
//         'text': _messageController.text,
//         'createdAt': Timestamp.now(),
//       });
//       _messageController.clear();
//     }
//   }
//   late final chatfond;
//   Future<void> fetchChatIdIfExists(String uid) async {
//     try {
//       // جلب المستندات بناءً على الشرط
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .collection('chats')
//           .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         for (var doc in querySnapshot.docs) {
//           final chatfond =
//               doc['chatId']; // افتراضًا أن الحقل chatId موجود في المستند
//           print('تم العثور على chatId: $chatfond');
//         }
//       } else {
//         print('لا توجد محادثات متطابقة.');
//       }
//     } catch (e) {
//       print('حدث خطأ أثناء الجلب: $e');
//     }
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     fetchChatIdIfExists(widget.uid);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           "Chat",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder(
//               stream: FirebaseFirestore.instance
//                   .collection('cahtsUsers')
//                   .doc(chatfond).snapshots(),

//               builder: (ctx, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//                 final chatDocs = snapshot.data!;
//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: chatDocs.length,
//                   itemBuilder: (ctx, index) => ListTile(
//                     title: Row(
//                       children: [
//                         Container(
//                             alignment: chatDocs == _auth.currentUser!.uid
//                                 ? Alignment.centerLeft
//                                 : Alignment.centerRight,
//                             padding: EdgeInsets.symmetric(
//                                 vertical: 8, horizontal: 15),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(50),
//                               color: chatDocs == _auth.currentUser!.uid
//                                   ? Colors.grey[850]
//                                   : Colors.blue,
//                               // gradient: LinearGradient(
//                               //   begin: AlignmentDirectional(0, 1),
//                               //   colors: chatDocs == _auth.currentUser!.uid
//                               //       ? [
//                               //           const Color.fromARGB(255, 13, 114, 197),
//                               //           const Color.fromARGB(255, 139, 40, 253)
//                               //         ]
//                               //       : null,
//                               // ),
//                             ),
//                             child: Text(
//                               chatDocs[index]['text'],
//                               style: TextStyle(color: Colors.white),
//                             )),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     cursorColor: Colors.blue,
//                     controller: _messageController,
//                     style: TextStyle(color: Colors.white),
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                       hintStyle: TextStyle(
//                         color: Colors.grey,
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: BorderSide(color: Colors.grey),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: BorderSide(color: Colors.grey),
//                       ),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           Icons.send,
//                           color: Colors.grey,
//                         ),
//                         onPressed: _sendMessage,
//                       ),
//                       prefixIcon: IconButton(
//                         onPressed: () {},
//                         icon: Icon(
//                           Icons.image,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:clone_instagram/screens/features/firebase_services.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  final String uid;
  ChatScreen({super.key, required this.uid});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? chatId; // لتخزين chatId بمجرد الحصول عليه

  @override
  void initState() {
    super.initState();
    fetchChatIdIfExists(widget.uid);
  }

  Future<void> fetchChatIdIfExists(String uid) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chats')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          chatId = querySnapshot.docs.first['chatId'];
        });
        print('تم العثور على chatId: $chatId');
      } else {
        print('لا توجد محادثات متطابقة.');
      }
    } catch (e) {
      print('حدث خطأ أثناء الجلب: $e');
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty && chatId != null) {
      final user = _auth.currentUser;
      if (chatId == null) {
        final uuid = Uuid().v4();
        FirebaseServices().addChatFrind(cahtid: uuid, userid: widget.uid);
      } else {
        await FirebaseFirestore.instance
            .collection('chatsUsers')
            .doc(chatId) // استخدام chatId هنا
            .collection('messages') // إنشاء مجموعة للرسائل
            .add({
          'userId': user?.uid,
          'text': _messageController.text,
          'createdAt': Timestamp.now(),
        });
        _messageController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Chat",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatId == null
                ? Center(child: Text('start message'))
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('chatsUsers')
                        .doc(chatId)
                        .collection('messages')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('لا توجد رسائل حتى الآن'));
                      }
                      final chatDocs = snapshot.data!.docs;

                      return ListView.builder(
                        reverse: true,
                        itemCount: chatDocs.length,
                        itemBuilder: (ctx, index) => ListTile(
                          title: Align(
                            alignment: chatDocs[index]['userId'] ==
                                    _auth.currentUser!.uid
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: chatDocs[index]['userId'] ==
                                        _auth.currentUser!.uid
                                    ? Colors.blue
                                    : Colors.grey[850],
                              ),
                              child: Text(
                                chatDocs[index]['text'],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    cursorColor: Colors.blue,
                    controller: _messageController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: () {
                            final uuid = Uuid().v4();
                            FirebaseServices()
                                .addChatFrind(cahtid: uuid, userid: widget.uid);
                          },
                          icon: Icon(Icons.add)),
                      hintText: 'Type a message...',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
