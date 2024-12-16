import 'package:flutter/material.dart';

class Poupp extends StatelessWidget {
  const Poupp({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'option2'){
                 
                }
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
  }
}