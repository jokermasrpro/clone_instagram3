import 'dart:io';
import 'package:clone_instagram/Moded/model_user.dart';
import 'package:clone_instagram/screens/auth_page/login_screen.dart';
import 'package:clone_instagram/shard/widgets/button_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final nameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    nameController.dispose();
    super.dispose();
  }

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
          content: Text('تم تسحيل الحساب بنجاح'),
        ));
      } else {
        print('فشل رفع الصورة: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('حدث خطأ أثناء رفع الصورة: $e');
    }
  }

  Future<void> signUp() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );
      await uploadImageToImgBB();
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, password: passController.text);
      ModelUser user = ModelUser(
          nameController.text,
          emailController.text,
          [],
          [],
          passController.text,
          exportUrl!,
          FirebaseAuth.instance.currentUser!.uid,
          [],
          [],
          
          );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(user.convertToMap());

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) =>  ButtonNav()));
    } on FirebaseAuthException catch (error) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: ${error.message}")));
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An unexpected error occurred: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 80,
              ),
              const Text(
                'insta app',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(
                height: 30,
              ),
              exportUrl != null ? Text("$exportUrl") : Text("Not found"),
              Stack(
                children: [
                  if (selectedImage != null)
                    CircleAvatar(
                      backgroundImage: FileImage(selectedImage!),
                      radius: 50,
                    )
                  else
                    const CircleAvatar(
                      backgroundImage: AssetImage('assets/avatar.png'),
                      radius: 50,
                    ),
                  Positioned(
                    left: 50,
                    top: 50,
                    child: IconButton(
                      onPressed: () => pickImage(ImageSource.gallery),
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    // name conroller
                    TextFormField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "user name is empty";
                        } else if (value.length < 8) {
                          return "name is short";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Enter user name",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white)),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // email conroller
                    TextFormField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "email is empty";
                        } else if (value.length < 10) {
                          return "email is short";
                        } else if (value.contains('@') && value.contains('.')) {
                          return null;
                        } else {
                          return "this not email";
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Enter Email",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // pass controller
                    TextFormField(
                      controller: passController,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "password is empty";
                        } else if (value.length < 10) {
                          return "password is short";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.visibility_off)),
                        hintText: "Enter password",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                                BeveledRectangleBorder(
                                    borderRadius: BorderRadius.circular(3))),
                            backgroundColor:
                                WidgetStateProperty.all(Colors.blue),
                          ),
                          onPressed: () {
                            formKey.currentState!.save();
                            if (formKey.currentState!.validate()) {
                              signUp();
                            }
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                      },
                      child: const Text(
                        "Dont have an account",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
