import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationModel {
  String? notificationId;
  String? title;
  String? body;
  Timestamp? timestamp;
  String? sentBy;
  String? sentTo;
  bool? isSeen;

  NotificationModel(
      {this.notificationId,
        this.title,
        this.body,
        this.timestamp,
        this.sentBy,
        this.sentTo,
        this.isSeen});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    notificationId = json['notificationId'];
    title = json['title'];
    body = json['body'];
    timestamp = json['timestamp'];
    sentBy = json['sentBy'];
    sentTo = json['sentTo'];
    isSeen = json['isSeen'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['notificationId'] = this.notificationId;
    data['title'] = this.title;
    data['body'] = this.body;
    data['timestamp'] = Timestamp.now();
    data['sentBy'] = this.sentBy;
    data['sentTo'] = this.sentTo;
    data['isSeen'] = false;
    return data;
  }

}
