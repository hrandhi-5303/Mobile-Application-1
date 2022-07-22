import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/Notification_controller.dart';
import 'package:lesson3/model/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  static const routeName = '/notificationScreen';
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _stream=NotificationController.getUnSeenNotifications();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        NotificationController().updateToSeen();
        return true;
      },
      child: SafeArea(child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: (){
              NotificationController().updateToSeen();
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: Text('Notifications'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _stream,
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator(),);
            }
            if(snapshot.data!.size==0){
              return Center(child: Text('No Notification'),);
            }
            var allDocs=snapshot.data!.docs;
           return ListView.builder(
              itemCount:allDocs.length,
              itemBuilder: (context,index){
                NotificationModel notificationModel=NotificationModel.fromJson(allDocs[0].data() as Map<String,dynamic>);
                return Card(
                  elevation: 5,
                  child: ListTile(
                    title:Text(notificationModel.title!),
                    subtitle: Text(notificationModel.body!),
                  ),
                );
              },
            );
          },
        ),
      )),
    );
  }
}
