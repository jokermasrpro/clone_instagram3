import 'dart:io';

import 'package:flutter/material.dart';

Future dialogStory(
    {required BuildContext context,
    File? selectedImage,
    required final desController,
    required VoidCallback click,
    required VoidCallback cancel}) {
  return showDialog(
    context: context,
    builder: (context) {
      return Expanded(
        child: AlertDialog(backgroundColor: Colors.grey[900], actions: [
          Column(
            children: [
              SizedBox(
                width: 400,
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: cancel,
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey,
                      )),
                  TextButton(
                      onPressed: click,
                      child: Text(
                        "PUSH",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                ],
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                // width: double.infinity,
                child: Visibility(
                  visible: selectedImage != null ? false : true,
                  child: TextField(
                    controller: desController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter Comment",
                      hintStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(
                            color: const Color.fromARGB(255, 63, 82, 92)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              selectedImage != null
                  ? Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      child: Image.file(
                        selectedImage,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    )
                  : SizedBox(
                      height: 5,
                    ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ]),
      );
    },
  );
}
