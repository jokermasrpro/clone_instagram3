import 'package:clone_instagram/Moded/model_user.dart';
import 'package:clone_instagram/screens/features/firebase_services.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  ModelUser? user;
  ModelUser? userData;
  ModelUser? get getuser {
    return userData;
  }

  void fetchuser({
    required userid,
  }) async {
    user = await FirebaseServices().userdetils(userUid: userid);
    userData = user;
    notifyListeners();
  }

  void increase_followers() {
    getuser!.followers.length++;
    notifyListeners();
  }

  void decrease_followers() {
    getuser!.followers.length--;
    notifyListeners();
  }

  void delete_story({required Map story}) {
    userData!.stories.removeWhere(
      (element) {
        return element == story;
      },
    );
  }
}
