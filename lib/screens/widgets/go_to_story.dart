import 'package:clone_instagram/screens/add_story.dart';
import 'package:flutter/material.dart';

class GoToStory extends StatelessWidget {
  VoidCallback click;
  String? userImage;
  String? userName;
  String? hideOpenStory;
  bool? checkColor;
 
  GoToStory(
      {super.key,
      required this.click,
      this.userImage,
      this.userName,
      this.checkColor,
      this.hideOpenStory,
     });

    

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: click,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Stack(children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color:checkColor == true ?  Colors.pink : Colors.transparent  , width: 2),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      userImage != null
                          ? userImage!
                          : 'https://i.ibb.co/Y2WNxMT/proxy-image.jpg',
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: hideOpenStory == null ? true : false,
                child: Positioned(
                  top: 30,
                  left: 30,
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
              )
            ]),
            Container(
              alignment: Alignment.center,
              width: 60,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: NeverScrollableScrollPhysics(),
                child: Text(
                  userName != null ? userName! : "Name",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
