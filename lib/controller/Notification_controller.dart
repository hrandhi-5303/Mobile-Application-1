import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lesson3/model/notification_model.dart';

class NotificationController{

  static CollectionReference reference=FirebaseFirestore.instance.collection('notifications');

  static getMyNotifications(){
    return reference.where('sentTo',isEqualTo: FirebaseAuth.instance.currentUser!.email).orderBy('timestamp',descending: true).snapshots();
  }
  static getUnSeenNotifications(){
    return reference.where('sentTo',isEqualTo: FirebaseAuth.instance.currentUser!.email).where('isSeen',isEqualTo: false).orderBy('timestamp',descending: true).snapshots();
  }
   updateToSeen() async {
     QuerySnapshot snapshot=await reference.where('sentTo',isEqualTo: FirebaseAuth.instance.currentUser!.email).where('isSeen',isEqualTo: false).orderBy('timestamp',descending: true).get();
      var allDocs=snapshot.docs;
      for(var doc in allDocs){
        reference.doc(doc.id).update({
          'isSeen':true
        });
      }
  }

  sendNotification(NotificationModel notificationModel) async {
    notificationModel.notificationId=reference.doc().id;
    await reference.doc(notificationModel.notificationId).set(notificationModel.toJson());
  }
}