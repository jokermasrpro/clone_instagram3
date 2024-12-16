import 'package:flutter/material.dart';

class ViewImage extends StatelessWidget {
   ViewImage({super.key , required  this.image});
  String image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white,),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Image.network(image,width: double.infinity,height: 300,),
      ),
    );
  }
}