import 'package:flutter/material.dart';

class FilterScreen extends StatelessWidget {
  bool decending;
  final Function(bool) onSelect;
   FilterScreen({Key? key,required this.decending,required this.onSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Card(
              
              child: ListTile(
                onTap: (){
                  onSelect(false);
                  Navigator.pop(context);
                },
                title: Text("Sort by Ascending order (Az-Za)"),
                trailing: !decending?Icon(Icons.done,color: Colors.green,):SizedBox(),
              ),
            ),
            Card(
              child: ListTile(
                onTap: (){
                  onSelect(true);
                  Navigator.pop(context);
                },
                title: Text("Sort by Decending order (Za-Az)"),
                trailing: decending?Icon(Icons.done,color: Colors.green,):SizedBox(),
              ),
            ),
            
          ],
        ),
      )
    );
  }
}
