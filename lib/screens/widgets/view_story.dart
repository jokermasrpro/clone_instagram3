import 'package:clone_instagram/screens/features/firebase_services.dart';
import 'package:clone_instagram/screens/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/utils.dart';
import 'package:story_view/widgets/story_view.dart';

class ViewStory extends StatefulWidget {
  String myUid;
  List userStories;
  String? userImage;
  String? userName;
  ViewStory({super.key, required this.userStories,required this.myUid, this.userImage,this.userName});

  @override
  State<ViewStory> createState() => _ViewStoryState();
}

class _ViewStoryState extends State<ViewStory> {

  

  @override
  Widget build(BuildContext context) {
    final controller = StoryController();
    final userProvider = Provider.of<UserProvider>(context);

    int indexDelete = 0;
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
          child: CircleAvatar(
            backgroundImage: NetworkImage('https://i.ibb.co/Y2WNxMT/proxy-image.jpg'),
            radius: 60,
          ),
        ),
        title: Text(
          "JokerMasr",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          widget.userStories[indexDelete]['uid'] == widget.myUid
              ? IconButton(
                  onPressed: () {
                    FirebaseServices()
                        .delete_story(story: widget.userStories[indexDelete]);
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                )
              : Text(" "),
        ],
      ),
      body: StoryView(
        controller: controller, // pass controller here too
        repeat: false, // should the stories be slid forever
        onComplete: () {
          Navigator.pop(context);
        },
        onVerticalSwipeComplete: (direction) {
          if (direction == Direction.down) {
            Navigator.pop(context);
          }
        },
        onStoryShow: (storyItem, index) {
          indexDelete = index;
        },
        storyItems: widget.userStories.map((myMap) {
          if (myMap['content'] != null) {
            return StoryItem.pageImage(
                url: myMap['content'], controller: controller);
          } else {
            return StoryItem.text(
                title: myMap['des'] ?? '', backgroundColor: Colors.black);
          }
        }).toList(), // To disable vertical swipe gestures, ignore this parameter.
      ),
    );
  }
}
