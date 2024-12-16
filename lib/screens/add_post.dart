import 'dart:convert';
import 'dart:io';
import 'package:clone_instagram/screens/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clone_instagram/shard/widgets/button_nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  late VideoPlayerController videoPlayerController;
  final String apiKey = '4f583d1e868a139e8a60dbd4b10b9cb9';
  File? selectedImage;
  String? exportUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Not selected image")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erorr on uploading $e")));
    }
  }

  Future<void> uploadImageToImgBB() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Image not found")));
      return;
    }

    try {
      String base64Image = base64Encode(selectedImage!.readAsBytesSync());
      String url = 'https://api.imgbb.com/1/upload';

      Map<String, String> body = {
        'key': apiKey,
        'image': base64Image,
      };

      final response = await http.post(Uri.parse(url), body: body);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        String imageUrl = jsonResponse['data']['url'];
        exportUrl = imageUrl;
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Done'),
        ));
      } else {
        print('فشل رفع الصورة: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('حدث خطأ أثناء رفع الصورة: $e');
    }
  }

   @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.fetchuser( userid: FirebaseAuth.instance.currentUser!.uid);
  }
  @override
  Widget build(BuildContext context) {
    final desController = TextEditingController();
    final userprovider = Provider.of<UserProvider>(context);

    void pushPOST() async {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );
        await uploadImageToImgBB();
        final uuid = Uuid().v4();
        await FirebaseFirestore.instance.collection('posts').doc(uuid).set({
          'userName': userprovider.getuser!.userName,
          'uid': userprovider.getuser!.uid,
          'userImage': userprovider.getuser!.userImage,
          'imagePost': exportUrl,
          'postId': uuid,
          'likes': [],
          'des': desController.text,
          'time':Timestamp.now(),
        });
        setState(() {
          selectedImage = null;
          desController.clear();
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (_) => ButtonNav()));
        });
      } on FirebaseAuthException catch (error) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: ${error.message}")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("An unexpected error occurred: $e")));
      }
    }

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Expanded(
            child: SingleChildScrollView(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          )),
                      const Text(
                        "New Post",
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                      TextButton(
                          onPressed: pushPOST,
                          child: const Text(
                            "PUSH",
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                          )),
                    ],
                  ),
                  Column(
                    children: [
                      // selectedImage != null ? Image.file(): SizedBox(height: 200,),

                      if (selectedImage != null)
                        ClipRRect(
                          child: Image.file(
                            selectedImage!,
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        )
                      else
                        SizedBox(
                          height: 200,
                        ),

                      IconButton(
                        onPressed: () => pickImage(ImageSource.gallery),
                        icon: const Icon(
                          Icons.upload,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      TextField(
                        controller: desController,
                        maxLines: 8,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter Comment",
                          hintStyle: const TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
